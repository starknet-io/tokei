import {
  Box,
  Text,
  Button,
  Table,
  Thead,
  Tr,
  Th,
  Td,
  Tbody,
} from "@chakra-ui/react";
import { LockupLinearStreamInterface, StreamCardView } from "../../types";
import { feltToAddress, feltToString } from "../../utils/starknet";
import { useAccount } from "@starknet-react/core";
import { cancelStream } from "../../hooks/lockup/cancelStream";
import {
  CONTRACT_DEPLOYED_STARKNET,
  DEFAULT_NETWORK,
} from "../../constants/address";
import { formatDateTime, timeAgo } from "../../utils/format";
import { MdCancel } from "react-icons/md";

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
          <>
            <Thead>
              <Tr>
                <Th>Sender</Th>
                <Th>Actions</Th>

                <Th>Token address</Th>
                <Th>Amount deposit</Th>
                <Th>Date</Th>
                <Th>Status</Th>
                <Th>Withdraw</Th>
              </Tr>
            </Thead>
            <Tbody>
              {streams.length > 0 &&
                streams.map((s, i) => {
                  const sender = feltToAddress(BigInt(s?.sender));
                  const recipient = feltToAddress(BigInt(s?.recipient));
                  const asset = feltToAddress(BigInt(s?.asset));
                  let total_amount = s?.amounts?.deposited;
                  let total_withdraw = s?.amounts?.withdrawn;
                  console.log("s", s);
                  const startDateBn = Number(s.start_time.toString());
                  const startDate = new Date(startDateBn);

                  const endDateBn = Number(s.end_time.toString());
                  const endDate = new Date(endDateBn);

                  return (
                    <Tr key={i}
                      height={{ base: "100%" }}

                    >
                      <Td>
                        {sender?.slice(0, 10)} ...
                        {sender?.slice(sender?.length - 10, sender?.length)}{" "}
                      </Td>
                      <Box
                        gap={{ base: "1em" }}
                      >
                        <Td
                          w={"100%"}>
                          <Button
                            width={"100%"}
                            my={{ base: "0.15em" }}>Withdraw</Button>
                          <Button my={{ base: "0.15em" }}>Withdraw max</Button>
                        </Td>
                      </Box>
                      <Td>
                        {asset?.slice(0, 10)} ...
                        {asset?.slice(asset?.length - 10, asset?.length)}{" "}
                      </Td>
                      <Td>{Number(total_amount?.toString()) / 10 ** 18}</Td>
                      <Td
                        display={"flex"}
                      >
                        <Text>
                          Date: {formatDateTime(startDate)}

                        </Text>
                        <Text>
                          End  Date: {formatDateTime(endDate)}

                        </Text>

                      </Td>
                      <Td>{s.was_canceled && <Text >Cancel: <MdCancel></MdCancel>
                      </Text>}

                        {!s.was_canceled &&

                          <Text> {endDate.getTime() > new Date().getTime() ?
                            `Claimable in : ${timeAgo(endDate)}`
                            :
                            `Can be claim in : ${timeAgo(endDate)}`


                          }


                          </Text>}



                      </Td>

                      <Td>{Number(total_withdraw?.toString()) / 10 ** 18}</Td>

                    </Tr>
                  );
                  // }
                })}
            </Tbody>

          </>
        )}
        {viewType == StreamCardView.SENDER_VIEW && (
          <>
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
            <Tbody>
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
            </Tbody>
          </>
        )}
      </Table>
    </Box>
  );
};
