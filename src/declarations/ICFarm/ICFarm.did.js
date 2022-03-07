export const idlFactory = ({ IDL }) => {
  const Branch = IDL.Rec();
  const List = IDL.Rec();
  const CropPhase = IDL.Record({
    'period' : IDL.Nat,
    'name' : IDL.Text,
    'image' : IDL.Text,
  });
  const Crop = IDL.Record({
    'seedImage' : IDL.Text,
    'seedPrice' : IDL.Nat,
    'seedRange' : IDL.Tuple(IDL.Nat, IDL.Nat),
    'seedName' : IDL.Text,
    'productName' : IDL.Text,
    'productImage' : IDL.Text,
    'productPrice' : IDL.Nat,
    'phases' : IDL.Vec(CropPhase),
    'productRange' : IDL.Tuple(IDL.Nat, IDL.Nat),
  });
  const R_11 = IDL.Variant({ 'ok' : IDL.Nat, 'err' : IDL.Text });
  const R_3 = IDL.Variant({ 'ok' : IDL.Vec(IDL.Principal), 'err' : IDL.Text });
  const Hash = IDL.Nat32;
  const Key = IDL.Record({ 'key' : IDL.Nat, 'hash' : Hash });
  List.fill(
    IDL.Opt(IDL.Tuple(IDL.Tuple(Key, IDL.Tuple(IDL.Nat, IDL.Nat)), List))
  );
  const AssocList = IDL.Opt(
    IDL.Tuple(IDL.Tuple(Key, IDL.Tuple(IDL.Nat, IDL.Nat)), List)
  );
  const Leaf = IDL.Record({ 'size' : IDL.Nat, 'keyvals' : AssocList });
  const Trie = IDL.Variant({
    'branch' : Branch,
    'leaf' : Leaf,
    'empty' : IDL.Null,
  });
  Branch.fill(IDL.Record({ 'left' : Trie, 'size' : IDL.Nat, 'right' : Trie }));
  const Map = IDL.Variant({
    'branch' : Branch,
    'leaf' : Leaf,
    'empty' : IDL.Null,
  });
  const Inventory = IDL.Record({ 'crops' : Map, 'tokens' : IDL.Nat });
  const R_2 = IDL.Variant({ 'ok' : Inventory, 'err' : IDL.Text });
  const R_1 = IDL.Variant({ 'ok' : IDL.Principal, 'err' : IDL.Text });
  const R_10 = IDL.Variant({
    'ok' : IDL.Vec(IDL.Tuple(IDL.Nat, Crop)),
    'err' : IDL.Text,
  });
  const R_9 = IDL.Variant({
    'ok' : IDL.Vec(IDL.Tuple(IDL.Nat, IDL.Tuple(IDL.Nat, IDL.Nat))),
    'err' : IDL.Text,
  });
  const R_8 = IDL.Variant({
    'ok' : IDL.Vec(IDL.Tuple(IDL.Nat, IDL.Nat, IDL.Nat, IDL.Nat)),
    'err' : IDL.Text,
  });
  const Player = IDL.Record({
    'name' : IDL.Text,
    'plotIds' : IDL.Vec(IDL.Nat),
    'avatar' : IDL.Text,
  });
  const R_7 = IDL.Variant({
    'ok' : IDL.Tuple(Player, Inventory),
    'err' : IDL.Text,
  });
  const R_6 = IDL.Variant({
    'ok' : IDL.Vec(IDL.Tuple(IDL.Nat, IDL.Nat)),
    'err' : IDL.Text,
  });
  const R_5 = IDL.Variant({ 'ok' : Player, 'err' : IDL.Text });
  const Time = IDL.Int;
  const Plot = IDL.Record({ 'cropId' : IDL.Opt(IDL.Nat), 'timestamp' : Time });
  const R_4 = IDL.Variant({
    'ok' : IDL.Vec(IDL.Tuple(IDL.Nat, IDL.Opt(Plot))),
    'err' : IDL.Text,
  });
  const R = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  return IDL.Service({
    'addCrop' : IDL.Func([Crop], [R_11], []),
    'addGameMasters' : IDL.Func([IDL.Vec(IDL.Principal)], [R_3], []),
    'buy' : IDL.Func(
        [IDL.Vec(IDL.Tuple(IDL.Nat, IDL.Nat, IDL.Nat)), IDL.Nat],
        [R_2],
        [],
      ),
    'claimOwner' : IDL.Func([], [R_1], []),
    'getCrops' : IDL.Func([], [R_10], ['query']),
    'getPrices' : IDL.Func([], [R_9], ['query']),
    'harvest' : IDL.Func([IDL.Vec(IDL.Nat)], [R_8], []),
    'initPlayer' : IDL.Func([IDL.Text, IDL.Text], [R_7], []),
    'inventory' : IDL.Func([], [R_2], ['query']),
    'listGameMasters' : IDL.Func([], [R_3], ['query']),
    'plant' : IDL.Func([IDL.Vec(IDL.Tuple(IDL.Nat, IDL.Nat))], [R_6], []),
    'queryPlayer' : IDL.Func([IDL.Principal], [R_5], ['query']),
    'queryPlots' : IDL.Func([IDL.Vec(IDL.Nat)], [R_4], ['query']),
    'removeGameMasters' : IDL.Func([IDL.Vec(IDL.Principal)], [R_3], []),
    'resignGameMaster' : IDL.Func([], [R], []),
    'sell' : IDL.Func(
        [IDL.Vec(IDL.Tuple(IDL.Nat, IDL.Nat, IDL.Nat)), IDL.Nat],
        [R_2],
        [],
      ),
    'transferOwner' : IDL.Func([IDL.Principal], [R_1], []),
    'updateCrop' : IDL.Func([IDL.Nat, Crop], [R], []),
    'updatePrices' : IDL.Func([IDL.Nat, IDL.Tuple(IDL.Nat, IDL.Nat)], [R], []),
  });
};
export const init = ({ IDL }) => { return []; };
