pragma solidity ^0.8.0;

import "https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary/blob/master/contracts/BokkyPooBahsDateTimeLibrary.sol";

contract BirthdayPayout {
    string private _name;
    address private _owner;
    uint256 private constant PRESENT = 100000000000000000;
    mapping(address => uint) public sent;
    Teammate[] public teammates;

    struct Teammate {
        string name;
        address account;
        uint256 birthday;
    }

    constructor() {
        _name = "yar";
        _owner = msg.sender;
    }

    function addTeammate(address account, string memory name, uint256 birthday) public onlyOwner {
        require(msg.sender != account, "Cannot add oneself");
        Teammate memory newTeammate = Teammate(name, account, birthday);
        teammates.push(newTeammate);
        emit NewTeammate(account, name);
    }

    function sendPresent() public onlyOwner {
        uint256 today_year = BokkyPooBahsDateTimeLibrary.getYear(block.timestamp);
        require(getTeammatesNumber() > 0, "No teammates in database");
        for (uint256 i = 0; i < getTeammatesNumber(); i++) {
            if (checkBirthday(i) && sent[teammates[i].account] != today_year) {
                sendToTeammate(i);
                sent[teammates[i].account] = today_year;
                emit HappyBirthday(teammates[i].name, teammates[i].account);
            }
        }
    }

    function findBirthday() public {
        for (uint256 i = 0; i < teammates.length; i++) {
            if (checkBirthday(i)) {
                sendToTeammate(i);
            }
        }
        revert("None found");
    }

    function checkBirthday(uint256 index) view public returns(bool) {
        uint256 birthday = teammates[index].birthday;
        (, uint256 birthday_month, uint256 birthday_day) = getDate(birthday);
        uint256 today = block.timestamp;
        (, uint256 today_month, uint256 today_day) = getDate(today);

        if (birthday_day == today_day && birthday_month == today_month) {
            return true;
        }
        return false;
    }

    function demoIf(uint256 par) view public returns(bool) {
        if (par == 2) {
            return true;
        }
        return false;
    }

    function getDate(uint256 timestamp) pure public returns(uint256 year, uint256 month, uint256 day) {
        (year, month, day) = BokkyPooBahsDateTimeLibrary.timestampToDate(timestamp);
    }

    function getTeam() view public returns(Teammate[] memory) {
        return teammates;
    }
    
    function getTeammatesNumber() view public returns(uint256) {
        return teammates.length;
    }

    function sendToTeammate(uint256 index) public onlyOwner {
        payable(teammates[index].account).transfer(PRESENT);
    }

    function deposit() public payable {
    }

    modifier onlyOwner {
        require(msg.sender == _owner, "Sender should be the owner of contract");
        _;
    }

    event NewTeammate(address account, string name);

    event HappyBirthday(string name, address account);
}
