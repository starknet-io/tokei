import { useEffect, ReactNode } from "react";
import { Box, BoxProps, VStack } from "@chakra-ui/react";

interface InfiniteScrollProps extends BoxProps {
  loadMore: () => void;
  hasMore: boolean;
  containerRef: React.RefObject<HTMLDivElement>;
  children: ReactNode;
  height?: string;
  propsElement?: BoxProps;
}

const InfiniteScrollSimple: React.FC<InfiniteScrollProps> = ({
  loadMore,
  hasMore,
  containerRef,
  children,
  height,
  propsElement,
}) => {
  const handleScroll = () => {
    const { scrollTop, clientHeight, scrollHeight } = containerRef.current!;
    if (scrollTop === 0) {
      loadMore();
    }
  };

  useEffect(() => {
    if (containerRef.current) {
      containerRef.current.addEventListener("scroll", handleScroll);
    }
    return () => {
      if (containerRef.current) {
        containerRef.current.removeEventListener("scroll", handleScroll);
      }
    };
  }, [handleScroll]);

  return (
    <Box
      ref={containerRef}
      width="100%"
      height={height ?? "450px"}
      {...propsElement}
      overflowY="scroll"
      className={"no-scrollbar scroll"}
      overflowX="hidden"
    >
      <VStack
        spacing={4}
        align="start"
        w={"100%"}
        // justifyContent="flex-end"
      >
        {children}
      </VStack>
      {hasMore && (
        <Box p={4} textAlign="center" fontWeight="bold">
          Loading more...
        </Box>
      )}
    </Box>
  );
};

export default InfiniteScrollSimple;
