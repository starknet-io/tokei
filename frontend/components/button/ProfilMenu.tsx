import Link from "next/link";
import {
  Menu,
  MenuButton,
  MenuList,
  MenuItem,
  MenuItemOption,
  MenuGroup,
  MenuOptionGroup,
  MenuDivider,
  Button,
} from "@chakra-ui/react";
import { BiChevronDown } from "react-icons/bi";

export default function ProfilMenu() {
  return (
    <Menu>
      {({ isOpen }) => (
        <>
          <MenuButton
            isActive={isOpen}
            as={Button}
            rightIcon={<BiChevronDown />}
          >
            {isOpen && "My profil"}
          </MenuButton>
          <MenuList>
            <MenuItem>
              <Button>
                <Link href="/my-profil">My profil</Link>
              </Button>
            </MenuItem>

            {/* <MenuItem onClick={() => alert('Kagebunshin')}>Create a Copy</MenuItem> */}
          </MenuList>
        </>
      )}
    </Menu>
  );
}
