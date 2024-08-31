// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/* Requirements:
    - Users should be able to stake the ERC20 token by transferring the tokens to the contract.
    - The contract should track the amount and duration of each user’s stake.
    - Implement a reward mechanism similar to the Ether staking contract, where rewards are based on the staking duration.
    - Users should be able to withdraw their staked tokens and the rewards after the staking period.
    - The contract should handle ERC20 token transfers securely and efficiently.
*/

contract ERC20_Stake {
    struct Stake {
        uint256 amount;
        uint256 duration;
        uint256 enddate;
        uint256 reward;
    }

    address public owner;
    address public tokenAddress;

    mapping(address => Stake) stakes;

    constructor( address _tokenAddress) {
        owner = msg.sender;
        tokenAddress = _tokenAddress;
    }

    error AddressZeroDetected();
    error ZeroValueNotAllowed();
    error RewardNotReached();
    error NotOwner();
    error NoReward();
    error DurationZero();
    error InsufficientBalance();
    error InsufficientFunds();

    event StakeSuccessful(address indexed _user, uint256 indexed  _amount);
    event WithdrawSuccessful(address indexed _user, uint256 indexed  _amount);
    event RewardSent(address indexed _user, uint256 indexed  _reward);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    //function for users to stake their ether
    function stakeERC20(uint256 _amount, uint256 _duration) external payable {
        if(msg.sender == address(0)) {
            revert AddressZeroDetected();
        }

        uint256 _userTokenBalance = IERC20(tokenAddress).balanceOf(msg.sender);

        if(_userTokenBalance < _amount) {
            revert InsufficientFunds();
        }

        if(_amount <= 0) {
            revert ZeroValueNotAllowed();
        }

        if(_duration <= 0) {
            revert DurationZero();
        }

        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);

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
        //uint256 _userTokenBalance = IERC20(tokenAddress).balanceOf(msg.sender);

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

        IERC20(tokenAddress).transfer(msg.sender, finalPayment);

        delete stakes[msg.sender];

        emit RewardSent(_user, finalPayment);
    }

    //function to withdraw their reward before the set date (the user does not get their reward)
    function withdraw() external onlyOwner {
        Stake storage userStake = stakes[msg.sender];

        IERC20(tokenAddress).transfer(msg.sender, userStake.amount);

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
        return IERC20(tokenAddress).balanceOf(address(this));
    }
}