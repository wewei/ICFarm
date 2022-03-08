import Principal "mo:base/Principal";
import Option "mo:base/Option";
import List "mo:base/List";
import TrieSet "mo:base/TrieSet";
import LC "lambda/Compare";
import LTS "lambda/TrieSet";
import State "State";

module {
  public let ERR_UNAUTHORIZED = "ERR_UNAUTHORIZED";
  public let ERR_INVALID_USER = "ERR_INVALID_USER";
  public let ERR_CANNOT_RESIGN = "ERR_CANNOT_RESIGN";

  private type List<E> = List.List<E>;
  private type Set<E> = TrieSet.Set<E>;

  public class Authorization() {
    private let isAnonymous = Principal.isAnonymous;
    private let userSet = LTS.forType<Principal>(Principal.hash, Principal.equal);

    public let getGameMasters: State.Getter<{
      caller: Principal;
      gameMasters: Set<Principal>;
    }, [Principal], Text> =
      func ({ caller; gameMasters }) =
        if (isAnonymous(caller))
          #err(ERR_UNAUTHORIZED)
        else
          #ok(TrieSet.toArray(gameMasters));

    public let claimOwner = State.setter<{
      // props
      caller: Principal;
    }, {
      // states
      owner: Principal;
    }, Text>(
      func ({ caller }, { owner }) =
        if (isAnonymous(caller) or not isAnonymous(owner))
          #err(ERR_UNAUTHORIZED)
        else
          #ok({ owner = caller })
    );

    public let transferOwner = State.setter<{
      // props
      caller: Principal;
      userId: Principal;
    }, {
      // states
      owner: Principal;
    }, Text>(
      func ({ caller; userId }, { owner }) =
        if (caller != owner)
          #err(ERR_UNAUTHORIZED)
        else if (isAnonymous(userId))
          #err(ERR_INVALID_USER)
        else
          #ok({ owner = userId })
    );

    public let addGameMasters = State.setter<{
      // props
      caller: Principal;
      owner: Principal;
      userIds: List<Principal>;
    }, {
      // states
      gameMasters: Set<Principal>;
    }, Text>(
      func ({ caller; owner; userIds }, { gameMasters }) =
        if (caller == owner or userSet.contains(caller)(gameMasters)) 
          #ok({
            gameMasters = List.foldLeft(userIds, gameMasters, userSet.addElement);
          })
        else
          #err(ERR_UNAUTHORIZED)
    );

    public let removeGameMasters = State.setter<{
      // props
      caller: Principal;
      owner: Principal;
      userIds: List<Principal>;
    }, {
      // states
      gameMasters: Set<Principal>;
    }, Text>(
      func ({ caller; owner; userIds }, { gameMasters }) =
        if (caller == owner or userSet.contains(caller)(gameMasters))
          #ok({
            gameMasters = List.foldLeft(userIds, gameMasters, userSet.delElement);
          })
        else
          #err(ERR_UNAUTHORIZED)
    );

    public let resignGameMaster = State.setter<{
      // props
      caller: Principal;
    }, {
      // states
      gameMasters: Set<Principal>;
    }, Text>(
      func ({ caller }, { gameMasters }) =
        if (userSet.contains(caller)(gameMasters))
          #ok({
            gameMasters = userSet.delElement(gameMasters, caller)
          })
        else
          #err(ERR_CANNOT_RESIGN)
    );
  }
}