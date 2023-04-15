# Contracts 
- Mumbai(80001)

  - VRFv2Consumer: 亂數產生器

    - [0x046550482B6bfDBfF8d129b81e2A36585ce68735](https://mumbai.polygonscan.com/address/0x046550482B6bfDBfF8d129b81e2A36585ce68735)
    - subscribe: 4203
    - owner: 0xF16Aa7E201651e7eAd5fDd010a5a14589E220826 (最後需改為一番賞合約)
  - IchibanDAO: 一番賞合約
    - [0xD4859e124557689d2cca2A060D43Edc305DFCbBe](https://mumbai.polygonscan.com/address/0xD4859e124557689d2cca2A060D43Edc305DFCbBe)
    - subscribe: 4203

## Polygon ID Wallet setup

1. Download the Polygon ID mobile app on the [Google Play](https://play.google.com/store/apps/details?id=com.polygonid.wallet) or [Apple app store](https://apps.apple.com/us/app/polygon-id/id1629870183)

2. Open the app and set a pin for security

3. Issue yourself a Credential of type `Kyc Age Credential Merklized` from the [Polygon ID Issuer Sandbox](https://issuer-v2.polygonid.me/)

## Deploy smart contract

1. Deploy and verify
  `npx hardhat run scripts/IchibanDAO/deploy.js`

2. update contract address in set-request.js

3. send zk-request
   `npx hardhat run scripts/IchibanDAO/set-request.js`

4. Add contract address to VRF consumer

5. Verify seller by using polygon ID issuer
   

## Operation Process
