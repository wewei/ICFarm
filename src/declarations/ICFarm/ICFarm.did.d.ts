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
export type R = { 'ok' : null } |
  { 'err' : string };
export type R_1 = { 'ok' : Inventory } |
  { 'err' : string };
export type R_10 = { 'ok' : bigint } |
  { 'err' : string };
export type R_2 = { 'ok' : Array<[bigint, [] | [Plot]]> } |
  { 'err' : string };
export type R_3 = { 'ok' : Player } |
  { 'err' : string };
export type R_4 = { 'ok' : Array<[bigint, bigint]> } |
  { 'err' : string };
export type R_5 = { 'ok' : [Player, Inventory] } |
  { 'err' : string };
export type R_6 = { 'ok' : Array<[bigint, bigint, bigint, bigint]> } |
  { 'err' : string };
export type R_7 = { 'ok' : Array<[bigint, [bigint, bigint]]> } |
  { 'err' : string };
export type R_8 = { 'ok' : Array<Principal> } |
  { 'err' : string };
export type R_9 = { 'ok' : Array<[bigint, Crop]> } |
  { 'err' : string };
export type Time = bigint;
export type Trie = { 'branch' : Branch } |
  { 'leaf' : Leaf } |
  { 'empty' : null };
export interface _SERVICE {
  'addCrop' : (arg_0: Crop) => Promise<R_10>,
  'addGameMasters' : (arg_0: Array<Principal>) => Promise<R>,
  'buy' : (arg_0: Array<[bigint, bigint, bigint]>, arg_1: bigint) => Promise<
      R_1
    >,
  'claimOwner' : () => Promise<R>,
  'getCrops' : () => Promise<R_9>,
  'getGameMasters' : () => Promise<R_8>,
  'getPrices' : () => Promise<R_7>,
  'harvest' : (arg_0: Array<bigint>) => Promise<R_6>,
  'initPlayer' : (arg_0: string, arg_1: string) => Promise<R_5>,
  'inventory' : () => Promise<R_1>,
  'plant' : (arg_0: Array<[bigint, bigint]>) => Promise<R_4>,
  'queryPlayer' : (arg_0: Principal) => Promise<R_3>,
  'queryPlots' : (arg_0: Array<bigint>) => Promise<R_2>,
  'removeGameMasters' : (arg_0: Array<Principal>) => Promise<R>,
  'resignGameMaster' : () => Promise<R>,
  'sell' : (arg_0: Array<[bigint, bigint, bigint]>, arg_1: bigint) => Promise<
      R_1
    >,
  'transferOwner' : (arg_0: Principal) => Promise<R>,
  'updateCrop' : (arg_0: bigint, arg_1: Crop) => Promise<R>,
  'updatePrices' : (arg_0: bigint, arg_1: [bigint, bigint]) => Promise<R>,
}
