// 1. Import the extendTheme function
import {
  extendTheme,
  StyleFunctionProps,
  type ThemeConfig,
} from "@chakra-ui/react";
import { mode } from "@chakra-ui/theme-tools";
// 2. Extend the theme to include custom colors, fonts, etc
const colors = {
  brand: {
    primary: "#DDBD22",
    secondary: "#4f89a8",
    complement: "#2242DD",
    // callToAction:"#22DDBD"
    callToAction:"#22DDBD"
  },

  blue: {
    primary: "#0d0889",
    secondary: "#084389",
    flash: "##120bb9",
  },
  button: {
    primary: "rgba(168, 103, 43, 0.65)",
  },

  gray: {
    // 800: '#153e75',
    700: "#252627",
    basic: "#3c3c3c",
    one: "#F5F5F5",
    two: "#EEEEEE",
  },
  body: {
    body: {
      bg: "#153e75",
    },
  },
};

// 2. Add your color mode config
// const config: ThemeConfig = {
//   initialColorMode: "light",
//   useSystemColorMode: false,
// };

const config: ThemeConfig = {
  initialColorMode: "dark",
  useSystemColorMode: true,
};

const theme = extendTheme({
  colors,
  config,
  styles: {
    global: (props: StyleFunctionProps) => ({
      body: {
        color: mode("gray.700", "gray.200")(props),
        bg: mode("gray.200", "gray.800")(props),
        lineHeight: "base",
      },
    }),
  },
  components: {
    Text: {
      sizes: {
        sm: {
          fontSize: "17px",
          px: 4, // <-- px is short for paddingLeft and paddingRight
          py: 3, // <-- py is short for paddingTop and paddingBottom
        },
        md: {
          fontSize: "21px",
          px: 6, // <-- these values are tokens from the design system
          py: 4, // <-- these values are tokens from the design system
        },
        lg: {
          fontSize: "25px",
          px: 6, // <-- these values are tokens from the design system
          py: 4, // <-- these values are tokens from the design system
        },
      },
  
    },
  },
});

export default theme;
