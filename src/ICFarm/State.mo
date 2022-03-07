import Result "mo:base/Result";

module {
  public type Updater<P, S, R, E> = (P, S, (S -> R)) -> Result.Result<R, E>;

  public func updater<P, S, R, E>(
    callback: (P, S) -> Result.Result<S, E>,
  ): Updater<P, S, R, E> {
    func (props, state, update) {
      Result.chain<S, R, E>(
        callback(props, state),
        func (state) {
          #ok(update(state))
        }
      )
    }
  }
}
