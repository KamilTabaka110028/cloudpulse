# ☁️ CloudPulse — Health Check Monitor

Prosty system monitorowania dostępności usług HTTP.

## 🚀 Uruchomienie

```bash
chmod +x health_check.sh
./health_check.sh
```

## 📋 Co sprawdza?

| Endpoint | Oczekiwany status |
|----------|------------------|
| httpbin.org/status/200 | 200 OK |
| google.com | 200 OK (po redirect) |
| onet.pl | 200 OK (po redirect) |
| httpbin.org/status/503 | 503 (celowy test błędu) |

## 🛠️ Technologie

- Bash
- curl
- cron (automatyzacja)

## 📦 Struktura

```
cloudpulse/
├── health_check.sh     # Główny skrypt monitorujący
├── checker.sh          # Prosty checker jednego URL
└── .gitignore          # Chroni sekrety i logi
```
