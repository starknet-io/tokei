import React from "react";
import { Box, CircularProgress, Icon, Flex } from "@chakra-ui/react";
import GearLoader from "./GearLoader";
const SocialLoader: React.FC = () => {
  return (
    <Box
      display={"grid"}
      alignItems="center"
      justifyItems="center"
      justifyContent={"center"}
    >
     
      <Flex
        align="center"
        justify="center"
        height={"100%"}
        width={"100%"}
        alignItems={"baseline"}
        alignContent={"baseline"}
        gap={{ base: "0.5em", md: "1em" }}
      >
        <Box h={"100%"}>
          <GearLoader></GearLoader>
        </Box>
      </Flex>
    </Box>
  );
};

export default SocialLoader;
