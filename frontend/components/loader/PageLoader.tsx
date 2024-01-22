import React from 'react';
import { Box,  Flex } from '@chakra-ui/react';
import GearLoader from './GearLoader';

const PageLoader: React.FC = () => {
    return (

        <Box
        display={"grid"}
        alignItems="center" 
        justifyItems="center"
        justifyContent={"center"}
        >
            <GearLoader></GearLoader>
            <Flex 
            align="center" justify="center"
                height={"100%"}
                width={"100%"}
                alignItems={"baseline"}
                alignContent={"baseline"}
                gap={{base:"0.5em",md:"1em"}}

            >
            </Flex>
        </Box>

    );
};

export default PageLoader;
