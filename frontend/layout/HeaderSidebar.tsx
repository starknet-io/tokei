"use client";
import {
  IconButton,
  Box,
  CloseButton,
  Flex,
  HStack,
  Icon,
  useColorModeValue,
  Text,
  Drawer,
  DrawerContent,
  useDisclosure,
  BoxProps,
  FlexProps,
  Menu,
  MenuButton,
  MenuDivider,
  MenuItem,
  MenuList,
  useColorMode,
} from "@chakra-ui/react";
import { FiHome, FiMenu, FiChevronDown, FiUser } from "react-icons/fi";
import { IconType } from "react-icons";
import BottomMobileNavBar from "../components/BottomMobileNavBar";
import Link from "next/link";
import ConnectModal from "../components/modal/login";
import IconComponent from "../components/view/IconComponent";
import React from "react";
import { ButtonIconToggle } from "../components/button/color/ButtonToggle";
import { useRouter } from "next/router";
import { ToggleColor } from "../components/button/color/ToggleColor";
import { useAccount } from "@starknet-react/core";
import { CONFIG_WEBSITE } from "../constants";
import { LinkItemProps } from "../types";
import { IoCreate } from "react-icons/io5";


interface NavItemProps extends FlexProps {
  icon: IconType;
  children: React.ReactNode;
  href?: string;
}

interface IconNavItemProps extends FlexProps {
  icon?: IconType;
  children: React.ReactNode;
  href?: string;
  onClick: () => void;
}
interface MobileProps extends FlexProps {
  onOpen: () => void;
}

interface SidebarProps extends BoxProps {
  onClose: () => void;
}

const LinkItems: Array<LinkItemProps> = [
  { name: "Home", icon: FiHome, href: "/" },
  { name: "Create", icon: IoCreate, href: "/create" },
];

const SidebarContent = ({ onClose, ...rest }: SidebarProps) => {
  let color = useColorModeValue("gray.300", "gray.300");
  const [isOver, setIsOver] = React.useState<boolean | undefined>(false);
  const { colorMode, toggleColorMode } = useColorMode();
  return (
    <Box
      as="nav"
      transition="3s ease"
      bg={useColorModeValue("gray.300", "gray.900")}
      borderRight="1px"
      borderRightColor={useColorModeValue("gray.500", "gray.700")}
      w={{ base: "full", lg: "7em" }}
      _hover={{
        width: "11em",
      }}
      onMouseOver={() => {
        setIsOver(true);
      }}
      onMouseOut={() => {
        setIsOver(false);
      }}
      pos="fixed"
      h="full"
      {...rest}
    >
      <Flex h="20" alignItems="center" mx="8" justifyContent="space-between">
        <Link
          href="/"
        >
          <IconComponent
            src="/assets/logo.svg"
            alt="Starknet starter-pack"
            size="50px"
          />
        </Link>

        <CloseButton
          display={{ base: "flex", md: "none" }}
          onClick={onClose}
          color={color}
        />
      </Flex>
      <Box display={{ base: "grid" }} gap={{ base: "0.3em", md: "0.5em" }}>
        {LinkItems.map((link) => (
          <NavItem
            key={link.name}
            onClick={onClose}
            icon={link.icon}
            href={link.href}
          >
            {isOver && link.name}
          </NavItem>
        ))}
        <IconNavItem
          key={"toggle"}
          onClick={() => {
            toggleColorMode();
            onClose();
          }}

        >
          <ToggleColor />
        </IconNavItem>
      </Box>
    </Box>
  );
};

const SidebarContentMobile = ({ onClose, ...rest }: SidebarProps) => {
  let color = useColorModeValue("gray.700", "gray.500");
  let bg = useColorModeValue("gray.500", "gray.550");
  const { colorMode, toggleColorMode } = useColorMode();
  return (
    <Box
      transition="3s ease"
      bg={useColorModeValue("gray.300", "gray.900")}
      borderRight="1px"
      w={'100%'}
      borderRightColor={useColorModeValue("gray.500", "gray.700")}
      pos="fixed"
      h="full"
      {...rest}
    >
      <Flex h="20" alignItems="center" mx="8" justifyContent="space-between">
        <Link
          href="/"
        >
          <IconComponent
            src="/assets/logo.svg"
            alt={CONFIG_WEBSITE.title}
            size="50px"
          />
        </Link>

        <CloseButton
          display={{ base: "flex", md: "none" }}
          onClick={onClose}
          bg={bg}
          color={color}
        />
      </Flex>
      <Box display={{ base: "grid" }} gap={{ base: "0.3em", md: "0.5em" }}>
        {LinkItems.map((link) => (
          <NavItem
            key={link.name}
            onClick={onClose}
            icon={link.icon}
            href={link.href}
          >
            {link.name}
          </NavItem>
        ))}
        <IconNavItem

          key={"toggle"}
          onClick={() => {
            toggleColorMode();
            onClose();
          }}

        >
          <ToggleColor />
        </IconNavItem>
      </Box>
    </Box>
  );
};

const IconNavItem = ({ icon, children, href, ...rest }: IconNavItemProps) => {

  const color = useColorModeValue("gray.800", "gray.300");
  return (
    <Box
      _focus={{ boxShadow: "none" }}
      color={color}
    >
      <Flex
        align="center"
        p="4"
        mx="4"
        borderRadius="lg"
        role="group"
        cursor="pointer"
        _hover={{
          bg: "brand.primary",
          color: "white",
        }}
        {...rest}
      >
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
        {children}
      </Flex>
    </Box>
  );
};
const NavItem = ({ icon, children, href, ...rest }: NavItemProps) => {
  const color = useColorModeValue("gray.800", "gray.300");
  return (
    <Box
      as={Link}
      href={href}
      _focus={{ boxShadow: "none" }}
      color={color}
    >
      <Flex
        align="center"
        p="4"
        mx="4"
        borderRadius="lg"
        role="group"
        cursor="pointer"
        _hover={{
          bg: "brand.primary",
        }}
        fontSize={{ base: "15px" }}
        {...rest}
      >
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
        {children}
      </Flex>
    </Box>
  );
};

const MobileNav = ({ onOpen, ...rest }: MobileProps) => {

  const account = useAccount();
  const {
    isOpen,
    onOpen: onOpenConnectModal,
    onClose: onCloseConnectModal,
  } = useDisclosure();

  return (
    <Flex
      ml={{ base: 0, lg: "fit-content" }}
      px={{ base: 4, md: 4 }}
      height="20"
      alignItems="center"
      bg={useColorModeValue("gray.300", "gray.900")}
      borderBottomWidth="1px"
      borderBottomColor={useColorModeValue("gray.200", "gray.700")}
      justifyContent={{ base: "space-between", lg: "flex-end" }}
      {...rest}
    >
      <Box display={{ lg: "none" }}>
        <Link
          href="/"
        >
          <IconComponent

            src="/assets/logo.svg"
            alt="Starkent startup pack"
            size="50px"
          />
        </Link>
      </Box>

      <HStack spacing={{ base: "0", md: "6" }} gap={{ base: "0.75em" }}>
        <IconButton
          order={3}
          display={{ base: "flex", lg: "none" }}
          onClick={onOpen}
          color={useColorModeValue("gray.700", "gray.300")}
          variant="outline"
          aria-label="open menu"
          icon={<FiMenu />}
        />
        <ConnectModal
          modalOpen={isOpen}
          onClose={onCloseConnectModal}
          onOpen={onOpenConnectModal}
        />
        <Flex alignItems={"center"}>
          <Menu>
            <MenuButton
              py={2}
              transition="all 0.3s"
              _focus={{ boxShadow: "none" }}
            >
              <HStack>
                <Text>See more</Text>
                <Box display={{ base: "none", md: "flex" }}>
                  <FiChevronDown />
                </Box>
              </HStack>
            </MenuButton>
            <MenuList
            >
              <MenuItem as={Box}>
                <ConnectModal
                  modalOpen={isOpen}
                  onClose={onCloseConnectModal}
                  onOpen={onOpenConnectModal}
                />
              </MenuItem>
              {/* <MenuItem
                as={Box}
                width={"100%"}
              >
                <ButtonLinkBasic href="/my_profile" title="My profile" />
              </MenuItem> */}
              <MenuDivider />
              <MenuItem as={Box}>
                <ButtonIconToggle></ButtonIconToggle>
              </MenuItem>
            </MenuList>
          </Menu>
        </Flex>
      </HStack>
    </Flex>
  );
};

interface IHeaderSidebar {
  children: React.ReactNode;
}
const HeaderSidebar = ({ children }: IHeaderSidebar) => {
  const { isOpen, onOpen, onClose } = useDisclosure();

  const router = useRouter();
  const path = router.pathname;
  let isSidebarRight = PATH_SIDEBAR_DATA.includes(path);
  const {
    isOpen: isOpenCreate,
    onClose: onCloseCreate,
    onOpen: onOpenCreate,
  } = useDisclosure();
  return (
    <Box
      minH="100vh"
      // bg={useColorModeValue("gray.100", "black.300")}
    >
      <SidebarContent
        onClose={() => onClose}
        display={{ base: "none", lg: "block" }}
      />

      <Drawer
        isOpen={isOpen}
        placement="left"
        onClose={onClose}
        returnFocusOnClose={false}
        onOverlayClick={onClose}
      >
        <DrawerContent width={"80%"}>
          <SidebarContentMobile onClose={onClose} />
        </DrawerContent>
      </Drawer>
      <BottomMobileNavBar></BottomMobileNavBar>
      <MobileNav onOpen={onOpen} />
      <Box ml={{ base: 0, lg: "13em" }}>
        <Box display={"flex"}>{children}</Box>
      </Box>
    </Box>
  );
};

const PATH_SIDEBAR_DATA = ["/", "trendings", "explorer"];

const DATA_SIDEBAR = {
  "/": true,
  "/trendings": false,
};

export default HeaderSidebar;
