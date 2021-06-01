pragma solidity ^0.5.0;

import './ERC827.sol';
import './AppMachine.sol';

contract Sensor {

	uint256 sensorData;
	address appAddress;

	//Wird vom Contract AppMachine aufgerufen und speichert die Addresse dieses Contracts. Sensordaten werden hier einfach gesetzt, da wir keinen realen Sensor haben.
	constructor () public {
		sensorData = 555;
		appAddress = msg.sender;
	}
	
	//Stellt sicher, dass nur der Contract AppMachine diese Funktion aufrufen kann
	modifier fromContract{
		require(msg.sender == appAddress);
		_;
	}

	//getter
	function getCurrentData() public view fromContract returns(uint256)
	{
		return sensorData;
	}

}