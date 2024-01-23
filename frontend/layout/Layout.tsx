import {
  Box,
  useColorModeValue,
} from "@chakra-ui/react";
import { Suspense } from "react";
import Footer from "./Footer";
import Script from "next/script";
import HeaderSidebar from "./HeaderSidebar";
import SocialLoader from "../components/loader/SocialLoader";
import { useRouter } from "next/router";
import React from "react";
import PageLoader from "../components/loader/PageLoader";

interface ILayout {
  children: React.ReactNode;
}

export default function Layout({ children }: ILayout) {
  const router = useRouter();

  const [loading, setLoading] = React.useState(false);

  React.useEffect(() => {
    const handleStart = (url) => (url !== router.asPath) && setLoading(true);
    const handleComplete = (url) => (url === router.asPath) && setLoading(false);

    router.events.on('routeChangeStart', handleStart)
    router.events.on('routeChangeComplete', handleComplete)
    router.events.on('routeChangeError', handleComplete)

    return () => {
      router.events.off('routeChangeStart', handleStart)
      router.events.off('routeChangeComplete', handleComplete)
      router.events.off('routeChangeError', handleComplete)
    }
  })


  const bg = useColorModeValue("#CEFFB7", "#CEFFB7");

  return (
    <Box
      width={"100%"}
      maxWidth={"100%"}
//       bg={useColorModeValue("gray.200", "gray.800")}
//       color={useColorModeValue("gray.700", "gray.100")}
      scrollBehavior={"smooth"}
    >
      {process.env.NODE_ENV == "production" && (
        <>
          <Script
            src={`https://www.googletagmanager.com/gtag/js?id=${process.env.GOOGLE_ANALYTICS_ID}`}
          />

          <Script id="google-analytics">
            {`
        window.dataLayer = window.dataLayer || [];
        function gtag(){dataLayer.push(arguments);}
        gtag('js', new Date());

        gtag('config', ${process.env.GOOGLE_ANALYTICS_ID});
        `}
          </Script>
        </>
      )}

      <Suspense fallback={<SocialLoader></SocialLoader>}>
        <HeaderSidebar>

          <Box
            width={"100%"}
            height={"100%"}
            minH={{ base: "90vh" }}
            scrollBehavior={"smooth"}
          >
            {loading ?
              <PageLoader></PageLoader> :
              children
            }
          </Box>
        </HeaderSidebar>
        <Footer></Footer>
      </Suspense>


    </Box>
  );
}
