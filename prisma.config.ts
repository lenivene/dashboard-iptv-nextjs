import { Env } from "@/infrastructure/config/env";
import "dotenv/config";
import path from "node:path";
import { defineConfig, env } from "@prisma/config";

export default defineConfig({
  schema: path.join("prisma", "schema.prisma"),
  migrations: {
    path: path.join("prisma", "db", "migrations"),
    seed: "tsx prisma/db/seed/seed.ts",
  },
  datasource: {
    url: env<Env>("DATABASE_URL"),
  },
});
