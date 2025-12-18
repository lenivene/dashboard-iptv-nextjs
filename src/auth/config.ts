import github from "next-auth/providers/github";
import type { NextAuthConfig } from "next-auth";

export const authConfig: NextAuthConfig = {
  providers: [github],
  session: {
    strategy: "jwt",
  },
};
