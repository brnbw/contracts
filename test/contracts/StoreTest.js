const { expect } = require("chai");
const { keccak256 } = require("@ethersproject/keccak256")


describe("Collection", function () {
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

  describe('AccessControl', () => {
    it('can grant a role', async () => {
      await contract.grantRoleString('MINTER', wallet1.address);

      await expect(
        contract.connect(wallet1).mint(1, 1, "ipfs://blah", wallet1.address)
      ).to.not.be.revertedWith("");
    })

    it('can revoke a role', async () => {
      await contract.grantRoleString('MINTER', wallet1.address);
      await contract.revokeRoleString('MINTER', wallet1.address);

      await expect(
        contract.connect(wallet1).mint(1, 1, "ipfs://blah", wallet1.address)
      ).to.be.revertedWith("");
    })
  })

  describe("mint", () => {
    it("can mint works to an address", async () => {
      await contract.mint(1, 1, "ipfs://blah", wallet1.address);
      expect(await contract.balanceOf(wallet1.address, 1)).to.eq(1);
    });

    it("saves uris", async () => {
      await contract.mint(1, 1, "ipfs://blah", wallet1.address);
      expect(await contract.uri(1)).to.eq("ipfs://blah");
    });

    it("fails mint for non-minter role", async () => {
      await expect(
        contract.connect(wallet1).mint(1, 1, "ipfs://blah", wallet1.address)
      ).to.be.revertedWith("");
    });
  });

  describe("setUri", () => {
    it("can set as admin", async () => {
      await contract.setUri(1, "hello");
      expect(await contract.uri(1)).to.eq("hello");
    });

    it("cannot set as anyone else", async () => {
      await expect(
        contract.connect(wallet1).setUri(1, "hello")
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
