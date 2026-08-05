# Configurazione ambiente locale

Questa guida descrive tutto ciò che serve per avviare la piattaforma in locale
tramite `start-dev.sh` o `restart-service.sh` dalla root del workspace.

---

## Prerequisiti

- Java 21 (`/opt/java/jdk-21.0.11+10`)
- Node.js 24 (via nvm)
- k3s in esecuzione con Keycloak installato (namespace `keycloak`)
- kubectl configurato per il cluster locale

---

## File da creare (non versionati in git)

### 1. `case-platform-pgcc/scripts/secrets.env`

Contiene il client secret del BFF. Non deve mai entrare in git.

```bash
export BFF_OIDC_CLIENT_SECRET="<valore dal client pgcc-bff in Keycloak>"
```

> Dove trovarlo: Keycloak → Realm `case-platform` → Clients → `pgcc-bff` → Credentials → Client Secret

---

### 2. `case-platform-frontend/apps/shell/.env`

Configurazione del dev server della Shell (porta e proxy Vite).

```env
PORT=3000
BFF_URL=http://localhost:8081
PGCC_MFE_PORT=3001
```

> `PGCC_MFE_PORT` viene usato in due modi:
> - dal proxy Vite per instradare `/mfe/pgcc/*` → dev server del MFE
> - dal plugin Module Federation per costruire l'entry URL `http://localhost:3001/remoteEntry.js`
>
> Per ogni nuovo dominio aggiungere una riga `{NOME}_MFE_PORT=<porta>`.
>
> **Nota**: `PGCC_BACKEND_URL` non è necessaria per il funzionamento attuale — il MFE PGCC
> chiama il backend direttamente tramite `VITE_PGCC_API_URL`. Servirà quando il MFE
> verrà aggiornato per usare path relativi.

---

### 3. `case-platform-pgcc/frontend/.env`

Configurazione del dev server del PGCC MFE.

```env
PORT=3001
PGCC_MFE_BASE=/
VITE_PGCC_API_URL=http://localhost:8082
```

> **Nota**: `VITE_PGCC_API_URL` è una variabile browser-side (prefisso `VITE_`).
> In locale punta direttamente al backend. In k3s dovrà diventare un path relativo
> `/api/pgcc` — questo è un work in progress.

---

## Variabili per la build di produzione (CI/CD)

Per la build k3s, aggiungere nelle variabili di ambiente del pipeline:

| Variabile | Valore esempio | Dove usata |
|-----------|---------------|------------|
| `PGCC_MFE_ENTRY` | `/mfe/pgcc/remoteEntry.js` | Shell — entry Module Federation per il browser |
| `PGCC_MFE_BASE` | `/mfe/pgcc/` | PGCC MFE — base path degli asset serviti da nginx |

Se `PGCC_MFE_ENTRY` non è impostata, il plugin usa `http://localhost:{PGCC_MFE_PORT}/remoteEntry.js` (solo dev).

---

## File già versionati (nessuna modifica necessaria)

| File | Servizio | Cosa configura |
|------|----------|----------------|
| `case-platform-bff/src/main/resources/application.properties` | BFF | Porta `8081`, OIDC, CORS |
| `case-platform-pgcc/backend/src/main/resources/application.properties` | PGCC Backend | Porta `8082` |
| `case-platform-pgcc/scripts/set-env-bff.sh` | BFF | URL Keycloak, client-id (sourciato da `start-dev.sh`) |

---

## Porte dei servizi

| Servizio | Porta |
|---------|-------|
| Shell (frontend) | 3000 |
| PGCC MFE | 3001 |
| BFF | 8081 |
| PGCC Backend | 8082 |
| Keycloak (port-forward da k3s) | 8180 |

---

## Avvio

```bash
# dalla root del workspace
./start-dev.sh
```

Lo script:
1. Esegue il port-forward di Keycloak da k3s su `localhost:8180`
2. Carica le variabili BFF da `set-env-bff.sh` (che legge `secrets.env`)
3. Avvia in background: PGCC Backend, BFF, PGCC MFE, Shell
4. Scrive i PID in `.dev.pid` e i log in `.dev-logs/`

```bash
# riavviare un singolo servizio
./restart-service.sh shell        # o: pgcc-mfe | bff | pgcc-backend
```

```bash
# fermare tutto
./stop-dev.sh
```
