import {Image as ImageChakra} from "@chakra-ui/react"

interface IVoyagerExplorerImage {
    width?:string;
}

export const VoyagerExplorerImage = ({width}:IVoyagerExplorerImage) => {
    return(
        <ImageChakra
        w={{base:width??"110px"}}
        src='/assets/voyager_explorer.svg'
        >

        </ImageChakra>
    )
  
}