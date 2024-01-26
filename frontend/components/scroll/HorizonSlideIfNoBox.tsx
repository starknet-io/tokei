// components/HorizontalSlider.tsx
import { Box, Flex, SimpleGrid, useDisclosure } from "@chakra-ui/react";
import { ReactNode, useRef, useEffect, useState } from "react";

interface HorizontalSliderProps {
  children: ReactNode[];
}

const cardWidth = 300; // Width of each card
const HorizontalSlider: React.FC<HorizontalSliderProps> = ({ children }) => {
  const scrollableContainerRef = useRef<HTMLDivElement | null>(null);
  const [scrollPosition, setScrollPosition] = useState(0);
  const { isOpen, onToggle } = useDisclosure();
  useEffect(() => {
    if (scrollableContainerRef.current) {
      scrollableContainerRef.current.scrollTo({
        left: 0,
        behavior: "smooth", // Optional: Add smooth scrolling behavior
      });
    }
  }, []);

  const handleScrollLeft = () => {
    if (scrollableContainerRef.current) {
      scrollableContainerRef.current.scrollTo({
        left: scrollableContainerRef.current.scrollLeft - 200, // Adjust scroll distance as needed
        behavior: "smooth", // Optional: Add smooth scrolling behavior
      });
      setScrollPosition((prevPosition) => prevPosition - cardWidth);
    }
  };

  const handleScrollRight = () => {
    if (scrollableContainerRef.current) {
      scrollableContainerRef.current.scrollTo({
        left: scrollableContainerRef.current.scrollLeft + 200, // Adjust scroll distance as needed
        behavior: "smooth", // Optional: Add smooth scrolling behavior
      });
      setScrollPosition((prevPosition) => prevPosition - cardWidth);
    }
  };

  return (
    <Flex direction="column" alignItems="center">
      <Box
        maxW={{ base: "100%", md: "100%" }}
        // overflowX="auto"
        overflowX={"scroll"}
        // overflowY="hidden"
        whiteSpace="nowrap"
        // sx={{
        //     '&::-webkit-scrollbar': {
        //         width: '15px',
        //     },
        //     '&::-webkit-scrollbar-thumb': {
        //         // bg: 'gray.300',
        //         bg: "black",
        //         borderRadius: 'full',
        //     },
        // }}
        ref={scrollableContainerRef}
      >
        <SimpleGrid
          overflowX={"scroll"}
          // overflowY={"scroll"}
          display={"flex"}
          minChildWidth={{ base: "200px", md: "350px" }}
          // minChildWidth="200px" // Adjust the minimum child width as needed
          spacingX={4}
          p={4}
          // width="max-content" // Ensure the content doesn't wrap to a new line
        >
          {children}
        </SimpleGrid>
      </Box>
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
    </Flex>
  );
};

export default HorizontalSlider;
