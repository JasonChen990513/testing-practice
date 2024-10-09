//test end to end function
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("End", () => {

    before(async () => {
		[owner, user] = await ethers.getSigners();

		Token = await ethers.getContractFactory('Token');
		token = await Token.deploy();
		await token.waitForDeployment();

		Contract = await ethers.getContractFactory('DecentralizedMarketplace');
		contract = await Contract.deploy(await token.getAddress());
		await contract.waitForDeployment();

        await token.connect(owner).transfer(user.address, ethers.parseEther('100'));
        expect(await token.balanceOf(user.address)).to.equal(ethers.parseEther('100'));
    })

    it('should add a good', async () => {
        await contract.connect(owner).addGood('apple','this is a apple', ethers.parseEther('1'), 10, 'https://www.collinsdictionary.com/images/full/apple_158989157.jpg', 'Food');
        expect(await contract.getGoodLengh()).to.equal(1);
    })

    it('add to cart', async () => {
        await contract.connect(user).addToCart(0, 1);
        const cart = await contract.connect(user).getCart();
        expect(cart.length).to.equal(1);
    })

    it('check out', async () => {
        await token.connect(user).approve(await contract.getAddress(), ethers.parseEther('1'));
        await contract.connect(user).cartCheckOut([0]);
        const cart = await contract.connect(user).getCart();
        expect(cart.length).to.equal(0);
        expect(await token.balanceOf(user.address)).to.equal(ethers.parseEther('99'));

    })

    it('add comment', async () => {
        await contract.connect(user).addComment('Jason','this is a comment 1',5 ,0);
        const goods = await contract.getGoods();
        expect(goods[0].comment[0].comment).to.equal('this is a comment 1');
    })
});
