import {
  Tabs,
  TabList,
  TabPanels,
  Tab,
  TabPanel,
  Box,
  Text,
} from "@chakra-ui/react";
import { useAccount } from "@starknet-react/core";
import { useEffect, useState } from "react";
import { LockupLinearStreamInterface } from "../../types";
import { get_streams_by_sender } from "../../hooks/lockup/get_streams_by_sender";
import {
  CONTRACT_DEPLOYED_STARKNET,
  DEFAULT_NETWORK,
} from "../../constants/address";

/** @TODO getters Cairo contracts, Indexer */
export const StreamViewContainer = () => {
  return (
    <>
      <Tabs>
        <TabList>
          <Tab>All streams</Tab>
          <Tab>As recipient</Tab>
          <Tab>As sender</Tab>
          <Tab>Search</Tab>
        </TabList>

        <TabPanels>
          <TabPanel>
            <AllStreamComponent></AllStreamComponent>
          </TabPanel>
          <TabPanel>
            <RecipientStreamComponent></RecipientStreamComponent>
          </TabPanel>
          <TabPanel>
            <SenderStreamComponent></SenderStreamComponent>
          </TabPanel>
          <TabPanel>
            <SearchStreamComponent></SearchStreamComponent>
          </TabPanel>
        </TabPanels>
      </Tabs>
    </>
  );
};

/** @TODO Cairo spec to be defined. */
const AllStreamComponent = () => {
  return (
    <Box>
      <Text>Find all streams</Text>
      <Text>Coming soon</Text>
    </Box>
  );
};

/** @TODO Cairo spec recipient component */
const RecipientStreamComponent = () => {
  const account = useAccount();
  const [streamsSend, setStreamsSend] =
    useState<LockupLinearStreamInterface[]>();

  useEffect(() => {
    const getStreamsByRecipient = async () => {
      const contractAddress =
        CONTRACT_DEPLOYED_STARKNET[DEFAULT_NETWORK].lockupLinearFactory;
      let streams = await get_streams_by_sender(
        account?.address,
        contractAddress
      );
      setStreamsSend(streams);
    };

    if (account?.address) {
      getStreamsByRecipient();
    }
  }, [account?.address]);
  return (
    <Box>
      <Text>Find here your stream</Text>
      <Text>Coming soon</Text>
    </Box>
  );
};

/** @TODO Cairo spec recipient component */
const SenderStreamComponent = () => {
  const account = useAccount();
  const [streamsSend, setStreamsSend] =
    useState<LockupLinearStreamInterface[]>();

  useEffect(() => {
    const getStreamsBySender = async () => {
      const contractAddress =
        CONTRACT_DEPLOYED_STARKNET[DEFAULT_NETWORK].lockupLinearFactory;
      let streams = await get_streams_by_sender(
        account?.address,
        contractAddress
      );
      setStreamsSend(streams);
    };

    if (account?.address) {
      getStreamsBySender();
    }
  }, [account?.address]);
  return (
    <Box>
      <Text>Find here your stream</Text>
      <Text>Coming soon</Text>
    </Box>
  );
};

/** @TODO add search stream components. Spec to be defined. */
const SearchStreamComponent = () => {
  return (
    <Box>
      <Text>Coming soon</Text>
    </Box>
  );
};
