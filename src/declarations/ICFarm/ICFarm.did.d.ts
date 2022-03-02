import type { Principal } from '@dfinity/principal';
export interface Crop {
  'seedImage' : string,
  'seedPrice' : bigint,
  'seedRange' : [bigint, bigint],
  'seedName' : string,
  'productName' : string,
  'productImage' : string,
  'productPrice' : bigint,
  'phases' : Array<CropPhase>,
  'productRange' : [bigint, bigint],
}
export interface CropPhase {
  'period' : bigint,
  'name' : string,
  'image' : string,
}
export interface _SERVICE {
  'addCrop' : (arg_0: Crop) => Promise<bigint>,
  'addGameMasters' : (arg_0: Array<Principal>) => Promise<Array<Principal>>,
  'claimOwner' : () => Promise<Principal>,
  'getCrops' : () => Promise<Array<[bigint, Crop]>>,
  'getPrices' : () => Promise<Array<[bigint, [bigint, bigint]]>>,
  'listGameMasters' : () => Promise<Array<Principal>>,
  'removeGameMasters' : (arg_0: Array<Principal>) => Promise<Array<Principal>>,
  'resignGameMaster' : () => Promise<undefined>,
  'transferOwner' : (arg_0: Principal) => Promise<Principal>,
  'updateCrop' : (arg_0: bigint, arg_1: Crop) => Promise<undefined>,
  'updatePrices' : (arg_0: bigint, arg_1: [bigint, bigint]) => Promise<
      undefined
    >,
}
