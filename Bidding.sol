//SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

contract Bidding{
    uint public highestBid;
    uint public time=block.timestamp+90;
    struct Product{
        string ID;
        string pName;
        uint price;
        address seller;
        bool isSold;
    }
    struct Log{
        address bidder;
        bool transferIsDone;
        uint timestamp;
        string message;
    }
    Log[] public logs;
    function createLog(bool transferIsDone,address bidderr,uint timestamp,string memory message) public{
        Log memory log;
        log.bidder=bidderr;
        log.timestamp=timestamp;
        log.message=message;
        log.transferIsDone=transferIsDone;
        logs.push(log);
    }
    mapping(string => Product)public idToProduct;
    function createProduct(string memory pName,uint price,address seller) public{
        Product memory product;
        product.ID="0";
        product.pName=pName;
        product.price=price;
        product.seller=seller;
        product.isSold=false;
        idToProduct[product.ID]=product;
        createLog(true,seller,block.timestamp,"Product created.");
    }
    function takeMoney()public payable{
        require(msg.value>0);
        payable(msg.sender).transfer(address(this).balance);
    }
    function giveOffer(uint value,string memory pId)public{
        require(value>highestBid,"Not smaller than highest bid");
        require(value>idToProduct[pId].price,"Nor smaller than product price");
        require(idToProduct[pId].isSold==false,"You can't give offer for this product because it was sold.");
        if(msg.sender!=idToProduct[pId].seller){
            payable(msg.sender).transfer(value);
        }
        highestBid=value;
        createLog(true, msg.sender, block.timestamp, "Offer was given.");
    }
    function endAuction(string memory pId) public{
        idToProduct[pId].isSold=true;
        payable(idToProduct[pId].seller).transfer(address(this).balance);
        createLog(true,msg.sender,block.timestamp,"Product was sold.");
    }
}
