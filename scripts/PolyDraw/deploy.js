const hre = require("hardhat");
const execSync = require("child_process").execSync;

async function main() {
  const networkName = hre.network.name;
  if (networkName == "mumbai") {
    const spongePoseidonLib = "0x12d8C87A61dAa6DD31d8196187cFa37d1C647153";
    const poseidon6Lib = "0xb588b8f07012Dc958aa90EFc7d3CF943057F17d7";

    const PolyDraw = await hre.ethers.getContractFactory("PolyDraw", {
      libraries: {
        SpongePoseidon: spongePoseidonLib,
        PoseidonUnit6L: poseidon6Lib,
      },
    });

    const VRFCoordinator = "0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed";
    const KeyHash =
      "0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f";
    const SubscriptionId = 4203;

    const polyDraw = await PolyDraw.deploy(
      VRFCoordinator,
      KeyHash,
      SubscriptionId
    );
    
    await polyDraw.deployed();
    console.log(`Deploy PolyDraw at ${polyDraw.address}`);

    let output = execSync(
      `npx hardhat verify --network ${networkName} ` +
        `--contract contracts/PolyDraw.sol:PolyDraw ` +
        `${polyDraw.address} ${VRFCoordinator} ${KeyHash} ${SubscriptionId}`,
      { encoding: "utf-8" }
    );
    console.log("Output was:\n", output);
  } else if (networkName == "polygon") {
    d;
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
