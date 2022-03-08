import Result "mo:base/Result";

module {
  public type State<S> = (S, S -> ());
  public type Getter<P, R, E> = P -> Result.Result<R, E>;
  public type Setter<P, S, E> = P -> (State<S>) -> Result.Result<(), E>;

  public func setter<P, S, E>(
    callback: (P, S) -> Result.Result<S, E>,
  ): Setter<P, S, E> {
    func (props) = func((state, setState)) =
      Result.chain<S, (), E>(
        callback(props, state),
        func (state) = #ok(setState(state))
      );
  };
}
