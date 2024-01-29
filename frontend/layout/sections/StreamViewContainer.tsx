import {
  Tabs,
  TabList,
  TabPanels,
  Tab,
  TabPanel,
  Text,
  Card,
  Box,
  useColorModeValue,
  Button,
  Table,
  Thead,
  Tr,
  Th,
  Td,
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
import { feltToAddress } from "../../utils/starknet";

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
  const account = useAccount().account
  const [streamsSend, setStreamsSend] = useState<LockupLinearStreamInterface[]>(
    []
  );

  const [streamsReceived, setStreamsReceived] = useState<LockupLinearStreamInterface[]>(
    []
  );
  const [selectView, setSelectView] = useState<EnumStreamSelector>(
    EnumStreamSelector.SENDER
  );
  const [viewType, setViewType] = useState<ViewType>(ViewType.CARDS);
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

    if (account?.address) {
      getStreamsBySender();
    }
  }, [account?.address]);

  return (
    <>
      <Box>
        <Button onClick={() => setViewType(ViewType.CARDS)}>Card</Button>
        <Button onClick={() => setViewType(ViewType.TABS)}>Tabs</Button>
      </Box>

      <Tabs
        minH={{ base: "250px", md: "350px" }}
        variant="enclosed"
        alignItems={"center"}
        gap={{ sm: "1em" }}
      >
        <TabList>
          {/* <Tab>All streams</Tab> */}

          <Tab onClick={() => setSelectView(EnumStreamSelector.SENDER)}>
            As recipient
          </Tab>

          <Tab onClick={() => setSelectView(EnumStreamSelector.SENDER)}>
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
            streamsReceivedProps={streamsSend}
            setStreamsReceivedProps={setStreamsSend}
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

/** @TODO Cairo spec to be defined. */
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

/** @TODO Cairo spec recipient component */
const RecipientStreamComponent = ({
  streamsReceivedProps,
  setStreamsReceivedProps,
  viewType,
  setViewType,
}: IRecipientStreamComponent) => {
  const account = useAccount();
  const [streamsReceived, setStreamsReiceived] =
    useState<LockupLinearStreamInterface[]>(streamsReceivedProps);

  useEffect(() => {
    const getStreamsByRecipient = async () => {
      const contractAddress =
        CONTRACT_DEPLOYED_STARKNET[DEFAULT_NETWORK].lockupLinearFactory;
      let streams = await get_streams_by_recipient(
        account?.address,
        contractAddress
      );
      console.log("streams receive", streams);

      setStreamsReceivedProps(streams);
      setStreamsReiceived(streams)
    };

    if (account?.address) {
      getStreamsByRecipient();
    }
  }, [account?.address]);
  return (
    <Box>
      <Text>Check the streams you can receive here.</Text>
      <Text>Total: {streamsReceived?.length}</Text>
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
          {streamsReceived?.length > 0 &&
            streamsReceived.map((s, i) => {
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

      {viewType == ViewType.TABS && (
        <Table
        overflow={"auto"}
        overflowX={"auto"}

        >
          <Thead>
            <Tr>
              <Th>Sender</Th>
              <Th>Token address</Th>
              <Th>Amount deposit</Th>
              <Th>Withdraw</Th>
              <Th>Call</Th>
            </Tr>
          </Thead>
          {streamsReceived.length > 0 &&
            streamsReceived.map((s, i) => {
              const sender = feltToAddress(BigInt(s?.sender));
              const recipient = feltToAddress(BigInt(s?.recipient));
              const asset = feltToAddress(BigInt(s?.asset));
              let total_amount = s?.amounts?.deposited;
              let total_withdraw = s?.amounts?.withdrawn;
              console.log("s", s);
              return (
                <Tr key={i}>
                  <Td>
                    {sender?.slice(0, 10)} ...
                    {sender?.slice(sender?.length - 10, sender?.length)}{" "}
                  </Td>
                  <Td>
                    {asset?.slice(0, 10)} ...
                    {asset?.slice(asset?.length - 10, asset?.length)}{" "}
                  </Td>
                  <Td>{Number(total_amount?.toString()) / 10 ** 18}</Td>
                  <Td>{Number(total_withdraw?.toString()) / 10 ** 18}</Td>
                  <Td>{Number(total_withdraw?.toString()) / 10 ** 18}</Td>
                  <Td>
                    <Box>
                      <Button>Cancel</Button>
                      <Button>Withdraw</Button>
                    </Box>
                  </Td>
                </Tr>
              );
              // }
            })}
        </Table>
      )}
    </Box>
  );
};

interface ISenderStreamComponent {
  streamsSend: LockupLinearStreamInterface[];
  setStreamsSend: (lockups: LockupLinearStreamInterface[]) => void;
  viewType?: ViewType;
  setViewType: (viewType: ViewType) => void;
}
/** @TODO Cairo spec recipient component */
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
      <Text>Total: {streamsSend.length}</Text>

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

      {viewType == ViewType.TABS && (
        <Table
        // display={"grid"}
        // gridTemplateColumns={{
        //   base: "repeat(1,1fr)",
        //   md: "repeat(2,1fr)",
        // }}
        // gap={{ base: "0.5em" }}
        >
          <Thead>
            <Tr>
              {/* <Th>Sender</Th> */}
              <Th>Token address</Th>
              <Th>Amount deposit</Th>
              <Th>Withdraw</Th>
              <Th>Recipient</Th>
              <Th>Call</Th>
            </Tr>
          </Thead>
          {streamsSend.length > 0 &&
            streamsSend.map((s, i) => {
              const sender = feltToAddress(BigInt(s?.sender));
              const recipient = feltToAddress(BigInt(s?.recipient));
              const asset = feltToAddress(BigInt(s?.asset));
              let total_amount = s?.amounts?.deposited;
              let total_withdraw = s?.amounts?.withdrawn;
              console.log("s", s);
              return (
                <tr key={i}>
                  <Td>
                    {sender?.slice(0, 10)} ...
                    {sender?.slice(sender?.length - 10, sender?.length)}{" "}
                  </Td>
                  <Td>
                    {asset?.slice(0, 10)} ...
                    {asset?.slice(asset?.length - 10, asset?.length)}{" "}
                  </Td>
                  <Td>{Number(total_amount?.toString()) / 10 ** 18}</Td>
                  <Td>{Number(total_withdraw?.toString()) / 10 ** 18}</Td>
                  <Td>{Number(total_withdraw?.toString()) / 10 ** 18}</Td>
                  <Td>
                    <Box>
                      <Button>Cancel</Button>
                      <Button>Withdraw</Button>
                    </Box>
                  </Td>
                </tr>
              );
              // }
            })}
        </Table>
      )}
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
