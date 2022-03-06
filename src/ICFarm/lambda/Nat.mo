module {
  public func safeSub(x: Nat, y: Nat): (Nat, Nat) {
    if (x >= y) (x - y, 0) else (0, y - x)
  };
} 