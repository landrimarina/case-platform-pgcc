# Routing — Come funziona in locale e in k3s

## Da dove vengono i path?

| File | Servizio | Cosa configura |
|------|----------|----------------|
| `case-platform-frontend/apps/shell/.env` | Shell | Porta 3000, BFF_URL, PGCC_MFE_PORT |
| `case-platform-pgcc/frontend/.env` | PGCC MFE | Porta 3001, PGCC_MFE_BASE |
| `case-platform-bff/.../application.properties` | BFF | Porta 8081, OIDC |
| `case-platform-pgcc/backend/.../application.properties` | PGCC Backend | Porta 8082 |

---

## Il flusso passo per passo

```
1. L'utente apre il browser su localhost:3000
   └─ risponde la Shell (Vite dev server)

2. Shell carica App.tsx e chiede "chi sei?"
   └─ GET /api/session/me
      └─ Vite proxy vede "/api" → manda a BFF_URL (8081)
      └─ BFF risponde con { username, roles } oppure 401

3a. Se 401 → mostra pagina "Accedi"
    └─ click "Accedi" → GET /api/login
       └─ Vite proxy → BFF (8081)
       └─ BFF → redirect a Keycloak (8180)
       └─ Keycloak → utente inserisce credenziali
       └─ Keycloak → GET /auth/callback
          └─ Vite proxy vede "/auth" → BFF (8081)
          └─ BFF salva cookie → redirect a Shell (3000)
          └─ torna al punto 2

3b. Se 200 → mostra la Shell con menu e route

4. Shell chiede la lista dei MFE da caricare  [TO DO: da implementare]
   └─ GET /api/registry
      └─ BFF risponde: [{ name:'pgcc', entry:'/mfe/pgcc/remoteEntry.js', route:'/pgcc' }]
      └─ il path arriva dal BFF, NON è cablato nella Shell

5. Shell carica il menu e la pagina del PGCC MFE
   └─ GET /mfe/pgcc/remoteEntry.js
      └─ Vite proxy vede "/mfe/pgcc" → legge PGCC_MFE_PORT dal .env → manda a 3001
      └─ PGCC MFE dev server risponde con il bundle JS

6. Utente naviga su /pgcc → Shell carica PgccHome
   └─ stesso meccanismo del punto 5

7. PgccHome chiede i dati al backend  [problema aperto: ora chiama diretto]
   └─ GET /api/pgcc/home
      └─ Vite proxy vede "/api/pgcc" → manda a PGCC_BACKEND_URL (8082)
      └─ PGCC Backend risponde con { message: "Benvenuto..." }
```

---

## Chi conosce cosa?

```
SHELL conosce:
  ✓ la porta del BFF       (da .env → BFF_URL)
  ✓ la porta dei MFE       (da .env → PGCC_MFE_PORT)
  ✗ NON conosce le route   (arriveranno dal BFF /api/registry — TO DO)

BFF conosce:
  ✓ Keycloak               (da set-env-bff.sh → BFF_OIDC_AUTH_SERVER_URL)
  ✓ chi può accedere a cosa (ruoli → MFE — da configurare)
  ✗ NON conosce la Shell direttamente (solo il cookie di sessione)

MFE PGCC conosce:
  ✓ la propria porta       (da .env → PORT=3001)
  ✓ il path dei suoi asset (da .env → PGCC_MFE_BASE=/)
  ✗ NON conosce la Shell (è autonomo)

PGCC BACKEND conosce:
  ✓ la propria porta       (da application.properties → 8082)
  ✗ NON conosce nessun altro servizio
```

---

## Chi fa il proxy in base all'ambiente?

| Ambiente | Proxy | Configurazione |
|----------|-------|----------------|
| **Locale** | Vite dev server | `vite.config.ts` legge le porte da Shell `.env` |
| **k3s** | APISIX | `ApisixRoute` nel gitops — usa nomi k8s (`pgcc-frontend.pgcc.svc.cluster.local`) |

Il codice della Shell è **identico** nei due ambienti — cambia solo chi risponde ai path.

---

## Regole proxy Vite (locale) vs APISIX (k3s)

| Path | Locale (Vite proxy) | k3s (APISIX) |
|------|---------------------|--------------|
| `/mfe/pgcc/*` | `localhost:{PGCC_MFE_PORT}` | `pgcc-frontend.pgcc.svc` |
| `/api/pgcc/*` | `localhost:{PGCC_BACKEND_URL}` | `pgcc-backend.pgcc.svc` |
| `/api/*` | `localhost:{BFF_URL}` | `bff.platform.svc` |
| `/auth/*` | `localhost:{BFF_URL}` | `bff.platform.svc` |
