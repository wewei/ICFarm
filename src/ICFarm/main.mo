import Option "mo:base/Option";
import Result "mo:base/Result";
import TrieSet "mo:base/TrieSet";
import Trie "mo:base/Trie";
import Time "mo:base/Time";
import Array  "mo:base/Array";
import Buffer "mo:base/Buffer";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Func "mo:base/Func";
import List "mo:base/List";

import Types "Types";
import LL "lambda/Logical";
import LC "lambda/Compare";
import LTS "lambda/TrieSet";
import LT "lambda/Trie";
import LN "lambda/Nat";
import LR "lambda/Result";

import State "State";
import Authorization "Authorization";

actor ICFarm {
  /********************
        Aliases
  ********************/
  // Types
  type Player = Types.Player;
  type Crop = Types.Crop;
  type Plot = Types.Plot;
  type Inventory = Types.Inventory;
  type State<S> = State.State<S>;

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
  let ERR_USER_EXISTS = "ERR_USER_EXISTS";
  let ERR_USER_NOT_FOUND = "ERR_USER_NOT_FOUND";
  let ERR_INVALID_CROP = "ERR_INVALID_CROP";
  let ERR_INSUFFICIENT_TOKENS = "ERR_INSUFFICIENT_TOKENS";
  let ERR_INSUFFICIENT_CROPS = "ERR_INSUFFICIENT_CROPS";
  let ERR_PRICE_CHANGED = "ERR_PRICE_CHANGED";
  let ERR_INVALID_PLOT = "ERR_INVALID_PLOT";
  let ERR_PLOT_UNAVAILABLE = "ERR_PLOT_UNAVAILABLE";

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


  // API

  /********************
      Authorization
  ********************/

  private let authorization = Authorization.Authorization();

  private let useOwner = func (): State<{
    owner: Principal;
  }> = ({ owner }, func (result) {
    owner := result.owner;
  });

  private let useGameMaster = func (): State<{
    gameMasters: Set<Principal>;
  }> = ({ gameMasters }, func (result) {
    gameMasters := result.gameMasters;
  });

  public shared query({ caller }) func getGameMasters() : async R<[Principal]> {
    authorization.getGameMasters({ caller; gameMasters })
  };

  public shared({ caller }) func claimOwner() : async R<()> {
    authorization.claimOwner({ caller })(useOwner())
  };

  public shared({ caller }) func transferOwner(userId: Principal): async R<()> {
    authorization.transferOwner({ caller; userId })(useOwner())
  };

  public shared({ caller }) func addGameMasters(userIds: [Principal]) : async R<()> {
    authorization.addGameMasters({
      caller; owner;
      userIds = List.fromArray(userIds);
    })(useGameMaster())
  };

  public shared({ caller }) func removeGameMasters(userIds: [Principal]) : async R<()> {
    authorization.removeGameMasters({
      caller; owner;
      userIds = List.fromArray(userIds);
    })(useGameMaster())
  };

  public shared({ caller }) func resignGameMaster() : async R<()> {
    authorization.resignGameMaster({ caller })(useGameMaster())
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

  public shared({ caller }) func buy(list: [(Nat, Nat, Nat)], estimation: Nat): async R<Inventory> {
    let r_0 = Result.fromOption<Inventory, Text>(
      userMap.getValue<Inventory>(inventories, caller),
      ERR_USER_NOT_FOUND
    );

    let r_1 = Result.chain<Inventory, Inventory, Text>(r_0, func ({ tokens }) {
      if (tokens < estimation) #err(ERR_INSUFFICIENT_TOKENS) else r_0
    });

    let r_2 = Result.chain<Inventory, Inventory, Text>(r_1, func(inventory) {
      foldLeft<(Nat, Nat, Nat), R<Inventory>>(list, #ok(inventory), func (rInv, (cropId, pCount, sCount)) {
        Result.chain<Inventory, Inventory, Text>(rInv, func ({ crops; tokens }) {
          let r2_0 = Result.fromOption<(Nat, Nat), Text>(
            natMap.getValue<(Nat, Nat)>(crops, cropId),
            ERR_INVALID_CROP
          );

          let r2_1 = Result.chain<(Nat, Nat), Inventory, Text>(r2_0, func ((pPrice, sPrice)) {
            let price = pPrice * pCount + sPrice * sCount;
            if (price > tokens) {
              #err(ERR_INSUFFICIENT_TOKENS)
            } else {
              #ok({
                crops = natMap.alter<(Nat, Nat)>(const(func (rPair: ?(Nat, Nat)): ?(Nat, Nat) {
                  let (pC, sC) = Option.get(rPair, (0, 0));
                  ?(pC + pCount, sC + sCount)
                }))(crops, cropId);
                tokens = Int.abs(tokens - price);
              })
            }
          })
        })
      });
    });

    LR.bind2<Inventory, Inventory, Inventory, Text>(func (invOrig) = func (invNew) {
      if (invNew.tokens + estimation != invOrig.tokens) {
        #err(ERR_PRICE_CHANGED)
      } else {
        inventories := userMap.putKeyValue<Inventory>(inventories, caller, invNew);
        #ok(invNew)
      }
    })(r_0)(r_2);
  };

  public shared({ caller }) func sell(list: [(Nat, Nat, Nat)], estimation: Nat): async R<Inventory> {
    let r_0 = Result.fromOption<Inventory, Text>(
      userMap.getValue<Inventory>(inventories, caller),
      ERR_USER_NOT_FOUND
    );

    let r_1 = Result.chain<Inventory, Inventory, Text>(r_0, func(inventory) {
      foldLeft<(Nat, Nat, Nat), R<Inventory>>(list, #ok(inventory), func (rInv, (cropId, pCount, sCount)) {
        Result.chain<Inventory, Inventory, Text>(rInv, func ({ crops; tokens }) {
          let r2_0 = Result.fromOption<(Nat, Nat), Text>(
            natMap.getValue<(Nat, Nat)>(crops, cropId),
            ERR_INVALID_CROP
          );

          let r2_1 = Result.chain<(Nat, Nat), Inventory, Text>(r2_0, func ((pPrice, sPrice)) {
            let price = pPrice * pCount + sPrice * sCount;
            if (price > tokens) {
              #err(ERR_INSUFFICIENT_TOKENS)
            } else {
              let (pC, sC) = Option.get<(Nat, Nat)>(natMap.getValue<(Nat, Nat)>(crops, cropId), (0, 0));
              if (pC < pCount or sC < sCount) {
                #err(ERR_INSUFFICIENT_CROPS)
              } else {
                #ok({
                  crops = natMap.alter<(Nat, Nat)>(const(func (rPair: ?(Nat, Nat)): ?(Nat, Nat) {
                    let (pC, sC) = Option.get(rPair, (0, 0));
                    ?(Int.abs(pC - pCount), Int.abs(sC - sCount))
                  }))(crops, cropId);
                  tokens = tokens + price;
                })
              }
            }
          })
        })
      });
    });

    LR.bind2<Inventory, Inventory, Inventory, Text>(func (invOrig) = func (invNew) {
      if (invOrig.tokens + estimation != invNew.tokens) {
        #err(ERR_PRICE_CHANGED)
      } else {
        inventories := userMap.putKeyValue<Inventory>(inventories, caller, invNew);
        #ok(invNew)
      }
    })(r_0)(r_1);

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
    LR.bind<(Map<Principal, Inventory>, Map<Nat, Plot>), [(Nat, Nat)], Text>(func (invs, pls) {
      inventories := invs;
      plots := pls;
      #ok(tasks)
    })(
      foldLeft<(Nat, Nat), R<(Map<Principal, Inventory>, Map<Nat, Plot>)>>(tasks, #ok((inventories, plots)), func (rPair, (plotId, cropId)) {
        switch rPair {
          case (#err(e)) { #err(e) };
          case (#ok((inventories, plots))) {
            let timestamp = Time.now();
            LR.bind2<Plot, Principal, (Map<Principal, Inventory>, Map<Nat, Plot>), Text>(func (plot) = func (owner) {
              if (owner != caller) {
                #err(ERR_UNAUTHORIZED)
              } else {
                let rInv = LR.bind<Inventory, Inventory, Text>(func ({ crops; tokens }) {
                  let (pCount, sCount) = Option.get(natMap.getValue<(Nat, Nat)>(crops, cropId), (0, 0));
                  if (sCount == 0) {
                    #err(ERR_INSUFFICIENT_CROPS)
                  } else {
                    #ok({
                      crops = natMap.putKeyValue<(Nat, Nat)>(crops, cropId, (pCount, Int.abs(sCount - 1)));
                      tokens;
                    })
                  }
                })(Result.fromOption(userMap.getValue(inventories, caller), ERR_INVALID_USER));

                LR.bind<Inventory, (Map<Principal, Inventory>, Map<Nat, Plot>), Text>(func (inventory) {
                  if (plot.cropId == null) {
                    #ok((
                      userMap.putKeyValue<Inventory>(inventories, caller, inventory),
                      natMap.putKeyValue<Plot>(plots, plotId, { cropId = ?cropId; timestamp })
                    ))
                  } else {
                    #err(ERR_PLOT_UNAVAILABLE)
                  }
                })(rInv)
              }
            })(
              Result.fromOption(natMap.getValue<Plot>(plots, plotId), ERR_INVALID_PLOT)
            )(
              Result.fromOption(natMap.getValue<Principal>(plotOwners, plotId), ERR_INVALID_PLOT)
            );
          }
        }
      })
    )
  };

  public shared({ caller }) func harvest(tasks: [Nat]): async R<[(Nat, Nat, Nat, Nat)]> {
    #err("ERR_NOT_IMPLEMENTED")
  };

};
