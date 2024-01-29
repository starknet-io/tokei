import {
  Box,
  Card,
  Text,
  Button,
  CardFooter,
  Table,
  Thead,
  Tr,
  Th,
  Td,
} from "@chakra-ui/react";
import { LockupLinearStreamInterface, StreamCardView } from "../../types";
import { cairo, shortString, stark, validateAndParseAddress } from "starknet";
import { feltToAddress, feltToString } from "../../utils/starknet";
import { useAccount } from "@starknet-react/core";
import { cancelStream } from "../../hooks/lockup/cancelStream";
import {
  CONTRACT_DEPLOYED_STARKNET,
  DEFAULT_NETWORK,
} from "../../constants/address";
import { withdraw_max } from "../../hooks/lockup/withdrawn";
import { useEffect, useState } from "react";
import { formatRelativeTime } from "../../utils/format";
import { BiCheck } from "react-icons/bi";

interface IStreamCard {
  streams?: LockupLinearStreamInterface[];
  stream?: LockupLinearStreamInterface;
  viewType?: StreamCardView;
}

/** @TODO get component view ui with call claim reward for recipient visibile */
export const TableViewStreams = ({ viewType, streams }: IStreamCard) => {
  const account = useAccount().account;
  return (
    <Box overflowX={"auto"}>
      <Table overflow={"auto"} overflowX={"auto"}>
        {viewType == StreamCardView.RECIPIENT_VIEW && (
          <Box>
            <Thead>
              <Tr>
                <Th>Sender</Th>
                <Th>Token address</Th>
                <Th>Amount deposit</Th>
                <Th>Withdraw</Th>
                <Th>Actions</Th>
              </Tr>
            </Thead>
            {streams.length > 0 &&
              streams.map((s, i) => {
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
                    <Box
                      //  display={"grid"}
                      gap={{ base: "1em" }}
                    >
                      <Td>
                        <Button my={{ base: "0.15em" }}>Withdraw</Button>
                        <Button my={{ base: "0.15em" }}>Withdraw max</Button>
                      </Td>
                    </Box>
                  </Tr>
                );
                // }
              })}
          </Box>
        )}
        {viewType == StreamCardView.SENDER_VIEW && (
          <Box overflowX={"auto"}>
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
                  <Th>Actions</Th>
                </Tr>
              </Thead>
              {streams?.length > 0 &&
                streams.map((s, i) => {
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
                        {sender?.slice(
                          sender?.length - 10,
                          sender?.length
                        )}{" "}
                      </Td>
                      <Td>
                        {asset?.slice(0, 10)} ...
                        {asset?.slice(asset?.length - 10, asset?.length)}{" "}
                      </Td>
                      <Td>{Number(total_amount?.toString()) / 10 ** 18}</Td>
                      <Td>{Number(total_withdraw?.toString()) / 10 ** 18}</Td>
                      <Box>
                        <Td>
                          <Button
                            onClick={() => {
                              cancelStream(
                                account,
                                CONTRACT_DEPLOYED_STARKNET[DEFAULT_NETWORK]
                                  .lockupLinearFactory,
                                s?.stream_id
                              );
                            }}
                          >
                            Cancel
                          </Button>
                        </Td>
                      </Box>
                    </tr>
                  );
                  // }
                })}
            </Table>
          </Box>
        )}
      </Table>
    </Box>
  );
};
