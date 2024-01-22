import React, { ReactNode, useEffect, useRef, useState } from "react";
import {
  Box,
  Flex,
  Icon,
  Link as LinkChakra,
  FlexProps,
  Button,
  ButtonProps,
  useColorModeValue,
} from "@chakra-ui/react";
import { IconType } from "react-icons";
import Link from "next/link";

interface NavItemProps extends FlexProps {
  icon: IconType;
  children: ReactNode;
  href: string;
}

export const NavItem = ({ icon, children, href, ...rest }: NavItemProps) => {
  return (
    <Button as={Link} href={href} width={"100%"} gap={3} p={3}>
      <Box>
        <Flex align="center" borderRadius="lg" role="group">
          {icon && (
            <Icon
              mr="4"
              fontSize="16"
              _groupHover={{
                color: "white",
              }}
              as={icon}
            />
          )}
        </Flex>
      </Box>
    </Button>
  );
};

interface StylizedButtonLinkProps extends ButtonProps {
  icon?: IconType;
  href: string;
  title?: string;
  text?: string;
  children: React.ReactNode;
  isExternal?: boolean;
  onClick?: () => void;
}

export const StylizedButtonLink: React.FC<StylizedButtonLinkProps> = ({
  icon,
  title,
  text,
  href,
  children,
  isExternal,
  onClick,
  ...rest
}) => (
  <Button
    display="inline-flex"
    alignItems="center"
    justifyItems={"left"}
    justifyContent={"left"}
    textAlign={"left"}
    width={"100%"}
  >
    <Box
      as={Link}
      href={href}
      width={"100%"}
      textAlign={"left"}
      justifyItems={"left"}
      justifyContent={"left"}
      title={title ?? `ToolFiBot link ${isExternal && "external"}`}
    >
      <Box justifyContent={"left"} justifyItems={"left"} textAlign={"left"}>
        {icon && <Icon as={icon} marginRight={2} />}
        {children}
      </Box>
    </Box>
  </Button>
);

interface ILearnMoreButton extends ButtonProps {
  scrollToElement?: () => void;
  title?: string;
  rest?: ButtonProps;
  text?: string;
}

export const LearnMoreButton: React.FC<ILearnMoreButton> = (props) => {
  return (
    <Button
      mt={"0.5em"}
      w="100%"
      p="1em"
      title={props.title}
      fontFamily={"monospace"}
      rounded={"full"}
      onClick={props.scrollToElement}
      px={6}
      _hover={{
        bg: "brand.complement",
      }}
    >
      {props.text ? props.text : "Learn more"}
    </Button>
  );
};


export const ExternalStylizedButtonLink: React.FC<StylizedButtonLinkProps> = ({
  icon,
  href,
  text,
  title,
  children,
  ...rest
}) => {
  return (
    <Box as={LinkChakra} title={title} {...rest} href={href} target="_blank">
      <Button
        rel="noopener noreferrer"
        display="inline-flex"
        alignItems="center"
        width={"100%"}
        {...rest}
      >
        {icon && <Icon as={icon} marginRight={2} />}
        {children}
      </Button>
    </Box>
  );
};

export default StylizedButtonLink;
