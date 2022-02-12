// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

//import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
//import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';

import './transferHelper.sol';
import './ISwapRouter.sol';

contract SingleSwapTest {
    ISwapRouter public immutable swapRouter; 

    address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; 
    address public constant DAI = 0xaD6D458402F60fD3Bd25163575031ACDce07538D; 

    uint24 public constant poolFee = 3000; 

    constructor (ISwapRouter _swapRouter) {
        swapRouter = _swapRouter;

    }
    // swap a fixed amount of ETH for a maximum amount of DAI
    function swapExactInputSingle(uint256 amountIn) external returns (uint256 amountOut) {
        TransferHelper.safeTransferFrom(ETH, msg.sender, address(this), amountIn);
        TransferHelper.safeApprove(ETH, address(swapRouter), amountIn);
        
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
                tokenIn : ETH,
                tokenOut : DAI,
                fee: poolFee, 
                recipient: msg.sender, 
                deadline : block.timestamp,
                amountIn : amountIn, 
                amountOutMinimum: 0,
                //obtain the amountOutMinimum data from an oracle or another data source for better security    
                sqrtPriceLimitX96 : 0
        });
        amountOut = swapRouter.exactInputSingle(params);
    }

    //swap a minimum amount of ETH for a fixed amount of DAI
    function swapExactOutputSingle(uint256 amountOut, uint256 amountInMaximum) external returns (uint256 amountIn) {
        TransferHelper.safeTransferFrom(ETH, msg.sender, address(this), amountIn);
        TransferHelper.safeApprove(ETH, address(swapRouter), amountIn);

        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter.ExactOutputSingleParams({
                tokenIn : ETH,
                tokenOut : DAI,
                fee : poolFee,
                recipient : msg.sender, 
                deadline : block.timestamp,
                amountOut : amountOut,
                amountInMaximum : amountInMaximum,
                sqrtPriceLimitX96 : 0
        });
        amountIn = swapRouter.exactOutputSingle(params);

        if(amountIn > amountInMaximum) {
            TransferHelper.safeApprove(ETH, address(swapRouter), 0);
            TransferHelper.safeTransfer(ETH, msg.sender, amountInMaximum - amountIn);
        }
    }
}
