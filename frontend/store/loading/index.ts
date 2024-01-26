// store.ts
import { configureStore, createSlice, PayloadAction } from "@reduxjs/toolkit";

// Define a slice of your application state
interface CounterState {
  loading: boolean;
}

const initialState: CounterState = {
  loading: false,
};

export const loadingSlice = createSlice({
  name: "counter",
  initialState,
  reducers: {
    isLoading: (state) => {
      // state.value += 1;
      state.loading = false;
    },
    isLoadingFinish: (state) => {
      state.loading = false;
    },
  },
});

export const { isLoading, isLoadingFinish } = loadingSlice.actions;
