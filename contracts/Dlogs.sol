pragma solidity ^0.4.24;

import "./SafeMath.sol";
// import "./Register.sol";
// @title Main Contract for Dlogs

contract Register{
    function isRegistered(address addr) public view returns (bool);
}

contract Dlogs{
    using SafeMath for uint256;
    struct Blogger {
        address addr;
        uint blogCount;
        uint currentAvailableLikes;
        mapping(string => uint) blogToIndex;
        mapping(uint => string) blogList;
        mapping(string => uint) likes;
        mapping(string => uint) dislikes;
    }

    mapping(address => uint256) private tkgBalances;
    mapping(address => Blogger ) private bloggers;
    // the cost to write a blog is 0.005 ETH
    uint256 private costForWriteBlog = 5000000000000000;
    // the cost to write a blog is 0.001 ETH
    uint256 private costForLikeOrDislike = 1000000000000000;
    uint private totalNumberOfLikes;
    address register;


    constructor(address _addr) public {
       register = _addr;
    }

    modifier userHasLikes(address user) {
        require(bloggers[user].currentAvailableLikes > 0);
		_;
	}

    modifier whenRegistered(address user) {
        require(Register(register).isRegistered(user));
        _;
    }

    modifier hasBlog(address user, string blogHash){
        require((bloggers[user].blogToIndex)[blogHash] != 0);
        _;
    }

    //TODO: This is playing function, needs to be deleted 
    function isRegistered(address addr) public view returns (bool){
         return Register(register).isRegistered(addr);
    }

    function getRegisterAddress(address addr) public view returns (address){
        return register;
    }


    // add a blog
    function addBlog(string blogHash) payable external whenRegistered(msg.sender) returns (bool){
        require(msg.value > costForWriteBlog);
        if(bloggers[msg.sender].addr != (0)){
            uint count = 1;
            // mapping(string => uint) blogToIndex;
            // mapping(uint => string) blogList;
            // mapping(string => uint) likes;
            // mapping(string => uint) dislikes;
            // blogToIndex[blogHash] = count;
            // blogList[count] = blogHash;
            bloggers[msg.sender] = Blogger(msg.sender, count, 0 ); 
        }else{
            bloggers[msg.sender].blogCount = bloggers[msg.sender].blogCount + 1;
            (bloggers[msg.sender].blogToIndex)[blogHash] =  bloggers[msg.sender].blogCount;
            (bloggers[msg.sender].blogList)[ bloggers[msg.sender].blogCount] = blogHash;
        }
        tkgBalances[msg.sender] = tkgBalances[msg.sender].add(5);
        emit AddedBlog(msg.sender, blogHash);
        return true;
    }
    // delete a blog
    function deleteBlog(string blogHash) external hasBlog(msg.sender, blogHash) returns (bool){
        mapping(string => uint) blogidx = bloggers[msg.sender].blogToIndex;
        mapping(uint => string) blogList = bloggers[msg.sender].blogList;

		if (bloggers[msg.sender].blogCount == 1) {		
			delete bloggers[msg.sender].blogList[bloggers[msg.sender].blogToIndex[blogHash]];
			delete bloggers[msg.sender].blogToIndex[blogHash];
		} else {
			bloggers[msg.sender].blogList[bloggers[msg.sender].blogToIndex[blogHash]] = bloggers[msg.sender].blogList[bloggers[msg.sender].blogCount];
			bloggers[msg.sender].blogToIndex[bloggers[msg.sender].blogList[bloggers[msg.sender].blogCount]] = bloggers[msg.sender].blogToIndex[blogHash];
			delete bloggers[msg.sender].blogToIndex[bloggers[msg.sender].blogList[bloggers[msg.sender].blogCount]];	
			delete bloggers[msg.sender].blogList[bloggers[msg.sender].blogCount];
        }
        bloggers[msg.sender].blogCount = bloggers[msg.sender].blogCount -1;
        emit DeletedBlog(msg.sender, blogHash);
        return true;
    }

    // like a blog
    function likeBlog(address blogOwner, string blogHash) payable external hasBlog(blogOwner, blogHash) returns (bool){
        require(msg.value > costForLikeOrDislike);
        bloggers[msg.sender].likes[blogHash] =  bloggers[msg.sender].likes[blogHash] + 1;
        tkgBalances[msg.sender] = tkgBalances[msg.sender].add(1);
        return true;

    }
    // dislike a blog
    function dislikeBlog(address blogOwner, string blogHash) external returns (bool){
        require(msg.value > costForLikeOrDislike);
        bloggers[msg.sender].dislikes[blogHash] =  bloggers[msg.sender].dislikes[blogHash] + 1;
        tkgBalances[msg.sender] = tkgBalances[msg.sender].add(1);
        return true;
    }

    // withdraw the balance for a blogger
    function withdrawETH() external userHasLikes(msg.sender) returns (bool){
        msg.sender.transfer(address(this).balance.mul(bloggers[msg.sender].currentAvailableLikes).div(totalNumberOfLikes));
        totalNumberOfLikes = totalNumberOfLikes - bloggers[msg.sender].currentAvailableLikes;
        bloggers[msg.sender].currentAvailableLikes = 0;
        return true;
    }

    function getBalanceOfTKG() external view returns (uint256){
        return tkgBalances[msg.sender];
    } 
    // get the availabe balance for a blogger
    function getAvailableETHForWithdraw() external view returns (uint256){
        return address(this).balance.mul(bloggers[msg.sender].currentAvailableLikes).div(totalNumberOfLikes);
    }

    //deposit ETH to this contract
    function deposit() payable public {
        // nothing to do, this will add the balance to the smart contract
    }
    // get balance of ETH in this contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // get the blogger 
    function getBlogs(address _addr) external view returns (uint){
        Blogger blogger = bloggers[_addr];
        return blogger.blogCount;        
    }
    //fallback function
    function () public payable { revert(); }

    event AddedBlog(address addr, string blogHash);
    event DeletedBlog(address addr, string blogHash);
    event LikedBlog(address reader, address blogger, string blogHash);
    event DislikedBlog(address reader, address blogger, string blogHash);
} 
