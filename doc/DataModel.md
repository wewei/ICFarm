# Data Model of the Farm Game

## Data types

| Type        | Property       | Type                            | Description                                        |
| ----------- | -------------- | ------------------------------- | -------------------------------------------------- |
| `GameState` |                |                                 | The overall game state                             |
|             | `crops`        | `TrieMap<Nat, Crop>`            | A list of registered crops                         |
|             | `plots`        | `TrieMap<Nat, Plot>`            | A list of plots                                    |
|             | `players`      | `TrieMap<Principal, Player>`    | A map from the principal to the player             |
|             | `inventories`  | `TrieMap<Principal, Inventory>` | A map from the principal to the player's inventory |
|             | `market`       | `Market`                        | The market place                                   |
|             | `gameMasters`  | `TrieSet<Principal>`            | A set of game master                               |
| `Crop`      |                |                                 | Represents a registered crop type                  |
|             | `productName`  | `Text`                          | The name of the products (in Chinese)              |
|             | `productImage` | `Text`                          | The URL of the image of the products               |
|             | `productRange` | `(Nat, Nat)`                    | The range of expected quantity of products         |
|             | `productPrice` | `Nat`                           | The default price of the products                  |
|             | `seedName`     | `Text`                          | The name of the seed in Chinese                    |
|             | `seedImage`    | `Text`                          | The URL of the image of seeds                      |
|             | `seedRange`    | `(Nat, Nat)`                    | The range of expected quantity of seeds            |
|             | `seedPrice`    | `Nat`                           | The default price of the seeds                     |
|             | `phases`       | `[CropPhase]`                   | A list of growing phases of the crop               |
| `CropPhase` |                |                                 | One growing phase of certain crop                  |
|             | `name`         | `Text`                          | Name of the phase (in Chinese)                     |
|             | `image`        | `Text`                          | The URL of the image of the growing phase          |
|             | `period`       | `Nat`                           | The period of the growing phase in seconds         |
| `Market`    |                |                                 | The market place to trade seeds and products       |
|             | `cropPrices`   | `[(Nat, Nat)]`                  | A list of crop (product price, seed price)         |
| `Player`    |                |                                 | The state of a given player                        |
|             | `name`         | `Text`                          | The name of the player                             |
|             | `avatar`       | `Text`                          | The URL of the avatar of the player                |
|             | `plotIds`      | `[Nat]`                         | The ID of the plots ownedby the player             |
| `Inventory` |                |                                 | The inventory of a player                          |
|             | `tokens`       | `Nat`                           | The number of tokens hold by the player            |
|             | `crops`        | `[(Nat, Nat)]`                  | The (products, seeds) of crops owned by the player |
| `Plot`      |                |                                 | A square field to plant crops                      |
|             | `cropId`       | `?Nat`                          | The ID of the planted crop, `null` for empty plot  |
|             | `timestamp`    | `Time`                          | The timestamp of the most recent crop change       |

## API

### Roles

| Role        | Perm Level | Description                                             |
| ----------- | ---------- | ------------------------------------------------------- |
| Player      | 0          | Ordinary player                                         |
| Game master | 1          | To tune the parameters, and to grant other game masters |
| Owner       | 2          | The all mighty super user                               |

### Error handling

The output of all APIs are supposed to have `Result<Out, Text>` type. They would return a `Text` message on error cases.
We would omit the error message in the following API declarations.

### Authorization

| API                 | Role/Parameter | Type          | Description                                  |
| ------------------- | -------------- | ------------- | -------------------------------------------- |
| `claimOwner`        | Anyone         | _Update_      | Claim to be owner of the game                |
|                     | `->`           | `Principal`   | The principal of the game owner              |
| `transferOwner`     | Owner          | _Update_      | Transfer the game owner role to other player |
|                     | `userId`       | `Principal`   | The principal of the new owner               |
|                     | `->`           | `Principal`   | The principal of the game owner              |
| `addGameMasters`    | Game Master    | _Update_      | Add a set of game masters                    |
|                     | `userIds`      | `[Principal]` | The principals of the new game masters       |
|                     | `->`           | `[Principal]` | The principals of newly added game masters   |
| `resignGameMaster`  | Game Master    | _Update_      | Resign as a game master                      |
|                     | `->`           | `()`          |                                              |
| `removeGameMasters` | Owner          | _Update_      | Remove a set of game masters                 |
|                     | `userIds`      | `[Principal]` | The principals of the removing game masters  |
|                     | `->`           | `[Principal]` | The principals of removed game masters       |
| `listGameMasters`   | Game Master    | _Query_       | List the game masters                        |
|                     | `->`           | `[Principal]` | The principals of the game masters           |

### Crop Management

| API          | Role/Parameter | Type     | Description                       |
| ------------ | -------------- | -------- | --------------------------------- |
| `addCrop`    | Game Master    | _Update_ | Add a new type of crop            |
|              | `crop`         | `Crop`   | The crop descriptor               |
|              | `->`           | `Nat`    | The ID of the new crop type       |
| `updateCrop` | Game Master    | _Update_ | Update a registered crop          |
|              | `cropId`       | `Nat`    | The ID of the crop type to update |
|              | `crop`         | `Crop`   | The updated descriptor            |
|              | `->`           | `()`     |                                   |
| `getCrops`   | Player         | _Query_  | Get information of all crop types |
|              | `->`           | `[Crop]` | The crop descriptors              |

### Market Management

| API            | Role/Parameter | Type           | Description                           |
| -------------- | -------------- | -------------- | ------------------------------------- |
| `updatePrices` | Game Master    | _Update_       | Update the product and seed price     |
|                | `cropId`       | `Nat`          | The ID of the crop to update          |
|                | `prices`       | `(Nat, Nat)`   | The product and seed prices in tokens |
|                | `->`           | `()`           |                                       |
| `getPrices`    | Player         | _Query_        | Get the prices of all corps           |
|                | `->`           | `[(Nat, Nat)]` | The product and seed prices           |

### Trade

| API         | Role/Parameter | Type                  | Description                                                          |
| ----------- | -------------- | --------------------- | -------------------------------------------------------------------- |
| `buy`       | Player         | _Update_              | Buy products and seeds of crops at certain price                     |
|             | `list`         | `[(Nat, Nat, Nat)]`   | The shopping list of `(cropId, productCount, seedCount)` tuples      |
|             | `tokens`       | `Nat`                 | The tokens willing to pay (there may be price changes)               |
|             | `->`           | `Nat`                 | The tokens paid (no more than the `tokens` parameter)                |
| `sell`      | Player         | _Update_              | Sell products and seeds of crops at certain price                    |
|             | `list`         | `[(Nat, Nat, Nat)]`   | The selling list of `(cropId, productCount, seedCount)` tuples       |
|             | `tokens`       | `Nat`                 | The tokens expected to gain (there may be price changes)             |
|             | `->`           | `Nat`                 | The tokens gained (no less than the `tokens` parameter)              |
| `inventory` | Player         | _Query_               | Get the inventory of the caller                                      |
|             | `->`           | `([(Nat, Nat)], Nat)` | The `(productCount, seedCount)` tuples for each crop, and the tokens |

### Farming

| API       | Role/Parameter | Type                     | Description                                                             |
| --------- | -------------- | ------------------------ | ----------------------------------------------------------------------- |
| `plant`   | Player         | _Update_                 | Plant seeds in plots                                                    |
|           | `tasks`        | `[(Nat, Nat)]`           | Array of `(plotId, cropId)` tuples                                      |
|           | `->`           | `[(Nat, Nat)]`           | The planted plots                                                       |
| `harvest` | Player         | _Update_                 | Harvest from plots                                                      |
|           | `plotIds`      | `[Nat]`                  | The IDs of the plots to harvest                                         |
|           | `->`           | `[(Nat, Nat, Nat, Nat)]` | The gains in form of `(plotId, cropId, productCount, seedCount)` tuples |
| `plots`   | Player         | _Query_                  | Query the state of plots                                                |
|           | `plotIds`      | `[Nat]`                  | The IDs of the plots to query                                           |
|           | `->`           | `[(Nat, Plot)]`          | The plot states in form of `(plotId, Plot)` tuples                      |

### Visiting

| API           | Role/Parameter | Type        | Description                          |
| ------------- | -------------- | ----------- | ------------------------------------ |
| `playerState` | Player         | _Query_     | Get the public state of a player     |
|               | `userId`       | `Principal` | The principal of the player to visit |
|               | `->`           | `Play`      | The information of the player        |
