import Option "mo:base/Option";
import TrieSet "mo:base/TrieSet";
import { filter } "mo:base/Array";
import { foldLeft } "mo:base/Array";
import Buffer "mo:base/Buffer";
import Principal "mo:base/Principal";
import { isAnonymous } "mo:base/Principal";
import Iter "mo:base/Iter";
import Types "Types";

actor ICFarm {
    // Game State
  stable var owner: Principal = Principal.fromBlob("\04");
  stable var gameMasters: TrieSet.Set<Principal> = TrieSet.empty();

  // Logical compositors
  func negate<A>(pred: A -> Bool): A -> Bool {
    func (x: A) = not pred(x)
  };

  func either<A>(predA: A -> Bool, predB: A -> Bool): A -> Bool {
    func (x: A) = predA(x) or predB(x)
  };

  func both<A>(predA: A -> Bool, predB: A -> Bool): A -> Bool {
    func (x: A) = predA(x) and predB(x)
  };

  func neither<A>(predA: A -> Bool, predB: A -> Bool): A -> Bool {
    func (x: A) = not (predA(x) or predB(x))
  };

  func equalTo<A>(val: A, eq: (A, A) -> Bool): A -> Bool {
    func (x: A): Bool = eq(x, val)
  };

  func hasPrincipal(sx: TrieSet.Set<Principal>, x: Principal): Bool {
    TrieSet.mem<Principal>(sx, x, Principal.hash(x), Principal.equal)
  };

  func addPrincipal(sx: TrieSet.Set<Principal>, x: Principal): TrieSet.Set<Principal> {
    TrieSet.put(sx, x, Principal.hash(x), Principal.equal)
  };

  func removePrincipal(sx: TrieSet.Set<Principal>, x: Principal): TrieSet.Set<Principal> {
    TrieSet.delete(sx, x, Principal.hash(x), Principal.equal)
  };

  func isGameMaster(userId: Principal): Bool {
    hasPrincipal(gameMasters, userId)
  };

  let isOwner: Principal -> Bool =
    both(
      negate(isAnonymous),
      equalTo(owner, Principal.equal));

  let isOwnerOrGameMaster: Principal -> Bool =
    either(
      isOwner,
      isGameMaster);

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

    let newGameMasters: [Principal] = filter(userIds, neither(isGameMaster, isAnonymous));
    gameMasters := foldLeft(newGameMasters, gameMasters, addPrincipal);
    newGameMasters
  };

  public shared({ caller }) func removeGameMasters(userIds: [Principal]) : async [Principal] {
    assert(isOwner(caller));

    let removingGameMasters: [Principal] = filter(userIds, isGameMaster);
    gameMasters := foldLeft(removingGameMasters, gameMasters, removePrincipal);
    removingGameMasters
  };

  public shared({ caller }) func resignGameMaster() : async () {
    assert(isOwnerOrGameMaster(caller));

    gameMasters := removePrincipal(gameMasters, caller);
  };

};
