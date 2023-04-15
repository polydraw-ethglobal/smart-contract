# PolyDraw.sol

## Function

### Merchant function

#### function listPhysicalPrizeGame

```function listPhysicalPrizeGame(uint _numPrizeTypes, uint _totalItems, uint[] memory _prizeCount, string[] memory _prizeInfo, uint _price) ```

- parameters:

|name|type|description|
|:--|:--|:----|
|_numPrizeTypes|uint|獎賞類型總數, ex.共有A賞,B賞,C賞, 代3|
|_totalItems|uint|全部獎賞總數, ex.A賞1個,B賞2個,C賞3個, 代6|
|_prizeCount|uint[]|每個獎賞類型的數量, ex.A賞1個,B賞2個,C賞3個, 代[1,2,3]|
|_prizeInfo|string[]|每個獎賞類型的CID, ex.['a的CID','b的CID','c的CID']|
|_price|uint|每次抽獎的價格, 單位: wei|

### Player function

#### playPhysicalPrizeGame

```playPhysicalPrizeGame(uint gameId, uint8 playRounds)```

- parameters:

|name|type|description|
|:--|:--|:----|
|value|主幣|需要大於 price * playRounds|
|gameId|uint|實體獎品遊戲的編號|
|playRounds|uint|抽獎次數, 需要設上限, 否則可能導致超過subscriber可用gas上限|

