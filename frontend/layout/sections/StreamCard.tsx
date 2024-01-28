import {
  Box,
  Card,
  Text,
  Button
} from "@chakra-ui/react";
import { LockupLinearStreamInterface } from "../../types";
import { cairo, shortString, stark, validateAndParseAddress } from "starknet";
import { feltToAddress, feltToString } from "../../utils/starknet";
import { useAccount } from "@starknet-react/core";
import { cancelStream } from "../../hooks/lockup/cancelStream";
import { CONTRACT_DEPLOYED_STARKNET, DEFAULT_NETWORK } from "../../constants/address";
import { withdraw_max } from "../../hooks/lockup/withdrawn";
import { useEffect, useState } from "react";

interface IStreamCard {
  stream?: LockupLinearStreamInterface
}
/** @TODO get component view ui with call claim reward for recipient visibile */
export const StreamCard = ({ stream }: IStreamCard) => {
  const startDateBn = Number(stream.start_time.toString())
  const startDate = new Date(startDateBn)

  const endDateBn = Number(stream.end_time.toString())
  const endDate = new Date(endDateBn)
  const account = useAccount().account
  const address = account?.address


  const [withdrawTo, setWithdrawTo] = useState<string|undefined>(address)
  useEffect(()=> {

    const updateWithdrawTo = () => {
      if(!withdrawTo && address) {
        setWithdrawTo(address)
      }
    }
    updateWithdrawTo()

  },[address])

  const recipientAddress = feltToAddress(BigInt(stream.recipient.toString()))

  const senderAddress = feltToAddress(BigInt(stream.sender.toString()))
  return (
    <>
      <Card
        textAlign={"left"}
        borderRadius={{ base: "1em" }}
        maxW={{ base: "100%" }}
        minH={{ base: "150px" }}
        py={{ base: "0.5em" }}
        w={{ base: "100%", lg: "350px" }}
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
          Start Date:  {startDate?.toString()}
        </Text>

        <Text>
          End Date:  {endDate?.toString()}
        </Text>

        {stream?.stream_id &&
          <Box>
            Stream id:  {shortString.decodeShortString(stream?.stream_id.toString())}
          </Box>
        }

        <Text>
          Asset: {feltToAddress(BigInt(stream.asset.toString()))}
        </Text>
        <Text>
          Sender: {senderAddress}
        </Text>
        <Text>
          Recipient: {recipientAddress}
        </Text>

        {senderAddress == address &&

          <Box>
            <Button onClick={() => cancelStream(account, CONTRACT_DEPLOYED_STARKNET[DEFAULT_NETWORK].lockupLinearFactory, stream?.stream_id)}>Cancel</Button>
          </Box>
        }

        {recipientAddress == address && withdrawTo &&

          <Box>
            <Button onClick={() => withdraw_max(account, 
              CONTRACT_DEPLOYED_STARKNET[DEFAULT_NETWORK].lockupLinearFactory,
               stream?.stream_id,
               withdrawTo
               )}>Withdraw max</Button>
          </Box>
        }


      </Card>


    </>
  );
};
