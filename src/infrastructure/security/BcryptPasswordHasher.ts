// src/infrastructure/security/BcryptPasswordHasher.ts
import bcrypt from "bcrypt";
import { env } from "@/infrastructure/config/env";
import { IPasswordHasher } from "@/domain/security/IPasswordHasher";

export class BcryptPasswordHasher implements IPasswordHasher {
  constructor(private readonly saltRounds = env.BCRYPT_SALT_ROUNDS) {}

  hash(plain: string): Promise<string> {
    const salt = bcrypt.genSaltSync(this.saltRounds);

    return bcrypt.hash(plain, salt);
  }

  verify(plain: string, hash: string): Promise<boolean> {
    return bcrypt.compare(plain, hash);
  }
}
