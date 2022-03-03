import Time "mo:base/Time";
import Trie "mo:base/Trie";

module {
  type Map<K, V> = Trie.Trie<K, V>;

  public type Crop = {
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

  public type CropPhase = {
    name: Text;
    image: Text;
    period: Nat;
  };

  public type Player = {
    name: Text;
    avatar: Text;
    plotIds: [Nat];
  };

  public type Inventory = {
    tokens: Nat;
    crops: Map<Nat, (Nat, Nat)>;
  };

  public type Plot = {
    cropId: ?Nat;
    timestamp: Time.Time;
  };

}