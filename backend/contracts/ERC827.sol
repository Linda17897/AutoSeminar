pragma solidity ^0.5.0;

contract ERC20 
{

 // Transfer event
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );
  
    // Approval event
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    
    uint256 totalSupply_;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    
    // Constructor
    constructor(uint256 _total) public
    {
        totalSupply_ = _total;
        balances[msg.sender] = totalSupply_;
    }

    // Get total Supply of tokens
    function totalSupply() public view returns(uint256)
    {
        return totalSupply_;
    }
  
  
    // Get token balances of a certain address
    function balanceOf(address _owner) public view returns(uint256)
    {
        return balances[_owner];
    }
  
    // Transfer tokens to a certain address
    function transfer(address _to, uint256 _value) public returns(bool)
    {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
  
    // Transfer tokens from a certain address to a certain address
    function transferFrom(address _from, address _to, uint256 _value)
        public returns (bool)
    {
        require(_to != address(0));
        require(_from != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][_to]);
        
        balances[_from] = balances[_from] - _value;
        balances[_to] = balances[_to] + _value;
        
        emit Transfer(_from, _to, _value);
        return true;
    }
  
    // Give allowance to the contract to transfer a certain amount of value from spender
    function approve(address _spender, uint256 _value)
        public returns (bool)
    {
        allowed[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
        
    // Get the amount of token a certain owner is allowed to spend    
    function allowance(address _owner, address _spender)
        public view returns (uint256)
    {
        return allowed[_owner][_spender];
    }

}


contract ERC827 is ERC20
{

    // Constructor
    constructor(uint256 _total) ERC20(_total) public
    {
    }

    // Approve with function call (_data is bytecode of the function call)
    function approveAndCall(address _spender, uint256 _value, bytes memory _data)
        public returns(bool)
    {
        require(_spender != address(this));
        super.approve(_spender, _value);
        
        (bool success, ) = _spender.call(_data);
        require(success);
        
        
        return true;
    }
     
     // Transfer tokens with function call (_data is bytecode of the function call)  
    function transferAndCall(address _to, uint256 _value, bytes memory _data)
        public returns(bool)
    {
        require(_to != address(this));
        super.transfer(_to, _value);
        
        (bool success, ) = _to.call(_data);
        require(success);
        
        return true;
    }
        
    // Transfer tokens from a certain address and call (_data is bytecode of the function call)
    function transferFromAndCall(address _from, address _to, uint256 _value, bytes memory _data)
        public returns(bool)
    {
        require(_to != address(this));
        super.transferFrom(_from, _to, _value);
        
        (bool success, ) = _to.call(_data);
        require(success);
        
        return true;
    }
}