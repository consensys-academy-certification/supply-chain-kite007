// Implement the smart contract SupplyChain following the provided instructions.
// Look at the tests in SupplyChain.test.js and run 'truffle test' to be sure that your contract is working properly.
// Only this file (SupplyChain.sol) should be modified, otherwise your assignment submission may be disqualified.

pragma solidity ^0.5.0;

contract SupplyChain {
    
    address payable owner = msg.sender;
    uint PAY_FEE = 1 finney;
    
  // Create a variable named 'itemIdCount' to store the number of items and also be used as reference for the next itemId.
    uint itemIdCount;
    
  // Create an enumerated type variable named 'State' to list the possible states of an item (in this order): 'ForSale', 'Sold', 'Shipped' and 'Received'.
    enum State {
        ForSale, 
        Sold,
        Shipped,
        Received
    }
  // Create a struct named 'Item' containing the following members (in this order): 'name', 'price', 'state', 'seller' and 'buyer'.
    struct Item {
        string name;
        uint price;
        State state;
        address payable seller;
        address payable buyer;
    }
  // Create a variable named 'items' to map itemIds to Items.
    mapping(uint => Item) items;
    
  // Create an event to log all state changes for each item.
    event ChangeStateEvent (
        uint indexed id,
        string name,  
        uint price,
        State state,
        address payable seller, 
        address payable buyer
    );


  // Create a modifier named 'onlyOwner' where only the contract owner can proceed with the execution.
    modifier onlyOwner() {
        require(msg.sender==owner);
        _;
    }

  // Create a modifier named 'checkState' where the execution can only proceed if the respective Item of a given itemId is in a specific state.
    modifier checkState(uint itemID) {
        require(items[itemID].state>=State.ForSale && items[itemID].state<=State.Received);
        _;
    }
  // Create a modifier named 'checkCaller' where only the buyer or the seller (depends on the function) of an Item can proceed with the execution.
    modifier checkCaller(uint itemID) {
        require(items[itemID].buyer==msg.sender || items[itemID].seller==msg.sender);
        _;
    }
  // Create a modifier named 'checkValue' where the execution can only proceed if the caller sent enough Ether to pay for a specific Item or fee.
    modifier checkValue() {
        uint overpayment;
        if(msg.value > PAY_FEE) {
            overpayment = msg.value - PAY_FEE;
            msg.sender.transfer(overpayment);
        }
        else revert();
        _;
    }
    
  // Create a function named 'addItem' that allows anyone to add a new Item by paying a fee of 1 finney. Any overpayment amount should be returned to the caller. All struct members should be mandatory except the buyer.
    function addItem(string memory _itemName, uint _price) public payable {
        uint overpayment;
        uint _id;
        if(msg.value > PAY_FEE) {
            overpayment = msg.value - PAY_FEE;
            msg.sender.transfer(overpayment);
      
            Item memory newItem;
        
            newItem.name = _itemName;
            newItem.price = _price;
            newItem.state = State.ForSale;
            newItem.seller = msg.sender;
            newItem.buyer = address(0);

        
            _id = itemIdCount;
            items[_id] = newItem;
            itemIdCount = itemIdCount + 1;
            
            emit ChangeStateEvent(_id, newItem.name, newItem.price, newItem.state, newItem.seller, newItem.buyer);
        }
        else if(msg.value == PAY_FEE) {
            Item memory newItem;
        
            newItem.name = _itemName;
            newItem.price = _price;
            newItem.state = State.ForSale;
            newItem.seller = msg.sender;
            newItem.buyer = address(0);
        
            _id = itemIdCount;
            items[_id] = newItem;
            itemIdCount = itemIdCount + 1;
            
             emit ChangeStateEvent(_id, newItem.name, newItem.price, newItem.state, newItem.seller, newItem.buyer);
        }
        else revert();
    }
    
  // Create a function named 'buyItem' that allows anyone to buy a specific Item by paying its price. The price amount should be transferred to the seller and any overpayment amount should be returned to the buyer.
    function buyItem(uint _itemId) public payable {
        
        uint overpayment;
        uint price_amount; 
       
        if(msg.value>=items[_itemId].price) {
            overpayment = msg.value - items[_itemId].price;
            price_amount = items[_itemId].price;
            items[_itemId].state = State.Sold;
            items[_itemId].buyer = msg.sender;
            items[_itemId].seller.transfer(price_amount);
            msg.sender.transfer(overpayment);
        }
        emit ChangeStateEvent(_itemId, items[_itemId].name, items[_itemId].price, items[_itemId].state, items[_itemId].seller, items[_itemId].buyer);
        
    }
  // Create a function named 'shipItem' that allows the seller of a specific Item to record that it has been shipped.
    function shipItem(uint _itemId) public {
        if(items[_itemId].seller == address(msg.sender))
            items[_itemId].state = State.Shipped;
        emit ChangeStateEvent(_itemId, items[_itemId].name, items[_itemId].price, items[_itemId].state, items[_itemId].seller, items[_itemId].buyer);
    }
    
  // Create a function named 'receiveItem' that allows the buyer of a specific Item to record that it has been received.
    function receiveItem(uint _itemId) public {
        if(items[_itemId].buyer == address(msg.sender))
          items[_itemId].state = State.Received;
        emit ChangeStateEvent(_itemId, items[_itemId].name, items[_itemId].price, items[_itemId].state, items[_itemId].seller, items[_itemId].buyer);
    }
  // Create a function named 'getItem' that allows anyone to get all the information of a specific Item in the same order of the struct Item.
    function getItem(uint _itemId) public view returns(string memory, uint, State, address payable, address payable)  {
            return (items[_itemId].name, items[_itemId].price, items[_itemId].state, items[_itemId].seller, items[_itemId].buyer);
    }
  // Create a function named 'withdrawFunds' that allows the contract owner to withdraw all the available funds.
    function withdrawFunds() onlyOwner public payable {
	// I can't understand your direction for this function. So, I implemented the function for transfer to owner all price...
        uint funds;
        for(uint _id = 0; _id <itemIdCount;_id++) {
            funds = items[_id].price;
            items[_id].price = 0; 
            owner.transfer(funds);
        }
        
    }
}
