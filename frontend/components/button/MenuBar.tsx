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
  Text,
  useColorModeValue,
  useDisclosure,
  Box,
  HStack,
  Drawer,
  Flex,
  Icon,
} from "@chakra-ui/react";
import StylizedButtonLink, { ExternalStylizedButtonLink } from "./NavItem";
import { LinkItemProps } from "../../types";
export default function MenuBar({
  title,
  href,
  isSubmenu,
  linksSubmenu,
  icon,
}: 
LinkItemProps) {
  const { isOpen, onOpen, onClose } = useDisclosure();
  return (
    <HStack
    >
      <Menu
      >
        {({ isOpen }) => (
          <>
            <Flex>
              <MenuButton
                as={Button}
                onClick={onOpen}
                display="inline-flex"
                alignItems="center"
                width={"100%"}
              >
                {icon && <Icon as={icon} marginRight={2} />}
                {title}
              </MenuButton>

            </Flex>
            
            <MenuList
              p="1em"
              gap="1em"
              zIndex={1000}
            >
              {isSubmenu &&
                linksSubmenu &&
                linksSubmenu.length > 0 &&
                linksSubmenu.map((link, i) => {
                  return (
                    <Box p={{ sm: "0.5em" }}>
                      {link?.isSubmenu ? (
                        <MenuBar {...link}>{link.title}</MenuBar>
                      ) : link.isExternal ? (
                        <ExternalStylizedButtonLink
                          key={link.name}
                          icon={link.icon}
                          href={link.href}
                          isExternal={link.isExternal}
                          title={link?.title}
                        >
                          {link.name}
                        </ExternalStylizedButtonLink>
                      ) : (
                        <StylizedButtonLink
                          key={link.name}
                          icon={link.icon}
                          href={link.href}
                          isExternal={link.isExternal}
                          title={link.title}
                        >
                          {link.name}
                        </StylizedButtonLink>
                      )}
                     
                    </Box>
                  );
                })}
            </MenuList>
          </>
        )}
      </Menu>
    </HStack>
  );
}
