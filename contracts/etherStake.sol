// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

/* Requirements:
    - Users should be able to stake Ether by sending a transaction to the contract.
    - The contract should record the staking time for each user.
    - Implement a reward mechanism where users earn rewards based on how long they have staked their Ether.
    - The rewards should be proportional to the duration of the stake.
    - Users should be able to withdraw both their staked Ether and the earned rewards after the staking period ends.
    - Ensure the contract is secure, especially in handling users’ funds and calculating rewards.
*/

contract etherStake {
    struct Stake {
        uint256 amount;
        uint256 duration;
        uint256 enddate;
        uint256 reward;
    }

    address owner;

    mapping(address => Stake) stakes;

    constructor() {
        owner = msg.sender;
    }

    error AddressZeroDetected();
    error ZeroValueNotAllowed();
    error RewardNotReached();
    error NotOwner();
    error NoReward();
    error DurationZero();
    error InsufficientBalance();

    event StakeSuccessful(address indexed _user, uint256 indexed  _amount);
    event WithdrawSuccessful(address indexed _user, uint256 indexed  _amount);
    event RewardSent(address indexed _user, uint256 indexed  _reward);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    //function for users to stake their ether
    function stakeEther(uint256 _duration) external payable {
        if(msg.sender == address(0)) {
            revert AddressZeroDetected();
        }

        if(msg.value <= 0) {
            revert ZeroValueNotAllowed();
        }

        if(_duration <= 0) {
            revert DurationZero();
        }

        stakes[msg.sender] = Stake({
            amount: msg.value, 
            duration: _duration, 
            enddate: _duration + block.timestamp/24, /*convert block timestamp to days*/ 
            reward: calculate_reward(msg.value, _duration)     
        });

        emit StakeSuccessful(msg.sender, msg.value);
    }

    //function to calculate the reward for a user based on the length of staking
    function calculate_reward(uint256 _principal, uint256 _time) public pure returns(uint256) {      
        return (_principal * _time * 10/100);
    }

    //function to automatically pay the user once the time has reached
    function payReward(address _user) external payable {
        Stake storage userStake = stakes[_user];

        if(_user == address(0)) {
            revert AddressZeroDetected();
        }

        if(userStake.reward <= 0) {
            revert NoReward();
        }

        if(userStake.enddate <= block.timestamp) {
            revert RewardNotReached();
        }
               
        uint256 finalPayment = userStake.amount + userStake.reward;

        if(address(this).balance <= finalPayment) {
            revert InsufficientBalance();
        }

        delete stakes[msg.sender];

        (bool success, ) = payable(msg.sender).call{value: finalPayment}("");
        require(success, "Transfer failed");

        emit RewardSent(_user, finalPayment);
    }

    //function to withdraw their reward before the set date (the user does not get their reward)
    function withdraw() external onlyOwner {
        Stake storage userStake = stakes[msg.sender];

        (bool success,) = msg.sender.call{value : userStake.amount}("");
        require(success, "Failed withdrawal!");

        delete stakes[msg.sender];

        emit WithdrawSuccessful(msg.sender, userStake.amount);
    }

    //function for users to view their stake
    function viewStake() external view onlyOwner returns(uint256) {
        Stake storage userStake = stakes[msg.sender];

        return userStake.amount;
    }

    //function for users to view their reward
    function viewReward() external view onlyOwner returns(uint256) {
        Stake storage userStake = stakes[msg.sender];

        return userStake.reward;
    }
    
    function getContractBalance() external view returns(uint256) {
        return address(this).balance;
    }
}