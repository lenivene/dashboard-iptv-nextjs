# 🧠 Mapa Mental — Funcionamento do Banco / Domínio

## 👤 Usuário (`User`)

- É **global** no sistema
- Pode:

  - Estar vinculado a **N painéis**
  - Ter **overrides de domínio M3U**

- Possui:

  - `GlobalRole` (`WEBMASTER | USER`)

    - `WEBMASTER` ignora qualquer regra de painel
    - `USER` depende das regras do painel

```
User
 ├─ GlobalRole
 ├─ credit
 ├─ PanelUser (N)
 └─ UserM3uDomainOverride (N)
```

---

## 🧩 Painel (`Panel`)

- Representa um **tenant**
- Identificado por:

  - `domain` (único e case-insensitive)

- Possui:

  - Usuários
  - Servidores
  - Conjuntos de permissões

```
Panel
 ├─ domain (único, citext)
 ├─ PanelUser (N)
 ├─ Permission (N)
 └─ Servers (N)
```

---

## 🔗 Usuário no Painel (`PanelUser`)

> **Entidade mais importante do sistema**

- Liga **User ↔ Panel**
- Um usuário:

  - Só pode existir **1 vez por painel**

- Define:

  - Papel no painel
  - Permissões
  - Acesso a servidores

```
PanelUser
 ├─ User (1)
 ├─ Panel (1)
 ├─ role (ADMIN | CUSTOM)
 ├─ Permission (0..1)
 └─ UserServerPermission (N)
```

### Regras mentais

- `ADMIN`

  - Acesso total
  - Ignora Permission

- `CUSTOM`

  - Depende de:

    - Permission (flags)
    - UserServerPermission (quais servers pode usar)

---

## 🔐 Permissões (`Permission`)

- São **do painel**, não do usuário
- Funcionam como **perfil reutilizável**
- Definem **o que** o usuário pode fazer

```
Permission
 ├─ Panel (1)
 ├─ name
 ├─ flags (CRUD user, server, m3u)
 └─ PanelUser (N)
```

➡️ Um painel pode ter várias permissões
➡️ Vários usuários podem usar a mesma permissão

---

## 🖥️ Servidores (`Servers`)

- Representam servidores IPTV
- Podem existir **apenas dentro de um painel**
- Possuem um **tipo**, que define seus dados técnicos

```
Servers
 ├─ Panel (0..1)
 ├─ type (XUI | XTREAM | ONE_STREAM)
 ├─ M3uDomain (N)
 ├─ UserServerPermission (N)
 └─ Server*Data (1)
```

### Dados por tipo

- `XUI` → `ServerXuiData`
- `XTREAM` → `ServerXtreamData`
- `ONE_STREAM` → `ServerOneStreamData`

> Regra mental: **1 servidor = 1 tipo = 1 tabela de dados**

---

## 🔑 Permissão por Servidor (`UserServerPermission`)

- Controla **quais servidores** um usuário pode acessar
- Sempre ligado a um `PanelUser`

```
UserServerPermission
 ├─ PanelUser (1)
 └─ Servers (1)
```

➡️ Usado principalmente para usuários `CUSTOM`
➡️ ADMIN geralmente ignora isso

---

## 🌐 Domínios M3U (`M3uDomain`)

- Domínios associados a **um servidor**
- São a base para acesso M3U

```
M3uDomain
 ├─ Servers (1)
 └─ UserM3uDomainOverride (N)
```

Regras:

- Mesmo domínio não pode repetir no mesmo servidor
- Case-insensitive

---

## 👤 Override de Domínio (`UserM3uDomainOverride`)

- Permite domínio **personalizado por usuário**
- Sempre ligado a:

  - Um usuário
  - Um domínio M3U base

```
UserM3uDomainOverride
 ├─ User (1)
 └─ M3uDomain (1)
```

Regras fortes:

- Um usuário só pode ter 1 override por M3U
- Um domínio override é **único no sistema inteiro**

---

## 🧭 Fluxo mental resumido (bem “bla bla” 😄)

> **Usuário**
> → entra em **Painel**
> → vira um **PanelUser**
> → recebe um **role**
> → se CUSTOM:
> → usa uma **Permission**
> → e só acessa **Servers permitidos**
> → servidores possuem **Domínios M3U**
> → usuário pode sobrescrever o domínio M3U pra ele

---

## 🧩 Mapa ultra-resumido (1 linha)

```
User → PanelUser → Panel
                → Permission
                → UserServerPermission → Servers → M3uDomain → UserM3uDomainOverride
```
