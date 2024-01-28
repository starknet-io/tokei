import {
  Box,
  Card,
  Text,
} from "@chakra-ui/react";
import { LockupLinearStreamInterface } from "../../types";
import { cairo, shortString, stark, validateAndParseAddress } from "starknet";
import { feltToAddress, feltToString } from "../../utils/starknet";

interface IStreamCard {
  stream?: LockupLinearStreamInterface
}
/** @TODO get component view ui with call claim reward for recipient visibile */
export const StreamCard = ({ stream }: IStreamCard) => {
  const startDateBn = Number(stream.start_time.toString())
  const startDate = new Date(startDateBn)

  return (
    <>
      <Card
        textAlign={"left"}
        borderRadius={{ base: "1em" }}
        maxW={{ base: "100%" }}
        minH={{ base: "150px" }}
        py={{ base: "0.5em" }}
        w={{ base: "100%", lg: "750px" }}
        maxWidth={{ lg: "750px" }}
        rounded={"sm"}
        mx={[5, 5]}
        overflow={"hidden"}
        border={"1px"}
        // borderColor="black"
        // boxShadow={colorBoxShadow}
        // bg={bg}
        height={"100%"}
        p='1em'
      >
        <Text>
          {stream?.stream_id &&
            <Box>
              Stream id:  {shortString.decodeShortString(stream?.stream_id)}
            </Box>
          }

        </Text>

        <Text>
          Asset: {feltToAddress(BigInt(stream.asset.toString()))}
        </Text>
        <Text>
          Recipient: {feltToAddress(BigInt(stream.recipient.toString()))}
        </Text>
        <Text>
          Date:  {startDate?.toString()}
        </Text>
      </Card>


    </>
  );
};
