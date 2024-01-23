import React from "react";
import { Box, Image } from "@chakra-ui/react";

interface ImagePreviewProps {
  buffer: ArrayBuffer;
}

const ImagePreview: React.FC<ImagePreviewProps> = ({ buffer }) => {
  const blob = new Blob([buffer], { type: "image/jpeg" }); // Replace 'image/jpeg' with the appropriate MIME type

  return (
    <Box>
      <Image src={URL.createObjectURL(blob)} alt="Preview" 
      />
    </Box>
  );
};

export default ImagePreview;
