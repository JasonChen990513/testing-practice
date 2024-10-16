const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Integration", () => {

    //deploy the contract
    beforeEach(async () => {
		[owner, user] = await ethers.getSigners();

		Token = await ethers.getContractFactory('Token');
		token = await Token.deploy();
		await token.waitForDeployment();

		Contract = await ethers.getContractFactory('DecentralizedMarketplace');
		contract = await Contract.deploy(await token.getAddress());
		await contract.waitForDeployment();

    })

    //testing contract call tracnsfer function
    it('test buy good function', async () => {
        await token.connect(owner).transfer(user.address, ethers.parseEther('100'));
        expect(await token.balanceOf(user.address)).to.equal(ethers.parseEther('100'));
        await token.connect(user).approve(await contract.getAddress(), ethers.parseEther('1'));

        await contract.connect(owner).addGood('apple','this is a apple', ethers.parseEther('1'), 10, 'https://www.collinsdictionary.com/images/full/apple_158989157.jpg', 'Food');
        await contract.connect(user).buyGood(0, 1);

        expect(await token.balanceOf(owner.address)).to.equal(ethers.parseEther('999901'));
        expect(await token.balanceOf(user.address)).to.equal(ethers.parseEther('99'));
    })

    //test contract call token balance function
    it('check balance before checkout', async () => {
        await token.connect(owner).transfer(user.address, ethers.parseEther('1'));
        await token.connect(user).approve(await contract.getAddress(), ethers.parseEther('1'));

        await contract.connect(owner).addGood('apple','this is a apple', ethers.parseEther('1'), 10, 'https://www.collinsdictionary.com/images/full/apple_158989157.jpg', 'Food');
        await contract.connect(user).addToCart(0, 2);
        await expect(contract.connect(user).cartCheckOut([0])).to.be.revertedWith('balance not enough cartcheckout');
    })

    //confirm user buy the good and pay the money (tokens)
    //check the balance after transaction done
    it ('should check out a good from cart', async () => {
        await token.connect(owner).transfer(user.address, ethers.parseEther('100'));
        expect(await token.balanceOf(user.address)).to.equal(ethers.parseEther('100'));
        await token.connect(user).approve(await contract.getAddress(), ethers.parseEther('1'));

        await contract.connect(owner).addGood('apple','this is a apple', ethers.parseEther('1'), 10, 'https://www.collinsdictionary.com/images/full/apple_158989157.jpg', 'Food');
        await contract.connect(user).addToCart(0, 1);
        await contract.connect(user).cartCheckOut([0]);

        expect(await token.balanceOf(owner.address)).to.equal(ethers.parseEther('999901'));
        expect(await token.balanceOf(user.address)).to.equal(ethers.parseEther('99'));
    })


})