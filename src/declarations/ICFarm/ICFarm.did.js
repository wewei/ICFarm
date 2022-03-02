export const idlFactory = ({ IDL }) => {
  return IDL.Service({
    'addGameMasters' : IDL.Func(
        [IDL.Vec(IDL.Principal)],
        [IDL.Vec(IDL.Principal)],
        [],
      ),
    'claimOwner' : IDL.Func([], [IDL.Principal], []),
    'listGameMasters' : IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
    'removeGameMasters' : IDL.Func(
        [IDL.Vec(IDL.Principal)],
        [IDL.Vec(IDL.Principal)],
        [],
      ),
    'resignGameMaster' : IDL.Func([], [], []),
    'transferOwner' : IDL.Func([IDL.Principal], [IDL.Principal], []),
  });
};
export const init = ({ IDL }) => { return []; };
