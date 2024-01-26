// store.ts
import { configureStore, createSlice, PayloadAction } from "@reduxjs/toolkit";
import { useDispatch } from "react-redux";
interface State {
  isLoading?:boolean;
  isLoaderOverlay?:boolean;
  isReferral?:boolean;
  isFeedBarOpen?:boolean;
  value: number;
  loading?: boolean;
  isAbleToScratchGold?: boolean;
  isProjectBarOpen?: boolean;
}

const initialState: State = {
  value: 0,
  isLoaderOverlay: undefined,
  isLoading: undefined,
  loading: false,
  isAbleToScratchGold: undefined,
  isFeedBarOpen:true,
  isProjectBarOpen:true
};

export const appSlice = createSlice({
  name: "app",
  initialState,
  reducers: {
    reverseOpenFeedBarOpen: (state) => {
      state.isFeedBarOpen = !state.isFeedBarOpen;
    },
    reverseProjectBarOpen: (state) => {
      state.isProjectBarOpen = !state.isProjectBarOpen;
    },
  
    changeIsAbleToScratchGold: (state, action: PayloadAction<boolean>) => {
      state.isAbleToScratchGold = action.payload;
    },
   
    changeLoading: (state, action: PayloadAction<boolean>) => {
      state.loading = action.payload;
    },
    increment: (state) => {
      state.value += 1;
    },
    decrement: (state) => {
      state.value -= 1;
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

  const dispatchIsAbleToScratchGold = (isAbleToScracthGold: boolean) => {
    dispatch(changeIsAbleToScratchGold(isAbleToScracthGold));
  };

  const dispatchLoading = (loading: boolean) => {
    console.log("dispatchLoading", loading);
    dispatch(changeLoading(loading));
  };
  return {
    dispatchReverseIsOpenFeedbar,
    dispatchLoading,
    dispatchIsAbleToScratchGold,
    dispatchReverseIsProjectSelectedBar
  };
};

export const {
  reverseOpenFeedBarOpen,
  changeLoading,
  changeIsAbleToScratchGold,
  reverseProjectBarOpen
} = appSlice.actions;
