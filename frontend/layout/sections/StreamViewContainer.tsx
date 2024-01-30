import {
  Tabs,
  TabList,
  TabPanels,
  Tab,
  TabPanel,
  Text,
  Card,
  Box,
  Button,
} from "@chakra-ui/react";
import { useAccount } from "@starknet-react/core";
import { useEffect, useState } from "react";
import { LockupLinearStreamInterface, StreamCardView } from "../../types";
import { get_streams_by_sender } from "../../hooks/lockup/get_streams_by_sender";
import {
  CONTRACT_DEPLOYED_STARKNET,
  DEFAULT_NETWORK,
} from "../../constants/address";
import { get_streams_by_recipient } from "../../hooks/lockup/get_streams_by_recipient";
import { StreamCard } from "./StreamCard";
import { TableViewStreams } from "./TableViewStreams";
import { BiCard, BiTable } from "react-icons/bi";
import { BsCardChecklist, BsCardList } from "react-icons/bs";

enum EnumStreamSelector {
  SENDER = "SENDER",
  RECIPIENT = "RECIPIENT",
}

enum ViewType {
  TABS = "TABS",
  CARDS = "CARDS",
}
/** @TODO getters Cairo contracts, Indexer */
export const StreamViewContainer = () => {
  const account = useAccount().account;
  const [streamsSend, setStreamsSend] = useState<LockupLinearStreamInterface[]>(
    []
  );

  const [streamsReceived, setStreamsReceived] = useState<
    LockupLinearStreamInterface[]
  >([]);
  const [selectView, setSelectView] = useState<EnumStreamSelector>(
    EnumStreamSelector.SENDER
  );
  const [viewType, setViewType] = useState<ViewType>(ViewType.TABS);
  console.log("streams state Send", streamsSend);

  useEffect(() => {
    const getStreamsBySender = async () => {
      const contractAddress =
        CONTRACT_DEPLOYED_STARKNET[DEFAULT_NETWORK].lockupLinearFactory;
      let streams = await get_streams_by_sender(
        account?.address,
        contractAddress
      );
      console.log("streams send", streams);
      setStreamsSend(streams);
    };

    const getStreamsByRecipient = async () => {
      const contractAddress =
        CONTRACT_DEPLOYED_STARKNET[DEFAULT_NETWORK].lockupLinearFactory;
      let streams = await get_streams_by_recipient(
        account?.address,
        contractAddress
      );
      console.log("streams recipient", streams);
      setStreamsReceived(streams);
    };
    if (
      account?.address
      // &&  selectView == EnumStreamSelector.SENDER
    ) {
      getStreamsBySender();
    }
    if (
      account?.address
      //  && selectView== EnumStreamSelector.RECIPIENT
    ) {
      getStreamsByRecipient();
    }
  }, [account?.address, account]);

  return (
    <>
      <Box display={"flex"} gap="1em"
      py={{base:"1em"}}
      textAlign={"right"}
      justifyContent={"right"}
      >
        <Button onClick={() => setViewType(ViewType.TABS)}>Tabs <BiTable></BiTable></Button>
        <Button onClick={() => setViewType(ViewType.CARDS)}>Card <BsCardChecklist></BsCardChecklist></Button>
      </Box>

      <Tabs
        minH={{ base: "250px", md: "350px" }}
        variant="enclosed"
        // variant={""}
        alignItems={"center"}
        gap={{ sm: "1em" }}
      >
        <TabList
        
        >
          {/* <Tab>All streams</Tab> */}

          <Tab onClick={() => setSelectView(EnumStreamSelector.RECIPIENT)}
          // color={"brand.primary"}
          _selected={{ color: 'brand.primary',  }}
          >
            As recipient
          </Tab>

          <Tab onClick={() => setSelectView(EnumStreamSelector.SENDER)}
          // color={"brand.primary"}
          _selected={{ color: 'brand.primary', }}
          >
            As sender
          </Tab>

          {/* <Tab>Search</Tab> */}
        </TabList>

        <TabPanels>
          {/* <TabPanel>
            <AllStreamComponent></AllStreamComponent>
          </TabPanel> */}
          <TabPanel>
            <RecipientStreamComponent
              streamsReceivedProps={streamsReceived}
              setStreamsReceivedProps={setStreamsReceived}
              setViewType={setViewType}
              viewType={viewType}
            ></RecipientStreamComponent>
          </TabPanel>
          <TabPanel>
            <SenderStreamComponent
              streamsSend={streamsSend}
              setStreamsSend={setStreamsSend}
              setViewType={setViewType}
              viewType={viewType}
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

const AllStreamComponent = () => {
  return (
    <Box>
      <Text>Find all streams</Text>
      <Text>Coming soon</Text>
    </Box>
  );
};

interface IRecipientStreamComponent {
  streamsReceivedProps: LockupLinearStreamInterface[];
  setStreamsReceivedProps: (lockups: LockupLinearStreamInterface[]) => void;
  viewType?: ViewType;
  setViewType: (viewType: ViewType) => void;
}

const RecipientStreamComponent = ({
  streamsReceivedProps,
  setStreamsReceivedProps,
  viewType,
  setViewType,
}: IRecipientStreamComponent) => {
  const account = useAccount();
  console.log("streamsReceivedProps", streamsReceivedProps);
  return (
    <Box>
      <Text>Check the streams you can receive here.</Text>
      <Text>Total: {streamsReceivedProps?.length}</Text>
      {viewType == ViewType.CARDS && (
        <Box
          // display={"grid"}
          // gap={{ base: "0.5em" }}

          display={"grid"}
          gridTemplateColumns={{
            base: "repeat(1,1fr)",
            md: "repeat(2,1fr)",
          }}
          gap={{ base: "0.5em" }}
        >
          {streamsReceivedProps?.length > 0 &&
            streamsReceivedProps.map((s, i) => {
              // if (!s?.was_canceled) {
              return (
                <StreamCard
                  stream={s}
                  key={i}
                  viewType={StreamCardView.RECIPIENT_VIEW}
                />
              );
              // }
            })}
        </Box>
      )}

      <TableViewStreams
        streams={streamsReceivedProps}
        viewType={StreamCardView.RECIPIENT_VIEW}
      ></TableViewStreams>

    </Box>
  );
};

interface ISenderStreamComponent {
  streamsSend: LockupLinearStreamInterface[];
  setStreamsSend: (lockups: LockupLinearStreamInterface[]) => void;
  viewType?: ViewType;
  setViewType: (viewType: ViewType) => void;
}
const SenderStreamComponent = ({
  streamsSend,
  setStreamsSend,
  viewType,
  setViewType,
}: ISenderStreamComponent) => {
  const account = useAccount();

  return (
    <Box>
      <Text>Find here your stream</Text>
      <Text>Total: {streamsSend?.length}</Text>

      {viewType == ViewType.CARDS && (
        <Box
          display={"grid"}
          gridTemplateColumns={{
            base: "repeat(1,1fr)",
            md: "repeat(2,1fr)",
          }}
          gap={{ base: "0.5em" }}
        >
          {streamsSend.length > 0 &&
            streamsSend.map((s, i) => {
              console.log("s", s);

              if (!s?.was_canceled) {
                return (
                  <StreamCard
                    stream={s}
                    key={i}
                    viewType={StreamCardView.SENDER_VIEW}
                  />
                );
              }
            })}
        </Box>
      )}

      <TableViewStreams
        streams={streamsSend}
        viewType={StreamCardView.SENDER_VIEW}
      ></TableViewStreams>

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
