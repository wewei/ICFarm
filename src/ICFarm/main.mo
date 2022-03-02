import TrieSet "mo:base/TrieSet";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";

import Types "Types";

actor ICFarm {
    // Authorization
    stable var gameMasters: TrieSet.Set<Principal> = TrieSet.empty();

    public shared query({ caller }) func listGameMasters() : async [Principal] {
        TrieSet.toArray(gameMasters)
    };

    public shared({ caller }) func addGameMasters(userIds: [Principal]) : async [Principal] {
        let newGameMasters: [Principal] = Array.filter(
            userIds,
            func (x: Principal): Bool {
                not TrieSet.mem<Principal>(gameMasters, x, Principal.hash(x), Principal.equal)
            });

        gameMasters := Array.foldLeft(
            newGameMasters,
            gameMasters,
            func (gms: TrieSet.Set<Principal>, gm: Principal): TrieSet.Set<Principal> {
                TrieSet.put<Principal>(gms, gm, Principal.hash(gm), Principal.equal)
            });

        newGameMasters
    };

    public shared({ caller }) func removeGameMasters(userIds: [Principal]) : async [Principal] {
        let removingGameMasters: [Principal] = Array.filter(
            userIds,
            func (x: Principal): Bool {
                TrieSet.mem<Principal>(gameMasters, x, Principal.hash(x), Principal.equal)
            });
        gameMasters := Array.foldLeft(
            removingGameMasters,
            gameMasters,
            func (gms: TrieSet.Set<Principal>, gm: Principal): TrieSet.Set<Principal> {
                TrieSet.delete<Principal>(gms, gm, Principal.hash(gm), Principal.equal)
            });

        removingGameMasters
    };

    public shared({ caller }) func resignGameMaster() : async () {
        gameMasters := TrieSet.delete<Principal>(gameMasters, caller, Principal.hash(caller), Principal.equal);
    };

};
