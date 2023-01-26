//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "./Products.sol";
import "./EmreCoin.sol";
contract Bidder{
    address public bidder;
    uint public highestBid;
    // uint public time;
    Products public products;
    EmreCoin public coin;
    uint public time=block.timestamp+90;
    struct Product{
        string productName;
        uint ID;
        uint price;
        address seller;
    }
    struct Log{
        address account;
        string transferIsDone;
        uint price;
    }
    Log[] public logs;
    constructor(address _productAddress,address _coinAddress){
        products=Products(_productAddress);
        coin=EmreCoin(_coinAddress);
        createProduct("Elma",0,1000000000000000000);
        bidder=msg.sender;
    }
    mapping(uint => Product) public idToProduct;
    function takeMoney() public payable{
        require(msg.value>0);
        coin.mint(msg.sender,msg.value);
        payable(msg.sender).transfer(msg.value);
    }
    function createProduct(string memory _productName,uint _id,uint _price)private{
        Product memory product;
        product.productName=_productName;
        product.ID=_id;
        product.price=_price;
        product.seller=msg.sender;
        idToProduct[_id]=product;
    }
    function createLog() public payable{
        Log memory log;
        log.account=bidder;
        log.price=(msg.value)/1e18;
        log.transferIsDone="Success";
        logs.push(log);
    }
    function addProduct(uint _amount,uint _id)public {
        products.mint(msg.sender,_id,_amount,"");
    }
    modifier ignoreBid() {
        require(msg.value<=coin.balanceOf(msg.sender),"Daha fazla yatirma.");
        _;
    }
    modifier auctionTime(){
        require(block.timestamp>=time);
        _;
    }
    function giveOffer()public ignoreBid payable{
        require(msg.value>highestBid,"Not smaller than highest bid");
        require(coin.balanceOf(msg.sender)>0,"You have not a EmreCoin");
        // require(time>block.timestamp);
        if(bidder!=idToProduct[0].seller){
            payable(bidder).transfer(highestBid);
        }
        bidder=msg.sender;
        coin.burnFrom(msg.sender,highestBid);
        highestBid=msg.value;
        createLog();
    }
    function endAuction() public auctionTime{
        require(bidder != idToProduct[0].seller, "The seller cannot end the auction.");
        payable(idToProduct[0].seller).transfer(address(this).balance);
        products.burn(msg.sender,0,5);
        createLog();
    }
}
