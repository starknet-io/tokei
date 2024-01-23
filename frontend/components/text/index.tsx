import { Text } from "@chakra-ui/react";

interface ITextSubtitleContainer {
  title: string;
  align?: string;
}
export const TextSubtitleContainer = ({
  title,
  align,
}: ITextSubtitleContainer) => {
  return (
    <Text
      fontFamily={"PressStart2P"}
      fontSize={{ base: "19px", md: "23px", lg: "25px" }}
    >
      {title}
    </Text>
  );
};


interface ITextSubtitleContainer {
  title: string;
  align?: string;
}
export const TextHeaderPage = ({
  title,
  align,
}: ITextSubtitleContainer) => {
  return (
    <Text
      fontWeight={500}
      fontFamily={"PressStart2P"} 
      fontSize={{ base: "25px", md: "31px", lg: "35px" }}
    >
      {title}
    </Text>
  );
};
