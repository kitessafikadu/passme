import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";
import { getSession } from "next-auth/react";

export interface PasswordChangeRequest {
  old_password: string;
  new_password: string;
  confirm_password: string;
}

export interface UsernameUpdateRequest {
  new_username: string;
}

export interface ProfileResponse {
  username: string;
  email: string;
  about: string;
}

export const profileApi = createApi({
  reducerPath: "profileApi",
  baseQuery: fetchBaseQuery({
    baseUrl: process.env.NEXT_PUBLIC_BACKEND_URL,
    prepareHeaders: async (headers) => {
      const session = await getSession();
      // @ts-ignore
      if (session?.accessToken) {
        // @ts-ignore
        headers.set("Authorization", `Bearer ${session.accessToken}`);
      }
      headers.set("Content-Type", "application/json");
      return headers;
    },
  }),
  tagTypes: ["Profile"],
  endpoints: (builder) => ({
    getProfile: builder.query<ProfileResponse, void>({
      query: () => "/profile/",
      providesTags: [{ type: "Profile", id: "PROFILE" }],
    }),

    updateUsername: builder.mutation<
      { message: string },
      UsernameUpdateRequest
    >({
      query: (data) => ({
        url: "/profile/username",
        method: "PUT",
        body: data,
      }),
      async onQueryStarted(arg, { dispatch, queryFulfilled }) {
        // Optimistically update the profile
        const patchResult = dispatch(
          profileApi.util.updateQueryData("getProfile", undefined, (draft) => {
            draft.username = arg.new_username;
          })
        );
        try {
          await queryFulfilled;
        } catch {
          patchResult.undo();
        }
      },
      invalidatesTags: [{ type: "Profile", id: "PROFILE" }],
    }),

    changePassword: builder.mutation<
      { message: string },
      PasswordChangeRequest
    >({
      query: (data) => ({
        url: "/profile/password",
        method: "PUT",
        body: data,
      }),
      // No need to invalidate cache for password change
    }),
  }),
});

export const {
  useGetProfileQuery,
  useUpdateUsernameMutation,
  useChangePasswordMutation,
} = profileApi;
