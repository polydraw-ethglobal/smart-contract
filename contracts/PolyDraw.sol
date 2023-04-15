// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interfaces/IPUSHCommInterface.sol";
import "./verifiers/ZKPVerifier.sol";

contract PolyDraw is ZKPVerifier, VRFConsumerBaseV2, ReentrancyGuard{
    event RequestSent(uint requestId, uint8 numWords);
    event RequestFulfilled(uint requestId, uint[] randomWords);
    event PlayPhysicalPrizeGame(
        uint indexed gameId,
        address indexed player,
        uint requestId,
        uint8 playRounds,
        uint pendingPrizeCount
    );
    event ListPhysicalPrizeGame(
        address indexed owner,
        uint indexed gameId,
        uint[] remainPrizeCount,
        string[] prizeInfo,
        uint price
    );
    event OwnedPrizesFulfilled(
        uint indexed gameId,
        address indexed player,
        uint[] ownedPrizes
    );

    enum PrizeType {A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P}
    enum GameType {PhysicalPrize, OnChainPrize, UnmintedNFT}

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint[] randomWords;
    }

    struct OrderBook {
        address player;
        uint gameType; // 0: PhysicalPrizeGame, 1: OnChainPrize, 2: UnmintedNFT
        uint gameId;
    }

    struct PhysicalPrizeGame {
        address gameOwner;
        uint prizeTypesCount;
        uint pendingPrizeCount;
        uint remainingPrizeCount;
        uint[] prizeRemain;
        string[] prizeInfo;
        uint price;
    }

    PhysicalPrizeGame[] public physicalPrizeGames;

    mapping(uint => OrderBook) orderBooks; // requestId => order book
    mapping(uint => mapping(address => uint[])) ownedPrizes; // gameId -> owner -> prizes
    mapping(uint => RequestStatus) public s_requests; 
    mapping(uint256 => address) public zkpIdToAddress;
    mapping(address => uint256) public zkpAddressToId;

    address public EPNS_COMM_ADDRESS = 0xb3971BCef2D791bc4027BbfedFb47319A4AAaaAa;
    address public EPNS_CHANNEL_ADDRESS = 0xB926660866633fe4D83E94Dd09E9e775999722b4;

    VRFCoordinatorV2Interface COORDINATOR;

    uint64 s_subscriptionId;
    uint[] public requestIds;
    uint public lastRequestId;
    bytes32 keyHash;
    uint32 callbackGasLimit = 2500000; // max callback gas limit 
    uint16 requestConfirmations = 3;
    // can customize request id 
    uint64 public constant TRANSFER_REQUEST_ID = 1;

    constructor(
        address _vrfCoordinator, 
        bytes32 _keyHash, 
        uint64 _subscriptionId
    )
        VRFConsumerBaseV2(_vrfCoordinator)
    {
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        keyHash = _keyHash;
        s_subscriptionId = _subscriptionId;
    }

    /***************************/
    /****  Admin Functions  ****/
    /***************************/

    function setCallbackGasLimit(uint32 _limit) external onlyOwner {
        callbackGasLimit = _limit;
    }

    /****************************/
    /***  Merchant Functions  ***/
    /****************************/

    function listPhysicalPrizeGame(
        uint _numPrizeTypes,
        uint _totalItems,
        uint[] memory _prizeCount,
        string[] memory _prizeInfo,
        uint _price
    ) external {
        require(
            proofs[msg.sender][TRANSFER_REQUEST_ID] == true,
            "only identities who provided proof are allowed to list game"
        );
        require(_prizeCount.length == _numPrizeTypes, "Unmatched prize count");
        require(_prizeInfo.length == _numPrizeTypes, "Unmatched prize info");
        uint totalItems;
        for (uint i = 0; i < _numPrizeTypes; i++) {
            totalItems += _prizeCount[i];
        }
        require(totalItems == _totalItems, "Unmatched total items");

        PhysicalPrizeGame memory newPhysicalPrizeGame = PhysicalPrizeGame(
            msg.sender,
            _numPrizeTypes,
            _totalItems,
            _totalItems,
            _prizeCount,
            _prizeInfo,
            _price
        );
        physicalPrizeGames.push(newPhysicalPrizeGame);
        emit ListPhysicalPrizeGame(msg.sender,physicalPrizeGames.length, _prizeCount, _prizeInfo, _price);
    }

    /****************************/
    /****  Player Functions  ****/
    /****************************/

    function playPhysicalPrizeGame(uint gameId, uint8 playRounds)
        external 
        payable 
        nonReentrant 
    {
        PhysicalPrizeGame storage physicalPrizeGame = physicalPrizeGames[gameId];
        uint totalCost = physicalPrizeGame.price * playRounds;
        require(msg.value >= totalCost, "Insufficient funds");
        require(playRounds <= physicalPrizeGame.pendingPrizeCount, "Insufficient prizes");

        OrderBook memory newOrder = OrderBook(
            msg.sender,
            0,
            gameId
        );
        uint requestId = requestRandomWords(playRounds);
        orderBooks[requestId] = newOrder;
        physicalPrizeGame.pendingPrizeCount--;

        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }

        emit PlayPhysicalPrizeGame(gameId, msg.sender, requestId, playRounds, physicalPrizeGame.pendingPrizeCount);
    }

    /****************************/
    /***  Internal Functions  ***/
    /****************************/

    // todo: 抽獎付款後跳到這個function
    // 要記得把合約地址加入consumer!!!
    function requestRandomWords(uint8 numWords)
        internal
        returns (uint requestId)
    {
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    // ZKP functions

    function _beforeProofSubmit(
        uint64, /* requestId */
        uint256[] memory inputs,
        ICircuitValidator validator
    ) internal view override {
        // check that challenge input is address of sender
        address addr = GenesisUtils.int256ToAddress(
            inputs[validator.getChallengeInputIndex()]
        );
        // this is linking between msg.sender and
        require(
            _msgSender() == addr,
            "address in proof is not a sender address"
        );
    }

    function _afterProofSubmit(
        uint64 requestId,
        uint256[] memory inputs,
        ICircuitValidator validator
    ) internal override {
        require(
            requestId == TRANSFER_REQUEST_ID && zkpAddressToId[_msgSender()] == 0,
            "proof can not be submitted more than once"
        );

        // address didn't get airdrop tokens
        uint256 id = inputs[validator.getChallengeInputIndex()];
        // additional check didn't get airdrop tokens before
        if (zkpIdToAddress[id] == address(0)) {
            zkpAddressToId[_msgSender()] = id;
            zkpIdToAddress[id] = _msgSender();
        }
    }

    // todo: 選中隨機數後，分派獎勵的邏輯寫在這裡
    function fulfillRandomWords(
        uint _requestId,
        uint[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;

        OrderBook memory orderbook = orderBooks[_requestId];
        PhysicalPrizeGame storage physicalPrizeGame = 
            physicalPrizeGames[orderbook.gameId];
        uint remainingPrizeCount = physicalPrizeGame.remainingPrizeCount;
        for (uint i = 0; i < _randomWords.length; i++) {
            uint r = _randomWords[i] % remainingPrizeCount;
            uint index;
            for (uint j = 0; j < physicalPrizeGame.prizeRemain.length; j++) {
                if (physicalPrizeGame.prizeRemain[j] > r) {
                    index = j;
                    break;
                } else {
                    r -= physicalPrizeGame.prizeRemain[j];
                }
            }
            
            ownedPrizes[orderbook.gameId][orderbook.player].push(index);
            physicalPrizeGame.remainingPrizeCount--;
            physicalPrizeGame.prizeRemain[index]--;
        }

        sendNotification(orderbook.gameId, orderbook.player);

        emit RequestFulfilled(_requestId, _randomWords);
        emit OwnedPrizesFulfilled(
            orderbook.gameId, 
            orderbook.player, 
            ownedPrizes[orderbook.gameId][orderbook.player]
        );
    }

    /**************************/
    /***  Status Functions  ***/
    /**************************/

    function getRequestStatus(
        uint _requestId
    ) external view returns (bool fulfilled, uint[] memory randomWords) {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }

    function getPhysicalPrizeGamePrizeRemain(uint gameId) 
        external 
        view 
        returns (uint[] memory) 
    {
        PhysicalPrizeGame memory physicalPrizeGame = 
            physicalPrizeGames[gameId];
        return physicalPrizeGame.prizeRemain;
    }

    function getPhysicalPrizeGamePrizeInfo(uint gameId) 
        external 
        view 
        returns (string[] memory) 
    {
        PhysicalPrizeGame memory physicalPrizeGame = 
            physicalPrizeGames[gameId];
        return physicalPrizeGame.prizeInfo;
    }

    function getOwnedPrizes(uint gameId, address player) 
        external
        view
        returns (uint[] memory) 
    {
        return ownedPrizes[gameId][player];
    }

    /***************************/
    /***  Utility Functions  ***/
    /***************************/

    function sendNotification(uint gameId, address winner) internal
    {

         IPUSHCommInterface(EPNS_COMM_ADDRESS).sendNotification(
            EPNS_CHANNEL_ADDRESS, // from channel
            address(this), // to recipient, put address(this) in case you want Broadcast or Subset. For Targetted put the address to which you want to send
            bytes(
                string(
                    // We are passing identity here: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/identity/payload-identity-implementations
                    abi.encodePacked(
                        "0", // this is notification identity: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/identity/payload-identity-implementations
                        "+", // segregator
                        "1", // this is payload type: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/payload (1, 3 or 4) = (Broadcast, targetted or subset)
                        "+", // segregator
                        "Prize Alert", // this is notificaiton title
                        "+", // segregator
                        "Hooray! ", // notification body
                        string.concat(
                            Strings.toString(gameId),
                            addressToString(winner)
                        ), // notification body
                        " sent "
                    )
                )
            )
         );
    }

    function addressToString(address _address) internal pure returns(string memory) {
        bytes32 _bytes = bytes32(uint(uint160(_address)));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _string = new bytes(42);
        _string[0] = '0';
        _string[1] = 'x';
        for(uint i = 0; i < 20; i++) {
            _string[2+i*2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _string[3+i*2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }
        return string(_string);
    }
}
