// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.14;

/*  PROPIEDADES DEL CONTRATO
1) Solo el propietario puede añadir productos nuevos
2) Solo el propietario puede reponer productos
3) Solo el propietario puede acceder al balance de la maquina
4) Cualquiera puede comprar productos
5) Solo el propietario puede traspasar el saldo de la maquina a su cuenta

*/

contract VendingMachine {
   address payable  owner;

   uint256 number;

    struct Snack {
        uint32 id;
        string name;
        uint32 amount_snack;
        uint16 price_eth;        

    }

   Snack[] stock;
   uint32 totalSnacks;

   //Events
   event newSnackAdded(string _name, uint8 _price);
   event snackRestocked(string _name, uint32 _quantity);
   event snackSold(string _name, uint32 _quantity);


    constructor( ) {
      owner=payable (msg.sender);  
      totalSnacks=0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner,"y tu quien xuxa eres");
        _;//sigue si se verifica la condición del require

    }

    modifier correctNewSnackData(string memory _name,  uint32 _quantity, uint8 _price){
        require(bytes(_name).length !=0, "null Name");
        require(_quantity!=0,"null quty");
        require(_price !=0, "null price");
        for(uint8 i =0; i<stock.length; i++){
            require(compareStrings(_name, stock[i].name),"snack already exist");
        }
        _;
    }

       modifier correctSnackData(uint32 _id,  uint32 _quantity){
        require(_id<totalSnacks);
        require(_quantity!=0,"null quty");
      
        _;
    }

    function addNewSnack(string memory _name,  uint32 _quantity, uint8 _price ) external onlyOwner correctNewSnackData(_name,_quantity, _price ) {

        Snack memory newSnack= Snack( totalSnacks, _name, _quantity,_price*10^18);
        stock.push(newSnack);
        totalSnacks++;
        emit newSnackAdded(_name, _price);
    
     
    }

    function restoreSnack(uint32 _snackId, uint32 _amount) external onlyOwner correctSnackData(_snackId,_amount){

        stock[_snackId].amount_snack=_amount;
        emit snackRestocked(stock[_snackId].name,stock[_snackId].amount_snack);
    }

   
    function getBalance() external view  onlyOwner returns (uint) {
        return address(this).balance;
    }

      function getStock() external view  onlyOwner returns (Snack[] memory) {

          return stock;
      }
    
    function withdraw() external onlyOwner{

        owner.transfer(address(this).balance);
    }

       function buySnack (uint32 _id, uint32 _amount) external payable {
        require (_amount > 0, "Incorrect amount");
        require (stock[_id].amount_snack >= _amount, "Insufficient quantity");
        require (msg.value >=  _amount*stock[_id].price_eth); 

        stock[_id].amount_snack -= _amount;
        emit snackSold(stock[_id].name, _amount);
    }





    function compareStrings(string memory a, string memory b) internal pure returns(bool){
    
       bool rsp=(keccak256(abi.encodePacked(a))==keccak256(abi.encodePacked(b)));
    
        return rsp;
    }
  
}