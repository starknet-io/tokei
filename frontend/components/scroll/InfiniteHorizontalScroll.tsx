import { useEffect, ReactNode } from "react";
import { Box, BoxProps, VStack, HStack } from "@chakra-ui/react";

interface InfiniteScrollProps extends BoxProps {
  loadMore?: () => void;
  hasMore?: boolean;
  containerRef?: React.RefObject<HTMLDivElement>;
  children: ReactNode;
  height?: string;
  propsElement?: BoxProps;
}

const InfiniteHorizontalScroll: React.FC<InfiniteScrollProps> = ({
  loadMore,
  hasMore,
  containerRef,
  children,
  height,
  propsElement,
}) => {
  const handleScroll = () => {
    const { scrollTop, clientHeight, scrollHeight, scrollLeft } =
      containerRef?.current!;
    if (scrollTop === 0) {
      loadMore();
    }
  };

  useEffect(() => {
    if (containerRef?.current) {
      containerRef?.current.addEventListener("scroll", handleScroll);
    }
    return () => {
      if (containerRef?.current) {
        containerRef?.current.removeEventListener("scroll", handleScroll);
      }
    };
  }, [handleScroll]);

  return (
    <Box
      ref={containerRef}
      width="100%"
      height={height ?? "450px"}
      {...propsElement}
      overflowX="scroll"
    >
      <HStack spacing={4} align="start" justifyContent="flex-end">
        {children}
      </HStack>
      {hasMore && (
        <Box p={4} textAlign="center" fontWeight="bold">
          Loading more...
        </Box>
      )}
    </Box>
  );
};

export default InfiniteHorizontalScroll;
