import { z } from "zod";
import { parse } from "tldts";
import { normHost } from "@/shared/utils/domain-key";

const isValidBaseDomain = (v: string) => {
  const p = parse(v);
  return Boolean(p.domain && p.publicSuffix && !p.isIp);
};

export const envSchema = z
  .object({
    NODE_ENV: z
      .enum(["development", "test", "production"])
      .default("development"),

    BASE_PANEL_DOMAIN: z
      .string()
      .min(1, "BASE_PANEL_DOMAIN is required")
      .transform((value) => normHost(value))
      .refine(isValidBaseDomain, {
        message:
          'BASE_PANEL_DOMAIN must be a valid domain (no protocol, no path). Example: "meupainel.com"',
      }),

    DATABASE_URL: z
      .string()
      .min(1, "DATABASE_URL is required")
      .refine(
        (v) => /^postgres(ql)?:\/\//i.test(v),
        "DATABASE_URL must be a PostgreSQL URL (postgres:// or postgresql://)"
      ),

    BCRYPT_SALT_ROUNDS: z.coerce.number().int().min(4).default(8),

    ARGON2_MEMORY_COST: z.coerce
      .number()
      .int()
      .min(8 * 1024)
      .default(65536), // 64MB
    ARGON2_TIME_COST: z.coerce.number().int().min(1).default(3),
    ARGON2_PARALLELISM: z.coerce.number().int().min(1).default(4),
  })
  .strip();

const parsed = envSchema.safeParse(process.env);

export type Env = z.infer<typeof envSchema>;
export const env = Object.freeze(parsed.data as any as Env);
