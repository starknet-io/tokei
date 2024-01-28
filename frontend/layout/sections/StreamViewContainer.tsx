import {
  Tabs,
  TabList,
  TabPanels,
  Tab,
  TabPanel,
  Text,
  Card,
  Box,
  useColorModeValue
} from "@chakra-ui/react";
import { useAccount } from "@starknet-react/core";
import { useEffect, useState } from "react";
import { LockupLinearStreamInterface } from "../../types";
import { get_streams_by_sender } from "../../hooks/lockup/get_streams_by_sender";
import {
  CONTRACT_DEPLOYED_STARKNET,
  DEFAULT_NETWORK,
} from "../../constants/address";
import { get_streams_by_recipient } from "../../hooks/lockup/get_streams_by_recipient";
import { StreamCard } from "./StreamCard";


enum EnumStreamSelector {
  SENDER = "SENDER",
  RECIPIENT = "RECIPIENT"
}
/** @TODO getters Cairo contracts, Indexer */
export const StreamViewContainer = () => {
  const [streamsSend, setStreamsSend] = useState<LockupLinearStreamInterface[]>([]);
  const [selectView, setSelectView] = useState<EnumStreamSelector>(EnumStreamSelector.SENDER)
  console.log("streams state Send", streamsSend)
  return (
    <>

      <Tabs
        minH={{ base: "250px", md: "350px" }}
        variant="enclosed"
        alignItems={"center"}
        gap={{ sm: "1em" }}
      >
        <TabList>
          {/* <Tab>All streams</Tab> */}

          <Tab
            onClick={() => setSelectView(EnumStreamSelector.SENDER)}
          >As recipient</Tab>

          <Tab
            onClick={() => setSelectView(EnumStreamSelector.SENDER)}
          >As sender</Tab>

          {/* <Tab>Search</Tab> */}
        </TabList>

        <TabPanels>
          {/* <TabPanel>
            <AllStreamComponent></AllStreamComponent>
          </TabPanel> */}
          <TabPanel>
            <RecipientStreamComponent></RecipientStreamComponent>
          </TabPanel>
          <TabPanel>
            <SenderStreamComponent
              streamsSend={streamsSend}
              setStreamsSend={setStreamsSend}
            />
          </TabPanel>


          {/* <TabPanel>
            <SearchStreamComponent></SearchStreamComponent>
          </TabPanel> */}
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
  const [streamsReceived, setStreamsSend] =
    useState<LockupLinearStreamInterface[]>([]);

  useEffect(() => {
    const getStreamsByRecipient = async () => {
      const contractAddress =
        CONTRACT_DEPLOYED_STARKNET[DEFAULT_NETWORK].lockupLinearFactory;
      let streams = await get_streams_by_recipient(
        account?.address,
        contractAddress
      );
      console.log('streams receive', streams)

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
      {streamsReceived.length > 0 && streamsReceived.map((s, i) => {
        return (<Box
          key={i}
        >
          <Text>
            {s.asset}

          </Text>
          <Text>
            {s.recipient}
          </Text>
        </Box>)
      })}
    </Box>
  );
};

interface ISenderStreamComponent {
  streamsSend: LockupLinearStreamInterface[]
  setStreamsSend: (lockups: LockupLinearStreamInterface[]) => void;

}
/** @TODO Cairo spec recipient component */
const SenderStreamComponent = ({
  streamsSend,
  setStreamsSend
}: ISenderStreamComponent) => {
  const account = useAccount();
  useEffect(() => {
    const getStreamsBySender = async () => {
      const contractAddress =
        CONTRACT_DEPLOYED_STARKNET[DEFAULT_NETWORK].lockupLinearFactory;
      let streams = await get_streams_by_sender(
        account?.address,
        contractAddress
      );
      console.log("streams send", streams)
      setStreamsSend(streams);
    };

    if (account?.address) {
      getStreamsBySender();
    }
  }, [account?.address]);
  const colorText = useColorModeValue("gray.700", "gray.300");
  const bg = useColorModeValue("gray.300", "gray.700");

  return (
    <Box>
      <Text>Find here your stream</Text>
      <Text>Total: {streamsSend.length}</Text>

      <Box
        // display={"grid"}
        // gap={{ base: "0.5em" }}

        display={"grid"}
        gridTemplateColumns={{
          md: "repeat(1,1fr)",
          lg: "repeat(3,1fr)",
        }}
        gap={{ base: "0.5em" }}
      >
        {streamsSend.length > 0 && streamsSend.map((s, i) => {
          console.log("s", s)
          return (
            <StreamCard stream={s} key={i} />
          )
        }
        )
        }
      </Box>

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
