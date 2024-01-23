import React from "react";
import { IconType } from "react-icons";

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

