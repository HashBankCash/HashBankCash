pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
}
interface ISwapPair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}
interface IInitialCashDistributor {
    function countPool() external view returns (uint);
    function pools(uint _index) external view returns (address);
}
interface IInitialShareDistributor {
    function daibacLPPool() external view returns (address);
    function daibasLPPool() external view returns (address);
}
interface IBACPool {
    function starttime() external view returns (uint);
    function basisCash() external view returns (address);
    function token() external view returns (address);
    function periodFinish() external view returns (uint);
    function balanceOf(address account) external view returns (uint256); 
}
interface ISharePool {
    function starttime() external view returns (uint);
    function basisShare() external view returns (address);
    function lpt() external view returns (address);
    function periodFinish() external view returns (uint);
    function balanceOf(address account) external view returns (uint256); 
}

contract Query {
    address public owner;
    address public cashDistributor;
    address public shareDistributor;
    string public chainSymbol = 'ETH';

    struct Pool {
        address pool;
        uint starttime;
        uint periodFinish;
        uint balance;
        address depositToken;
        address earnToken;
        address depositToken0;
        address depositToken1;
        uint depositTokenDecimals;
        uint earnTokenDecimals;
        string depositTokenSymbol;
        string earnTokenSymbol;
        string depositTokenSymbol0;
        string depositTokenSymbol1;
    }

    constructor() public {
        owner = msg.sender;
        uint id;
        assembly {
            id := chainid()
        }
        if(id == 56 || id == 97) {
            chainSymbol = 'BNB';
        } else if(id == 128 || id == 256) {
            chainSymbol = 'HT';
        }
    }

    function setDistributor(address _cashDistributor, address _shareDistributor) public {
        require(msg.sender == owner, 'Only Owner');
        cashDistributor = _cashDistributor;
        shareDistributor = _shareDistributor;
    }

    function getPoolForPair(address _pool, address _user) public view returns (Pool memory d) {
        d.pool = _pool;
        d.depositToken = ISharePool(d.pool).lpt();
        d.earnToken = ISharePool(d.pool).basisShare();
        d.starttime = ISharePool(d.pool).starttime();
        d.periodFinish = ISharePool(d.pool).periodFinish();
        d.balance = ISharePool(d.pool).balanceOf(_user);
        d.depositTokenDecimals = 18;
        d.earnTokenDecimals = IERC20(d.earnToken).decimals();
        d.depositTokenSymbol = 'LP';
        d.earnTokenSymbol = IERC20(d.earnToken).symbol();
        d.depositToken0 = ISwapPair(d.depositToken).token0();
        d.depositToken1 = ISwapPair(d.depositToken).token1();
        d.depositTokenSymbol0= IERC20(d.depositToken0).symbol();
        d.depositTokenSymbol1 = IERC20(d.depositToken1).symbol();
        return d;
    }

    function getPools(address _user) public view returns (Pool[] memory data) {
        uint count = IInitialCashDistributor(cashDistributor).countPool();
        data = new Pool[](count+2);
        if(count > 0) {
            for(uint i = 0;i < count;i++) {
                Pool memory d;
                d.pool = IInitialCashDistributor(cashDistributor).pools(i);
                d.starttime = IBACPool(d.pool).starttime();
                d.periodFinish = IBACPool(d.pool).periodFinish();
                d.balance = IBACPool(d.pool).balanceOf(_user);
                d.depositToken = IBACPool(d.pool).token();
                d.earnToken = IBACPool(d.pool).basisCash();
                d.earnTokenSymbol = IERC20(d.earnToken).symbol();
                d.earnTokenDecimals = IERC20(d.earnToken).decimals();
                if(d.depositToken == address(0)) {
                    d.depositTokenSymbol = chainSymbol;
                    d.depositTokenDecimals = 18;
                } else  {
                    d.depositTokenSymbol = IERC20(d.depositToken).symbol();
                    d.depositTokenDecimals = IERC20(d.depositToken).decimals();
                }
                data[i] = d;
            }
        }
        data[count] = getPoolForPair(IInitialShareDistributor(shareDistributor).daibacLPPool(), _user);
        data[count+1] = getPoolForPair(IInitialShareDistributor(shareDistributor).daibasLPPool(), _user);
        return data;
    }
 
    function getSwapPairReserve(address _pair) public view returns (address token0, address token1, uint8 decimals0, uint8 decimals1, uint reserve0, uint reserve1) {
        token0 = ISwapPair(_pair).token0();
        token1 = ISwapPair(_pair).token1();
        decimals0 = IERC20(token0).decimals();
        decimals1 = IERC20(token1).decimals();
        (reserve0, reserve1, ) = ISwapPair(_pair).getReserves();
    }

}