// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VerifyHash is Ownable {
    using ECDSA for bytes32;

    mapping(address => uint256) public _usedNonces;

    function matchAddresSigner(address player, bytes32 hash, bytes memory signature)
        private
        pure
        returns (bool)
    {
        return player == hash.recover(signature);
    }
    
    function verifyClaim(
        uint gameId,
        uint prizeType,
        address playerAddress,
        uint nonce,
        uint expireTime,
        bytes memory signature
    ) internal returns (bool) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(abi.encodePacked(
                    address(this),
                    gameId,
                    prizeType,
                    playerAddress,
                    nonce,
                    expireTime
                ))
            )
        );
        require(matchAddresSigner(playerAddress, hash, signature), "VerifyHash: signature not correct"); 
        require(nonce > _usedNonces[playerAddress], "VerifyHash: HASH_USED");
        _usedNonces[playerAddress] = nonce;
        return true;
    }

    function getUsedNonces(address player) public view returns (uint) {
        return _usedNonces[player];
    }

}