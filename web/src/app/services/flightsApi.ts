import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';
import { getSession } from 'next-auth/react';

export interface QAItem {
  question: string;
  answer: string;
}

export interface FlightRequest {
  title: string;
  language: string;
  from_country: string;
  to_country: string;
  date: string;
  user_id: string;
  qa: QAItem[];
}

export interface FlightResponse extends FlightRequest {
  id: string;
}

export const flightsApi = createApi({
  reducerPath: 'flightsApi',
  baseQuery: fetchBaseQuery({
    baseUrl: process.env.NEXT_PUBLIC_BACKEND_URL,
    prepareHeaders: async (headers) => {
      const session = await getSession();
      // @ts-ignore
      if (session?.accessToken) {
        // @ts-ignore
        headers.set('Authorization', `Bearer ${session.accessToken}`);
      }
      headers.set('Content-Type', 'application/json');
      return headers;
    },
  }),
  tagTypes: ['Flight'],
  endpoints: (builder) => ({
    getFlights: builder.query<FlightResponse[], void>({
      query: () => '/flights',
      providesTags: (result) =>
        result
          ? [
              ...result.map(({ id }) => ({ type: 'Flight' as const, id })),
              { type: 'Flight' as const, id: 'LIST' },
            ]
          : [{ type: 'Flight' as const, id: 'LIST' }],
    }),

    getFlight: builder.query<FlightResponse, string>({
      query: (id) => `/flights/${id}`,
      providesTags: (_result, _error, id) => [{ type: 'Flight' as const, id }],
    }),

    createFlight: builder.mutation<FlightResponse, FlightRequest>({
      query: (flight) => ({
        url: '/flights',
        method: 'POST',
        body: flight,
      }),
      async onQueryStarted(arg, { dispatch, queryFulfilled }) {
        const patchResult = dispatch(
          flightsApi.util.updateQueryData('getFlights', undefined, (draft) => {
            draft.push({ id: 'temp-id', ...arg });
          })
        );
        try {
          const { data } = await queryFulfilled;
          dispatch(
            flightsApi.util.updateQueryData('getFlights', undefined, (draft) => {
              const index = draft.findIndex((f) => f.id === 'temp-id');
              if (index !== -1) draft[index] = data;
            })
          );
        } catch {
          patchResult.undo();
        }
      },
      invalidatesTags: [{ type: 'Flight' as const, id: 'LIST' }],
    }),

    deleteFlight: builder.mutation<{ success: boolean }, string>({
      query: (id) => ({
        url: `/flights/${id}`,
        method: 'DELETE',
      }),
      async onQueryStarted(id, { dispatch, queryFulfilled }) {
        const patchResult = dispatch(
          flightsApi.util.updateQueryData('getFlights', undefined, (draft) => {
            return draft.filter((f) => f.id !== id);
          })
        );
        try {
          await queryFulfilled;
        } catch {
          patchResult.undo();
        }
      },
      invalidatesTags: (result, error, id) => [
        { type: 'Flight' as const, id },
        { type: 'Flight' as const, id: 'LIST' },
      ],
    }),
  }),
});

export const {
  useGetFlightsQuery,
  useGetFlightQuery,
  useCreateFlightMutation,
  useDeleteFlightMutation,
} = flightsApi;
