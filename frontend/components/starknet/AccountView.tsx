import { Box, Button, Text, useColorModeValue } from "@chakra-ui/react";
import { useAccount, useDisconnect } from "@starknet-react/core";
import { ExternalStylizedButtonLink } from "../button/NavItem";
import { CONFIG_WEBSITE } from "../../constants";

interface IAccountView {
  isViewDisconnectButton?: boolean;
  isViewExplorer?: boolean;
}
const AccountView = ({
  isViewDisconnectButton,
  isViewExplorer,
}: IAccountView) => {
  const accountStarknet = useAccount();
  const { disconnect } = useDisconnect();
  const color = useColorModeValue("gray.900", "gray.300");
  const bg = useColorModeValue("gray.700", "gray.500");
  const address = accountStarknet?.account?.address;

  return (
    <>
      <Box>
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

            {isViewExplorer && (
              <ExternalStylizedButtonLink
                href={`${CONFIG_WEBSITE.page?.explorer}/contract/${address}`}
                width={"150px"}
              >
                Explorer
              </ExternalStylizedButtonLink>
            )}

            {isViewDisconnectButton && (
              <Button
                width={"150px"}
                onClick={() => {
                  disconnect();
                }}
              >
                Disconnect wallet
              </Button>
            )}
          </Box>
        )}
      </Box>
    </>
  );
};

export default AccountView;
