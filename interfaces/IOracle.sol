pragma solidity ^0.6.0;

interface IOracle {
    function token0() external returns (address);
    function token1() external returns (address);
    function update() external;

    function consult(address token, uint256 amountIn)
        external
        view
        returns (uint256 amountOut);
    // function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestamp);
}
