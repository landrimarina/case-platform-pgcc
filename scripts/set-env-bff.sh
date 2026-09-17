#!/usr/bin/env bash
# Variabili d'ambiente per il BFF del dominio pgcc (sviluppo locale)

export BFF_OIDC_AUTH_SERVER_URL="http://localhost:8180/realms/case-platform"
export BFF_OIDC_CLIENT_ID="case-platform-bff"

# Il secret non deve stare in git — caricalo da un file locale non versionato
SECRETS_FILE="$(dirname "$0")/secrets.env"
if [ -f "$SECRETS_FILE" ]; then
  # shellcheck source=/dev/null
  source "$SECRETS_FILE"
else
  echo "⚠  File secrets mancante: $SECRETS_FILE"
  echo "   Crea il file con: BFF_OIDC_CLIENT_SECRET=<valore>"
  exit 1
fi
