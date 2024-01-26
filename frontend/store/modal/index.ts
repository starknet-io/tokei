// store.ts
import { configureStore, createSlice, PayloadAction } from "@reduxjs/toolkit";
import { useDispatch } from "react-redux";

export enum ModalType {
  WALLET_CONNECT="WALLET_CONNECT",
  PROFILE_MODAL="PROFILE_MODAL"

}
interface State {
  isLoading?:boolean;
  isFeedBarOpen?:boolean;
  isProjectBarOpen?: boolean;
  modalType?:ModalType;
  isModalOpen?:boolean
}

const initialState: State = {

  modalType:undefined,

};

export const modalSlice = createSlice({
  name: "modal",
  initialState,
  reducers: {
    reverseOpenFeedBarOpen: (state) => {
      state.isFeedBarOpen = !state.isFeedBarOpen;
    },
    reverseProjectBarOpen: (state) => {
      state.isProjectBarOpen = !state.isProjectBarOpen;
    },
  
  },
});

export const useAppDispatch = () => {
  const dispatch = useDispatch();

  const dispatchReverseIsProjectSelectedBar = () => {
    dispatch(reverseProjectBarOpen());
  };


  const dispatchReverseIsOpenFeedbar = () => {
    dispatch(reverseOpenFeedBarOpen());
  };

  return {
    dispatchReverseIsOpenFeedbar,
    dispatchReverseIsProjectSelectedBar
  };
};

export const {
  reverseOpenFeedBarOpen,
  reverseProjectBarOpen
} = modalSlice.actions;
