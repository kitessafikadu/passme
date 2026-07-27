import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";
import { getSession } from "next-auth/react";

export interface ChatResponse {
  question: {
    main: string;
    translated: string;
  };
  answer: {
    main: string;
    translation: string;
    pronounciation: string;
  };
  audio: string;
}

export interface SendAudioPayload {
  flightId: string;
  file: File;
}

export const chatApi = createApi({
  reducerPath: "chatApi",
  baseQuery: fetchBaseQuery({
    baseUrl: process.env.NEXT_PUBLIC_FLASK_BACKEND_URL,
    prepareHeaders: async (headers) => {
      const session = await getSession();
      // @ts-ignore
      if (session?.accessToken) {
        // @ts-ignore
        headers.set("Authorization", `Bearer ${session.accessToken}`);
      }
      return headers;
    },
  }),
  endpoints: (builder) => ({
    sendAudioChat: builder.mutation<ChatResponse, SendAudioPayload>({
      query: ({ flightId, file }) => {
        const formData = new FormData();
        formData.append("flight_id", flightId);
        formData.append("audio", file);
        return {
          url: "/chat-ai",
          method: "POST",
          body: formData,
        };
      },
    }),
  }),
});

export const { useSendAudioChatMutation } = chatApi;
