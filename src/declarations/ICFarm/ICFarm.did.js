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
  const Result = IDL.Variant({ 'ok' : IDL.Nat, 'err' : IDL.Text });
  const Result_4 = IDL.Variant({
    'ok' : IDL.Vec(IDL.Tuple(IDL.Nat, IDL.Nat, IDL.Nat, IDL.Nat)),
    'err' : IDL.Text,
  });
  const Player = IDL.Record({
    'name' : IDL.Text,
    'plotIds' : IDL.Vec(IDL.Nat),
    'avatar' : IDL.Text,
  });
  const Result_1 = IDL.Variant({ 'ok' : Player, 'err' : IDL.Text });
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
  const Result_3 = IDL.Variant({ 'ok' : Inventory, 'err' : IDL.Text });
  const Result_2 = IDL.Variant({
    'ok' : IDL.Vec(IDL.Tuple(IDL.Nat, IDL.Nat)),
    'err' : IDL.Text,
  });
  const Time = IDL.Int;
  const Plot = IDL.Record({ 'cropId' : IDL.Opt(IDL.Nat), 'timestamp' : Time });
  return IDL.Service({
    'addCrop' : IDL.Func([Crop], [IDL.Nat], []),
    'addGameMasters' : IDL.Func(
        [IDL.Vec(IDL.Principal)],
        [IDL.Vec(IDL.Principal)],
        [],
      ),
    'buy' : IDL.Func(
        [IDL.Vec(IDL.Tuple(IDL.Nat, IDL.Nat, IDL.Nat)), IDL.Nat],
        [Result],
        [],
      ),
    'claimOwner' : IDL.Func([], [IDL.Principal], []),
    'getCrops' : IDL.Func([], [IDL.Vec(IDL.Tuple(IDL.Nat, Crop))], ['query']),
    'getPrices' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Nat, IDL.Tuple(IDL.Nat, IDL.Nat)))],
        ['query'],
      ),
    'harvest' : IDL.Func([IDL.Vec(IDL.Nat)], [Result_4], []),
    'initPlayer' : IDL.Func([IDL.Text, IDL.Text], [Result_1], []),
    'inventory' : IDL.Func([], [Result_3], ['query']),
    'listGameMasters' : IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
    'plant' : IDL.Func([IDL.Vec(IDL.Tuple(IDL.Nat, IDL.Nat))], [Result_2], []),
    'queryPlayer' : IDL.Func([IDL.Principal], [Result_1], ['query']),
    'queryPlots' : IDL.Func(
        [IDL.Vec(IDL.Nat)],
        [IDL.Vec(IDL.Tuple(IDL.Nat, IDL.Opt(Plot)))],
        ['query'],
      ),
    'removeGameMasters' : IDL.Func(
        [IDL.Vec(IDL.Principal)],
        [IDL.Vec(IDL.Principal)],
        [],
      ),
    'resignGameMaster' : IDL.Func([], [], []),
    'sell' : IDL.Func(
        [IDL.Vec(IDL.Tuple(IDL.Nat, IDL.Nat, IDL.Nat)), IDL.Nat],
        [Result],
        [],
      ),
    'transferOwner' : IDL.Func([IDL.Principal], [IDL.Principal], []),
    'updateCrop' : IDL.Func([IDL.Nat, Crop], [], []),
    'updatePrices' : IDL.Func([IDL.Nat, IDL.Tuple(IDL.Nat, IDL.Nat)], [], []),
  });
};
export const init = ({ IDL }) => { return []; };
