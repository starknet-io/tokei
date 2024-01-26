import { IconButton, useColorMode, useColorModeValue , Box} from "@chakra-ui/react";
import { BsMoon, BsSun } from "react-icons/bs";

export const ToggleColor = () => {
  const { colorMode, toggleColorMode } = useColorMode();

  return (
    <Box
      // p={{ base: "0.5em" }}
      // size="lg"
      // position="fixed"
      // bottom="5em"
      // right="7"
      onClick={toggleColorMode}
      // border="1px solid"
      // borderColor={`mode.${colorMode}.text`}
      // bg={useColorModeValue("gray.100", "gray.900")}
      // color={useColorModeValue("gray.700", "gray.100")}
      // color={`mode.${colorMode}.text`}
      aria-label="toggle dark mode"
      // icon={colorMode === "light" ? <BsMoon /> : <BsSun />}
    // zIndex="sticky"
    >
      {colorMode === "light" ? <BsMoon /> : <BsSun />}
    </Box>
  );
};
