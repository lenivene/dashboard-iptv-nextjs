import { parse } from "tldts";
import { env } from "@/infrastructure/config/env";

export const stripPort = (host: string) => host.replace(/:\d+$/, "");
export const stripWww = (host: string) => host.replace(/^www\./i, "");
export const normHost = (raw: string) =>
  stripWww(
    stripPort(
      String(raw || "")
        .trim()
        .toLowerCase()
    )
  );

/**
 * Regras:
 * - Se host termina em BASE_PANEL_DOMAIN => retorna último label do subdomain
 *   Ex.: "foo.meupainel.com" -> "foo"
 *   Ex.: "bar.foo.meupainel.com" -> "foo"
 * - Senão => retorna host completo normalizado
 */
export function computePanelDomainKey(rawHost: string): string | null {
  const base = normHost(env.BASE_PANEL_DOMAIN);
  const host = normHost(rawHost);

  if (!host || !base) return null;
  if (host === base) return null; // opcional: bloquear apex

  const parsedHost = parse(host);
  const parsedBase = parse(base);

  if (!parsedHost.domain || !parsedBase.domain) return null;

  const hostRegistrable = `${parsedHost.domain}.${parsedHost.publicSuffix}`;
  const baseRegistrable = `${parsedBase.domain}.${parsedBase.publicSuffix}`;

  if (hostRegistrable === baseRegistrable) {
    if (!parsedHost.subdomain) return null;

    const labels = parsedHost.subdomain.split(".");

    return labels[labels.length - 1];
  }

  return host;
}
