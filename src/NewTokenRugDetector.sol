// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "./interfaces/ITrap.sol";

interface IUniswapV2Pair {
    function getReserves() external view returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );
}

/// @title NewTokenRugDetector (Drosera-compatible)
/// @notice Set PAIR constant to the UniswapV2-style pair to monitor before compiling.
contract NewTokenRugDetector is ITrap {
    // <<< EDIT THIS: set to the pair you want to monitor (checksummed) >>>
    address public constant PAIR = 0x0000000000000000000000000000000000000000;

    /// Drop threshold in basis points (e.g. 5000 = 50%)
    uint256 public constant THRESHOLD_BPS = 5000;

    /// Number of blocks in which a large drop is considered a "new-token rug"
    uint256 public constant LAUNCH_WINDOW_BLOCKS = 500;

    /// Collect returns (totalLiquidity, blockNumber)
    function collect() external view override returns (bytes memory) {
        // Safe staticcall to avoid reverting if PAIR has no code
        (bool ok, bytes memory returnData) = PAIR.staticcall(
            abi.encodeWithSelector(IUniswapV2Pair.getReserves.selector)
        );

        if (!ok || returnData.length == 0) {
            // If the call fails, return zero liquidity so collect never reverts
            return abi.encode(uint256(0), block.number);
        }

        (uint112 r0, uint112 r1, ) = abi.decode(returnData, (uint112, uint112, uint32));
        uint256 total = uint256(r0) + uint256(r1);
        return abi.encode(total, block.number);
    }

    /// shouldRespond expects an array of bytes where each element is abi.encode(totalLiquidity, blockNumber)
    /// data[0] = newest, data[n-1] = oldest
    function shouldRespond(bytes[] calldata data)
        external
        pure
        override
        returns (bool, bytes memory)
    {
        uint256 len = data.length;
        if (len < 2) return (false, "");

        // Latest = data[0], Oldest = data[len-1]
        (uint256 latestLiquidity, uint256 latestBlock) = abi.decode(data[0], (uint256, uint256));
        (uint256 oldestLiquidity, uint256 oldestBlock) = abi.decode(data[len - 1], (uint256, uint256));

        if (oldestLiquidity == 0) return (false, "");
        if (latestLiquidity >= oldestLiquidity) return (false, "");

        uint256 diff = oldestLiquidity - latestLiquidity;
        uint256 dropBps = (diff * 10000) / oldestLiquidity;

        // Trigger only if drop >= threshold AND the time window between oldest/newest <= LAUNCH_WINDOW_BLOCKS
        if (dropBps >= THRESHOLD_BPS && (latestBlock - oldestBlock) <= LAUNCH_WINDOW_BLOCKS) {
            return (true, abi.encode(latestLiquidity, oldestLiquidity, dropBps));
        }
        return (false, "");
    }
}
