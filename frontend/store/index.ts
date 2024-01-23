// store.ts
import { configureStore, createSlice, PayloadAction } from "@reduxjs/toolkit";
import { appSlice } from "./app";
import { modalSlice } from "./modal";
// Create the Redux store
const store = configureStore({
  reducer: {
    app:appSlice.reducer,
    modal:modalSlice.reducer
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

export default store;
