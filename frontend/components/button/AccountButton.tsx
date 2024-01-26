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

export const AccountButton = () => {
  const account = useAccount();
  const address = account.address;
  return (
    <Menu
    >
      {({ isOpen }) => (
        <>
          <MenuButton
            as={Button}
            width={{ base: "100%" }}
          >
            <span>
              {isOpen ? "My profil" : "My account"}
              <Icon
                as={UsersIcon}
                width={"16px"}
                h="16px"
              ></Icon>
            </span>
          </MenuButton>
          <MenuList>
            <MenuItem>
              <Text> {account?.address}</Text>{" "}
            </MenuItem>
          </MenuList>
        </>
      )}
    </Menu>
  );
};
