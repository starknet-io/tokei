import Head from "next/head";
import Script from "next/script";
import { CONFIG_WEBSITE } from "../constants";

interface IHeaderSEO {
  title?: string;
  description?: string;
  isWithTitle?:boolean;
}
const HeaderSEO = ({ title, isWithTitle, description, }: IHeaderSEO) => {
  return (
    <>
      {process.env.NODE_ENV == "production" && (
        <>
          <Script
            src={`https://www.googletagmanager.com/gtag/js?id=${process.env.NEXT_PUBLIC_GOOGLE_ANALYTICS}`}
          />
          <Script id="google-analytics">
            {`
                    window.dataLayer = window.dataLayer || [];
                    function gtag(){dataLayer.push(arguments);}
                    gtag('js', new Date());
                    gtag('config', '${process.env.NEXT_PUBLIC_GOOGLE_ANALYTICS}', {
                    page_path: window.location.pathname,
                    });
                `}
          </Script>
        </>
      )}

      <Head>
   
        <meta
          name="title"
          content={CONFIG_WEBSITE.title}
        />
        <meta
          name="description"
          content={CONFIG_WEBSITE.description}

        />
        <meta
          name="keywords"
          content="Starknet, Starkware, Starter-pack, Dev, SocialFi, Dashboard, Network, Tool, Bot, Community, Web3, Trade, Launchpad, Portofolio, Wallet, Multi chains, Fast, Easy, Mobile"
        />
        <meta name="author" content="Starknet starter-pack" />
        <meta
          property="og:title"
          content={CONFIG_WEBSITE.title}

        />
        <meta
          property="og:description"
          content={CONFIG_WEBSITE.description}
        />
  
        <link rel="shortcut icon" href="/favicon.ico" type="image/x-icon" />
      </Head>
    </>
  );
};

export default HeaderSEO;
