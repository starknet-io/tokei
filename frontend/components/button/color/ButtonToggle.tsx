
import { IconButton, useColorMode, useColorModeValue } from "@chakra-ui/react";
import { BsMoon, BsSun } from "react-icons/bs";

export const ButtonIconToggle = () => {
  const { colorMode, toggleColorMode } = useColorMode();

  return (
    <IconButton
      onClick={toggleColorMode}
      border="1px solid"
      borderColor={`mode.${colorMode}.text`}
      aria-label="toggle dark mode"
      icon={colorMode === "light" ? <BsMoon /> : <BsSun />}
    >
      Toggle {colorMode === "light" ? "Dark" : "Light"}
    </IconButton>
  );
};
