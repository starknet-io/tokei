// components/MobileNavBar.tsx
import {
  Box,
  Flex,
  IconButton,
  Link as LinkChakra,
  Spacer,
  Stack,
  useColorModeValue,
} from "@chakra-ui/react";
import { BiConversation, BiVideo } from "react-icons/bi";
import { BsQuestion } from "react-icons/bs";
import { FiHome, FiSearch, FiUser } from "react-icons/fi";
import { IoCreate } from "react-icons/io5";
import Link from "next/link";
import { CreateButtonFixed } from "./button/CreateButtonFixed";
const BottomMobileNavBar: React.FC = () => {
  let colorButton = "";
  let bg = useColorModeValue("green.100", "green.100");
  let bgReverted = useColorModeValue("gray.300", "gray.900");
  let color = useColorModeValue("green.100", "green.100");
  return (
    <Flex
      justify="center" // Center-align the content horizontally
      position="fixed"
      bottom="0"
      left="0"
      right="0"
      bg={bgReverted}
      display={{ lg: "none" }}
      zIndex="999"
    >
      <Stack
        direction="row"
        spacing={4}
        justify="center"
        justifyContent={"space-around"}
        display={"flex"}
        p={{ base: "0.7em", md: "1em" }}
      >
        {" "}
        <Link href="/">
          <IconButton
            aria-label="Home"
            icon={<FiHome size={"16px"} />}
            size="32px"
            bg="transparent"
            color="brand.primary"
          />
        </Link>
        <Link href="/create">
          <IconButton
            aria-label="Create"
            size="32px"
            icon={<IoCreate size={"16px"} />}
            color="brand.primary"
          />
        </Link>
   
      </Stack>
    </Flex>
  );
};

export default BottomMobileNavBar;
