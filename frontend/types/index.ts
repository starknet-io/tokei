import React from "react";
import { IconType } from "react-icons";


export interface LinkItemProps {
    name: string;
    title?:string;
    icon: IconType;
    href: string;
    target?: string;
    isExternal?: boolean;
    isSubmenu?: boolean;
    linksSubmenu?: LinkItemProps[];
  }