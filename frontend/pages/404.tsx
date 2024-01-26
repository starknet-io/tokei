import type { NextPage, NextPageContext } from "next";
import { useEffect } from "react";
import { Box, Text } from "@chakra-ui/react";
import HeaderSEO from "../components/HeaderSEO";
import { ButtonLink, ButtonLinkBasic } from "../components/button";
import { CONFIG_WEBSITE } from "../constants";
const ErrorPage: NextPage = () => {

  return (
    <>
      <HeaderSEO></HeaderSEO>
      <Box
        height={"100%"}
        width={"100%"}
        minH={{ base: "70vh" }}
      >
        <Text>{CONFIG_WEBSITE.title}</Text>
        <Box>
          <Box
            display={'grid'}
            gridTemplateColumns={{ base: "repeat(2,1fr)" }}
            gap={{base:"5%"}}
          >
            <ButtonLink
              href="/"
              title="Home" 
              />
          </Box>
        </Box>
      </Box>
    </>
  );
};

export default ErrorPage;
