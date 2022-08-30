const { expect } = require("chai");

describe("GenericCollection", function () {
  let owner, wallet1;
  let contract;

  before(async () => {
    [owner, wallet1] = await ethers.getSigners();
  });

  beforeEach(async () => {
    const ExampleSpecials = await ethers.getContractFactory("ExampleSpecials");
    contract = await ExampleSpecials.deploy(owner.address);
  });

  it("has a name and symbol", async () => {
    expect(await contract.name()).to.equal("Example Specials");
    expect(await contract.symbol()).to.equal("EXAMPLE");
  });

  describe("mint", () => {
    it("can mint to an address", async () => {
      await contract.mint(1, 1, wallet1.address);
      expect(await contract.balanceOf(wallet1.address, 1)).to.eq(1);
    });

    it("fails mint for non-minter role", async () => {
      await expect(
        contract.connect(wallet1).mint(1, 1, wallet1.address)
      ).to.be.revertedWith("");
    });
  });

  describe("mintCustom", () => {
    it("can mint works to an address", async () => {
      await contract.mintCustom(1, 1, wallet1.address, "ipfs://blah");
      expect(await contract.balanceOf(wallet1.address, 1)).to.eq(1);
    });

    it("saves uris", async () => {
      await contract.mintCustom(1, 1, wallet1.address, "ipfs://blah");
      expect(await contract.uri(1)).to.eq("ipfs://blah");
    });

    it("fails mint for non-minter role", async () => {
      await expect(
        contract.connect(wallet1).mintCustom(1, 1, wallet1.address, "ipfs://blah")
      ).to.be.revertedWith("");
    });
  });

  describe("setCustomUri", () => {
    it("can set as admin", async () => {
      await contract.setCustomUri(1, "hello");
      expect(await contract.uri(1)).to.eq("hello");
    });

    it("cannot set as anyone else", async () => {
      await expect(
        contract.connect(wallet1).setCustomUri(1, "hello")
      ).to.be.revertedWith("AccessControl:");
    });
  });

  describe("royalties", () => {
    it("knows where to send what", async () => {
      const [dest, amount] = await contract.royaltyInfo(1, 10000);
      expect(dest).to.eq(owner.address);
      expect(amount.toNumber()).to.eq(500);
    });

    it("can update its royalty info", async () => {
      await contract.setRoyaltyInfo(wallet1.address, 1000);
      const [dest, amount] = await contract.royaltyInfo(1, 10000);
      expect(dest).to.eq(wallet1.address);
      expect(amount.toNumber()).to.eq(1000);
    });
  });
});
