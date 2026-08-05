#!/usr/bin/env bash
# Ferma tutti i processi avviati da start-dev.sh

WORKSPACE="$(cd "$(dirname "$0")" && pwd)"
PID_FILE="$WORKSPACE/.dev.pid"

echo "=== Case Platform — Dev Stop ==="

# Kill processi registrati nel pid file (esclude keycloak rimosso da start-dev)
if [ -f "$PID_FILE" ]; then
  while read -r pid name; do
    if kill -0 "$pid" 2>/dev/null; then
      echo "■  Stop $name (PID $pid)"
      kill "$pid" 2>/dev/null || true
    fi
  done < "$PID_FILE"
fi

# Kill Java processes by port (JVM children survive shell PID kill)
for port in 8081 8082; do
  pid=$(ss -tlnp 2>/dev/null | grep ":$port " | grep -oP 'pid=\K[0-9]+' | head -1)
  if [ -n "$pid" ]; then
    echo "■  Stop java :$port (PID $pid)"
    kill "$pid" 2>/dev/null || true
  fi
done

# Kill Vite/node processes by port
for port in 3000 3001 3002 3003 3004 3005; do
  fuser -k "${port}/tcp" 2>/dev/null || true
done
echo "   Vite processi fermati (porte 3000-3005)"

rm -f "$PID_FILE"

# Attendi che le porte siano libere e verifica
echo ""
echo "Verifica porte in corso..."
sleep 2

ALL_CLEAR=true
for port in 8081 8082 3000 3001; do
  if ss -tlnp 2>/dev/null | grep -q ":$port "; then
    echo "  ATTENZIONE: porta $port ancora occupata"
    ALL_CLEAR=false
  fi
done

# Verifica processi quarkus residui
if pgrep -f "quarkus:dev" > /dev/null 2>&1; then
  echo "  ATTENZIONE: processi quarkus:dev ancora attivi, forzo kill..."
  pkill -f "quarkus:dev" 2>/dev/null || true
  ALL_CLEAR=false
fi

# Verifica agente JDWP (debug ports) - usa ss invece di lsof non disponibile in WSL
for jdwp_port in 5005 5006; do
  jdwp_pid=$(ss -tlnp 2>/dev/null | grep ":$jdwp_port " | grep -oP 'pid=\K[0-9]+' | head -1)
  if [ -n "$jdwp_pid" ]; then
    echo "  ATTENZIONE: porta JDWP $jdwp_port ancora occupata (PID $jdwp_pid), forzo kill..."
    kill "$jdwp_pid" 2>/dev/null || true
    ALL_CLEAR=false
  fi
done

if $ALL_CLEAR; then
  echo ""
  echo "✓ Tutti i processi terminati correttamente."
else
  echo ""
  echo "✓ Stop completato (con forzatura di alcuni processi residui)."
fi

