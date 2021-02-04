pragma solidity ^0.6.0;

import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

import '../interfaces/IDistributor.sol';
import '../interfaces/IRewardDistributionRecipient.sol';

contract InitialShareDistributor is IDistributor {
    using SafeMath for uint256;

    event Distributed(address pool, uint256 cashAmount);
    event Withdrawal(address user, uint256 amount);

    bool public once = true;

    IERC20 public share;
    IRewardDistributionRecipient public daibacLPPool;
    uint256 public daibacInitialBalance;
    // IRewardDistributionRecipient public daibasLPPool;
    // uint256 public daibasInitialBalance;
    IRewardDistributionRecipient public ETHbacLPPool;
    uint256 public ETHbacInitialBalance;
    IRewardDistributionRecipient public HTbacLPPool;
    uint256 public HTbacInitialBalance;

    constructor(
        IERC20 _share,
        IRewardDistributionRecipient _daibacLPPool,
        uint256 _daibacInitialBalance,
        // IRewardDistributionRecipient _daibasLPPool,
        // uint256 _daibasInitialBalance
        IRewardDistributionRecipient _ETHbacLPPool,
        uint256 _ETHbacInitialBalance,
        IRewardDistributionRecipient _HTbacLPPool,
        uint256 _HTbacInitialBalance     
    ) public {
        share = _share;
        daibacLPPool = _daibacLPPool;
        daibacInitialBalance = _daibacInitialBalance;
        // daibasLPPool = _daibasLPPool;
        // daibasInitialBalance = _daibasInitialBalance;
        ETHbacLPPool = _ETHbacLPPool;
        ETHbacInitialBalance = _ETHbacInitialBalance;
        HTbacLPPool = _HTbacLPPool;
        HTbacInitialBalance = _HTbacInitialBalance;                
    }

    function distribute() public override {
        require(
            once,
            'InitialShareDistributor: you cannot run this function twice'
        );

        share.transfer(address(daibacLPPool), daibacInitialBalance);
        daibacLPPool.notifyRewardAmount(daibacInitialBalance);
        emit Distributed(address(daibacLPPool), daibacInitialBalance);

        // share.transfer(address(daibasLPPool), daibasInitialBalance);
        // daibasLPPool.notifyRewardAmount(daibasInitialBalance);
        // emit Distributed(address(daibasLPPool), daibasInitialBalance);

        share.transfer(address(ETHbacLPPool), ETHbacInitialBalance);
        ETHbacLPPool.notifyRewardAmount(ETHbacInitialBalance);
        emit Distributed(address(ETHbacLPPool), ETHbacInitialBalance);
        
        share.transfer(address(HTbacLPPool), HTbacInitialBalance);
        HTbacLPPool.notifyRewardAmount(HTbacInitialBalance);
        emit Distributed(address(HTbacLPPool), HTbacInitialBalance);
        once = false;
    }
}
