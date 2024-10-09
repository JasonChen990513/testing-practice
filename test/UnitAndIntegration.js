//test every function in the contract
const { expect } = require("chai");
const { ethers } = require("hardhat");

//add a good
//add good to cart
//check out good from cart
//add a comment

//remove good from cart
//update good

describe('decetralised marketplace', () => {
    let Token, token, Contract, contract, owner, user;

    beforeEach(async () => {
		[owner, user] = await ethers.getSigners();

		Token = await ethers.getContractFactory('Token');
		token = await Token.deploy();
		await token.waitForDeployment();

		Contract = await ethers.getContractFactory('DecentralizedMarketplace');
		contract = await Contract.deploy(await token.getAddress());
		await contract.waitForDeployment();


    })


    it('should be deployed', async () => {
        expect(await contract.getGoodLengh()).to.equal(0);

		await token.connect(owner).transfer(user.address, 100);
		expect(await token.balanceOf(user.address)).to.equal(100);
    })

	describe('Good', () => {
		it('should add a good', async () => {
			await contract.connect(owner).addGood('apple','this is a apple', ethers.parseEther('1'), 10, 'https://www.collinsdictionary.com/images/full/apple_158989157.jpg', 'Food');
			expect(await contract.getGoodLengh()).to.equal(1);
		})

		it('should update a good', async () => {
			await contract.connect(owner).addGood('apple','this is a apple', ethers.parseEther('1'), 10, 'https://www.collinsdictionary.com/images/full/apple_158989157.jpg', 'Food');
			await contract.connect(owner).updateGood(0, 'Apple','This is a apple', ethers.parseEther('2'), 5, true, 'https://www.collinsdictionary.com/images/full/apple_158989157.jpg', 'Food');
			expect(await contract.getGoodLengh()).to.equal(1);
		})


	})


	describe('Cart', () => {
		it('should add a good to cart', async () => {
			await contract.connect(owner).addGood('apple','this is a apple', ethers.parseEther('1'), 10, 'https://www.collinsdictionary.com/images/full/apple_158989157.jpg', 'Food');
			await contract.connect(user).addToCart(0, 1);
			const cart = await contract.connect(user).getCart();
			expect(cart.length).to.equal(1);
		})

		it('add to cart item not exist', async () => {
			await contract.connect(owner).addGood('apple','this is a apple', ethers.parseEther('1'), 10, 'https://www.collinsdictionary.com/images/full/apple_158989157.jpg', 'Food');
			await expect(contract.connect(user).addToCart(1, 1)).to.be.revertedWith('Good does not exist');
		})

		it('item amount equal to 0', async () => {
			await contract.connect(owner).addGood('apple','this is a apple', ethers.parseEther('1'), 10, 'https://www.collinsdictionary.com/images/full/apple_158989157.jpg', 'Food');
			await expect(contract.connect(user).addToCart(0, 0)).to.be.revertedWith('Amount must be greater than zero');
		})

		it ('should remove a good from cart', async () => {
			await contract.connect(owner).addGood('apple','this is a apple', ethers.parseEther('1'), 10, 'https://www.collinsdictionary.com/images/full/apple_158989157.jpg', 'Food');
			await contract.connect(user).addToCart(0, 1);
			await contract.connect(user).removeFromCart(0);
			const cart = await contract.connect(user).getCart();
			expect(cart.length).to.equal(0);
		})

		it ('remove item not in cart', async () => {
			await contract.connect(owner).addGood('apple','this is a apple', ethers.parseEther('1'), 10, 'https://www.collinsdictionary.com/images/full/apple_158989157.jpg', 'Food');
			await contract.connect(user).addToCart(0, 1);
			await expect(contract.connect(user).removeFromCart(1)).to.be.revertedWith('Item not found in cart');
		})

		it ('should check out a good from cart', async () => {
			await token.connect(owner).transfer(user.address, ethers.parseEther('100'));
			expect(await token.balanceOf(user.address)).to.equal(ethers.parseEther('100'));
			await token.connect(user).approve(await contract.getAddress(), ethers.parseEther('1'));

			await contract.connect(owner).addGood('apple','this is a apple', ethers.parseEther('1'), 10, 'https://www.collinsdictionary.com/images/full/apple_158989157.jpg', 'Food');
			await contract.connect(user).addToCart(0, 1);
			await contract.connect(user).cartCheckOut([0]);
			const cart = await contract.connect(user).getCart();
			expect(cart.length).to.equal(0);
		})

		it('balance not enough', async () => {
			await token.connect(owner).transfer(user.address, ethers.parseEther('1'));
			expect(await token.balanceOf(user.address)).to.equal(ethers.parseEther('1'));
			await token.connect(user).approve(await contract.getAddress(), ethers.parseEther('1'));

			await contract.connect(owner).addGood('apple','this is a apple', ethers.parseEther('1'), 10, 'https://www.collinsdictionary.com/images/full/apple_158989157.jpg', 'Food');
			await contract.connect(user).addToCart(0, 2);
			await expect(contract.connect(user).cartCheckOut([0])).to.be.revertedWith('balance not enough cartcheckout');
		})

		it('good is unavaliable', async () => {
			await token.connect(owner).transfer(user.address, ethers.parseEther('100'));
			expect(await token.balanceOf(user.address)).to.equal(ethers.parseEther('100'));
			await token.connect(user).approve(await contract.getAddress(), ethers.parseEther('1'));

			await contract.connect(owner).addGood('apple','this is a apple', ethers.parseEther('1'), 10, 'https://www.collinsdictionary.com/images/full/apple_158989157.jpg', 'Food');
			await contract.connect(owner).updateGood(0, 'Apple','This is a apple', ethers.parseEther('2'), 5, false, 'https://www.collinsdictionary.com/images/full/apple_158989157.jpg', 'Food');
		
			await contract.connect(user).addToCart(0, 1);
			await expect(contract.connect(user).cartCheckOut([0])).to.be.revertedWith('this good is unavaliable now');
		})

	})

	describe('Comment', () => {
		it('add a comment', async () => {
			await token.connect(owner).transfer(user.address, ethers.parseEther('100'));
			expect(await token.balanceOf(user.address)).to.equal(ethers.parseEther('100'));

			await contract.connect(owner).addGood('apple','this is a apple', ethers.parseEther('1'), 10, 'https://www.collinsdictionary.com/images/full/apple_158989157.jpg', 'Food');
			await contract.connect(user).addToCart(0, 1);
			await token.connect(user).approve(await contract.getAddress(), ethers.parseEther('1'));

			await contract.connect(user).cartCheckOut([0]);
			await contract.connect(user).addComment('Jason','this is a comment 1',5 ,0);
			const goods = await contract.getGoods();
			expect(goods[0].comment[0].comment).to.equal('this is a comment 1');
		})
	})
})