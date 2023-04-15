const { sign } = require("crypto");
const { ethers } = require("hardhat");
const keccak256 = require("keccak256")
require('dotenv').config({ path: "./.env" })

async function signClaim(pk, contract, gameId, prizeType, playerAddress, nonce, expireTime){
    // const abiCoder = await new ethers.utils.AbiCoder();
    // wallet = await new ethers.Wallet(pk)
    // let hex = abiCoder.encode(
    //     ['address','address','uint256','uint256','uint256'],
    //     [contract,sender,amount,nonce,time]
    // );

    let wallet = new ethers.Wallet(pk);
    let hex = await ethers.utils.solidityKeccak256(
        ['address','uint256','uint256','address','uint256','uint256'],
        [contract,gameId,prizeType,playerAddress,nonce,expireTime]
    );
    
    // console.log("ethers:")
    // console.log(hex)
    // console.log(ethers.utils.arrayify(hex))
    let sig = await wallet.signMessage(ethers.utils.arrayify(hex));
    console.log("sig:")
    console.log(sig)
    return sig
}

module.exports = {
    signClaim
}


// pk = process.env.TEST_PK
// contract = "0xeaFaA996c40d8D3300d0505617a594482c331D5E"
// gameId = 1
// prizeType = 0
// playerAddress = "0xF16Aa7E201651e7eAd5fDd010a5a14589E220826"
// nonce = 4
// expireTime = 1000000000000
// signClaim(pk, contract, gameId, prizeType, playerAddress, nonce, expireTime)