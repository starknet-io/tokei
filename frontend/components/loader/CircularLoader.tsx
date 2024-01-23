import React from "react";
import { Spinner, Flex, Center, Text } from "@chakra-ui/react";
interface IFullPageLoader {
  text?: string;
}
const CircularLoader: React.FC = ({ text }: IFullPageLoader) => {
  return (
    <Center flex="1">
      <Spinner size="lg" color="blue.500" thickness="4px" />
      {text && <Text ml="4">{text ?? "Loading..."}</Text>}
    </Center>
  );
};

export default CircularLoader;
