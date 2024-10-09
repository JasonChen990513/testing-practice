// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract DecentralizedMarketplace {
    IERC20 public ercToken;

    constructor(address _tokenAddress) {
        // Add your constructor code here

        ercToken = IERC20(_tokenAddress);
    }

    //uint256 a = 1 ;
    // Define a struct to represent a comment
    struct Comment {
        string name; // Name of the commenter
        string comment; // The comment text
        uint8 star; // Star rating (0-5)
    }

    struct Good {
        string name;
        string description;
        uint256 price;
        address owner;
        uint256 amount;
        Comment[] comment;
        bool sellStatus;
        string image;
        address[] buyBefore;
        string categories;
    }

    struct CartItem {
        uint256 goodId; // ID of the good
        uint256 amount; // Amount of the good
    }

    // Array to store all goods
    Good[] public goods;
    address private owner = 0x9163f6f9A843827aB2fC1B0fBd95B7eF77763129;

    // Mapping to store each user's cart
    mapping(address => CartItem[]) public carts;

    // Event to emit when a new comment is added
    event CommentAdded(string name, string comment, uint8 star);
    // Event to emit when a new good is added
    event GoodAdded(
        string name,
        string description,
        uint256 price,
        address owner,
        bool sellStatus
    );

    event sellGoodMessage(string message);

    event updateCart(address user, string message);

    event showTotalAmount(uint256 total);

    function getGoodComment(uint256 id) public view returns (Comment[] memory) {
        return goods[id].comment;
    }

    //show all goods
    function getGoods() public view returns (Good[] memory) {
        return goods;
    }

    function getGoodLengh() public view returns (uint256) {
        return goods.length;
    }

    function getCartLengh() public view returns (uint256) {
        return carts[msg.sender].length;
    }

    function getCart() public view returns (CartItem[] memory) {
        return carts[msg.sender];
    }

    // Function to add a new comment
    function addComment(
        string memory _name,
        string memory _comment,
        uint8 _star,
        uint256 goodID
    ) public {
        bool buyBefore;
        require(_star <= 5, "Star rating must be between 0 and 5");
        for (uint i = 0; i < goods[goodID].buyBefore.length; i++) {
            if (goods[goodID].buyBefore[i] == msg.sender) {
                buyBefore = true;
            }
        }
        require(
            buyBefore || (msg.sender == owner),
            "you need to buy the good first"
        );

        // Create a new comment
        Comment memory newComment = Comment({
            name: _name,
            comment: _comment,
            star: _star
        });

        // Add the comment to the array
        goods[goodID].comment.push(newComment);

        // Emit an event
        //emit CommentAdded(_name, _comment, _star);
    }

    // Function to add a new good
    function addGood(
        string memory _name,
        string memory _description,
        uint256 _price,
        uint256 _amount,
        string memory _image,
        string memory _categories
    ) public {
        // Create a new Good
        Good storage newGood = goods.push();

        newGood.name = _name;
        newGood.description = _description;
        newGood.price = _price;
        newGood.owner = msg.sender;
        newGood.sellStatus = true;
        newGood.amount = _amount;
        newGood.image = _image;
        newGood.categories = _categories;
        // Emit an event
        //emit GoodAdded(_name, _description, _price, msg.sender, true);
    }

    // Function to add items to a user's cart
    function addToCart(uint256 goodId, uint256 amount) public {
        require(goodId < goods.length, "Good does not exist");
        require(amount > 0, "Amount must be greater than zero");

        // Check if the cart already has this good
        bool found = false;
        for (uint256 i = 0; i < carts[msg.sender].length; i++) {
            if (carts[msg.sender][i].goodId == goodId) {
                // If found, increase the amount
                carts[msg.sender][i].amount += amount;
                found = true;
                break;
            }
        }

        // If not found, add a new item to the cart
        if (!found) {
            carts[msg.sender].push(CartItem({goodId: goodId, amount: amount}));
        }
    }

    function buyGood(uint256 _goodID, uint256 _amount) public {
        //check the balance
        require(
            ercToken.balanceOf(msg.sender) >= _amount * goods[_goodID].price,
            "balance not enough buy step"
        );
        //check the good is avaliable
        require(
            goods[_goodID].sellStatus == true,
            "this good is unavaliable now"
        );
        require(
            goods[_goodID].amount - _amount >= 0,
            string(abi.encodePacked(" Only remain ", goods[_goodID].amount))
        );
        //transfer token to seller
        ercToken.transferFrom(
            msg.sender,
            goods[_goodID].owner,
            _amount * goods[_goodID].price
        );
        goods[_goodID].amount -= _amount;
        if (goods[_goodID].amount == 0) {
            goods[_goodID].sellStatus = false;
        }
        goods[_goodID].buyBefore.push(msg.sender);
    }

    // Function to remove an item from the cart
    function removeFromCart(uint256 goodId) public {
        uint256 length = carts[msg.sender].length;
        for (uint256 i = 0; i < length; i++) {
            if (carts[msg.sender][i].goodId == goodId) {
                // Shift elements to the left
                for (uint256 j = i; j < length - 1; j++) {
                    carts[msg.sender][j] = carts[msg.sender][j + 1];
                }
                // Remove the last element
                carts[msg.sender].pop();
                return;
            }
        }
        revert("Item not found in cart");
    }

    function getBuyTotalPrice(
        uint256[] memory items
    ) public view returns (uint256) {
        uint256 totalAmount;
        for (uint i = 0; i < carts[msg.sender].length; i++) {
            for (uint j = 0; j < items.length; j++) {
                if (carts[msg.sender][i].goodId == items[j]) {
                    totalAmount +=
                        carts[msg.sender][i].amount *
                        goods[carts[msg.sender][i].goodId].price;
                }
            }
        }
        return totalAmount;
    }

    //array is the item in cart want to check out
    function cartCheckOut(uint256[] memory items) public {
        //check the balance of user is enough for whole cart item
        uint256 totalAmount;

        for (uint j = 0; j < items.length; j++) {
            for (uint i = 0; i < carts[msg.sender].length; i++) {
                if (carts[msg.sender][i].goodId == items[j]) {
                    totalAmount +=
                        carts[msg.sender][i].amount *
                        goods[carts[msg.sender][i].goodId].price;
                }
            }
        }
        require(
            ercToken.balanceOf(msg.sender) >= totalAmount,
            "balance not enough cartcheckout"
        );
        emit showTotalAmount(totalAmount);
        //check out
        // for ( uint i=0 ; i < carts[msg.sender].length; i++)
        // {
        //     for (uint j = 0; j < items.length; j++)
        //     {
        //         if(carts[msg.sender][i].goodId == items[j]){
        //             buyGood(carts[msg.sender][i].goodId, carts[msg.sender][i].amount);
        //             removeFromCart(carts[msg.sender][i].goodId);
        //         }
        //     }
        // }

        for (uint j = 0; j < items.length; j++) {
            for (uint i = 0; i < carts[msg.sender].length; i++) {
                if (carts[msg.sender][i].goodId == items[j]) {
                    buyGood(
                        carts[msg.sender][i].goodId,
                        carts[msg.sender][i].amount
                    );
                    removeFromCart(carts[msg.sender][i].goodId);
                }
            }
        }

        //remove the item from cart
    }

    function updateGood(
        uint256 _goodID,
        string memory _name,
        string memory _description,
        uint256 _price,
        uint256 _amount,
        bool _sellStatus,
        string memory _categories,
        string memory _image
    ) public {
        //get the update data from frontend and update to smart contract
        goods[_goodID].name = _name;
        goods[_goodID].description = _description;
        goods[_goodID].price = _price;
        goods[_goodID].amount = _amount;
        goods[_goodID].sellStatus = _sellStatus;
        goods[_goodID].categories = _categories;
        goods[_goodID].image = _image;
    }

    function setTestData() public {
        require(msg.sender == owner, "you are not the owner");
        addGood(
            "apple",
            "this is a apple",
            1 ether,
            10,
            "https://www.collinsdictionary.com/images/full/apple_158989157.jpg",
            "Food"
        );
        addGood(
            "iphone",
            "this is iphone 15",
            2 ether,
            10,
            "https://shop.switch.com.my/cdn/shop/files/iPhone_15_Pink_PDP_Image_Position-1__GBEN_7cf60425-0d5a-4bc9-bfd9-645b9c86e68e.jpg?v=1717694179",
            "Electronics"
        );
        addGood(
            "bed",
            "this is a bed",
            3 ether,
            10,
            "https://www.fortytwo.my/media/catalog/product/cache/1/image/3000x/9df78eab33525d08d6e5fb8d27136e95/s/a/santiago_upholstered_queen_bed_grey___mg_5495__cropped.jpg",
            "Furniture"
        );
        addToCart(0, 1);
        addToCart(1, 2);
        addToCart(2, 3);
        addComment("jason1", "comment1", 5, 0);
        addComment("jason2", "comment2", 3, 0);
        addComment("jason3", "comment3", 4, 0);
        addComment("jason1", "comment4", 1, 1);
    }
}
