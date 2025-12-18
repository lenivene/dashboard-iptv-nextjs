import argon2 from "argon2";
import { env } from "@/infrastructure/config/env";
import { IPasswordHasher } from "@/domain/security/IPasswordHasher";

export class Argon2PasswordHasher implements IPasswordHasher {
  async hash(plain: string): Promise<string> {
    return argon2.hash(plain, {
      type: argon2.argon2id,
      memoryCost: env.ARGON2_MEMORY_COST,
      timeCost: env.ARGON2_TIME_COST,
      parallelism: env.ARGON2_PARALLELISM,
    });
  }

  async verify(plain: string, hash: string): Promise<boolean> {
    return argon2.verify(hash, plain);
  }
}
