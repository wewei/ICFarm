import type { Principal } from '@dfinity/principal';
export interface _SERVICE {
  'addGameMasters' : (arg_0: Array<Principal>) => Promise<Array<Principal>>,
  'listGameMasters' : () => Promise<Array<Principal>>,
  'removeGameMasters' : (arg_0: Array<Principal>) => Promise<Array<Principal>>,
  'resignGameMaster' : () => Promise<undefined>,
}
