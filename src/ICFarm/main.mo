import Option "mo:base/Option";
import TrieSet "mo:base/TrieSet";
import Trie "mo:base/Trie";
import { filter } "mo:base/Array";
import { foldLeft } "mo:base/Array";
import Buffer "mo:base/Buffer";
import Principal "mo:base/Principal";
import { isAnonymous } "mo:base/Principal";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Types "Types";
import LL "lambda/Logical";
import LC "lambda/Compare";
import LTS "lambda/TrieSet";
import LT "lambda/Trie";

actor ICFarm {
  /********************
      Authorizaton
  ********************/

  // State
  stable var owner: Principal = Principal.fromBlob("\04");
  stable var gameMasters: TrieSet.Set<Principal> = TrieSet.empty();

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
  stable var crops: Trie.Trie<Nat, Types.Crop> = Trie.empty();

  // Helpers
  private let natMap = LT.forKey<Nat>(Hash.hash, Nat.equal);

  // API
  public shared({ caller }) func addCrop(crop: Types.Crop): async Nat {
    assert(isOwnerOrGameMaster(caller));
    
    let cropId = Trie.size(crops);
    crops := natMap.putKeyValue<Types.Crop>(crops, cropId, crop);
    cropId
  };

  public shared({ caller }) func updateCrop(cropId: Nat, crop: Types.Crop): async () {
    assert(isOwnerOrGameMaster(caller));

    crops := natMap.putKeyValue<Types.Crop>(crops, cropId, crop);
  };

  public shared query({ caller }) func getCrops(): async [(Nat, Types.Crop)] {
    natMap.entries<Types.Crop>(crops)
  };

};
