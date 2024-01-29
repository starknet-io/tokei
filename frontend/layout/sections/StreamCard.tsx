import { Box, Card, Text, Button, CardFooter } from "@chakra-ui/react";
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
import { formatDateTime, formatRelativeTime } from "../../utils/format";
import { BiCheck, BiCheckShield } from "react-icons/bi";
import { ExternalStylizedButtonLink, ExternalTransparentButtonLink } from "../../components/button/NavItem";
import { CONFIG_WEBSITE } from "../../constants";

interface IStreamCard {
  stream?: LockupLinearStreamInterface;
  viewType?: StreamCardView;
}

/** @TODO get component view ui with call claim reward for recipient visibile */
export const StreamCard = ({ stream, viewType }: IStreamCard) => {
  const startDateBn = Number(stream.start_time.toString());
  const startDate = new Date(startDateBn);

  const endDateBn = Number(stream.end_time.toString());
  const endDate = new Date(endDateBn);
  const account = useAccount().account;
  const address = account?.address;

  const [withdrawTo, setWithdrawTo] = useState<string | undefined>(address);
  useEffect(() => {
    const updateWithdrawTo = () => {
      if (!withdrawTo && address) {
        setWithdrawTo(address);
      }
    };
    updateWithdrawTo();
  }, [address]);

  const recipientAddress = feltToAddress(BigInt(stream.recipient.toString()));
  function timeAgo(date: Date): string {
    const now = new Date();
    const diffInSeconds = Math.floor((now.getTime() - date.getTime()) / 1000);

    if (diffInSeconds < 60) {
      return `${diffInSeconds} seconds ago`;
    } else if (diffInSeconds < 3600) {
      const minutes = Math.floor(diffInSeconds / 60);
      return `${minutes} minute${minutes > 1 ? 's' : ''} ago`;
    } else if (diffInSeconds < 86400) {
      const hours = Math.floor(diffInSeconds / 3600);
      return `${hours} hour${hours > 1 ? 's' : ''} ago`;
    } else {
      const days = Math.floor(diffInSeconds / 86400);
      return `${days} day${days > 1 ? 's' : ''} ago`;
    }
  }
  const senderAddress = feltToAddress(BigInt(stream.sender.toString()));
  let total_amount = stream?.amounts?.deposited
  return (
    <>
      <Card
        textAlign={"left"}
        // borderRadius={{ base: "1em" }}
        // borderRadius={"5em"}
        maxW={{ base: "100%" }}
        minH={{ base: "150px" }}
        py={{ base: "0.5em" }}
        p={{ base: "1.5em", md: "1.5em" }}
        w={{ base: "100%", md: "330px", lg: "450px" }}
        maxWidth={{ lg: "750px" }}
        rounded={"1em"}
        // mx={[5, 5]}
        overflow={"hidden"}
        justifyContent={"space-between"}
        border={"1px"}
        height={"100%"}
      >
        {/* <Text>Start Date: {startDate?.toString()}</Text> */}
        <Text>Start Date: {formatDateTime(startDate)}</Text>
        <Text>End Date: {timeAgo(endDate)}</Text>
        <Text>End Date: {formatDateTime(endDate)}</Text>

        {stream?.was_canceled && (
          <Box display={"flex"} gap="1em" alignItems={"baseline"}>
            Cancel <BiCheck color="red"></BiCheck>
          </Box>
        )}

        {stream?.is_depleted && (
          <Box display={"flex"} gap="1em" alignItems={"baseline"}>
            Depleted <BiCheckShield></BiCheckShield>
          </Box>
        )}

        {stream?.amounts?.withdrawn && (
          <Box display={"flex"} gap="1em" alignItems={"baseline"}>
            Withdraw <BiCheck></BiCheck>
            <Box>{stream?.amounts?.withdrawn.toString()}</Box>
          </Box>
        )}

        {stream?.stream_id && (
          <Box>
            Stream id:{" "}
            {shortString.decodeShortString(stream?.stream_id.toString())}
          </Box>
        )}

        <Text>Asset: {feltToAddress(BigInt(stream.asset.toString()))}</Text>
        <a href={`${CONFIG_WEBSITE.page.goerli_voyager_explorer}/contract/${recipientAddress}`}>Recipient</a>
        <ExternalStylizedButtonLink
        pb={{base:"0.5em"}}
          textOverflow={"no"}

          href={`${CONFIG_WEBSITE.page.goerli_voyager_explorer}/contract/${recipientAddress}`}>
          {/* <Text>{senderAddress}</Text> */}
          <Text>Sender explorer</Text>

        </ExternalStylizedButtonLink>
        <ExternalStylizedButtonLink

          href={`${CONFIG_WEBSITE.page.goerli_voyager_explorer}/contract/${recipientAddress}`}>
          <Text>Recipient explorer</Text>

        </ExternalStylizedButtonLink>

        <Box>
          <Text>Amount: {Number(total_amount) / 10 ** 18}</Text>

          <Box
            display={{ base: "flex" }}
            gap={{ base: "0.5em" }}
          >
            {stream?.amounts?.refunded &&
              <Text>
                Refunded  {Number(stream.amounts?.refunded) / 10 ** 18}
              </Text>
            }
            {stream?.amounts?.withdrawn &&
              <Text>
                Withdraw {Number(stream.amounts?.withdrawn) / 10 ** 18}

              </Text>
            }
          </Box>

        </Box>

        <CardFooter
          textAlign={"left"}
        >
          {senderAddress == address && (
            <Box>
              <Button
                onClick={() =>
                  cancelStream(
                    account,
                    CONTRACT_DEPLOYED_STARKNET[DEFAULT_NETWORK]
                      .lockupLinearFactory,
                    stream?.stream_id
                  )
                }
              >
                Cancel
              </Button>
            </Box>
          )}

          {recipientAddress == address && withdrawTo && !stream.was_canceled && (
            <Box>
              <Button
                onClick={() =>
                  withdraw_max(
                    account,
                    CONTRACT_DEPLOYED_STARKNET[DEFAULT_NETWORK]
                      .lockupLinearFactory,
                    stream?.stream_id,
                    withdrawTo
                  )
                }
              >
                Withdraw max
              </Button>
            </Box>
          )}
        </CardFooter>
      </Card>
    </>
  );
};
