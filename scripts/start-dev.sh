#!/usr/bin/env bash
# Avvia tutti i processi di sviluppo in background con log separati

set -e

WORKSPACE="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$WORKSPACE/.dev-logs"
PID_FILE="$WORKSPACE/.dev.pid"

export JAVA_HOME=/opt/java/jdk-21.0.11+10
export PATH="$JAVA_HOME/bin:$PATH"

# nvm per node
export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm use 24 --silent

mkdir -p "$LOG_DIR"
> "$PID_FILE"

# Assicura che tutti i mvnw siano eseguibili
chmod +x "$WORKSPACE"/case-platform-bff/mvnw 2>/dev/null || true
chmod +x "$WORKSPACE"/case-platform-pgcc/backend/mvnw 2>/dev/null || true

start_process() {
  local name="$1"
  local dir="$2"
  local cmd="$3"
  local log="$LOG_DIR/${name}.log"

  echo "▶  Avvio $name..."
  (cd "$dir" && eval "$cmd" > "$log" 2>&1) &
  local pid=$!
  echo "$pid $name" >> "$PID_FILE"
  echo "   PID $pid — log: $log"
}

echo "=== Case Platform — Dev Start ==="

# Keycloak port-forward (richiede k3s in esecuzione)
if kubectl get svc -n keycloak case-platform-keycloak-service &>/dev/null; then
  echo "▶  Keycloak port-forward :8180 → k3s..."
  kubectl port-forward -n keycloak svc/case-platform-keycloak-service 8180:8080 \
    > "$LOG_DIR/keycloak-portforward.log" 2>&1 &
  echo "$! keycloak-portforward" >> "$PID_FILE"
else
  echo "⚠  Keycloak non trovato in k3s — avvialo prima nel cluster"
fi

# Carica env BFF
# shellcheck source=/dev/null
source "$WORKSPACE/case-platform-pgcc/scripts/set-env-bff.sh"

NPM="$NVM_DIR/versions/node/v24.19.0/bin/npm"

start_process "pgcc-backend" \
  "$WORKSPACE/case-platform-pgcc/backend" \
  "./mvnw clean quarkus:dev -Ddebug=5006"

start_process "bff" \
  "$WORKSPACE/case-platform-bff" \
  "./mvnw clean quarkus:dev -Ddebug=5005"

start_process "pgcc-mfe" \
  "$WORKSPACE/case-platform-pgcc/frontend" \
  "$NPM run dev"

start_process "shell" \
  "$WORKSPACE/case-platform-frontend/apps/shell" \
  "$NPM run dev"

echo ""
echo "Tutti i processi avviati. Porte:"
echo "  Shell      → http://localhost:3000"
echo "  PGCC MFE   → http://localhost:3001"
echo "  BFF        → http://localhost:8081"
echo "  PGCC BE    → http://localhost:8082"
echo "  Keycloak   → http://localhost:8180"
echo ""
echo "Log: $LOG_DIR/"
echo "Stop: ./stop-dev.sh"
