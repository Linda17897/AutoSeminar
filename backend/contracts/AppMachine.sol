pragma solidity ^0.5.0;
// We have to specify what version of compiler this code will compile with

import './ERC827.sol';
import './Sensor.sol';

contract AppMachine {


    address private appAddress;
    address payable private machineAddress;
    address contractAddress;

    struct RequestApp {
/*Unix time takes the format of uint256 */
        uint256 StartTime;
        uint256 Duration;
        uint Quality;
        uint Type;
    }

    RequestApp public myRequest;
    uint256 public requiredToken;
    bool public requestSent;
    bool public requestAcknowledged;
    bool public tokenTransferred;

    //Eine Sensorinstanz
    Sensor sensor1;

    //Event, welches beim Debuggen hilft um einen Funktionsaufruf nachzuweisen
    event FunctionCalled(
        address indexed sender,
        string name
    );


    /* This is the constructor which will be called once when you
    deploy the contract to the blockchain. When we deploy the contract,
    we will pass the address of the the app which makes the request and the target machine/sensor
    and also the request parameter such as startime, duration, and quality
    */

    constructor(address payable machAddress)  public {
        machineAddress = machAddress;
        tokenTransferred = false;
        requestSent = false;
        requestAcknowledged = false;

        appAddress = msg.sender;
        contractAddress = address(this);

        //Sensorinstanz erzeugen
        sensor1 = new Sensor();
    }


  // This is the sendRequest function called by the machine
    function sendRequest(uint startTime, uint duration, uint quality, uint infType) public {   
        myRequest.StartTime = startTime;
        myRequest.Duration = duration;
        myRequest.Quality = quality;
        myRequest.Type = infType;
        appAddress = msg.sender;
        requestSent = true;
        tokenTransferred = false;

        emit FunctionCalled(msg.sender, "sendRequest");
    }


  /*
  In this function we are calculating the token requiredToken
  this function is an internal function called by the requestToken() function
  */
    function calculateToken() private view returns (uint) {
        uint256 tokenAmount;

        if(myRequest.Type == 1) tokenAmount = myRequest.Duration*5e17;
        else tokenAmount = (myRequest.Duration*5e17) * myRequest.Quality;
        
        return tokenAmount;
    }

    /*
    Once the machine receives a requests it calls this function
    It calculates the number of tokens required
    */
    function requestToken() public {
        requiredToken = calculateToken();
        requestAcknowledged = true;

        emit FunctionCalled(msg.sender, "requestToken");
    }

    /*
    Once the App sees that the machine is requesting for token,
    this function is invoked. to send the token.
    if successfully tranferred then the tokenTranferred parameter is made true
    */
    function sendToken() public payable  {
        machineAddress.transfer(msg.value);
        tokenTransferred = true;

        emit FunctionCalled(msg.sender, "sendToken");
    }

/*
    Data handler
*/

    //Hilfsfunktion zum Encoden eines Funktionsaufrufs. Der Funktionsaufruf/Call durch den ERC827-Token benötigt den Bytecode des Funktionsaufrufes. 
    bytes code;
    function encoder() public returns(bytes memory)
    {
        code = abi.encodeWithSignature("setData()");
        return code;
    }

    //Einsehbare Daten
    uint256 public publicData;
    
    //Prüft, ob schon bezahlt ist. Kann als Vorraussetzung eines Funktionsaufrufes verwendet werden
    modifier isPaid()
    {
        require(tokenTransferred == true);
        _;
    }

    //Entnimmt die Daten vom Sensor
    function setData() public isPaid returns(bool) { 
        publicData = sensor1.getCurrentData();

        emit FunctionCalled(msg.sender, "setData");

        return true;
    }
    
    // MaLm: Restart der App
    function resetForRestart() public {
        tokenTransferred = false;
        requestSent = false;
        requestAcknowledged = false;
       
       
       emit FunctionCalled(msg.sender, "resetForRestart"); 
    }

/*
	getter functions
*/

    function getMachineAddress() public view returns (address){
      return machineAddress;
    }
    function getContractAddress() public view returns(address){
      return contractAddress;
    }
    function getStartTime() public view returns (uint256){
      return myRequest.StartTime;
    }
    function getDuration() public view returns (uint256) {
        return myRequest.Duration;
    }
    function getQuality() public view returns (uint){
      return myRequest.Quality;
    }
    function getType() public view returns (uint){
      return myRequest.Type;
    }
    function getAppAddress() public view returns (address){
      return appAddress;
    }
    function getRequiredToken() public view returns (uint256){
      return requiredToken;
    }
    function getTokenTrasnferredStatus() public view returns(bool){
      return tokenTransferred;
    }
    function getRequestSentStatus() public view returns(bool){
      return requestSent;
    }
    function getRequestAcknowledgeStatus() public view returns(bool){
      return requestAcknowledged;
    }
    function getPublicData() public view returns(uint256){
      return publicData;
    }

}
