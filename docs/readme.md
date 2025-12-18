# 📦 Painel IPTV – Modelo de Domínio & Regras de Negócio

Este documento descreve o **modelo de dados**, **regras de negócio**, **papéis**, **permissões** e **relações** do sistema de painéis IPTV, conforme definido no schema Prisma.

---

## 🧱 Visão Geral da Arquitetura

O sistema é multi-tenant e baseado em **painéis (`Panel`)**, onde:

- Um **usuário (`User`)** pode participar de vários painéis
- Cada painel possui:

  - Usuários com papéis específicos
  - Conjuntos de permissões customizadas
  - Servidores IPTV
  - Domínios M3U

- As permissões podem ser:

  - Globais (ADMIN do painel)
  - Customizadas por funcionalidade
  - Restritas por servidor

---

## 👤 Usuários (`User`)

Representa a identidade global do sistema.

### Campos importantes

- `role` (`GlobalRole`)

  - `WEBMASTER`: acesso total ao sistema (SUDO)
  - `USER`: usuário comum

- `credit`: saldo global
- `forceChangePassword`: força troca de senha no login

### Regras

- Um usuário **não pertence diretamente a um painel**
- O vínculo com painéis ocorre via `PanelUser`

---

## 🧩 Painéis (`Panel`)

Representa um painel IPTV (tenant).

### Regras importantes

- `domain` é **único e case-insensitive** (`Citext`)

  - `meupainel.com` = `MeuPainel.com`

- Um painel possui:

  - Usuários (`PanelUser`)
  - Servidores (`Servers`)
  - Permissões (`Permission`)

---

## 🔗 Associação Usuário ↔ Painel (`PanelUser`)

Tabela central de controle de acesso.

### Regras

- Um usuário pode estar **apenas uma vez** em cada painel
  `@@unique([userId, panelId])`
- Define o **papel do usuário dentro do painel**

### Papéis (`PanelRole`)

- `ADMIN`

  - Acesso total ao painel
  - Ignora permissões customizadas

- `CUSTOM`

  - Usa permissões definidas no modelo `Permission`

### Regras de negócio (nível aplicação)

- Se `role = CUSTOM` → `permissionId` **deve existir**
- Se `role = ADMIN` → `permissionId` deve ser `null`

---

## 🔐 Permissões (`Permission`)

Define permissões customizadas por painel.

### Escopo

- Sempre pertencem a **um painel específico**
- São reutilizáveis entre usuários do mesmo painel

### Regras

- Nome único por painel
  `@@unique([panelId, name])`

### Permissões disponíveis

- Usuários

  - `canCreateUser`
  - `canEditUser`
  - `canDeleteUser`

- Servidores

  - `canCreateServer`
  - `canEditServer`
  - `canDeleteServer`

- M3U

  - `canManageM3u`

---

## 🖥️ Servidores IPTV (`Servers`)

Representa um servidor IPTV vinculado a um painel.

### Tipos de servidor (`ServerType`)

- `XUI`
- `XTREAM`
- `ONE_STREAM`

### Regras

- Um servidor pertence opcionalmente a um painel
- Cada servidor pode ter **apenas um** conjunto de dados do seu tipo:

  - `ServerXuiData`
  - `ServerXtreamData`
  - `ServerOneStreamData`

> ⚠️ Regra de negócio (aplicação):
> O tipo do servidor **define obrigatoriamente** qual tabela de dados deve existir.

---

## 🔑 Permissões por Servidor (`UserServerPermission`)

Controla **quais servidores** um usuário pode acessar.

### Regras

- Um usuário não pode ter permissão duplicada para o mesmo servidor
  `@@unique([panelUserId, serverId])`
- Usado principalmente para usuários `CUSTOM`

---

## 🌐 Domínios M3U (`M3uDomain`)

Define domínios M3U associados a servidores.

### Regras

- Um domínio pertence a **um servidor**
- Não pode repetir domínio dentro do mesmo servidor
  `@@unique([serverId, domain])`

---

## 👤 Override de Domínio por Usuário (`UserM3uDomainOverride`)

Permite que um usuário tenha um **domínio M3U personalizado**.

### Regras críticas

- Um usuário pode ter apenas um override por domínio base
  `@@unique([userId, m3uDomainId])`
- Um domínio override é **globalmente único no sistema**
  `@@unique([domain])`

➡️ Isso garante que **nenhum domínio M3U personalizado seja reutilizado por outro usuário**.

---

## 🧹 Integridade Referencial (Deletes & Updates)

O schema foi desenhado para **não deixar dados órfãos**.

### Exemplos

- Deletar `User`:

  - Remove vínculos com painéis
  - Remove overrides de M3U

- Deletar `Panel`:

  - Remove usuários do painel
  - Remove permissões
  - Remove servidores

- Deletar `Permission`:

  - `PanelUser.permissionId` vira `null` (`SetNull`)

---

## 🧠 Regras Importantes (Resumo)

- ADMIN do painel **ignora permissões**
- CUSTOM depende de `Permission` + `UserServerPermission`
- Domínios são sempre **case-insensitive**
- Overrides M3U são **exclusivos globalmente**
- Tipos de servidor definem estrutura obrigatória de dados
- Regras condicionais são validadas **no domínio / use-case**, não no Prisma

---

## ✅ Boas Práticas Recomendadas

- Validar regras condicionais no **use-case**
- Nunca confiar apenas no Prisma para regras de negócio
- Usar `Citext` sempre que domínio / hostname estiver envolvido
- Centralizar verificação de permissão em middleware ou service
