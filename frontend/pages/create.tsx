import type { GetServerSideProps, NextPage, NextPageContext } from "next";
import {
  Box,
  Text
} from "@chakra-ui/react";
import HeaderSEO from "../components/HeaderSEO";
import { useAccount, useConnect, useDisconnect } from "@starknet-react/core";
import CreateStreamForm from "../components/form/create";

const Create: NextPage = ({}) => {
  return (
    <>
      <HeaderSEO></HeaderSEO>

      <Box
        height={"100%"}
        width={"100%"}
        minH={{ sm: "70vh" }}
        overflow={"hidden"}
        alignContent={"center"}
        justifyItems={"center"}
        justifyContent={"center"}
        alignItems={"center"}
        textAlign={"center"}
        py={{base:"2em"}}
      >
        <CreateStreamForm/>
      </Box>
    </>
  );
};

export default Create;
