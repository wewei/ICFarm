import Hash "mo:base/Hash";
import Trie "mo:base/Trie";

module {
  private type Map<K, V> = Trie.Trie<K, V>;
  private type Hash = Hash.Hash;

  public let forKey = func<K>(hash: K -> Hash, equal: (K, K) -> Bool): {
    replace: <V>(Map<K, V>, K, ?V) -> (Map<K, V>, ?V);
    putKeyValue: <V>(Map<K, V>, K, V) -> Map<K, V>;
    getValue: <V>(Map<K, V>, K) -> ?V;
    delKey: <V>(Map<K, V>, K) -> Map<K, V>;
    keys: <V>(Map<K, V>) -> [K];
    values: <V>(Map<K, V>) -> [V];
    entries: <V>(Map<K, V>) -> [(K, V)];
    alter: <V>(K -> ?V -> ?V) -> (Map<K, V>, K) -> Map<K, V>;
  } = object {

    public func replace<V>(map: Map<K, V>, key: K, value: ?V): (Map<K, V>, ?V) {
      let keyObj = { key = key; hash = hash(key) };
      Trie.replace(map, keyObj, equal, value)
    };

    public func putKeyValue<V>(map: Map<K, V>, key: K, value: V): Map<K, V> {
      let (result, _) = replace(map, key, ?value);
      result
    };

    public func getValue<V>(map: Map<K, V>, key: K): ?V {
      let keyObj = { key = key; hash = hash(key) };
      Trie.get<K, V>(map, keyObj, equal)
    };

    public func delKey<V>(map: Map<K, V>, key: K): Map<K, V> {
      let keyObj = { key = key; hash = hash(key) };
      let (result, _) = Trie.remove<K, V>(map, keyObj, equal);
      result
    };

    public func keys<V>(map: Map<K, V>): [K] {
      Trie.toArray<K, V, K>(map, func (k, _) = k)
    };

    public func values<V>(map: Map<K, V>): [V] {
      Trie.toArray<K, V, V>(map, func (_, v) = v)
    };

    public func entries<V>(map: Map<K, V>): [(K, V)] {
      Trie.toArray<K, V, (K, V)>(map, func (k, v) = (k, v))
    };

    public func alter<V>(f: K -> ?V -> ?V): (Map<K, V>, K) -> Map<K, V> {
      func (map, key) {
        let (result, _) = replace(map, key, f(key)(getValue<V>(map, key)));
        result
      }
    };
  };
}