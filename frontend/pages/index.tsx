import type { GetServerSideProps, NextPage, NextPageContext } from "next";
import {
  Box,
  Button,
  Image,
  Text,
  useColorModeValue,
  useDisclosure,
} from "@chakra-ui/react";
import HeaderSEO from "../components/HeaderSEO";
import { useAccount, useConnect, useDisconnect } from "@starknet-react/core";
import { ExternalStylizedButtonLink } from "../components/button/NavItem";
import { CONFIG_WEBSITE } from "../constants";
import ConnectModal from "../components/modal/login";

interface MyPageProps {}

const Home: NextPage<MyPageProps> = ({}) => {
  const accountStarknet = useAccount();

  const { connect, connectors } = useConnect();
  const { disconnect } = useDisconnect();
  const color = useColorModeValue("gray.900", "gray.300");
  const bg = useColorModeValue("gray.700", "gray.500");
  const address = accountStarknet?.account?.address;
  const {
    isOpen,
    onOpen: onOpenConnectModal,
    onClose: onCloseConnectModal,
  } = useDisclosure();
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
      >
        <Box display={{ lg: "flex" }} justifyContent={"space-between"}>
          <Box
            textAlign={{ base: "left", md: "center" }}
            p={{ base: "1em" }}
            minH={{ sm: "70vh" }}
            minW={{ lg: "950px" }}
            px={{ base: "1em" }}
            color={color}
          >
            <Box textAlign={"left"}
            py={{base:"0.5em"}}
            >
              <Image src="/assets/starknet_logo.svg"></Image>
              <Text
                fontFamily={"PressStart2P"}
                fontSize={{ base: "19px", md: "23px", lg: "27px" }}
              >
                {CONFIG_WEBSITE.title}✨💰⏳
              </Text>

              <Box width={{ base: "100%" }}>
                <ConnectModal
                  modalOpen={isOpen}
                  onClose={onCloseConnectModal}
                  onOpen={onOpenConnectModal}
                />
              </Box>
            </Box>
            {accountStarknet?.account && (
              <Box
                textAlign={"left"}
                display={{ base: "grid" }}
                gap={{ base: "0.5em", md: "1em" }}
              >
                <Text>Address:</Text>
                <Text width={{ base: "270px", md: "100%" }}>
                  {" "}
                  {accountStarknet?.account?.address}
                </Text>
                <ExternalStylizedButtonLink
                  href={`${CONFIG_WEBSITE.page?.explorer}/contract/${address}`}
                  width={"150px"}
                >
                  Explorer
                </ExternalStylizedButtonLink>

                <Button
                  width={"150px"}
                  onClick={() => {
                    disconnect();
                  }}
                >
                  Disconnect wallet
                </Button>
              </Box>
            )}
          </Box>
        </Box>
      </Box>
    </>
  );
};

export default Home;
