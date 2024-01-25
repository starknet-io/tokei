import React from "react";
import { IconType } from "react-icons";
import { Uint256 } from "starknet";

/** UI interface */
export interface LinkItemProps {
  name: string;
  title?: string;
  icon: IconType;
  href: string;
  target?: string;
  isExternal?: boolean;
  isSubmenu?: boolean;
  linksSubmenu?: LinkItemProps[];
}

export interface CreateStream extends StreamDurationProps {
  sender: string;
  recipient: string;
  total_amount: number;
  asset: string;
  cancelable: boolean;
  range: Range;
  broker: Broker;
  
}


export interface StreamDurationProps {
  total_amount: number;
  asset: string;
  cancelable: boolean;
  transferable: boolean;
  duration_cliff: number;
  duration_total: number;
  broker_account: string;
  broker_fee: Uint256;
  broker_fee_nb: number;
}


export interface CreateRangeProps {
  sender: string;
  recipient: string;
  total_amount: number;
  asset: string;
  cancelable: boolean;
  range: Range;
  broker: Broker;
  
}

/** Contract interface */

export interface LockupLinearStreamInterface {
  stream_id?:string;
  sender: string;
  recipient: string;
  total_amount: number;
  asset: string;
  cancelable: boolean;
  is_depleted:boolean;
  was_canceled:boolean;
  transferable:boolean;
  duration_cliff:number;
  duration_total;
  start_time?:number;
  end_time?:number;
  range: Range;
  broker: Broker;
  amounts?:LockupAmounts
}

export interface LockupAmounts {
  deposited:number;
  withdrawn:number;
  refunded:number;
}

export interface Range {
  start: number; //u64
  cliff: number; //u64
  end: number; //u64
}

export interface Broker {
  account:string;
  fee:number; // u128

}

