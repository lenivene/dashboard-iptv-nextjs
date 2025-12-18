import "dotenv/config";
import chalk from "chalk";
import ora from "ora";
import boxen from "boxen";
import { z } from "zod";
import { table, getBorderCharacters } from "table";
import { envSchema } from "@/infrastructure/config/env";

function getSchemaKeys(schema: z.ZodTypeAny): string[] {
  if (schema instanceof z.ZodObject) return Object.keys(schema.shape);
  // fallback
  // @ts-ignore
  const shape = schema?._def?.shape?.();
  return shape ? Object.keys(shape) : [];
}

function maskValue(key: string, val: unknown): string {
  const s = String(val ?? "");
  if (!s) return chalk.dim("<empty>");
  const sensitive = /(secret|password|pwd|token|key|database_url|url)/i.test(
    key
  );
  if (!sensitive) return s.length > 80 ? s.slice(0, 77) + "…" : s;
  if (s.length <= 8) return "*".repeat(s.length);
  return `${s.slice(0, 4)}${"*".repeat(Math.max(4, s.length - 8))}${s.slice(
    -4
  )}`;
}

function calcColumnWidths() {
  const term =
    typeof process.stdout.columns === "number" ? process.stdout.columns : 100;
  const total = Math.max(70, Math.min(120, term));
  const col1 = 28;
  const col2 = 8;
  const col3 = Math.max(20, total - col1 - col2 - 6);

  return [col1, col2, col3];
}

async function main() {
  const spinner = ora("Checking environment variables…").start();

  const keys = getSchemaKeys(envSchema);
  if (!keys.length) {
    spinner.fail("Unable to introspect env schema.");
    process.exit(1);
  }

  const result = envSchema.safeParse(process.env);

  const issuesByKey = new Map<string, string[]>();
  if (!result.success) {
    for (const issue of result.error.issues) {
      const key = String(issue.path?.[0] ?? "");
      if (!key) continue;
      const arr = issuesByKey.get(key) ?? [];
      arr.push(issue.message || issue.code);
      issuesByKey.set(key, arr);
    }
  }

  const rows: string[][] = [
    [chalk.cyan("Variable"), chalk.cyan("Status"), chalk.cyan("Value / Error")],
  ];

  for (const key of keys) {
    const rawVal = process.env[key];
    const errs = issuesByKey.get(key) ?? [];
    const hasError = errs.length > 0;
    const isMissing = (rawVal == null || rawVal === "") && hasError;

    if (isMissing) {
      rows.push([chalk.bold(key), chalk.red("✖"), chalk.dim("<missing>")]);
      continue;
    }

    if (hasError) {
      rows.push([
        chalk.bold(key),
        chalk.yellow("! "),
        chalk.yellow(errs.join("; ")),
      ]);
      continue;
    }

    const display = result.success
      ? // @ts-expect-error
        result.data[key]
      : rawVal;

    rows.push([chalk.bold(key), chalk.green("✔"), maskValue(key, display)]);
  }

  const [w1, w2, w3] = calcColumnWidths();

  const output = table(rows, {
    border: getBorderCharacters("honeywell"),
    columns: [
      { width: w1, wrapWord: true },
      { width: w2, alignment: "center" as const },
      { width: w3, wrapWord: true },
    ],
    columnDefault: { wrapWord: true },
    drawHorizontalLine: (lineIndex, rowCount) =>
      lineIndex === 0 || lineIndex === 1 || lineIndex === rowCount, // header + footer
  });

  if (result.success) {
    spinner.succeed("All required environment variables are present.");
    console.log(
      boxen(output, {
        padding: 0.5,
        borderColor: "green",
        title: "Environment",
        titleAlignment: "center",
      })
    );
    process.exit(0);
  } else {
    spinner.fail("Missing or invalid environment variables.");
    console.log(
      boxen(output, {
        padding: 0.5,
        borderColor: "red",
        title: "Environment",
        titleAlignment: "center",
      })
    );
    console.log(
      "\n" +
        chalk.red("Fix the issues above and try again.") +
        "\n\nTips:\n" +
        `  • Create/update ${chalk.bold(
          ".env.local"
        )} with the required variables\n` +
        `  • See ${chalk.bold("lib/env.ts")} for the definitive schema\n`
    );
    process.exit(1);
  }
}

main().catch((err) => {
  ora().fail("Unexpected error while checking envs.");
  console.error(err);
  process.exit(1);
});
