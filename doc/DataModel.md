# Data Model of the Farm Game

## Data types

| Type        | Property       | Type                            | Description                                        |
| ----------- | -------------- | ------------------------------- | -------------------------------------------------- |
| `GameState` |                |                                 | The overall game state                             |
|             | `crops`        | `[Crop]`                        | A list of registered crops                         |
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
| `CropId`    |                | `Nat`                           | (Type aliast) An incremental ID                    |
| `CropPhase` |                |                                 | One growing phase of certain crop                  |
|             | `name`         | `Text`                          | Name of the phase (in Chinese)                     |
|             | `image`        | `Text`                          | The URL of the image of the growing phase          |
|             | `period`       | `Nat`                           | The period of the growing phase in seconds         |
| `Market`    |                |                                 | The market place to trade seeds and products       |
|             | `cropPrices`   | `[(Nat, Nat)]`                  | A list of crop (product price, seed price)         |
| `Player`    |                |                                 | The state of a given player                        |
|             | `name`         | `Text`                          | The name of the player                             |
|             | `avatar`       | `Text`                          | The URL of the avatar of the player                |
|             | `farmLevel`    | `Nat`                           | The level of the farm, which decides the size      |
|             | `plots`        | `[Plot]`                        | The plots ownedby the player                       |
| `Inventory` |                |                                 | The inventory of a player                          |
|             | `tokens`       | `Nat`                           | The number of tokens hold by the player            |
|             | `crops`        | `[(Nat, Nat)]`                  | The (products, seeds) of crops owned by the player |
| `Plot`      |                |                                 | A square field to plant crops                      |
|             | `cropId`       | `CropId`                        | The ID of the planted crop, `null` for empty plot  |
|             | `timestamp`    | `Time`                          | The timestamp of the most recent crop change       |

## API

### Roles

| Role        | Perm Level | Description                                               |
| ----------- | ---------- | --------------------------------------------------------- |
| Player      | 0          | Ordinary player                                           |
| Game master | 1          | To tune the parameters, and to grant other game masters   |
| Owner       | 2          | The all mighty super user, who deployed the game canister |

### Error handling

The output of all APIs are supposed to have `Result<Out, Text>` type. They would return a `Text` message on error cases.
We would omit the error message in the following API declarations.

### Game Master Management

| Query | API                 | Input Type      | Output Type     | Minimal Role | Description                  |
| ----- | ------------------- | --------------- | --------------- | ------------ | ---------------------------- |
|       | `addGameMasters`    | `([Principal])` | `()`            | Game master  | Add a set of game masters    |
|       | `resignGameMaster`  | `()`            | `()`            | Game master  | Resign as a game master      |
|       | `removeGameMasters` | `([Principal])` | `()`            | Owner        | Remove a set of game masters |
| query | `listGameMasters`   | `()`            | `([Principal])` | Owner        | Remove a set of game masters |

### Crop Management

| Query | API          | Input Type       | Output Type | Minimal Role | Description              |
| ----- | ------------ | ---------------- | ----------- | ------------ | ------------------------ |
|       | `addCrop`    | `(Crop)`         | `CropId`    | Game master  | Add a new type of crop   |
|       | `updateCrop` | `(CropId, Crop)` | `()`        | Game master  | Update a registered crop |
| query | `getCrops`   | `CropId`         | `[Crop]`    | Player       | Get information          |

### Market Management

| Query | API            | Input Type             | Output Type    | Minimal Role | Description                              |
| ----- | -------------- | ---------------------- | -------------- | ------------ | ---------------------------------------- |
|       | `updatePrices` | `(CropId, (Nat, Nat))` | `()`           | Game master  | Update the product and seed price        |
| query | `getPrices`    | `()`                   | `[(Nat, Nat)]` | Player       | Get the crop (product price, seed price) |

### Trade

| Query | API         | Input Type                    | Output Type           | Minimal Role | Description                                           |
| ----- | ----------- | ----------------------------- | --------------------- | ------------ | ----------------------------------------------------- |
|       | `buy`       | `([(CropId, Nat, Nat)], Nat)` | `Nat`                 | Player       | Buy products and seeds of crops at certain price      |
|       | `sell`      | `([(CropId, Nat, Nat)], Nat)` | `Nat`                 | Player       | Sell products and seeds of crops at certain price     |
| query | `inventory` | `()`                          | `([(Nat, Nat)], Nat)` | Player       | Get the (products, seeds), and tokens owned by player |

### Farming

| Query | API       | Input Type          | Output Type            | Minimal Role | Description                                                  |
| ----- | --------- | ------------------- | ---------------------- | ------------ | ------------------------------------------------------------ |
|       | `upgrade` | `()`                | `(Nat, Nat)`           | Player       | Upgrade the farm, return the new height and width            |
|       | `plant`   | `([(Nat, CropId)])` | `()`                   | Player       | Plant seeds at given plots                                   |
|       | `harvest` | `([Nat])`           | `[(CropId, Nat, Nat)]` | Player       | Harvest at given plots, return the gained products and seeds |

### Visiting

| Query | API           | Input Type    | Output Type | Minimal Role | Description                      |
| ----- | ------------- | ------------- | ----------- | ------------ | -------------------------------- |
| query | `playerState` | `(Principal)` | `Player`    | Player       | Get the public state of a player |
