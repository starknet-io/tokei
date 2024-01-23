import { Box, Flex, SimpleGrid, useDisclosure } from "@chakra-ui/react";
import { ReactNode, useRef, useEffect, useState } from "react";

interface HorizontalSliderProps {
  children: ReactNode[];
  isNotMaxWidthLg?: boolean;
}

const cardWidth = 300; // Width of each card

const HorizontalSlider: React.FC<HorizontalSliderProps> = ({ children, isNotMaxWidthLg }) => {
  const scrollableContainerRef = useRef<HTMLDivElement | null>(null);
  const [scrollPosition, setScrollPosition] = useState(0);
  const { isOpen, onToggle } = useDisclosure();

  const handleScrollLeft = () => {
    if (scrollableContainerRef.current) {
      scrollableContainerRef.current.scrollLeft -= cardWidth;
      setScrollPosition((prevPosition) => prevPosition - cardWidth);
    }
  };

  const handleScrollRight = () => {
    if (scrollableContainerRef.current) {
      scrollableContainerRef.current.scrollLeft += cardWidth;
      setScrollPosition((prevPosition) => prevPosition + cardWidth);
    }
  };

  return (
    <Flex direction="column" alignItems="center" flex={1}
    width={"100%"}
    >
      <Flex mt={2}>
        <Box
          cursor="pointer"
          onClick={handleScrollLeft}
          opacity={isOpen ? 1 : 0}
          transition="opacity 0.3s"
        >
          &#9664;
        </Box>
        <Box
          cursor="pointer"
          onClick={handleScrollRight}
          ml={2}
          opacity={isOpen ? 1 : 0}
          transition="opacity 0.3s"
        >
          &#9654;
        </Box>
      </Flex>
      <Box
        maxW="100%" // Adjust the width as needed
        // maxW={{base:"100%",lg:!isNotMaxWidthLg? "550px": "100%"}}
        overflowX="auto"
        overflowY="hidden"
        whiteSpace="nowrap"
        ref={scrollableContainerRef}
      >
        <SimpleGrid
          display="flex"
          // minChildWidth={{ base: "200px", md: "350px" }}
          maxW={{ base: "100%", lg: !isNotMaxWidthLg ? "550px" : "100%" }}

          spacingX={4}
        // p={4}
        >
          {children}
        </SimpleGrid>
      </Box>
    </Flex>
  );
};

export default HorizontalSlider;
