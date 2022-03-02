import Time "mo:base/Time";

module {
  type Crop = {
    productName: Text;
    productImage: Text;
    productRange: (Nat, Nat);
    productPrice: Nat;
    seedName: Text;
    seedImage: Text;
    seedRange: (Nat, Nat);
    seedPrice: Nat;
    phases: [CropPhase];
  };

  type CropPhase = {
    name: Text;
    image: Text;
    period: Nat;
  };

  type Market = {
    cropPrices: [(Nat, Nat)];
  };

  type Player = {
    name: Text;
    avatar: Text;
    plotIds: [Nat];
  };

  type Inventory = {
    tokens: Nat;
    crops: [(Nat, Nat)];
  };

  type Plot = {
    cropId: ?Nat;
    timestamp: Time.Time;
  };
}