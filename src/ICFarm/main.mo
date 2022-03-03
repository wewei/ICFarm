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
  type Result<V, E> = Result.Result<V, E>;


  // Functions
  let filter = Array.filter;
  let foldLeft = Array.foldLeft;
  let isAnonymous = Principal.isAnonymous;
  let emptyMap = Trie.empty;
  let mapSize = Trie.size;
  let const = Func.const;

  // Consts
  let INIT_PLOTS = 8;

  /********************
      Authorizaton
  ********************/

  // State
  stable var owner: Principal = Principal.fromBlob("\04");
  stable var gameMasters: Set<Principal> = TrieSet.empty();

  // Helpers
  private let comparePrincipal = LC.Unordered<Principal>(Principal.equal);
  private let principalSet = LTS.forType<Principal>(Principal.hash, Principal.equal);

  private let isGameMaster = principalSet.elementOf(gameMasters);
  private let isOwner = LL.both<Principal>
    (LL.negate(isAnonymous))
    (comparePrincipal.equalTo(owner));
  private let isOwnerOrGameMaster = LL.either<Principal>
    (isOwner)
    (isGameMaster);

  // API
  public shared query({ caller }) func listGameMasters() : async [Principal] {
    assert(not isAnonymous(caller));

    TrieSet.toArray(gameMasters)
  };

  public shared({ caller }) func claimOwner() : async Principal {
    assert(not isAnonymous(caller));
    assert(isAnonymous(owner));

    owner := caller;
    caller
  };

  public shared({ caller }) func transferOwner(userId: Principal): async Principal {
    assert(isOwner(caller));
    assert(not Principal.isAnonymous(userId));

    owner := userId;
    userId
  };

  public shared({ caller }) func addGameMasters(userIds: [Principal]) : async [Principal] {
    assert(isOwnerOrGameMaster(caller));

    let newGameMasters: [Principal] = filter(userIds, LL.neither<Principal>(isGameMaster)(isAnonymous));
    gameMasters := foldLeft(newGameMasters, gameMasters, principalSet.addElement);
    newGameMasters
  };

  public shared({ caller }) func removeGameMasters(userIds: [Principal]) : async [Principal] {
    assert(isOwner(caller));

    let removingGameMasters: [Principal] = filter(userIds, isGameMaster);
    gameMasters := foldLeft(removingGameMasters, gameMasters, principalSet.delElement);
    removingGameMasters
  };

  public shared({ caller }) func resignGameMaster() : async () {
    assert(isOwnerOrGameMaster(caller));

    gameMasters := principalSet.delElement(gameMasters, caller);
  };

  /********************
     Crop Management
  ********************/

  // State
  stable var crops: Map<Nat, Crop> = emptyMap();

  // Helpers
  private let natMap = LT.forKey<Nat>(Hash.hash, Nat.equal);

  // API
  public shared({ caller }) func addCrop(crop: Crop): async Nat {
    assert(isOwnerOrGameMaster(caller));

    let cropId = mapSize(crops);
    crops := natMap.putKeyValue<Crop>(crops, cropId, crop);
    cropId
  };

  public shared({ caller }) func updateCrop(cropId: Nat, crop: Crop): async () {
    assert(isOwnerOrGameMaster(caller));
    assert(cropId < mapSize(crops));

    crops := natMap.putKeyValue<Crop>(crops, cropId, crop);
  };

  public shared query({ caller }) func getCrops(): async [(Nat, Crop)] {
    natMap.entries<Crop>(crops)
  };

  /********************
    Market Management
  ********************/

  // State
  stable var cropPrices: Map<Nat, (Nat, Nat)> = emptyMap();

  // API
  public shared({ caller }) func updatePrices(cropId: Nat, prices: (Nat, Nat)): async () {
    assert(isOwnerOrGameMaster(caller));
    assert(cropId < mapSize(crops));

    cropPrices := natMap.putKeyValue<(Nat, Nat)>(cropPrices, cropId, prices);
  };

  public shared query({ caller }) func getPrices(): async [(Nat, (Nat, Nat))] {
    natMap.entries<(Nat, Nat)>(cropPrices)
  };

  /********************
    Plot Management
  ********************/

  // State
  stable var plotOwners: Map<Nat, Principal> = emptyMap();
  stable var plots: Map<Nat, Plot> = emptyMap();

  // Helpers
  private func allocatePlots(owner: Principal, count: Nat): [Nat] {
    let s = mapSize(plots);
    let newPlots = Array.tabulate<Nat>(count, func (i) = s + i);
    let timestamp = Time.now();
    plotOwners := foldLeft<Nat, Map<Nat, Principal>>(
      newPlots,
      plotOwners,
      natMap.putMapping<Principal>(const(owner)));
    plots := foldLeft<Nat, Map<Nat, Plot>>(
      newPlots,
      plots,
      natMap.putMapping<Plot>(func (_): Plot = {
        cropId = null;
        timestamp = timestamp;
      }));
    newPlots
  };

  public shared query({ caller }) func queryPlots(plotIds: [Nat]): async [(Nat, ?Plot)] {
    Array.map<Nat, (Nat, ?Plot)>(plotIds, func (id) = (id, natMap.getValue<Plot>(plots, id)))
  };

  /********************
   Inventory Management
  ********************/

  // State
  stable var inventories: Map<Principal, Inventory> = emptyMap();


  /********************
      Player Access
  ********************/

  // State
  stable var players: Map<Principal, Player> = emptyMap();

  // Helpers
  private let userMap = LT.forKey<Principal>(Principal.hash, Principal.equal);

  // API
  public shared query({ caller }) func queryPlayer(userId: Principal): async Result<Player, Text> {
    switch (userMap.getValue<Player>(players, userId)) {
      case (?player) { #ok(player) };
      case (_) { #err("ERR_USER_NOT_FOUND") };
    }
  };

  public shared({ caller }) func initPlayer(name: Text, avatar: Text): async Result<Player, Text> {
    switch (userMap.getValue<Player>(players, caller)) {
      case (?player) { #err("ERR_USER_EXISTS") };
      case (_) {
        let player: Player = { name = name; avatar = avatar; plotIds = allocatePlots(caller, INIT_PLOTS) };
        players := userMap.putKeyValue<Player>(players, caller, player);
        #ok(player)
      }
    }
  };

  /********************
        Trade
  ********************/
  // API
  public shared({ caller }) func buy(list: [(Nat, Nat, Nat)], tokens: Nat): async Result<Nat, Text> {
    #err("ERR_NOT_IMPLEMENTED")
  };

  public shared({ caller }) func sell(list: [(Nat, Nat, Nat)], tokens: Nat): async Result<Nat, Text> {
    #err("ERR_NOT_IMPLEMENTED")
  };

  public shared query({ caller }) func inventory(): async Result<Inventory, Text> {
    #err("ERR_NOT_IMPLEMENTED")
  };


  /********************
        Farming
  ********************/

  // API
  public shared({ caller }) func plant(tasks: [(Nat, Nat)]): async Result<[(Nat, Nat)], Text> {
    #err("ERR_NOT_IMPLEMENTED")
  };

  public shared({ caller }) func harvest(tasks: [Nat]): async Result<[(Nat, Nat, Nat, Nat)], Text> {
    #err("ERR_NOT_IMPLEMENTED")
  };

};
