import Order "mo:base/Order";
import LL "Logical";

module {
  public let Ordered = func <A>(cmp: (A, A) -> Order.Order): {
    greaterThan: A -> A -> Bool;
    lessThan: A -> A -> Bool;
    equalTo: A -> A -> Bool;
    notGreaterThan: A -> A -> Bool;
    notLessThan: A -> A -> Bool;
    notEqualTo: A -> A -> Bool;
  } = object {

    public func greaterThan(x: A): LL.P<A> {
      func (y) = Order.isGreater(cmp(y, x))
    };

    public func lessThan(x: A): LL.P<A> {
      func(y) = Order.isLess(cmp(y, x))
    };

    public func equalTo(x: A): LL.P<A> {
      func(y) = Order.isEqual(cmp(y, x))
    };

    public func notGreaterThan(x: A): LL.P<A> {
      LL.negate(greaterThan(x))
    };

    public func notLessThan(x: A): LL.P<A> {
      LL.negate(lessThan(x))
    };

    public func notEqualTo(x: A): LL.P<A> {
      LL.negate(equalTo(x))
    };
  };

  public let Unordered = func <A>(equal: (A, A) -> Bool): {
    equalTo: A -> A -> Bool;
    notEqualTo: A -> A -> Bool;
  } = object {

    public func equalTo(x: A): LL.P<A> {
      func(y) = equal(y, x)
    };

    public func notEqualTo(x: A): LL.P<A> {
      LL.negate(equalTo(x))
    };
  };

}