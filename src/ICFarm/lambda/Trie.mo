import Hash "mo:base/Hash";
import Trie "mo:base/Trie";

module {
  private type Map<K, V> = Trie.Trie<K, V>;
  private type Hash = Hash.Hash;

  public let forKey = func<K>(hash: K -> Hash, equal: (K, K) -> Bool): {
    putKeyValue: <V>(Map<K, V>, K, V) -> Map<K, V>;
    getValue: <V>(Map<K, V>, K) -> ?V;
    delKey: <V>(Map<K, V>, K) -> Map<K, V>;
    keys: <V>(Map<K, V>) -> [K];
    values: <V>(Map<K, V>) -> [V];
    entries: <V>(Map<K, V>) -> [(K, V)];
    putMapping: <V>(K -> V) -> (Map<K, V>, K) -> Map<K, V>;
  } = object {

    public func putKeyValue<V>(map: Map<K, V>, key: K, value: V): Map<K, V> {
      let keyObj = { key = key; hash = hash(key) };
      let (result, _) = Trie.put<K, V>(map, keyObj, equal, value);
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

    public func putMapping<V>(mapping: K -> V): (Map<K, V>, K) -> Map<K, V> {
      func (map, key) = putKeyValue(map, key, mapping(key))
    };
  };
}