// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.14;
/*
1. Debe tener un propietario al que se van a realizar los pagos cuando se ocupe la habitación.
2. Debe tener una estructura que defina los dos posibles estados de la habitación de hotel:ocupada o libre.
3. Al desplegarse el contrato, el estado de la habitación será libre.
4. Debe tener una función que permita ocupar y pagar la habitación. El precio será 1 ether
y se transferirá directamente al propietario del contrato. Si la transacción se realiza
correctamente, emitiremos un evento con la información que veamos conveniente.
5. Para poder pagar y ocupar una habitación, esta tiene que estar libre.
*/

contract hotelRoom{

address payable owner;



enum roomState{
 busy,
 free
}

roomState public status;

//events

event Ocupy(address _ocupant, uint value);


constructor(){

  owner=payable (msg.sender); 
  status=roomState.free;

}


  modifier enoughBalance(uint amount){
    require(msg.value >=amount,"not enough Balance");
    _;
  }

  modifier hasToBeFree{

    require(status== roomState.free,"Room is bussy");
    _;

  }

   function  makeReservation () public payable enoughBalance(1 ether) hasToBeFree{

    status=roomState.busy;
    this.withdraw();
    emit Ocupy(msg.sender, msg.value);
   }

   function withdraw() public  {

        owner.transfer(address(this).balance);
    }


}