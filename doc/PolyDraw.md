# PolyDraw.sol

## Function

### Merchant function

#### function listPhysicalPrizeGame

```function listPhysicalPrizeGame(string memory _gameTitle, string memory _gameIntro, uint _numPrizeTypes, uint _totalItems, uint[] memory _prizeCount, string[] memory _prizeInfo, uint _price, string memory _gameCover) ```

- parameters:

|name|type|description|
|:--|:--|:----|
|_gameTitle|string|遊戲名稱|
|_gameIntro|string|遊戲介紹|
|_numPrizeTypes|uint|獎賞類型總數, ex.共有A賞,B賞,C賞, 代3|
|_totalItems|uint|全部獎賞總數, ex.A賞1個,B賞2個,C賞3個, 代6|
|_prizeCount|uint[]|每個獎賞類型的數量, ex.A賞1個,B賞2個,C賞3個, 代[1,2,3]|
|_prizeInfo|string[]|每個獎賞類型的CID, ex.['a的CID','b的CID','c的CID']|
|_price|uint|每次抽獎的價格, 單位: wei|
|_gameCover|string|遊戲封面圖CID|

- event:
    
```event ListPhysicalPrizeGame(address indexed owner, uint indexed gameId, string gameTitle, string gameIntro, uint[] remainPrizeCount, string[] prizeInfo, uint price, string gameCover);```



### Player function

#### playPhysicalPrizeGame

```playPhysicalPrizeGame(uint gameId, uint8 playRounds)```

- parameters:

|name|type|description|
|:--|:--|:----|
|value|主幣|需要大於 price * playRounds|
|gameId|uint|實體獎品遊戲的編號|
|playRounds|uint|抽獎次數, 需要設上限, 否則可能導致超過subscriber可用gas上限|

- event:

```event PlayPhysicalPrizeGame(uint indexed gameId, address indexed player, uint requestId, uint8 playRounds, uint pendingPrizeCount);```


#### claimPhysicalPrize

```claimPhysicalPrize(uint gameId, uint8 prizeType, address prizeOwner, uint nonce, uint expireTime, bytes memory signature)```

- parameters:

|name|type|description|
|:--|:--|:----|
|gameId|uint|遊戲編號|
|prizeType|uint|領獎類型|
|prizeOwner|address|領獎者|
|nonce|uint|計數|
|expireTime|uint|簽名到期時間|
|signature|bytes|簽名|

- event:
  
```event ClaimPrize( uint indexed gameId, address indexed prizeOwner, uint claimPrizeType);```

