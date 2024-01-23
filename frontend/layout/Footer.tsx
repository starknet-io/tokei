import {
  Box,
  Text,
  Drawer,
  Menu,
  MenuButton,
  HStack,
  chakra,
  Container,
  SimpleGrid,
  Stack,
  VisuallyHidden,
  Input,
  IconButton,
  useColorModeValue,
  Image as ImageChakra,
  Link as LinkChakra,
  ButtonProps,
  LinkProps,
} from "@chakra-ui/react";

import { ReactNode } from "react";
import { FaYoutube } from "react-icons/fa";
import React from "react";
import { MdWeb } from "react-icons/md";
import {
  BsFacebook,
  BsGithub,
  BsInstagram,
  BsTelegram,
  BsTwitter,
} from "react-icons/bs";
import { CONFIG_SOCIAL, CONFIG_WEBSITE } from "../constants";
import { IoLogoInstagram, IoSwapHorizontal } from "react-icons/io5";
import IconComponent from "../components/view/IconComponent";

interface ILogoProps {
  imgSrc?: string;
  props: any;
}

export const SocialButton = ({
  children,
  label,
  href,
  isExternal,
  title,
  rest,
}: {
  children: ReactNode;
  label: string;
  href: string;
  title?: string;
  isExternal?: boolean;
  rest?: LinkProps;
}) => {
  return (
    <chakra.button
      bg={useColorModeValue("blackAlpha.100", "whiteAlpha.100")}
      title={title}
      rounded={"full"}
      w={8}
      h={8}
      cursor={"pointer"}
      as={"a"}
      href={href}
      display={"inline-flex"}
      alignItems={"center"}
      justifyContent={"center"}
      target={isExternal ? "_blank" : "_parent"}
      transition={"background 0.3s ease"}
      _hover={{
        bg: useColorModeValue("blackAlpha.200", "whiteAlpha.200"),
      }}
    >
      <VisuallyHidden>{label}</VisuallyHidden>
      {children}
    </chakra.button>
  );
};

export default function FooterLarge() {
  return (
    <Box
      bg={useColorModeValue("gray.100", "gray.900")}
      color={useColorModeValue("gray.700", "gray.100")}
      mt={{ base: "0.5em", md: "1em" }}
      pb={{ base: "1.3em", md: "1.5em" }}
      borderColor={useColorModeValue("gray.100", "green.100")}
      width={"100%"}
      as="footer"
    >
      <Container as={Stack} maxW={"6xl"} py={10}>
        <Box
          alignSelf="center"
          pb={"1em"}
          display={{ base: "block", xl: "grid" }}
          gridTemplateColumns={"2fr 1fr"}
          alignItems="end"
          gap={{ md: "15%" }}
          justifyItems={"stretch"}
        >
          <Stack
            alignItems={{ sm: "center", md: "flex-start" }}
            paddingTop={"1em"}
            order={{ base: "2", md: "1" }}
          >
            <Stack
              display="grid"
              borderRadius={{ base: "3px" }}
              border={{ base: "3px" }}
              borderColor={useColorModeValue("green.100", "green.100")}
            >
              <Box
                width={{ base: "150x", md: "250px", lg: "250px" }}
                height={{ base: "150x", md: "150px", lg: "170px" }}
                textAlign={"center"}
                justifyContent={"center"}
                alignContent={"center"}
              >
                <IconComponent
                  src="/assets/logo.svg"
                  alt={CONFIG_WEBSITE.title}
                  size="150px"
                />
              </Box>
            </Stack>

            <Text textAlign={{ base: "left", md: "center" }}>
              {" "}
              {CONFIG_WEBSITE.title} - © {new Date().getFullYear()}.
            </Text>
            <Text>All rights reserved</Text>
          </Stack>
          <Box justifyContent={"center"} paddingTop={"1em"}>
            <Text textAlign={{ base: "left", md: "center" }}>
              Socials: {CONFIG_WEBSITE.title}
            </Text>
            <Stack
              direction={"row"}
              gridTemplateColumns={"repeat(3,50px)"}
              spacing={6}
              pt={"2em"}
              justifyContent={"center"}
            >
              <SocialButton
                isExternal={true}
                title={`${CONFIG_WEBSITE.title}  Portal`}
                label="Portal"
                href={CONFIG_WEBSITE?.page?.portal}
              >
                <MdWeb></MdWeb>
              </SocialButton>

              <SocialButton
                href={CONFIG_SOCIAL.github.link}
                title={`${CONFIG_WEBSITE.title}  Github`}
                label="Github Tokei Platform"
                isExternal={true}
              >
                <BsGithub></BsGithub>
              </SocialButton>

              <SocialButton
                isExternal={true}
                title={`${CONFIG_WEBSITE.title.toString()} Twitter OG Friends Community`}
                label="Twitter"
                href={CONFIG_SOCIAL.twitter.link}
              >
                <BsTwitter></BsTwitter>
              </SocialButton>
              {/* <SocialButton
                isExternal={true}
                title={`${CONFIG_WEBSITE.title?.toString()} Youtube Channel`}
                label="Youtube"
                href={CONFIG_SOCIAL.youtube.link}
              >
                <FaYoutube></FaYoutube>
              </SocialButton>
              <SocialButton
                isExternal={true}
                title={`${CONFIG_WEBSITE.title?.toString()} Telegram Channel`}
                label="Telegram"
                href={CONFIG_SOCIAL.telegram.community}
              >
                <BsTelegram></BsTelegram>
              </SocialButton>

              <SocialButton
                isExternal={true}
                title={`${CONFIG_WEBSITE.title?.toString()} Facebook page`}
                label="Facebook"
                href={CONFIG_SOCIAL.facebook.link}
              >
                <BsFacebook></BsFacebook>
              </SocialButton>

              <SocialButton
                isExternal={true}
                title={`${CONFIG_WEBSITE.title?.toString()} Instagram page`}
                label="Instagram"
                href={CONFIG_SOCIAL.instagram.link}
              >
                <IoLogoInstagram></IoLogoInstagram>
              </SocialButton> */}
            </Stack>
          </Box>
        </Box>
      </Container>
    </Box>
  );
}
