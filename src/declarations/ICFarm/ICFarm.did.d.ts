import type { Principal } from '@dfinity/principal';
export type AssocList = [] | [[[Key, [bigint, bigint]], List]];
export interface Branch { 'left' : Trie, 'size' : bigint, 'right' : Trie }
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
export type Hash = number;
export interface Inventory { 'crops' : Map, 'tokens' : bigint }
export interface Key { 'key' : bigint, 'hash' : Hash }
export interface Leaf { 'size' : bigint, 'keyvals' : AssocList }
export type List = [] | [[[Key, [bigint, bigint]], List]];
export type Map = { 'branch' : Branch } |
  { 'leaf' : Leaf } |
  { 'empty' : null };
export interface Player {
  'name' : string,
  'plotIds' : Array<bigint>,
  'avatar' : string,
}
export interface Plot { 'cropId' : [] | [bigint], 'timestamp' : Time }
export type R = { 'ok' : bigint } |
  { 'err' : string };
export type R_1 = { 'ok' : Player } |
  { 'err' : string };
export type R_2 = { 'ok' : Array<[bigint, bigint]> } |
  { 'err' : string };
export type R_3 = { 'ok' : Inventory } |
  { 'err' : string };
export type R_4 = { 'ok' : [Player, Inventory] } |
  { 'err' : string };
export type R_5 = { 'ok' : Array<[bigint, bigint, bigint, bigint]> } |
  { 'err' : string };
export type Time = bigint;
export type Trie = { 'branch' : Branch } |
  { 'leaf' : Leaf } |
  { 'empty' : null };
export interface _SERVICE {
  'addCrop' : (arg_0: Crop) => Promise<bigint>,
  'addGameMasters' : (arg_0: Array<Principal>) => Promise<Array<Principal>>,
  'buy' : (arg_0: Array<[bigint, bigint, bigint]>, arg_1: bigint) => Promise<R>,
  'claimOwner' : () => Promise<Principal>,
  'getCrops' : () => Promise<Array<[bigint, Crop]>>,
  'getPrices' : () => Promise<Array<[bigint, [bigint, bigint]]>>,
  'harvest' : (arg_0: Array<bigint>) => Promise<R_5>,
  'initPlayer' : (arg_0: string, arg_1: string) => Promise<R_4>,
  'inventory' : () => Promise<R_3>,
  'listGameMasters' : () => Promise<Array<Principal>>,
  'plant' : (arg_0: Array<[bigint, bigint]>) => Promise<R_2>,
  'queryPlayer' : (arg_0: Principal) => Promise<R_1>,
  'queryPlots' : (arg_0: Array<bigint>) => Promise<
      Array<[bigint, [] | [Plot]]>
    >,
  'removeGameMasters' : (arg_0: Array<Principal>) => Promise<Array<Principal>>,
  'resignGameMaster' : () => Promise<undefined>,
  'sell' : (arg_0: Array<[bigint, bigint, bigint]>, arg_1: bigint) => Promise<
      R
    >,
  'transferOwner' : (arg_0: Principal) => Promise<Principal>,
  'updateCrop' : (arg_0: bigint, arg_1: Crop) => Promise<undefined>,
  'updatePrices' : (arg_0: bigint, arg_1: [bigint, bigint]) => Promise<
      undefined
    >,
}
