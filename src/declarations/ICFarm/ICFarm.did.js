export const idlFactory = ({ IDL }) => {
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
  return IDL.Service({
    'addCrop' : IDL.Func([Crop], [IDL.Nat], []),
    'addGameMasters' : IDL.Func(
        [IDL.Vec(IDL.Principal)],
        [IDL.Vec(IDL.Principal)],
        [],
      ),
    'claimOwner' : IDL.Func([], [IDL.Principal], []),
    'getCrops' : IDL.Func([], [IDL.Vec(IDL.Tuple(IDL.Nat, Crop))], ['query']),
    'listGameMasters' : IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
    'removeGameMasters' : IDL.Func(
        [IDL.Vec(IDL.Principal)],
        [IDL.Vec(IDL.Principal)],
        [],
      ),
    'resignGameMaster' : IDL.Func([], [], []),
    'transferOwner' : IDL.Func([IDL.Principal], [IDL.Principal], []),
    'updateCrop' : IDL.Func([IDL.Nat, Crop], [], []),
  });
};
export const init = ({ IDL }) => { return []; };
