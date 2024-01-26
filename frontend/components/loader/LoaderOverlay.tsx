import React from 'react';
import { Box, CircularProgress, Icon, Flex } from '@chakra-ui/react';
import { FaPodcast, FaStream, FaUserFriends } from 'react-icons/fa';
import { CiStreamOn } from 'react-icons/ci';

const LoaderOverlay: React.FC = () => {
    return (

        <Box
        display={"grid"}
        alignItems="center" 
        justifyItems="center"
        justifyContent={"center"}
        >
            <CircularProgress
                isIndeterminate
                trackColor="gray.200"
            />
            <Flex 
            align="center" justify="center"
                height={"100%"}
                width={"100%"}
                alignItems={"baseline"}
                alignContent={"baseline"}
                gap={{base:"0.5em",md:"1em"}}
            >
                    <Icon as={FaUserFriends}
                        boxSize={{ base: "8", md: "10" }}
                        mb={4}
                    />
                    <Icon as={CiStreamOn}
                        boxSize={{ base: "8", md: "10" }}
                    />
                    <Icon as={FaPodcast}
                        boxSize={{ base: "8", md: "10" }}
                    />
            </Flex>
        </Box>

    );
};

export default LoaderOverlay;
