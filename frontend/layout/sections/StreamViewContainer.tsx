import {
  Tabs,
  TabList,
  TabPanels,
  Tab,
  TabPanel,
  Box,
  Text,
} from "@chakra-ui/react";

/** @TODO getters Cairo contracts, Indexer */
export const StreamViewContainer = () => {
  return (
    <>
      <Tabs>
        <TabList>
          <Tab>All streams</Tab>
          <Tab>As recipient</Tab>
          <Tab>As sender</Tab>
          <Tab>Search</Tab>
        </TabList>

        <TabPanels>
          <TabPanel>
            <AllStreamComponent></AllStreamComponent>
          </TabPanel>
          <TabPanel>
          <RecipientStreamComponent></RecipientStreamComponent>

          </TabPanel>
          <TabPanel>
            <p>three!</p>
          </TabPanel>
          <TabPanel>
            <SearchStreamComponent></SearchStreamComponent>
          </TabPanel>
        </TabPanels>
      </Tabs>
    </>
  );
};

/** @TODO Cairo spec to be defined. */
const AllStreamComponent = () => {
  return (
    <Box>
      <Text>Find all streams</Text>
      <Text>Coming soon</Text>
    </Box>
  );
};


/** @TODO Cairo spec recipient component */
const RecipientStreamComponent = () => {
  return (
    <Box>
      <Text>Find here your stream</Text>
      <Text>Coming soon</Text>
    </Box>
  );
};

/** @TODO add search stream components. Spec to be defined. */
const SearchStreamComponent = () => {
  return (
    <Box>
      <Text>Coming soon</Text>
    </Box>
  );
};
