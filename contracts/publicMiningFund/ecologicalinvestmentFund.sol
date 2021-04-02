pragma solidity ^0.8.0;
import "../interface/uniswap/IUniswapV2Router02.sol";
import "../ref/CoreRef.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract ecologicalinvestmentFund is CoreRef{
    using SafeMath for uint256;

    address[] public tokens; //设置0为RBT  1 为 btc 2为eth

    address[] public pools; // 0 彩虹DeFi投资基金 1 彩虹网络投资基金 2 彩虹教育投资基金 3 彩虹实业投资基金 4彩虹文化投资基金 5 彩虹投资投资基金 6 彩虹研发投资基金

    uint[] public ratios;

    uint public lastDistributionTime;
    IUniswapV2Router02 public router;
    IUniswapV2Router02 public rainbowRouter;


    //tokens 0 rbt 1 rbd 2 rbt-seed 3 rbt-ex 4 rusd

    constructor(address core,  address _router,address _rainbowRouter,address[] memory _pools,uint[] memory _ratios ) CoreRef(core) public {
        require(_pools.length == _ratios.length,'length wrong');
        //uinswap router
        router = IUniswapV2Router02(_router);
        rainbowRouter = IUniswapV2Router02(_rainbowRouter);
        ratios = _ratios;
        pools = _pools;
    }

    //todo 设置权限只允许调用者是DCV
    //将换到的token分给7个池子
    function tokenDistribution() public {
        //四个小时一次
        require(block.timestamp >= lastDistributionTime + 14400,'time is not in');
        _tokenSwap();
        //将eth WBTC 按发送到四个池子
        for(uint i=0;i<pools.length;i++){
            IERC20(tokens[2]).transfer(pools[i],IERC20(tokens[2]).balanceOf(address(this)).mul(ratios[i]).div(100));
            IERC20(tokens[1]).transfer(pools[i],IERC20(tokens[1]).balanceOf(address(this)).mul(ratios[i]).div(100));
        }
        //rbt发送到第一个池子
        IERC20(tokens[0]).transfer(pools[0],IERC20(tokens[0]).balanceOf(address(this)));
        lastDistributionTime = block.timestamp;
    }

    /*
        @dev将除了rbt其他的币换成wbtc跟eth
    */
    function _tokenSwap() internal {
        uint256 endTime = type(uint256).max;
        //将其他的币换成btc跟eth
        for(uint i=3; i< tokens.length;i++){
            address token = tokens[i];
            uint balance = IERC20(token).balanceOf(address(this));
            IERC20(token).approve(address(router),balance);
            address[] memory pathEth = new address[](2);
            pathEth[0] = tokens[i];
            pathEth[1] = tokens[2];
            router.swapExactTokensForETH(balance.mul(50).div(100),0,pathEth,address(this),endTime);
            address[] memory pathBTC = new address[](2);
            pathBTC[0] = tokens[i];
            pathBTC[1] = tokens[1];
            router.swapExactTokensForTokens(balance.mul(50).div(100),0,pathBTC,address(this),endTime);
        }
    }




    // function  _swap() public;





    function _removeLiquidityETH(uint256 liquidity, address token,uint deadline) internal returns (uint256)
    {
        (, uint256 amountWithdrawn) =
        router.removeLiquidityETH(
            token,
            liquidity,
            0,
            0,
            address(this),
            deadline
        );
        return amountWithdrawn;
    }
}
