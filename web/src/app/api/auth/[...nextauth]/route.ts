import NextAuth, { NextAuthOptions } from "next-auth";
import CredentialsProvider from "next-auth/providers/credentials";
import { store } from "@/app/libs/store";
import { authApi, AuthResponse } from "@/app/services/authApi";

const { login } = authApi.endpoints;

const authOptions: NextAuthOptions = {
  secret: process.env.NEXTAUTH_SECRET,
  session: { strategy: "jwt" },

  pages: {
    signIn: "/auth/login",
    error: "/auth/login", // redirect auth errors back to login page, not NextAuth's error page
  },

  providers: [
    CredentialsProvider({
      name: "Credentials",
      credentials: {
        email: { label: "Email", type: "email" },
        password: { label: "Password", type: "password" },
      },
      async authorize(credentials) {
        if (!credentials) return null;
        const result = await store.dispatch(
          login.initiate({
            email: credentials.email,
            password: credentials.password,
          }),
        );

        const { data, error } = result as {
          data?: AuthResponse;
          error?: {
            data?: {
              error?: string;
              message?: string;
            };
            error?: string;
          };
        };

        if (error || !data) {
          // Surface the actual backend error message so the UI can display it
          const message =
            error?.data?.error ||
            error?.data?.message ||
            error?.error ||
            "Invalid email or password";
          throw new Error(message);
        }

        const { user, token } = data;
        return {
          id: user.id,
          name: user.username,
          email: user.email,
          username: user.username,
          accessToken: token,
        };
      },
    }),
  ],

  callbacks: {
    async jwt({ token, user }) {
      if (user && "accessToken" in user) {
        token.accessToken = user.accessToken;
        token.username = user.username;
      }
      return token;
    },

    async session({ session, token }) {
      session.user = {
        ...session.user,
        id: token.sub as string,
        username: token.username ?? undefined,
      };
      session.accessToken = token.accessToken;
      return session;
    },
  },
};

const handler = NextAuth(authOptions);
export { handler as GET, handler as POST };
