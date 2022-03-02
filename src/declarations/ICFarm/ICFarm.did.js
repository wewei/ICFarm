export const idlFactory = ({ IDL }) => {
  return IDL.Service({
    'addGameMasters' : IDL.Func(
        [IDL.Vec(IDL.Principal)],
        [IDL.Vec(IDL.Principal)],
        [],
      ),
    'listGameMasters' : IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
    'removeGameMasters' : IDL.Func(
        [IDL.Vec(IDL.Principal)],
        [IDL.Vec(IDL.Principal)],
        [],
      ),
    'resignGameMaster' : IDL.Func([], [], []),
  });
};
export const init = ({ IDL }) => { return []; };
