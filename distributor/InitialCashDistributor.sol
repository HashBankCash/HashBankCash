pragma solidity ^0.6.0;

import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

import '../interfaces/IDistributor.sol';
import '../interfaces/IRewardDistributionRecipient.sol';

contract InitialCashDistributor is IDistributor {
    using SafeMath for uint256;

    event Distributed(address pool, uint256 cashAmount);
    event Withdrawal(address user, uint256 amount);

    bool public once = true;

    IERC20 public cash;
    IRewardDistributionRecipient[] public pools;
    uint256[] public percentages;
    uint256 public totalInitialBalance;

    constructor(
        IERC20 _cash,
        IRewardDistributionRecipient[] memory _pools,
        uint256[] memory _percentages,
        uint256 _totalInitialBalance
    ) public {
        require(_pools.length != 0, 'a list of BAC pools are required');
        require(_pools.length == _percentages.length, "the length of pools are not equal to length of percentages");
        
        uint256 sumOfPercentage = 0;
        for (uint256 i = 0; i < _percentages.length; i++) {
            sumOfPercentage = sumOfPercentage.add(_percentages[i]);
        }
        require(sumOfPercentage == 100, "the sum of percentage must to be 100");

        cash = _cash;
        pools = _pools;
        percentages = _percentages;
        totalInitialBalance = _totalInitialBalance;
    }

    function distribute() public override {
        require(
            once,
            'InitialCashDistributor: you cannot run this function twice'
        );
        
        for (uint256 i = 0; i < pools.length; i++) {
            // uint256 amount = totalInitialBalance.div(pools.length);
            uint256 amount = totalInitialBalance.mul(percentages[i]).div(100);

            cash.transfer(address(pools[i]), amount);
            pools[i].notifyRewardAmount(amount);

            emit Distributed(address(pools[i]), amount);
        }

        once = false;
    }

    function countPool() public view returns (uint) {
        return pools.length;
    }

}
