// pages/_document.js
import { ColorModeScript } from "@chakra-ui/react";
import NextDocument, { Html, Head, Main, NextScript } from "next/document";
import theme from "../theme";
import { CONFIG_WEBSITE } from "../constants";

export default class Document extends NextDocument {
  render() {
    return (
      <Html lang="en">
        <Head>
          <meta
            name="title"
          content={`${CONFIG_WEBSITE.page}`}

          />
          <meta
            name="description"
          content={`${CONFIG_WEBSITE.page}`}

          />
          <meta
            name="keywords"
          content={`${CONFIG_WEBSITE.page}`}

          />
          <meta name="author" 
          content={`${CONFIG_WEBSITE.page}`}
           />
          <meta
            property="og:title"
          content={`${CONFIG_WEBSITE.page}`}

          />
          <meta
            property="og:description"
          content={`${CONFIG_WEBSITE.page}`}
          />
          <meta
            property="og:image"
            content="https://"
          />

          <link rel="shortcut icon" href="/favicon.ico" type="image/x-icon" />
        </Head>
        <body>
          {/* 👇 Here's the script */}
          <ColorModeScript initialColorMode={theme.config.initialColorMode} />
          <Main />
          <NextScript />
        </body>
      </Html>
    );
  }
}
