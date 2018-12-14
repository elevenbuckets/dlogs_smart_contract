pragma solidity ^0.4.24;

// @title Registration for Dlogs

contract Register{
    struct User {
        address addr;
        string ipns;
        bool deleted;
    }


    mapping(address => uint) mapFromAddress;
    User[] users;
    uint public userCount = 0;


    modifier whenUser(uint _id) {
		require(!users[_id].deleted);
		_;
	}

    modifier whenRegistered(address addr) {
		require(mapFromAddress[addr]!= 0);
		_;
	}


    function register(string ipns) external returns (bool){
        require(mapFromAddress[msg.sender] == 0);

        users.push(User(msg.sender, ipns, false));
        mapFromAddress[msg.sender] = users.length;

        emit Registered(users.length -1, msg.sender, ipns);
        userCount = userCount + 1;
        return true;
    }

    function unregister() external whenRegistered(msg.sender) returns (bool){
        uint index = mapFromAddress[msg.sender] - 1;
        emit Unregistered(index, msg.sender, users[index].ipns );
		delete mapFromAddress[msg.sender];
		users[index].deleted = true;
		userCount = userCount - 1;
        return true;
    }

    function isRegistered(address addr) public view returns (bool){
        return mapFromAddress[addr]!= 0;
    }

    function getUser(uint id) public view whenUser(id) returns (address addr, string ipns){
        User storage user = users[id];
        addr = user.addr;
        ipns = user.ipns;
    }

    function getUserByAddress(address _addr) external view whenRegistered(_addr) returns (address, string){
        uint id = mapFromAddress[_addr] -1;
        return getUser(id);
    }

    event Registered(uint indexed id, address addr, string ipns);
	event Unregistered(uint indexed id, address addr, string ipns);
}