import Hash "mo:base/Hash";
import TrieSet "mo:base/TrieSet";

module {
  private type Set<A> = TrieSet.Set<A>;
  private type Hash = Hash.Hash;
  public let forType = func<A>(hash: A -> Hash, equal: (A, A) -> Bool): {
    addElement: (Set<A>, A) -> Set<A>;
    add: A -> Set<A> -> Set<A>;
    addTo: Set<A> -> A -> Set<A>;
    delElement: (Set<A>, A) -> Set<A>;
    del: A -> Set<A> -> Set<A>;
    delFrom: Set<A> -> A -> Set<A>;
    hasElement: (Set<A>, A) -> Bool;
    contains:  A -> Set<A> -> Bool;
    elementOf: Set<A> -> A -> Bool;
  } = object {
    public func addElement(xs: Set<A>, x: A): Set<A> {
      TrieSet.put(xs, x, hash(x), equal)
    };

    public func add(x: A): Set<A> -> Set<A> {
      func (xs) = addElement(xs, x)
    };

    public func addTo(xs: Set<A>): A -> Set<A> {
      func (x) = addElement(xs, x)
    };

    public func delElement(xs: Set<A>, x: A): Set<A> {
      TrieSet.delete(xs, x, hash(x), equal)
    };

    public func del(x: A): Set<A> -> Set<A> {
      func (xs) = delElement(xs, x)
    };

    public func delFrom(xs: Set<A>): A -> Set<A> {
      func (x) = delElement(xs, x)
    };

    public func hasElement(xs: Set<A>, x: A): Bool {
      TrieSet.mem(xs, x, hash(x), equal)
    };

    public func contains(x: A): Set<A> -> Bool {
      func (xs) = hasElement(xs, x)
    };

    public func elementOf(xs: Set<A>): A -> Bool {
      func (x) = hasElement(xs, x)
    };

  };
}