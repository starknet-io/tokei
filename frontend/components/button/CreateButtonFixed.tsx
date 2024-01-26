import { Box, IconButton, useColorMode, useColorModeValue, useDisclosure, Button } from "@chakra-ui/react";
import { BsMoon, BsSun } from "react-icons/bs";
import { SiLivejournal } from "react-icons/si";
import Link from "next/link";
interface IAdminPanelGroup {
  modalOpen: boolean;
  onClose: () => void;
  onOpen: () => void;
}
export const CreateButtonFixed = ({ modalOpen, onClose, onOpen }: IAdminPanelGroup) => {
  const { colorMode, toggleColorMode } = useColorMode();
  console.log("modalOpen", modalOpen)
  return (

    <Box

    >
   
      <Button
        position="fixed"
        bottom={{base:"5em",lg:"1.5em"}}
        right="7"
        as={Link}
        href="/create"
        >
        <SiLivejournal />
      </Button>
    </Box>

  );
};
