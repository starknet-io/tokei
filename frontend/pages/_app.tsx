import "../styles/globals.css";
import type { AppProps } from "next/app";
import { ChakraProvider } from "@chakra-ui/react";
import { Provider } from "react-redux";
import store from "../store";
import theme from "../theme";
import { useEffect } from "react";
import { useRouter } from "next/router";
import type { Session } from "next-auth";
import Layout from "../layout/Layout";

import { goerli, mainnet } from '@starknet-react/chains'
import { argent, braavos, publicProvider, StarknetConfig, starkscan, useInjectedConnectors } from '@starknet-react/core'
// import { WebWalletConnector } from 'starknetkit/dist/connectors/webwallet/index'
// import { ArgentMobileConnector } from 'starknetkit/dist/connectors/argentMobile'

const network = process.env.REACT_APP_NETWORK ?? 'goerli'
// STARKNET
interface StarknetProviderProps {
  children: React.ReactNode
}

export function StarknetProvider({ children }: StarknetProviderProps) {
  const { connectors: injected } = useInjectedConnectors({
    recommended: [argent(), braavos()],
    includeRecommended: 'always',
  })
  const connectors = [
    ...injected,
    // new WebWalletConnector({ url: 'https://web.argent.xyz' }),
    // new ArgentMobileConnector(),
  ]

  return (
    <StarknetConfig
      connectors={connectors}
      chains={[network === 'mainnet' ? mainnet : goerli]}
      provider={publicProvider()}
      explorer={starkscan}
      autoConnect
    >
      {children}
    </StarknetConfig>
  )
}

function ScrollToTop() {
  const router = useRouter();
  useEffect(() => {
    const handleRouteChange = () => {
      window.scrollTo(0, 0);
    };

    router.events.on("routeChangeComplete", handleRouteChange);

    return () => {
      router.events.off("routeChangeComplete", handleRouteChange);
    };
  }, []);

  return null;
}

function MyApp({
  Component,
  pageProps: { session, ...pageProps },
}: AppProps<{ session: Session }>) {
  return (
    <StarknetProvider
    >
      <ChakraProvider theme={theme}>
        <Provider store={store}>
              <Layout>
                <ScrollToTop></ScrollToTop>
                <Component {...pageProps} />
              </Layout>
        </Provider>
      </ChakraProvider>
    </StarknetProvider>

  );
}

export default MyApp;
