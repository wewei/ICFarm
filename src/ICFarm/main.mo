import Option "mo:base/Option";
import Result "mo:base/Result";
import TrieSet "mo:base/TrieSet";
import Trie "mo:base/Trie";
import Time "mo:base/Time";
import Array  "mo:base/Array";
import Buffer "mo:base/Buffer";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Func "mo:base/Func";

import Types "Types";
import LL "lambda/Logical";
import LC "lambda/Compare";
import LTS "lambda/TrieSet";
import LT "lambda/Trie";
import LN "lambda/Nat";

actor ICFarm {
  /********************
        Aliases
  ********************/
  // Types
  type Player = Types.Player;
  type Crop = Types.Crop;
  type Plot = Types.Plot;
  type Inventory = Types.Inventory;

  type Map<K, V> = Trie.Trie<K, V>;
  type Set<E> = TrieSet.Set<E>;
  type R<V> = Result.Result<V, Text>;


  // Functions
  let filter = Array.filter;
  let foldLeft = Array.foldLeft;
  let isAnonymous = Principal.isAnonymous;
  let emptyMap = Trie.empty;
  let mapSize = Trie.size;
  let const = Func.const;

  // Consts
  let INIT_PLOTS = 8;
  let INIT_TOKENS = 1000;

  // Error codes
  let ERR_NOT_IMPLEMENTED = "ERR_NOT_IMPLEMENTED";
  let ERR_UNAUTHORIZED = "ERR_UNAUTHORIZED";
  let ERR_INVALID_USER = "ERR_INVALID_USER";
  let ERR_CANNOT_RESIGN = "ERR_CANNOT_RESIGN";
  let ERR_USER_EXISTS = "ERR_USER_EXISTS";
  let ERR_USER_NOT_FOUND = "ERR_USER_NOT_FOUND";
  let ERR_INVALID_CROP = "ERR_INVALID_CROP";
  let ERR_INSUFFICIENT_TOKENS = "ERR_INSUFFICIENT_TOKENS";
  let ERR_PRICE_CHANGED = "ERR_PRICE_CHANGED";

  // State
  stable var owner: Principal = Principal.fromBlob("\04");
  stable var gameMasters: Set<Principal> = TrieSet.empty();
  stable var crops: Map<Nat, Crop> = emptyMap();
  stable var cropPrices: Map<Nat, (Nat, Nat)> = emptyMap();
  stable var plotOwners: Map<Nat, Principal> = emptyMap();
  stable var plots: Map<Nat, Plot> = emptyMap();
  stable var players: Map<Principal, Player> = emptyMap();
  stable var inventories: Map<Principal, Inventory> = emptyMap();

  // Helpers
  private let natMap = LT.forKey<Nat>(Hash.hash, Nat.equal);
  private let userMap = LT.forKey<Principal>(Principal.hash, Principal.equal);

  private let comparePrincipal = LC.Unordered<Principal>(Principal.equal);
  private let principalSet = LTS.forType<Principal>(Principal.hash, Principal.equal);

  private let isGameMaster = principalSet.elementOf(gameMasters);
  private let isOwner = LL.both<Principal>
    (LL.negate(isAnonymous))
    (comparePrincipal.equalTo(owner));
  private let isOwnerOrGameMaster = LL.either<Principal>
    (isOwner)
    (isGameMaster);

  private func allocatePlots(owner: Principal, count: Nat): [Nat] {
    let s = mapSize(plots);
    let newPlots = Array.tabulate<Nat>(count, func (i) = s + i);
    let timestamp = Time.now();
    plotOwners := foldLeft<Nat, Map<Nat, Principal>>(
      newPlots,
      plotOwners,
      natMap.alter<Principal>(const(const(?owner))));
    plots := foldLeft<Nat, Map<Nat, Plot>>(
      newPlots,
      plots,
      natMap.alter<Plot>(const(const(?{ cropId = null; timestamp; }))));
    newPlots
  };

  private func initInventory(userId: Principal): Inventory {
    let inventory = { tokens = INIT_TOKENS; crops = emptyMap() };
    inventories := userMap.putKeyValue<Inventory>(inventories, userId, inventory);
    inventory
  };

  private func priceForList(list: [(Nat, Nat, Nat)]): R<Nat> {
    foldLeft<(Nat, Nat, Nat), R<Nat>>(list, #ok(0), func (t, (cropId, pCount, sCount)) {
      Result.chain<Nat, Nat, Text>(t, func (tk) {
        switch (natMap.getValue(cropPrices, cropId)) {
          case (?(pPrice, sPrice)) { #ok(tk + pPrice * pCount + sPrice * sCount) };
          case (_) { #err(ERR_INVALID_CROP) };
        }
      })
    })
  };


  private func calcCrops(f: (Nat, Nat) -> Nat)
    : (R<Map<Nat, (Nat, Nat)>>, (Nat, Nat, Nat)) -> R<Map<Nat, (Nat, Nat)>> {
    func ( crops, (cropId, pCount, sCount)): R<Map<Nat, (Nat, Nat)>> {
      switch crops {
        case (#err(msg)) { #err(msg) };
        case (#ok(c)) {
          switch (natMap.getValue(c, cropId)) {
            case (?(productCount, seedCount)) {
              #ok(natMap.putKeyValue(c, cropId, (productCount + pCount, seedCount + sCount)))
            };
            case (_) {
              #err(ERR_INVALID_CROP)
            }
          }
        };
      }
    }
  };


  // API

  /********************
      Authorizaton
  ********************/

  public shared query({ caller }) func listGameMasters() : async R<[Principal]> {
    if (isAnonymous(caller)) {
      #err(ERR_UNAUTHORIZED)
    } else {
      #ok(TrieSet.toArray(gameMasters))
    }
  };

  public shared({ caller }) func claimOwner() : async R<Principal> {
    if (isAnonymous(caller) or not isAnonymous(owner)) {
      #err(ERR_UNAUTHORIZED)
    } else {
      owner := caller;
      #ok(caller)
    }
  };

  public shared({ caller }) func transferOwner(userId: Principal): async R<Principal> {
    if (not isOwner(caller)) {
      #err(ERR_UNAUTHORIZED)
    } else if (isAnonymous(userId)) {
      #err(ERR_INVALID_USER)
    } else {
      owner := userId;
      #ok(userId)
    }
  };

  public shared({ caller }) func addGameMasters(userIds: [Principal]) : async R<[Principal]> {
    if (not isOwnerOrGameMaster(caller)) {
      #err(ERR_UNAUTHORIZED)
    } else {
      let newGameMasters: [Principal] = filter(userIds, LL.neither<Principal>(isGameMaster)(isAnonymous));
      gameMasters := foldLeft(newGameMasters, gameMasters, principalSet.addElement);
      #ok(newGameMasters)
    }
  };

  public shared({ caller }) func removeGameMasters(userIds: [Principal]) : async R<[Principal]> {
    if (not isOwner(caller)) {
      #err(ERR_UNAUTHORIZED)
    } else {
      let removingGameMasters: [Principal] = filter(userIds, isGameMaster);
      gameMasters := foldLeft(removingGameMasters, gameMasters, principalSet.delElement);
      #ok(removingGameMasters)
    }
  };

  public shared({ caller }) func resignGameMaster() : async R<()> {
    if (isOwner(caller)) {
      #err(ERR_CANNOT_RESIGN)
    } else if (not isGameMaster(caller)) {
      #err(ERR_UNAUTHORIZED)
    } else {
      gameMasters := principalSet.delElement(gameMasters, caller);
      #ok()
    }
  };

  /********************
     Crop Management
  ********************/

  public shared({ caller }) func addCrop(crop: Crop): async R<Nat> {
    if (not isOwnerOrGameMaster(caller)) {
      #err(ERR_UNAUTHORIZED)
    } else {
      let cropId = mapSize(crops);
      crops := natMap.putKeyValue<Crop>(crops, cropId, crop);
      #ok(cropId)
    }
  };

  public shared({ caller }) func updateCrop(cropId: Nat, crop: Crop): async R<()> {
    if (not isOwnerOrGameMaster(caller)) {
      #err(ERR_UNAUTHORIZED)
    } else if (cropId >= mapSize(crops)) {
      #err(ERR_INVALID_CROP)
    } else {
      crops := natMap.putKeyValue<Crop>(crops, cropId, crop);
      #ok()
    }
  };

  public shared query({ caller }) func getCrops(): async R<[(Nat, Crop)]> {
    #ok(natMap.entries<Crop>(crops))
  };

  /********************
    Market Management
  ********************/

  public shared({ caller }) func updatePrices(cropId: Nat, prices: (Nat, Nat)): async R<()> {
    if (not isOwnerOrGameMaster(caller)) {
      #err(ERR_UNAUTHORIZED)
    } else if (cropId >= mapSize(crops)) {
      #err(ERR_INVALID_CROP)
    } else {
      cropPrices := natMap.putKeyValue<(Nat, Nat)>(cropPrices, cropId, prices);
      #ok()
    }
  };

  public shared query({ caller }) func getPrices(): async R<[(Nat, (Nat, Nat))]> {
    #ok(natMap.entries<(Nat, Nat)>(cropPrices))
  };

  /********************
    Plot Management
  ********************/

  public shared query({ caller }) func queryPlots(plotIds: [Nat]): async R<[(Nat, ?Plot)]> {
    #ok(Array.map<Nat, (Nat, ?Plot)>(plotIds, func (id) = (id, natMap.getValue<Plot>(plots, id))))
  };

  /********************
        Trade
  ********************/

  public shared({ caller }) func buy(list: [(Nat, Nat, Nat)], tokens: Nat): async R<Inventory> {
    switch (userMap.getValue<Inventory>(inventories, caller)) {
      case (null) {#err(ERR_USER_NOT_FOUND) };
      case (?inventory) {
        if (inventory.tokens < tokens) {
          #err(ERR_INSUFFICIENT_TOKENS)
        } else {
          Result.chain<Nat, Inventory, Text>(
            priceForList(list),
            func (realtimePrice) {
              if (realtimePrice > tokens) {
                #err(ERR_PRICE_CHANGED)
              } else {
                let (tokens, _) = LN.safeSub(inventory.tokens, realtimePrice);
                Result.chain<Map<Nat, (Nat, Nat)>, Inventory, Text>(
                  foldLeft(list, #ok(inventory.crops), calcCrops(func (a, b) = a + b)),
                  func (crops) {
                    let newInventory = { tokens; crops };
                    inventories := userMap.putKeyValue<Inventory>(inventories, caller, newInventory);
                    #ok(newInventory)
                  }
                )
              }
            }
          )
        }
      };
    }
  };

  public shared({ caller }) func sell(list: [(Nat, Nat, Nat)], tokens: Nat): async R<Nat> {
    #err("ERR_NOT_IMPLEMENTED")
    // switch (userMap.getValue<Inventory>(inventories, caller)) {
    //   case (null) {#err(ERR_USER_NOT_FOUND) };
    //   case (?inventory) {
    //     Result.chain<Nat, Inventory, Text>()
    //     priceForList
    //     if (inventory.tokens < tokens) {
    //       #err(ERR_INSUFFICIENT_TOKENS)
    //     } else {
    //       Result.chain<Nat, Inventory, Text>(
    //         priceForList(list),
    //         func (realtimePrice) {
    //           if (realtimePrice > tokens) {
    //             #err(ERR_PRICE_CHANGED)
    //           } else {
    //             let (tokens, _) = LN.safeSub(inventory.tokens, realtimePrice);
    //             Result.chain<Map<Nat, (Nat, Nat)>, Inventory, Text>(
    //               foldLeft(list, #ok(inventory.crops), calcCrops(func (a, b) = a + b)),
    //               func (crops) {
    //                 let newInventory = { tokens; crops };
    //                 inventories := userMap.putKeyValue<Inventory>(inventories, caller, newInventory);
    //                 #ok(newInventory)
    //               }
    //             )
    //           }
    //         }
    //       )
    //     }
    //   };
    // }

  };

  public shared query({ caller }) func inventory(): async R<Inventory> {
    switch (userMap.getValue<Inventory>(inventories, caller)) {
      case (?inventory) { #ok(inventory) };
      case (_) { #err(ERR_USER_NOT_FOUND) };
    }
  };

  /********************
      Player Access
  ********************/

  public shared query({ caller }) func queryPlayer(userId: Principal): async R<Player> {
    switch (userMap.getValue<Player>(players, userId)) {
      case (?player) { #ok(player) };
      case (_) { #err(ERR_USER_NOT_FOUND) };
    }
  };

  public shared({ caller }) func initPlayer(name: Text, avatar: Text): async R<(Player, Inventory)> {
    switch (userMap.getValue<Player>(players, caller)) {
      case (?player) { #err(ERR_USER_EXISTS) };
      case (_) {
        let player: Player = { name = name; avatar = avatar; plotIds = allocatePlots(caller, INIT_PLOTS) };
        players := userMap.putKeyValue<Player>(players, caller, player);
        #ok((player, initInventory(caller)))
      }
    }
  };


  /********************
        Farming
  ********************/

  public shared({ caller }) func plant(tasks: [(Nat, Nat)]): async R<[(Nat, Nat)]> {
    #err("ERR_NOT_IMPLEMENTED")
  };

  public shared({ caller }) func harvest(tasks: [Nat]): async R<[(Nat, Nat, Nat, Nat)]> {
    #err("ERR_NOT_IMPLEMENTED")
  };

};
