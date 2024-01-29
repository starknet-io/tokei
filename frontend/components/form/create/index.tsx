import {
  Box,
  Button,
  Input,
  useToast,
  Text,
  useColorModeValue,
  FormLabel,
  Checkbox,
} from "@chakra-ui/react";
import { useAccount, useNetwork } from "@starknet-react/core";
import { useEffect, useState } from "react";
import { CreateRangeProps, CreateStream, TypeCreationStream } from "../../../types";
import e from "cors";
import {
  create_with_duration,
  handleCreateStream,
} from "../../../hooks/lockup/create_with_duration";
import { ADDRESS_LENGTH, CONFIG_WEBSITE } from "../../../constants";
import {
  DEFAULT_NETWORK,
  CONTRACT_DEPLOYED_STARKNET,
  CHAINS_NAMES,
} from "../../../constants/address";

import ERC20Tokei from "../../../constants/abi/tokei_ERC20.contract_class.json";
import {
  Contract,
  Uint,
  Uint256,
  stark,
  uint256,
  BigNumberish,
  cairo,
  TransactionStatus,

} from "starknet";
import { create_with_range } from "../../../hooks/lockup/create_with_range";
import { ExternalStylizedButtonLink } from "../../button/NavItem";
import { VoyagerExplorerImage } from "../../view/VoyagerExplorerImage";

interface ICreateStream { }


const CreateStreamForm = ({ }: ICreateStream) => {
  const toast = useToast();
  const accountStarknet = useAccount();
  const network = useNetwork()
  const chainId= network.chain.id
  const networkName= network.chain.name
  
  const account = accountStarknet?.account;
  const address = accountStarknet?.account?.address;
  const [txHash, setTxHash] = useState<string | undefined>();
  const [isDisabled, setIsDisabled] = useState<boolean>(true);
  const [typeStreamCreation, setTypeStreamCreation] = useState<
    TypeCreationStream | undefined
  >(TypeCreationStream.CREATE_WITH_RANGE);
  const [recipient, setRecipient] = useState<boolean>(true);
  const [typeCreation, setTypeCreation] = useState<boolean>(true);
  const [form, setForm] = useState<CreateStream | undefined>({
    sender: account?.address,
    recipient: undefined,
    total_amount: undefined,
    asset: undefined,
    cancelable: true,
    transferable: true,
    range: {
      start: undefined,
      cliff: undefined,
      end: undefined,
    },
    broker: {
      account: undefined,
      fee: undefined,
    },
    duration_cliff: undefined,
    duration_total: undefined,
    broker_account: account?.address,
    broker_fee: undefined,
    broker_fee_nb: undefined,
  });
  useEffect(() => {
    if (address && account) {
      setIsDisabled(false);
      setForm({ ...form, sender: address });
    }
  }, [accountStarknet, account, address]);

  /** @TODO refacto */
  const prepareHandleCreateStream = async (
    typeOfCreation: TypeCreationStream
  ) => {

    try {
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

      console.log("form?.recipient?.length", form?.recipient?.length)
      if (
        form?.recipient?.length != ADDRESS_LENGTH
        && !cairo.isTypeContractAddress(form?.recipient)
        // !cairo.isTypeContractAddress(form?.recipient)

      ) {
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

      const erc20Contract = new Contract(ERC20Tokei.abi, form?.asset, account);

      let decimals = 18;

      try {
        decimals == (await erc20Contract.decimals());
      } catch (e) {
      } finally {
      }
      const total_amount_nb =
        form?.total_amount * (10 ** Number(decimals));
      let total_amount;

      if (Number.isInteger(total_amount_nb)) {
        total_amount = cairo.uint256(total_amount_nb);
      }
      else if (!Number.isInteger(total_amount_nb)) {
        // total_amount=total_amount_nb
        total_amount = uint256.bnToUint256(BigInt(total_amount_nb));
      }
      // Call function. Last check input
      if (typeOfCreation == TypeCreationStream.CREATE_WITH_DURATION) {
        if (!form?.duration_cliff) {
          toast({
            title: "Please provide End date",
            status: "warning",
          });
          return;
        }

        if (!form?.duration_total) {
          toast({
            title: "Please provide End date",
            status: "warning",
          });
          return;
        }

        if (!form?.broker_account) {
          toast({
            title: "Please provide broker account",
            status: "warning",
          });
          return;
        }

        if (cairo.isTypeContractAddress(form?.broker_account)) {
          toast({
            title: "Please provide a valid Address for your broker account",
            status: "warning",
          });
          return;
        }

        if (form?.duration_total < form?.duration_cliff) {
          toast({
            title: "Duration total need to be superior too duration_cliff",
            status: "error",
          });
          return;
        }

        if (!account?.address) {
          toast({
            title: "Duration total need to be superior too duration_cliff",
            status: "error",
          });
          return;
        }

        const { isSuccess, message, hash } = await create_with_duration(
          accountStarknet?.account,
          account?.address, //Sender
          form?.recipient, //Recipient
          total_amount, // Total amount
          form?.asset, // Asset
          form?.cancelable, // Asset
          form?.transferable, // Transferable
          parseInt(form?.duration_cliff.toString()),
          parseInt(form?.duration_total.toString()),
          form?.broker_account,
          form?.broker_fee
          // form?.broker_fee_nb
        );
        if (hash) {
          setTxHash(hash)
          const tx = await account.waitForTransaction(hash);
          toast({
            title: 'Tx send. Please wait for confirmation',
            description: `${CONFIG_WEBSITE.page.goerli_voyager_explorer}/tx/${hash}`,
            status: "info",
            isClosable: true

          })
          if (tx?.status) {
            toast({
              title: 'Tx confirmed',
              description: `${CONFIG_WEBSITE.page.goerli_voyager_explorer}/tx/${hash}`,

              // description: `Hash: ${hash}`
            })
          }
        }




        console.log("message", message);
      } else {
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

        const { isSuccess, message, hash } = await create_with_range(
          accountStarknet?.account,
          account?.address, //Sender
          form?.recipient, //Recipient
          total_amount, // Total amount
          form?.asset, // Asset
          form?.cancelable, // Asset
          form?.transferable, // Transferable
          parseInt(form?.range?.start.toString()),
          parseInt(form?.range?.cliff.toString()),
          parseInt(form?.range?.end.toString()),
          form?.broker_account,
          form?.broker_fee
        );

        if (hash) {
          setTxHash(hash)
          toast({
            title: 'Tx send. Please wait for confirmation',
            description: `${CONFIG_WEBSITE.page.goerli_voyager_explorer}/tx/${hash}`,
            status: "info",
            isClosable: true

          })
          const tx = await account.waitForTransaction(hash);
          if (tx?.status == TransactionStatus.ACCEPTED_ON_L2) {

            toast({
              title: 'Tx confirmed',
              description: `${CONFIG_WEBSITE.page.goerli_voyager_explorer}/tx/${hash}`,

              // description: `Hash: ${hash}`
            })
          }
        }
      }
    } catch (e) {
      console.log("prepareHandleCreateStream", e)
    }
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

      <Text>Select the type of Stream you want to create</Text>

      <Box
        py={{ base: "0.25em" }}
        // justifyContent={"space-around"}
        justifyContent={"center"}
        display={"flex"}
        gap={{ base: "1em" }}
      >

        <Button onClick={() => setTypeStreamCreation(TypeCreationStream.CREATE_WITH_DURATION)}>Stream with duration</Button>
        <Button onClick={() => setTypeStreamCreation(TypeCreationStream.CREATE_WITH_RANGE)}>Stream with range</Button>
      </Box>


      {txHash && (
        <Box py={{ base: "1em" }}>
          <ExternalStylizedButtonLink
            href={`${CHAINS_NAMES.GOERLI == networkName.toString() ? CONFIG_WEBSITE.page.goerli_voyager_explorer : CONFIG_WEBSITE.page.voyager_explorer}/tx/${txHash}`}
          >
            <VoyagerExplorerImage></VoyagerExplorerImage>
          </ExternalStylizedButtonLink>
        </Box>
      )}


      <Box
        py={{ base: "0.25em", md: "1em" }}
        display={{ md: "flex" }}
        height={"100%"}
        justifyContent={"space-around"}
        gap={{ base: "0.5em", md: "1em" }}
        alignContent={"baseline"}
        alignSelf={"self-end"}
        alignItems={"baseline"}
      >
        <Box height={"100%"} display={"grid"}>
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
                aria-valuetext={form?.broker?.account}
                onChange={(e) => {
                  setForm({
                    ...form,
                    broker_account: e.target.value,
                    sender: e.target.value,
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
                    // broker_fee: uint256.bnToUint256(Number(e?.target?.value)),
                    // broker_fee: cairo.uint256(Number(e?.target?.value)),
                    broker_fee: cairo.uint256(parseInt(e?.target?.value)),
                    broker_fee_nb: Number(e?.target?.value),

                    broker: {
                      ...form.broker,
                      fee: Number(e.target.value),
                    },
                  });
                }}
                placeholder="Fee broker"
              ></Input>

              <Box display={{ base: "flex" }}
                gap={{ base: "5em" }}
              >
                <Box>
                  <Text>Cancelable</Text>
                  <Checkbox
                    py={{ base: "0.5em" }}
                    type="number"
                    isChecked={form.cancelable}
                    my={{ base: "0.25em", md: "0.5em" }}
                    onChange={(e) => {
                      if (form?.cancelable) {
                        setForm({
                          ...form,
                          cancelable: false,
                        });
                      } else {
                        setForm({
                          ...form,
                          cancelable: true,
                        });
                      }
                    }}
                    onClick={(e) => {
                      if (form?.cancelable) {
                        setForm({
                          ...form,
                          cancelable: false,
                        });
                      } else {
                        setForm({
                          ...form,
                          cancelable: true,
                        });
                      }
                    }}
                    placeholder="Cancelable"
                  ></Checkbox>
                </Box>

                <Box>
                  <Text>Transferable</Text>
                  <Checkbox
                    py={{ base: "0.5em" }}
                    type="number"
                    isChecked={form.transferable}
                    my={{ base: "0.25em", md: "0.5em" }}
                    onChange={(e) => {
                      if (form?.transferable) {
                        setForm({
                          ...form,
                          transferable: false,
                        });
                      } else {
                        setForm({
                          ...form,
                          transferable: true,
                        });
                      }
                    }}
                    onClick={(e) => {
                      if (form?.transferable) {
                        setForm({
                          ...form,
                          transferable: false,
                        });
                      } else {
                        setForm({
                          ...form,
                          transferable: true,
                        });
                      }
                    }}
                    placeholder="Transferable"
                  ></Checkbox>
                </Box>
              </Box>

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

            {typeStreamCreation == TypeCreationStream.CREATE_WITH_RANGE &&

              <Box>
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
                  // type="number"
                  type="datetime-local"
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
                        // cliff: Number(e.target.value),
                        cliff: new Date(e.target.value).getTime(),

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
              </Box>}
            {typeStreamCreation == TypeCreationStream.CREATE_WITH_DURATION &&
              <Box>

                <FormLabel fontFamily={"monospace"}>
                  Duration stream type:{" "}
                </FormLabel>

                <Text
                  textAlign={"left"}
                  color={useColorModeValue("gray.100", "gray.300")}
                >
                  Duration cliff
                </Text>
                <Input
                  py={{ base: "0.5em" }}
                  type="number"
                  my={{ base: "0.25em", md: "0.5em" }}
                  color={useColorModeValue("gray.100", "gray.300")}
                  _placeholder={{
                    color: useColorModeValue("gray.100", "gray.300"),
                  }}
                  onChange={(e) => {
                    setForm({
                      ...form,
                      duration_cliff: Number(e?.target?.value),
                    });
                  }}
                  placeholder="Duration cliff"
                ></Input>

                <Text
                  textAlign={"left"}
                  color={useColorModeValue("gray.100", "gray.300")}
                >
                  Duration total
                </Text>
                <Input
                  py={{ base: "0.5em" }}
                  type="number"
                  my={{ base: "0.25em", md: "0.5em" }}
                  color={useColorModeValue("gray.100", "gray.300")}
                  _placeholder={{
                    color: useColorModeValue("gray.100", "gray.300"),
                  }}
                  onChange={(e) => {
                    setForm({
                      ...form,
                      duration_total: Number(e?.target?.value),
                    });
                  }}
                  placeholder="Duration total"
                ></Input>
              </Box>
            }

          </Box>
        </Box>
      </Box>

      <Box>
        <Text
          py={{ base: "0.1em" }}
          textAlign={{ base: "left" }}
        >Choose your type of stream to create</Text>

        <Box
          textAlign={"center"}
          display={{ base: "flex" }}
          gap={{ base: "0.5em" }}
        >

          {typeStreamCreation == TypeCreationStream.CREATE_WITH_DURATION ?
            <Button
              bg={useColorModeValue("brand.primary", "brand.primary")}
              disabled={isDisabled}
              onClick={() => {
                prepareHandleCreateStream(
                  TypeCreationStream.CREATE_WITH_DURATION
                );
              }}
            >
              Create duration stream ⏳
            </Button> :
            <Button
              bg={useColorModeValue("brand.primary", "brand.primary")}
              disabled={isDisabled}
              onClick={() => {
                prepareHandleCreateStream(TypeCreationStream.CREATE_WITH_RANGE);
              }}
            >
              Create stream
            </Button>

          }



        </Box>
      </Box>
    </Box >
  );
};

export default CreateStreamForm;
