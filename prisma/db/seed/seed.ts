import dotenv from "dotenv";
import path from "node:path";

import ora from "ora";
import chalk from "chalk";
import boxen from "boxen";
import { table, getBorderCharacters } from "table";

import { PrismaClient, GlobalRole, PanelRole } from "@prisma/client";
import { Pool } from "pg";
import { PrismaPg } from "@prisma/adapter-pg";

import { env } from "@/infrastructure/config/env";
import { SEED_USERS } from "./data";
import { Argon2PasswordHasher } from "@/infrastructure/security/Argon2PasswordHasher";

dotenv.config({ path: path.resolve(process.cwd(), ".env") });

async function main() {
  const spinner = ora("Running seed...").start();

  if (!env.DATABASE_URL) {
    spinner.fail("DATABASE_URL not found in .env");
    throw new Error("DATABASE_URL not found in .env");
  }

  const pool = new Pool({ connectionString: env.DATABASE_URL });
  const adapter = new PrismaPg(pool);
  const prisma = new PrismaClient({ adapter });

  const passwordHasher = new Argon2PasswordHasher();

  const results: Array<{
    type: "PANEL" | "USER" | "PANEL_USER";
    key: string;
    status: "CREATED" | "EXISTS";
    info?: string;
  }> = [];

  try {
    // 1) Demo Panel
    const panelName = "Demo";
    const panelDomain = "demo";

    const panelExisting = await prisma.panel.findUnique({
      where: { domain: panelDomain },
    });

    const panel = panelExisting
      ? panelExisting
      : await prisma.panel.create({
          data: { domain: panelDomain, name: panelName },
        });

    results.push({
      type: "PANEL",
      key: panel.domain,
      status: panelExisting ? "EXISTS" : "CREATED",
      info: `name=${panel.name}`,
    });

    // 2) Users + PanelUser
    for (const username of SEED_USERS) {
      const currentUser = await prisma.user.findFirst({
        where: { username },
      });

      const user = currentUser
        ? currentUser
        : await prisma.user.create({
            data: {
              username,
              password: await passwordHasher.hash(username),
              role: GlobalRole.WEBMASTER,
              isActive: true,
              forceChangePassword: false,
            },
          });

      results.push({
        type: "USER",
        key: user.username,
        status: currentUser ? "EXISTS" : "CREATED",
        info: `role=${user.role}`,
      });

      const linkExisting = await prisma.panelUser.findUnique({
        where: {
          userId_panelId: { userId: user.id, panelId: panel.id },
        },
      });

      if (!linkExisting) {
        await prisma.panelUser.create({
          data: {
            userId: user.id,
            panelId: panel.id,
            role: PanelRole.ADMIN,
          },
        });
      }

      results.push({
        type: "PANEL_USER",
        key: `${user.username} -> ${panel.domain}`,
        status: linkExisting ? "EXISTS" : "CREATED",
        info: `panelRole=${PanelRole.ADMIN}`,
      });
    }

    spinner.succeed(chalk.green("Seed completed successfully!"));
  } catch (err) {
    spinner.fail(chalk.red("Error while running seed"));
    throw err;
  } finally {
    await prisma.$disconnect();
    await pool.end();
  }

  const rows = [
    [
      chalk.bold("TYPE"),
      chalk.bold("KEY"),
      chalk.bold("STATUS"),
      chalk.bold("INFO"),
    ],
    ...results.map((r) => [
      r.type,
      r.key,
      r.status === "CREATED" ? chalk.green(r.status) : chalk.yellow(r.status),
      r.info ?? "",
    ]),
  ];

  const output = table(rows, {
    border: getBorderCharacters("norc"),
  });

  // eslint-disable-next-line no-console
  console.log(
    boxen(output, {
      padding: 0.2,
      margin: 0,
      borderStyle: "round",
      title: "Seed Result",
      titleAlignment: "center",
    })
  );
}

main().catch((e) => {
  // eslint-disable-next-line no-console
  console.error(
    chalk.red(e instanceof Error ? e.stack ?? e.message : String(e))
  );
  process.exit(1);
});
