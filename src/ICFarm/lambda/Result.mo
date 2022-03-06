import Result "mo:base/Result";

module {
  type R<V, E> = Result.Result<V, E>;
  // This is not working with Motoko@0.6.21
  // The `moc` crashes in stack overflow
  // This GitHub issue is tracking the problem
  // https://github.com/dfinity/motoko/issues/3057

  // public type ResultChain<A, E> = {
  //   then: <B>(A -> R<B, E>) -> ResultChain<B, E>;
  //   value: R<A, E>;
  // };

  // public func chain<A, E>(value: R<A, E>) {
  //   {
  //     then = func <B>(f: A -> R<B, E>): ResultChain<B, E> {
  //       switch value {
  //         case (#err(e)) { #err(e) };
  //         case (#ok(a)) { chain(f(a)) };
  //       }
  //     };
  //     value;
  //   }
  // }

  public func bind<A, B, E>(f: A -> R<B, E>): R<A, E> -> R<B, E> {
    func (r) = switch r {
      case (#ok(a)) { f(a) };
      case (#err(e)) { #err(e) };
    }
  };
}