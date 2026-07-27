import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';

export interface ChatResponse {
  translation: string;
  pronunciation: string;
  audio: string;
}

export const manualChatApi = createApi({
  reducerPath: 'manualChatApi',
  baseQuery: fetchBaseQuery({
    baseUrl: "https://translator-api-3etv.onrender.com/",
  }),
  endpoints: (builder) => ({
    sendManualAnswer: builder.mutation<ChatResponse, string>({
      query: (input) => ({
        url: '/manual-answer',
        method: 'POST',
        body: { input },
      }),
    }),
  }),
});

export const { useSendManualAnswerMutation } = manualChatApi;
