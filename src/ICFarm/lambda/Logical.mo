module {
  public type P<A> = A -> Bool;

  public func negate<A>(pred: P<A>): P<A> {
    func (x) = not pred(x)
  };

  public func either<A>(predA: P<A>): P<A> -> P<A> {
    func (predB) = func (x) = predA(x) or predB(x)
  };

  public func both<A>(predA: P<A>): P<A> -> P<A> {
    func (predB) = func (x) = predA(x) and predB(x)
  };

  public func neither<A>(predA: P<A>): P<A> -> P<A> {
    func (predB) = func (x) = not (predA(x) or predB(x))
  };
}