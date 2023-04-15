const hre = require("hardhat");
const execSync = require("child_process").execSync;

async function main() {
  const networkName = hre.network.name;
  if (networkName == "mumbai") {
    const IchibanDAO = await hre.ethers.getContractFactory("IchibanDAO");
    const VRFCoordinator = "0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed";
    const KeyHash =
      "0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f";
    const SubscriptionId = 4203;
    const ichibanDAO = await IchibanDAO.deploy(VRFCoordinator, KeyHash, SubscriptionId);
    await ichibanDAO.deployed();
    console.log(`Deploy IchibanDAO at ${ichibanDAO.address}`);

    let output = execSync(
        `npx hardhat verify --network ${networkName} ` +
          `--contract contracts/IchibanDAO.sol:IchibanDAO ` +
          `${ichibanDAO.address} ${VRFCoordinator} ${KeyHash} ${SubscriptionId}`,
        { encoding: "utf-8" }
      );
    console.log("Output was:\n", output);
  } else if (networkName == "polygon") {d
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
