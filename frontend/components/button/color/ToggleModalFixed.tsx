import { IconButton, useColorMode, useColorModeValue } from "@chakra-ui/react";
import { BsMoon, BsSun } from "react-icons/bs";
import { SiLivejournal } from "react-icons/si";

export const ToggleModalFixed = () => {
  const { colorMode, toggleColorMode } = useColorMode();

  return (
    <IconButton
      size="lg"
      position="fixed"
      bottom="5em"
      right="7"
      onClick={toggleColorMode}
      border="1px solid"
      borderColor={`mode.${colorMode}.text`}
      aria-label="toggle dark mode"
      icon={colorMode === "light" ? <SiLivejournal /> : <SiLivejournal />}
      zIndex="sticky"
    >
      Toggle {colorMode === "light" ? "Dark" : "Light"}
    </IconButton>
  );
};
