// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract Loyalty {
    address public owner;
    Company[] public companiesArr;
    Ads[] public allAds;
    
    struct Company {
        string name;
        string id;
        uint uId;
        
    }
    struct User {
        string name;
        uint uId;
        uint parentId;
        uint lastUsageTimestamp; 
        mapping(uint=>uint) balances;

    }
    struct Ads{
        uint coin;
        string text;
        uint aId;
        uint cId;
    }
    // struct redeemBoard{

    // }
    uint numUsers;
    mapping(uint => User) public users;
    constructor()   {
        owner = msg.sender;
        addCompany("Parent Company", "FlipKart");
        addUser(0, "Flipkart", 0, 1000000);
    }
    function getAllCompanies() public view returns(uint) {
        return companiesArr.length;
    }
    function addCompany(string memory id, string memory name) public {
        for (uint i = 0; i < companiesArr.length; i++) {
            if (keccak256(bytes(companiesArr[i].id)) == keccak256(bytes(id))) {
                revert("Company with the same ID already exists");
            }
        }
        Company memory newCompany = Company({
            id: id,
            name: name,
            uId: companiesArr.length
        });
        companiesArr.push(newCompany);
    }
    function getCompany(uint index) public view returns(string memory) {
        Company storage cc = companiesArr[index];
        return (cc.name);
    }
    function addUser(uint uId, string memory name, uint cId, uint bal) public {
        // User memory newUser = User({
        //     name: name,
        //     uId: uId,
        //     parentId: cId
            
        // });
        // users[uId] = newUser;
        User storage u = users[numUsers++];
        u.name = name;
        u.uId = uId;
        u.parentId = cId;
        u.lastUsageTimestamp = block.timestamp; 
        addUserBal(uId, cId, bal);
    }
    function addUserBal(uint uId, uint cId, uint bal) public {
        User storage _user = users[uId];
        _user.balances[cId] = bal;
    }
    function getUser(uint id, uint cId) public view returns(uint, string memory, uint){
        User storage uu = users[id];
        return(uu.uId, uu.name, uu.balances[cId]);
    }
    function totalAds() public view returns(uint) {
        return allAds.length;
    }
    function createAd(uint coins, string memory text, uint cId) public{
        uint _aId = allAds.length;
        Ads memory _ad = Ads({
            coin: coins,
            text: text,
            aId: _aId,
            cId: cId
        });
        allAds.push(_ad);
    }
    function displayAd(uint index) public view returns(uint, string memory) {
        Ads storage currentAd = allAds[index];
        return (currentAd.aId, currentAd.text);
    }
    
    function redeemAd(uint aId, uint uId) public restricted{
        Ads memory currentAd = allAds[aId];
        User storage currentuser = users[uId];
        require(currentuser.balances[currentAd.cId]> currentAd.coin);
        currentuser.balances[currentAd.cId] = currentuser.balances[currentAd.cId]- currentAd.coin;
    }
    
    modifier restricted() {
        require(msg.sender == owner);
        _;
    }

}
