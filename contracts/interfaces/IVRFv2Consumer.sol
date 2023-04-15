// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IVRFv2Consumer {
    function requestRandomWords() external returns (uint256);

    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool, uint256[] memory);

    function transferOwnership(address to) external;

    function acceptOwnership() external;
}
