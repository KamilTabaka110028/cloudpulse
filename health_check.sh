#!/usr/bin/env bash
# =============================================================================
# CloudPulse — health_check.sh
# Moduł 1: Fundament projektu
# Autor: Kamil | Bootcamp DevOps
# =============================================================================

set -uo pipefail
# Uwaga: celowo pomijamy -e żeby skrypt nie przerywał przy pierwszym błędzie
# (chcemy sprawdzić WSZYSTKIE endpointy i zebrać raport, nawet jeśli część padnie)

# ── Konfiguracja ─────────────────────────────────────────────────────────────

LOG_FILE="${LOG_FILE:-/tmp/cloudpulse_health.log}"
TIMEOUT=5          # maksymalny czas oczekiwania na odpowiedź (sekundy)
FAILED=0           # licznik nieudanych sprawdzeń

# Lista endpointów do sprawdzenia (dodaj/usuń dowolne)
ENDPOINTS=(
    "https://httpbin.org/status/200"
    "https://google.com"
    "https://onet.pl"
    "https://github.com"              # ← DODAJ TO
    "https://httpbin.org/status/503"
)

# ── Kolory w terminalu ────────────────────────────────────────────────────────

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color (reset)

# ── Funkcje ───────────────────────────────────────────────────────────────────

timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

log() {
    local level="$1"
    local message="$2"
    echo "[$(timestamp)] [$level] $message" | tee -a "$LOG_FILE"
}

check_endpoint() {
    local url="$1"

    # curl zwraca: kod_HTTP czas_ms
    local result
    result=$(curl -s -o /dev/null -L \
        --max-time "$TIMEOUT" \
        -w "%{http_code} %{time_total}" \
        "$url" 2>/dev/null || echo "000 0")

    local http_code
    local response_time
    http_code=$(echo "$result" | awk '{print $1}')
    response_time=$(echo "$result" | awk '{print $2}')

    if [[ "$http_code" == "200" ]]; then
        echo -e "${GREEN}✅ OK${NC}     [HTTP $http_code] [${response_time}s]  $url"
        log "OK"     "HTTP $http_code | ${response_time}s | $url"
    elif [[ "$http_code" == "000" ]]; then
        echo -e "${RED}❌ TIMEOUT${NC} [HTTP $http_code] [>${TIMEOUT}s]      $url"
        log "ERROR"  "TIMEOUT | $url"
        FAILED=$((FAILED + 1))
    else
        echo -e "${YELLOW}⚠️  WARN${NC}   [HTTP $http_code] [${response_time}s]  $url"
        log "WARN"   "HTTP $http_code | ${response_time}s | $url"
        FAILED=$((FAILED + 1))
    fi
}

# ── Główna logika ─────────────────────────────────────────────────────────────

main() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║        CloudPulse Health Check           ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
    echo ""
    echo "  Czas:     $(timestamp)"
    echo "  Log:      $LOG_FILE"
    echo "  Timeout:  ${TIMEOUT}s"
    echo ""

    log "INFO" "=== Rozpoczynam health check (${#ENDPOINTS[@]} endpointów) ==="

    for endpoint in "${ENDPOINTS[@]}"; do
        check_endpoint "$endpoint"
    done

    echo ""
    echo "────────────────────────────────────────────"

    if [[ "$FAILED" -eq 0 ]]; then
        echo -e "${GREEN}✅ Wszystkie endpointy działają poprawnie!${NC}"
        log "INFO" "=== Health check zakończony — SUKCES (0 błędów) ==="
        exit 0
    else
        echo -e "${RED}❌ Wykryto $FAILED problem(y)! Sprawdź logi: $LOG_FILE${NC}"
        log "ERROR" "=== Health check zakończony — BŁĄD ($FAILED problemów) ==="
        exit 1
    fi
}

main
