import React from "react";
import { IconType } from "react-icons";

export interface CreateRangeProps {
  sender: string;
  recipient: string;
  total_amount: number;
  asset: string;
  cancelable: boolean;
  range: Range;
  broker: Broker;
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
