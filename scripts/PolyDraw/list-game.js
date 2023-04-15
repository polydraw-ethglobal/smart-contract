const hre = require("hardhat");
require('dotenv').config({ path: "./.env" })
const { signClaim } = require("../testSign");

const PolyDrawAddress = "0xEA50E20C35D9DbB776610635a1cdCF7DeCFA13b1";
let gameId = 0;
let playRounds = 20;
let pk = process.env.TEST_PK

async function main() {
  let player = new ethers.Wallet(pk, hre.ethers.provider);
  let PolyDraw = await hre.ethers.getContractAt("PolyDraw", PolyDrawAddress);

  try {
    const result = await PolyDraw.connect(player).superInterface();
    console.log("Request set: ", result);
  } catch (e) {
    console.log("error: ", e);
  }
  
  try {
    const bigNumber = ethers.BigNumber.from("10000000000000000");
    const costNumber = ethers.BigNumber.from("200000000000000000");
    const result = await PolyDraw.connect(player).listPhysicalPrizeGame(
        "titleee", "introoo", 5, 100, [10,15,20,25,30], ['QmeR42Sw6Gemx88BxwmXm8erBMPFmGB5fT6eh694UwNxjv','QmeR42Sw6Gemx88BxwmXm8erBMPFmGB5fT6eh694UwNxjv','QmeR42Sw6Gemx88BxwmXm8erBMPFmGB5fT6eh694UwNxjv','QmeR42Sw6Gemx88BxwmXm8erBMPFmGB5fT6eh694UwNxjv','QmeR42Sw6Gemx88BxwmXm8erBMPFmGB5fT6eh694UwNxjv'], bigNumber, "QmeR42Sw6Gemx88BxwmXm8erBMPFmGB5fT6eh694UwNxjv"
    );
    console.log("Request set: ", result);
  } catch (e) {
    console.log("error: ", e);
  }

  try {
    const result = await PolyDraw.connect(player).playPhysicalPrizeGame(gameId, playRounds, {value:"200000000000000000"});
    console.log("Request set: ", result);
  } catch (e) {
    console.log("error: ", e);
  }

  try {
    let sig = await signClaim(
        pk, PolyDrawAddress, 0, 4,
        "0xF16Aa7E201651e7eAd5fDd010a5a14589E220826", 1, 10000000000
    )
    const result = await PolyDraw.connect(player).claimPhysicalPrize(
        0, 4, "0xF16Aa7E201651e7eAd5fDd010a5a14589E220826", 1, 10000000000, sig
    );
    console.log("Request set: ", result);
  } catch (e) {
    console.log("error: ", e);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
