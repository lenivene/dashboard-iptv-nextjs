-- CreateExtension
CREATE EXTENSION IF NOT EXISTS "citext";

-- CreateEnum
CREATE TYPE "GlobalRole" AS ENUM ('WEBMASTER', 'USER');

-- CreateEnum
CREATE TYPE "PanelRole" AS ENUM ('ADMIN', 'CUSTOM');

-- CreateEnum
CREATE TYPE "ServerType" AS ENUM ('XUI', 'XTREAM', 'ONE_STREAM');

-- CreateEnum
CREATE TYPE "DurationIn" AS ENUM ('HOURS', 'DAYS', 'MONTHS', 'YEARS');

-- CreateTable
CREATE TABLE "user" (
    "id" TEXT NOT NULL,
    "username" TEXT NOT NULL,
    "password" TEXT,
    "credit" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "role" "GlobalRole" NOT NULL DEFAULT 'USER',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "forceChangePassword" BOOLEAN NOT NULL DEFAULT false,
    "parentUserId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "user_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "panel" (
    "id" TEXT NOT NULL,
    "domain" CITEXT NOT NULL,
    "name" TEXT,
    "logo" TEXT,
    "isBlocked" BOOLEAN NOT NULL DEFAULT false,
    "expiredAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "panel_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "panel_user" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "panelId" TEXT NOT NULL,
    "role" "PanelRole" NOT NULL,
    "permissionId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "panel_user_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "permission" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "panelId" TEXT,
    "canCreateUser" BOOLEAN NOT NULL DEFAULT false,
    "canEditUser" BOOLEAN NOT NULL DEFAULT false,
    "canDeleteUser" BOOLEAN NOT NULL DEFAULT false,
    "canListUser" BOOLEAN NOT NULL DEFAULT false,
    "canDeleteAnyUser" BOOLEAN NOT NULL DEFAULT false,
    "canBlockUser" BOOLEAN NOT NULL DEFAULT false,
    "canUnblockUser" BOOLEAN NOT NULL DEFAULT false,
    "canCreateClient" BOOLEAN NOT NULL DEFAULT false,
    "canEditClient" BOOLEAN NOT NULL DEFAULT false,
    "canDeleteClient" BOOLEAN NOT NULL DEFAULT false,
    "canEditAnyClient" BOOLEAN NOT NULL DEFAULT false,
    "canDeleteAnyClient" BOOLEAN NOT NULL DEFAULT false,
    "canEditClientUsername" BOOLEAN NOT NULL DEFAULT false,
    "canEditClientPassword" BOOLEAN NOT NULL DEFAULT false,
    "canEditClientExpiryDate" BOOLEAN NOT NULL DEFAULT false,
    "canEditClientPlanPrice" BOOLEAN NOT NULL DEFAULT false,
    "canEditClientUser" BOOLEAN NOT NULL DEFAULT false,
    "canBlockClient" BOOLEAN NOT NULL DEFAULT false,
    "canUnblockClient" BOOLEAN NOT NULL DEFAULT false,
    "canTransferCredit" BOOLEAN NOT NULL DEFAULT false,
    "canRemoveCredit" BOOLEAN NOT NULL DEFAULT false,
    "canCreatePackage" BOOLEAN NOT NULL DEFAULT false,
    "canListPackage" BOOLEAN NOT NULL DEFAULT false,
    "canEditPackage" BOOLEAN NOT NULL DEFAULT false,
    "canDeletePackage" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "permission_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_server_permission" (
    "id" TEXT NOT NULL,
    "panelUserId" TEXT NOT NULL,
    "serverId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "user_server_permission_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "m3u_domains" (
    "id" TEXT NOT NULL,
    "name" TEXT,
    "domain" CITEXT NOT NULL,
    "useSsl" BOOLEAN NOT NULL DEFAULT false,
    "serverId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "m3u_domains_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_m3u_domain_override" (
    "id" TEXT NOT NULL,
    "domain" CITEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "m3uDomainId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "user_m3u_domain_override_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "servers" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "type" "ServerType" NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "defaultPassClient" TEXT NOT NULL,
    "allowedBouquets" INTEGER[],
    "userMaxConnection" INTEGER NOT NULL,
    "allowCreateRestream" BOOLEAN NOT NULL DEFAULT false,
    "templateCreateClient" TEXT NOT NULL,
    "panelId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "servers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "server_xui_data" (
    "id" TEXT NOT NULL,
    "serverId" TEXT NOT NULL,
    "domain" TEXT NOT NULL,
    "accessCode" TEXT NOT NULL,
    "apiKey" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "server_xui_data_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "server_xtream_data" (
    "id" TEXT NOT NULL,
    "serverId" TEXT NOT NULL,
    "host" CITEXT NOT NULL,
    "port" INTEGER NOT NULL DEFAULT 7999,
    "username" TEXT NOT NULL DEFAULT 'root',
    "password" TEXT,
    "database" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "server_xtream_data_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "server_one_stream_data" (
    "id" TEXT NOT NULL,
    "serverId" TEXT NOT NULL,
    "domain" TEXT NOT NULL,
    "apiToken" TEXT NOT NULL,
    "userToken" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "server_one_stream_data_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "packages" (
    "id" TEXT NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "isMag" BOOLEAN NOT NULL DEFAULT false,
    "isAsnLock" BOOLEAN NOT NULL DEFAULT false,
    "isIspLock" BOOLEAN NOT NULL DEFAULT false,
    "isTrial" BOOLEAN NOT NULL DEFAULT false,
    "isReStreamer" BOOLEAN NOT NULL DEFAULT false,
    "name" TEXT NOT NULL,
    "planPrice" INTEGER NOT NULL DEFAULT 0,
    "credit" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "accessOutput" TEXT[],
    "duration" INTEGER NOT NULL DEFAULT 1,
    "durationIn" "DurationIn" NOT NULL,
    "serverId" TEXT NOT NULL,
    "serverPackageId" TEXT NOT NULL,

    CONSTRAINT "packages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "client_server" (
    "id" TEXT NOT NULL,
    "username" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "totalScreen" INTEGER NOT NULL DEFAULT 1,
    "isTrial" BOOLEAN NOT NULL,
    "expirationDate" TIMESTAMP(3),
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "ownerUserId" TEXT NOT NULL,
    "serverId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "client_server_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "panel_domain_key" ON "panel"("domain");

-- CreateIndex
CREATE INDEX "panel_user_panelId_idx" ON "panel_user"("panelId");

-- CreateIndex
CREATE INDEX "panel_user_userId_idx" ON "panel_user"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "panel_user_userId_panelId_key" ON "panel_user"("userId", "panelId");

-- CreateIndex
CREATE UNIQUE INDEX "permission_panelId_name_key" ON "permission"("panelId", "name");

-- CreateIndex
CREATE INDEX "user_server_permission_panelUserId_idx" ON "user_server_permission"("panelUserId");

-- CreateIndex
CREATE INDEX "user_server_permission_serverId_idx" ON "user_server_permission"("serverId");

-- CreateIndex
CREATE UNIQUE INDEX "user_server_permission_panelUserId_serverId_key" ON "user_server_permission"("panelUserId", "serverId");

-- CreateIndex
CREATE INDEX "m3u_domains_serverId_idx" ON "m3u_domains"("serverId");

-- CreateIndex
CREATE UNIQUE INDEX "m3u_domains_serverId_domain_key" ON "m3u_domains"("serverId", "domain");

-- CreateIndex
CREATE INDEX "user_m3u_domain_override_userId_idx" ON "user_m3u_domain_override"("userId");

-- CreateIndex
CREATE INDEX "user_m3u_domain_override_m3uDomainId_idx" ON "user_m3u_domain_override"("m3uDomainId");

-- CreateIndex
CREATE UNIQUE INDEX "user_m3u_domain_override_userId_m3uDomainId_key" ON "user_m3u_domain_override"("userId", "m3uDomainId");

-- CreateIndex
CREATE UNIQUE INDEX "user_m3u_domain_override_domain_key" ON "user_m3u_domain_override"("domain");

-- CreateIndex
CREATE INDEX "servers_panelId_idx" ON "servers"("panelId");

-- CreateIndex
CREATE UNIQUE INDEX "server_xui_data_serverId_key" ON "server_xui_data"("serverId");

-- CreateIndex
CREATE INDEX "server_xui_data_domain_idx" ON "server_xui_data"("domain");

-- CreateIndex
CREATE UNIQUE INDEX "server_xtream_data_serverId_key" ON "server_xtream_data"("serverId");

-- CreateIndex
CREATE INDEX "server_xtream_data_host_port_idx" ON "server_xtream_data"("host", "port");

-- CreateIndex
CREATE UNIQUE INDEX "server_one_stream_data_serverId_key" ON "server_one_stream_data"("serverId");

-- CreateIndex
CREATE INDEX "server_one_stream_data_domain_idx" ON "server_one_stream_data"("domain");

-- CreateIndex
CREATE UNIQUE INDEX "packages_serverId_key" ON "packages"("serverId");

-- CreateIndex
CREATE INDEX "client_server_serverId_idx" ON "client_server"("serverId");

-- CreateIndex
CREATE UNIQUE INDEX "client_server_serverId_username_key" ON "client_server"("serverId", "username");

-- AddForeignKey
ALTER TABLE "user" ADD CONSTRAINT "user_parentUserId_fkey" FOREIGN KEY ("parentUserId") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "panel_user" ADD CONSTRAINT "panel_user_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "panel_user" ADD CONSTRAINT "panel_user_panelId_fkey" FOREIGN KEY ("panelId") REFERENCES "panel"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "panel_user" ADD CONSTRAINT "panel_user_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES "permission"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "permission" ADD CONSTRAINT "permission_panelId_fkey" FOREIGN KEY ("panelId") REFERENCES "panel"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_server_permission" ADD CONSTRAINT "user_server_permission_panelUserId_fkey" FOREIGN KEY ("panelUserId") REFERENCES "panel_user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_server_permission" ADD CONSTRAINT "user_server_permission_serverId_fkey" FOREIGN KEY ("serverId") REFERENCES "servers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "m3u_domains" ADD CONSTRAINT "m3u_domains_serverId_fkey" FOREIGN KEY ("serverId") REFERENCES "servers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_m3u_domain_override" ADD CONSTRAINT "user_m3u_domain_override_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_m3u_domain_override" ADD CONSTRAINT "user_m3u_domain_override_m3uDomainId_fkey" FOREIGN KEY ("m3uDomainId") REFERENCES "m3u_domains"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "servers" ADD CONSTRAINT "servers_panelId_fkey" FOREIGN KEY ("panelId") REFERENCES "panel"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "server_xui_data" ADD CONSTRAINT "server_xui_data_serverId_fkey" FOREIGN KEY ("serverId") REFERENCES "servers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "server_xtream_data" ADD CONSTRAINT "server_xtream_data_serverId_fkey" FOREIGN KEY ("serverId") REFERENCES "servers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "server_one_stream_data" ADD CONSTRAINT "server_one_stream_data_serverId_fkey" FOREIGN KEY ("serverId") REFERENCES "servers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "packages" ADD CONSTRAINT "packages_serverId_fkey" FOREIGN KEY ("serverId") REFERENCES "servers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "client_server" ADD CONSTRAINT "client_server_ownerUserId_fkey" FOREIGN KEY ("ownerUserId") REFERENCES "user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "client_server" ADD CONSTRAINT "client_server_serverId_fkey" FOREIGN KEY ("serverId") REFERENCES "servers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
