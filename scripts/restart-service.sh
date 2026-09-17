#!/usr/bin/env bash
# Riavvia un singolo servizio. Uso: ./restart-service.sh <nome>
# Servizi: shell | pgcc-mfe | bff | pgcc-backend

set -e

WORKSPACE="$(cd "$(dirname "$0")" && pwd)"
PID_FILE="$WORKSPACE/.dev.pid"
LOG_DIR="$WORKSPACE/.dev-logs"

export JAVA_HOME=/opt/java/jdk-21.0.11+10
export PATH="$JAVA_HOME/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm use 24 --silent

NPM="$NVM_DIR/versions/node/v24.19.0/bin/npm"

SERVICE="${1:-}"
if [ -z "$SERVICE" ]; then
  echo "Uso: $0 <nome-servizio>"
  echo "Servizi disponibili: shell | pgcc-mfe | bff | pgcc-backend"
  exit 1
fi

# Mappa nome → directory, comando e porta da liberare
case "$SERVICE" in
  shell)
    DIR="$WORKSPACE/case-platform-frontend/apps/shell"
    CMD="$NPM run dev"
    CLEAR_VITE=true
    PORT=3000
    ;;
  pgcc-mfe)
    DIR="$WORKSPACE/case-platform-pgcc/frontend"
    CMD="$NPM run dev"
    CLEAR_VITE=true
    PORT=3001
    ;;
  bff)
    DIR="$WORKSPACE/case-platform-bff"
    CMD="./mvnw clean quarkus:dev -Ddebug=5005"
    CLEAR_VITE=false
    PORT=8081
    ;;
  pgcc-backend)
    DIR="$WORKSPACE/case-platform-pgcc/backend"
    CMD="./mvnw clean quarkus:dev -Dquarkus.http.port=8082 -Ddebug=5006"
    CLEAR_VITE=false
    PORT=8082
    ;;
  *)
    echo "Servizio sconosciuto: $SERVICE"
    echo "Servizi disponibili: shell | pgcc-mfe | bff | pgcc-backend"
    exit 1
    ;;
esac

LOG="$LOG_DIR/${SERVICE}.log"

# Kill per porta (libera anche processi figli come Vite)
echo "■  Stop $SERVICE (porta $PORT)..."
fuser -k "${PORT}/tcp" 2>/dev/null || true

# Rimuovi dal pid file
[ -f "$PID_FILE" ] && sed -i "/ $SERVICE$/d" "$PID_FILE"

sleep 1

# Verifica che la porta sia libera
if fuser "${PORT}/tcp" 2>/dev/null; then
  echo "⚠  Porta $PORT ancora occupata, attendo..."
  sleep 2
fi

# Pulizia cache Vite se frontend
if [ "$CLEAR_VITE" = true ] && [ -d "$DIR/node_modules/.vite" ]; then
  echo "🗑  Pulizia cache Vite ($SERVICE)"
  rm -rf "$DIR/node_modules/.vite"
fi

# Avvio
echo "▶  Avvio $SERVICE..."
(cd "$DIR" && eval "$CMD" > "$LOG" 2>&1) &
NEW_PID=$!
echo "$NEW_PID $SERVICE" >> "$PID_FILE"
echo "   PID $NEW_PID — log: $LOG"
