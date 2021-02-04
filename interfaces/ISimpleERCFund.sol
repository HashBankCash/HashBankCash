pragma solidity ^0.6.0;

interface ISimpleERCFund {
    function deposit(
        address token,
        uint256 amount,
        string calldata reason
    ) external;

    function withdraw(
        address token,
        uint256 amount,
        address to,
        string calldata reason
    ) external;
}
