import { computePanelDomainKey } from "@/shared/utils/domain-key";
import { prisma } from "@/infrastructure/database/prisma";

export async function findPanelIdByHost(
  hostHeader: string
): Promise<string | null> {
  const domain = computePanelDomainKey(hostHeader);

  if (!domain) return null;

  const { id: panelId = null } =
    (await prisma.panel.findUnique({
      where: { domain },
      select: { id: true },
    })) || {};

  return panelId ?? null;
}
