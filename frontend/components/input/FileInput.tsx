// components/FileInput.tsx
import { Button, Input, useToast } from "@chakra-ui/react";
import { ChangeEvent, useRef } from "react";

interface FileInputProps {
  onFileSelected: (fileData: ArrayBuffer | null) => void;
  fileSelected?: ArrayBuffer | undefined;
  onFileType?: (type: string) => void;
  handleFileChangeVoid: (file: File) => void;
}

const FileInput: React.FC<FileInputProps> = ({
  onFileSelected,
  fileSelected,
  onFileType,
  handleFileChangeVoid,
}) => {
  const inputRef = useRef<HTMLInputElement | null>(null);

  const toast = useToast();

  const handleFileChange = (e: ChangeEvent<HTMLInputElement>) => {
   
    const fileInput = inputRef.current;
    const inputFiles = e.target;

    const file = inputFiles.files[0];

    if (onFileType) {
      onFileType(file.type);
    }
    if (fileInput && fileInput.files && fileInput.files.length > 0) {
      const selectedFile = fileInput.files[0];
      handleFileChangeVoid(selectedFile);
      const reader = new FileReader();

      reader.onload = (event) => {
        const result = event.target?.result;
        console.log("result", result);
        const buffer = event.target?.result as ArrayBuffer;
        console.log("buffer", buffer);

        onFileSelected(buffer);
        console.log("fileSelected", fileSelected);
      };

      reader.readAsArrayBuffer(selectedFile);
    } else {
      onFileSelected(null);
    }
  };

  return (
    <>
      <Input
        type="file"
        placeholder="Upload your file"
        size="xl"
        className="mt-4"
        ref={inputRef}
        accept=".png,.jpg,.jpeg,.svg"
        // style={{ display: 'none' }}
        onChange={handleFileChange}
      />
      {/* <Button onClick={() => inputRef.current?.click()}>Upload File</Button> */}
    </>
  );
};

export default FileInput;
