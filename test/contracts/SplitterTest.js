const { expect } = require("chai");
const { parseEther } = ethers.utils;

describe("Splitter", function () {
  let owner;
  let wallet1, wallet2, wallet3, wallet4isNotIn;
  let fakeWeth;

  let contract;

  before(async () => {
    [owner, wallet1, wallet2, wallet3, wallet4isNotIn] = await ethers.getSigners();

    const FakeWeth = await ethers.getContractFactory("FakeWeth");
    fakeWeth = await FakeWeth.deploy();
  });

  beforeEach(async () => {
    const Splitter = await ethers.getContractFactory("Splitter");
    contract = await Splitter.deploy(
      [wallet1.address, wallet2.address, wallet3.address],
      [7, 2, 1],
      fakeWeth.address
    );
  });

  it("can flush eth", async function () {
    await owner.sendTransaction({
      to: contract.address,
      value: parseEther("10"),
    });

    const tx = await contract.connect(wallet1).flush();

    await expect(tx).to.changeEtherBalances(
      [contract, wallet1, wallet2, wallet3],
      [-10, 7, 2, 1].map((n) => parseEther(n.toString()))
    );
  });

  it("requires FLUSHWORTHY role", async function () {
    await expect(contract.connect(wallet4isNotIn).flush()).to.be.revertedWith("AccessControl:")
  });

  it("can flush weth", async () => {
    await fakeWeth.transfer(contract.address, 10);

    expect((await fakeWeth.balanceOf(owner.address)).toNumber()).to.eq(999990);
    expect((await fakeWeth.balanceOf(contract.address)).toNumber()).to.eq(10);

    await expect(() =>
      contract.connect(wallet1).flushToken(fakeWeth.address)
    ).to.changeTokenBalances(
      fakeWeth,
      [contract, wallet1, wallet2, wallet3],
      [-10, 7, 2, 1]
    );
  });

  it("can flush eth + weth", async () => {
    await owner.sendTransaction({
      to: contract.address,
      value: parseEther("10"),
    });
    await fakeWeth.transfer(contract.address, 10);

    await expect(() => contract.connect(wallet1).flushCommon())
      .to.changeTokenBalances(
        fakeWeth,
        [contract, wallet1, wallet2, wallet3],
        [-10, 7, 2, 1]
      )
      .and.changeEtherBalances(
        [contract, wallet1, wallet2, wallet3],
        [-10, 7, 2, 1].map((n) => parseEther(n.toString()))
      );
  });
});
