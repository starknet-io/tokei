import {
  Box,
  Button,
  Input,
  useToast,
  Text,
  FormLabel,
} from "@chakra-ui/react";
import { useAccount, useConnect, useDisconnect, useStarkAddress } from "@starknet-react/core";
import { useEffect, useState } from "react";
import { CallData, Provider, cairo, constants, stark ,} from "starknet";
import {
  CONTRACT_DEPLOYED_STARKNET,
  DEFAULT_NETWORK,
} from "../../../constants/address";
import { CreateRangeProps } from "../../../types";
import e from "cors";
import { ADDRESS_LENGTH } from "../../../constants";
interface ICreateStream {}

const CreateStreamForm = ({}: ICreateStream) => {
  const toast = useToast();
  const accountStarknet = useAccount();
  const account = accountStarknet?.account;
  const address = accountStarknet?.account?.address;
  const [isDisabled, setIsDisabled] = useState<boolean>(true);
  const [recipient, setRecipient] = useState<boolean>(true);
  const [form, setForm] = useState<CreateRangeProps | undefined>({
    sender: account?.address,
    recipient: undefined,
    total_amount: undefined,
    asset: undefined,
    cancelable: undefined,
    range: {
      start: undefined,
      cliff: undefined,
      end: undefined,
    },
    broker: {
      account: undefined,
      fee: undefined,
    },
  });

  useEffect(() => {
    if (address && account) {
      setIsDisabled(false);
      setForm({...form, sender:address})
    }
  }, [accountStarknet, account, address]);

  const handleCreateStream = async () => {
    const CONTRACT_ADDRESS = CONTRACT_DEPLOYED_STARKNET[DEFAULT_NETWORK];

    if (!CONTRACT_ADDRESS.lockupLinearFactory?.toString()) {
      toast({
        title: `Contract Lockup linear is not deployed in ${DEFAULT_NETWORK}.`,
        isClosable:true,
        duration:1500
      });
      return;
    }

    /** Check value before send tx */
    
    if (!address) {
      toast({
        title: "Connect your account",
        status: "warning",
        isClosable:true,
        duration:1000

      });
      return;
    }

    if (!form?.sender) {
      toast({
        title: "Connect your account",
        status: "warning",
        isClosable:true,
        duration:1000


      });
      return;
    }


    if (!form?.total_amount) {
      toast({
        title: "Provide Total amount to lockup",
        status: "warning",
        isClosable:true,
        duration:1000


      });
      return;
    }

    /** Address verification */

    if (!form?.asset?.length) {
      toast({
        title: "Asset not provided",
        status: "warning",
        isClosable:true,

      });
      return;
    } 
  
    /***@TODO use starknet check utils isAddress */
    if(form?.asset?.length < ADDRESS_LENGTH){
      toast({
        title: "Asset is not address size. Please verify your ERC20 address",
        status: "warning",
        isClosable:true,

      });
      return;
    }

    if (!form?.recipient) {
      toast({
        title: "Recipient not provided",
        status: "warning",
        isClosable:true,

      });
      return;
    }
    /***@TODO use starknet check utils isAddress */

    if(form?.recipient?.length < ADDRESS_LENGTH){
      toast({
        title: "Recipient is not address size. Please verify your recipient address",
        status: "warning",
        isClosable:true,
      });
      return;
    }



    if (!form?.broker?.fee) {
      toast({
        title: "No fees provided",
        status: "warning",
      });
      return;
    }

    if (!form?.broker?.account) {
      toast({
        title: "No broker account provided",
        status: "warning",
      });
      return;
    }

    if (!form?.range.start) {
      toast({
        title: "Provide Start date",
        status: "warning",
      });
      return;
    }

    if (!form?.range.end) {
      toast({
        title: "Please provide End date",
        status: "warning",
      });
      return;
    }

    if (!form?.range.cliff) {
      toast({
        title: "Please provide Cliff",
        status: "warning",
      });
      return;
    }

    const result = await account.execute({
      contractAddress: CONTRACT_ADDRESS.lockupLinearFactory?.toString(),
      entrypoint: "create_with_range",
      calldata: CallData.compile({
        sender: account?.address,
        recipient: form.recipient,
        total_amount: form?.total_amount,
        asset: form?.asset,
        cancelable: form?.cancelable,
        range: {
          ...form.range,
        },
        broker: { ...form.broker },
      }),
    });
    const provider = new Provider({
      sequencer: { network: constants.NetworkName.SN_GOERLI },
    });
    await provider.waitForTransaction(result.transaction_hash);
  };
  return (
    <Box width={{ base: "100%" }} py={{ base: "1em", md: "2em" }}
    px={{base:"1em"}}
    >
      <Text fontFamily={"PressStart2P"}>
        Start creating your lockup linear vesting
      </Text>

      <Box
        py={{ base: "1em", md: "2em" }}
        display={{md:"flex"}}
        height={"100%"}
        // gridTemplateColumns={'1fr 1fr'}
        gap={{ base: "0.5em", md: "1em" }}
        alignContent={"baseline"}
        // justifyContent={"start"}
        // justifyContent={"start"}
        // alignItems={"flex-start"}
        // alignContent={"baseline"}
        // alignSelf={"baseline"}
        alignSelf={"self-end"}
        alignItems={"self-end"}
      >
        <Box
         height={"100%"}
          // gap="1em"
          // alignItems={"baseline"}
          display={"grid"}
        >
          <Text>Basic details</Text>
          
          <Input
            my='1em'

            py={{ base: "0.5em" }}
            type="number"
            placeholder="Total amount"
            onChange={(e) => {
              setForm({ ...form, total_amount: Number(e.target.value) });
            }}
          ></Input>

          <Input
            my='1em'
            py={{ base: "0.5em" }}
            onChange={(e) => {
              setForm({ ...form, asset: e.target.value });
            }}
            placeholder="Asset address"
          ></Input>

          <Input
            my='1em'

            py={{ base: "0.5em" }}
            onChange={(e) => {
              setForm({ ...form, recipient: e.target.value });
            }}
            placeholder="Recipient"
          ></Input>

        </Box>
        <Box display={{md:"flex"}} height={"100%"}>
          <Box>
            <Text>Range</Text>
            <Box>
              <FormLabel>Start date</FormLabel>
              <Input
                py={{ base: "0.5em" }}
                type="datetime-local"
                onChange={(e) => {
                  setForm({
                    ...form,
                    range: {
                      ...form.range,
                      start: new Date(e.target.value).getTime(),
                    },
                  });
                }}
                placeholder="Start date"
              ></Input>

              <Input
                py={{ base: "0.5em" }}
                type="number"
                placeholder="Cliff"
                onChange={(e) => {
                  setForm({
                    ...form,
                    range: {
                      ...form.range,
                      cliff: Number(e.target.value),
                    },
                  });
                }}
              ></Input>

              <FormLabel>End date</FormLabel>

              <Input
                py={{ base: "0.5em" }}
                type="datetime-local"
                onChange={(e) => {
                  setForm({
                    ...form,
                    range: {
                      ...form.range,
                      end: new Date(e.target.value).getTime(),
                    },
                  });
                }}
                placeholder="End date"
              ></Input>
            </Box>
          </Box>

          <Box
           height={"100%"}
          >
            <Text>Broker</Text>
            <Box>
              <Input
                py={{ base: "0.5em" }}
                onChange={(e) => {
                  setForm({
                    ...form,
                    broker: {
                      ...form.broker,
                      account: e.target.value,
                    },
                  });
                }}
                placeholder="Broker account address"
              ></Input>
              <Input
                py={{ base: "0.5em" }}
                type="number"
                onChange={(e) => {
                  setForm({
                    ...form,
                    broker: {
                      ...form.broker,
                      fee: Number(e.target.value),
                    },
                  });
                }}
                placeholder="Fee broker"
              ></Input>
            </Box>
          </Box>
        </Box>
      </Box>

      <Button
        disabled={isDisabled}
        onClick={() => {
          handleCreateStream();
        }}
      >
        Create stream
      </Button>
    </Box>
  );
};

export default CreateStreamForm;
