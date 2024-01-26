import { Button, ButtonProps, Link as LinkChakra, useColorModeValue } from "@chakra-ui/react"
import Link from "next/link"

interface IButtonLink {
    href: string;
    title?: string;
    restButton?:ButtonProps
}
export const ButtonLink = ({ href, title, restButton}: IButtonLink) => {
    const color = useColorModeValue("gray.300", "gray.300");
    const bg = useColorModeValue("gray.700", "gray.500");
    return (
    <Button my={"0.5em"} as={Link} href={href}
        bg={bg}
        color={color}
        {...restButton}
    >
        {title ?? "View more"}
    </Button>)
}

export const ButtonLinkBasic = ({ href, title }: IButtonLink) => {

    const color = useColorModeValue("gray.300", "gray.300");
    const bg = useColorModeValue("gray.700", "gray.500")

    return <Button my={"0.5em"} as={Link} href={href}
        width={"100%"}
        bg={bg}
        color={color}

    >
        {title ?? "View more"}
    </Button>
}


export const ButtonLinkBrand = ({ href, title }: IButtonLink) => {

    const color = useColorModeValue("gray.700", "gray.300");
    const bg = useColorModeValue("brand.primary", "brand.primary")

    return <Button my={"0.5em"} as={Link} href={href}
        width={"100%"}
        bg={bg}
        color={color}

    >
        {title ?? "View more"}
    </Button>
}