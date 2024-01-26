import {
  Box,
  Button,
  Input,
  useToast,
  Text,
  useColorModeValue,
} from "@chakra-ui/react";
import { useAccount } from "@starknet-react/core";
import { useEffect, useState } from "react";
import { CreateRangeProps } from "../../../types";
import e from "cors";
import { handleCreateStream } from "../../../hooks/lockup/handleCreateStream";
import { ADDRESS_LENGTH } from "../../../constants";
import { DEFAULT_NETWORK, CONTRACT_DEPLOYED_STARKNET,  } from "../../../constants/address";
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
      setForm({ ...form, sender: address });
    }
  }, [accountStarknet, account, address]);

  const prepareHandleCreateStream = async () => {
    const CONTRACT_ADDRESS = CONTRACT_DEPLOYED_STARKNET[DEFAULT_NETWORK];

    if (!CONTRACT_ADDRESS.lockupLinearFactory?.toString()) {
      toast({
        title: `Contract Lockup linear is not deployed in ${DEFAULT_NETWORK}.`,
        isClosable: true,
        duration: 1500,
      });
      return;
    }

    /** Check value before send tx */

    if (!address) {
      toast({
        title: "Connect your account",
        status: "warning",
        isClosable: true,
        duration: 1000,
      });
      return;
    }

    if (!form?.sender) {
      toast({
        status: "warning",
        isClosable: true,
        duration: 1000,
      });
      return {
        isSuccess: false,
        message: "Connect your account",
      };
    }

    if (!form?.total_amount) {
      toast({
        title: "Provide Total amount to lockup",
        status: "warning",
        isClosable: true,
        duration: 1000,
      });
      return;
    }

    /** Address verification */

    if (!form?.asset?.length) {
      toast({
        title: "Asset not provided",
        status: "warning",
        isClosable: true,
      });
      return;
    }

    /***@TODO use starknet check utils isAddress */
    if (form?.asset?.length < ADDRESS_LENGTH) {
      toast({
        title: "Asset is not address size. Please verify your ERC20 address",
        status: "warning",
        isClosable: true,
      });
      return;
    }

    if (!form?.recipient) {
      toast({
        title: "Recipient not provided",
        status: "warning",
        isClosable: true,
      });
      return;
    }
    /***@TODO use starknet check utils isAddress */

    if (form?.recipient?.length != ADDRESS_LENGTH) {
      toast({
        title:
          "Recipient is not address size. Please verify your recipient address",
        status: "warning",
        isClosable: true,
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
      return {};
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

    const {tx, isSuccess, message} = await handleCreateStream({
      form: form,
      address: address,
      accountStarknet: accountStarknet,
    });
  };

  return (
    <Box
      width={{ base: "100%" }}
      py={{ base: "1em", md: "2em" }}
      px={{ base: "1em" }}
    >
      <Text fontFamily={"PressStart2P"} fontSize={{ base: "19px", md: "21px" }}>
        Start creating your lockup linear vesting
      </Text>

      <Box
        py={{ base: "1em", md: "2em" }}
        display={{ md: "flex" }}
        height={"100%"}
        justifyContent={'space-around'}
        // gridTemplateColumns={'1fr 1fr'}
        gap={{ base: "0.5em", md: "1em" }}
        alignContent={"baseline"}
        alignSelf={"self-end"}
        alignItems={"baseline"}
      >
        <Box
          height={"100%"}
          // gap="1em"
          // alignItems={"baseline"}
          display={"grid"}
        >
          <Text textAlign={"left"} fontFamily={"PressStart2P"}>
            Basic details
          </Text>

          <Input
            my={{ base: "0.25em", md: "0.5em" }}
            py={{ base: "0.5em" }}
            type="number"
            placeholder="Total amount"
            onChange={(e) => {
              setForm({ ...form, total_amount: Number(e.target.value) });
            }}
          ></Input>

          <Input
            // my='1em'
            my={{ base: "0.25em", md: "0.5em" }}
            py={{ base: "0.5em" }}
            onChange={(e) => {
              setForm({ ...form, asset: e.target.value });
            }}
            placeholder="Asset address"
          ></Input>

          <Input
            // my='1em'
            my={{ base: "0.25em", md: "0.5em" }}
            py={{ base: "0.5em" }}
            onChange={(e) => {
              setForm({ ...form, recipient: e.target.value });
            }}
            placeholder="Recipient"
          ></Input>

          <Box height={"100%"}>
            <Box>
              <Text textAlign={"left"}>Account</Text>
              <Input
                my={{ base: "0.25em", md: "0.5em" }}
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
                my={{ base: "0.25em", md: "0.5em" }}
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
        <Box
          // display={{ md: "flex" }}
          height={"100%"}
          gap={{ base: "0.5em" }}
          w={{ base: "100%", md: "fit-content" }}
        >
          <Text textAlign={"left"} fontFamily={"PressStart2P"}>
            Range date ⏳
          </Text>
          <Box
            height={"100%"}
            w={{ base: "100%", md: "450px" }}
            bg={useColorModeValue("gray.900", "gray.700")}
            p={{ base: "1em" }}
            borderRadius={{ base: "5px" }}
          >
            <Text
              textAlign={"left"}
              color={useColorModeValue("gray.100", "gray.300")}
            >
              Start date
            </Text>
            <Input
              justifyContent={"start"}
              w={"100%"}
              py={{ base: "0.5em" }}
              my={{ base: "0.25em", md: "0.5em" }}
              type="datetime-local"
              color={useColorModeValue("gray.100", "gray.300")}
              _placeholder={{
                color: useColorModeValue("gray.100", "gray.300"),
              }}
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

            <Text
              textAlign={"left"}
              color={useColorModeValue("gray.100", "gray.300")}
            >
              Cliff date
            </Text>
            <Input
              py={{ base: "0.5em" }}
              my={{ base: "0.25em", md: "0.5em" }}
              type="number"
              placeholder="Cliff"
              color={useColorModeValue("gray.100", "gray.300")}
              _placeholder={{
                color: useColorModeValue("gray.100", "gray.300"),
              }}
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

            <Text
              textAlign={"left"}
              color={useColorModeValue("gray.100", "gray.300")}
            >
              End date
            </Text>
            <Input
              py={{ base: "0.5em" }}
              type="datetime-local"
              my={{ base: "0.25em", md: "0.5em" }}
              color={useColorModeValue("gray.100", "gray.300")}
              _placeholder={{
                color: useColorModeValue("gray.100", "gray.300"),
              }}
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
      </Box>

      <Box textAlign={"center"}>
        <Button
          bg={useColorModeValue("brand.primary", "brand.primary")}
          disabled={isDisabled}
          onClick={() => {
            prepareHandleCreateStream()
          }}
        >
          Create stream
        </Button>
      </Box>
    </Box>
  );
};

export default CreateStreamForm;
