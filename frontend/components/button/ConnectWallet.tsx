import {
  Box,
  Text,
  Menu,
  MenuButton,
  MenuList,
  MenuItem,
  Button,
  Icon,
} from "@chakra-ui/react";
import { UsersIcon } from "@heroicons/react/solid";
import { useAccount } from "@starknet-react/core";
import Link from "next/link";

export const ConnectWallet = () => {
  const account = useAccount();
  if (!account.address) {
    return;
  }

  return (
    <Box pr="1em" pl="1em">
      <Button onClick={() => {}}></Button>
      <Menu>
        {({ isOpen }) => (
          <>
            <MenuButton
              isActive={isOpen}
              as={Button}
            >
              {isOpen ? "My profil" : "Account"}
              <Icon
                as={UsersIcon}
                width={"16px"}
                h="16px"
              ></Icon>
            </MenuButton>
            <MenuList>
              <MenuItem>
                <Button>
                  <Link href="/my-profil">My profil</Link>
                </Button>
              </MenuItem>
              <Text> {account.address}</Text>
            </MenuList>
          </>
        )}
      </Menu>
    </Box>
  );
};
