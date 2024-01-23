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
import { StarknetProvider } from "../components/starknet/StarknetProvider";

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
