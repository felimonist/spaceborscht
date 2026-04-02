#!/bin/bash

# Функция для логирования с отметкой времени
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Ассоциативный массив для хранения PID процессов
declare -A PID_MAP

log "Запуск всех port-forward соединений..."

# 1. Loki Gateway
log "Настройка port-forward для Loki Gateway (namespace: loki)"
kubectl port-forward --namespace loki svc/loki-gateway 3100:80 > loki-gateway.log 2>&1 &
PID_MAP["loki:loki-gateway"]=$!

# Проверяем, что процесс запустился
if kill -0 "${PID_MAP[loki:loki-gateway]}" 2>/dev/null; then
    log "Port-forward для Loki Gateway запущен успешно (PID: ${PID_MAP[loki:loki-gateway]})"
else
    log "Ошибка: не удалось запустить port-forward для Loki Gateway"
fi

# 2. OpenTelemetry Collector
log "Настройка port-forward для OpenTelemetry Collector (namespace: opentelemetry)"
POD_NAME=$(kubectl get pods -n opentelemetry -l app.kubernetes.io/name=opentelemetry-collector -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -z "$POD_NAME" ]; then
    log "Ошибка: не удалось найти под с меткой 'app.kubernetes.io/name=opentelemetry-collector' в namespace 'opentelemetry'"
else
    kubectl port-forward --namespace opentelemetry "$POD_NAME" 13133:13133 > opentelemetry-collector.log 2>&1 &
    PID_MAP["opentelemetry:opentelemetry-collector"]=$!

    if kill -0 "${PID_MAP[opentelemetry:opentelemetry-collector]}" 2>/dev/null; then
        log "Port-forward для OpenTelemetry Collector запущен успешно (PID: ${PID_MAP[opentelemetry:opentelemetry-collector]})"
    else
        log "Ошибка: не удалось запустить port-forward для OpenTelemetry Collector"
    fi
fi

# 3. Prometheus
log "Настройка port-forward для Prometheus (namespace: prometheus)"
kubectl -n prometheus port-forward svc/kube-prometheus-stack-prometheus 9090:9090 > prometheus.log 2>&1 &
PID_MAP["prometheus:prometheus"]=$!

if kill -0 "${PID_MAP[prometheus:prometheus]}" 2>/dev/null; then
    log "Port-forward для Prometheus запущен успешно (PID: ${PID_MAP[prometheus:prometheus]})"
else
    log "Ошибка: не удалось запустить port-forward для Prometheus"
fi

# 4. Tempo
log "Настройка port-forward для Tempo (namespace: tempo)"
kubectl port-forward svc/tempo-query-frontend 3200:3200 -n tempo > tempo.log 2>&1 &
PID_MAP["tempo:tempo"]=$!

if kill -0 "${PID_MAP[tempo:tempo]}" 2>/dev/null; then
    log "Port-forward для Tempo запущен успешно (PID: ${PID_MAP[tempo:tempo]})"
else
    log "Ошибка: не удалось запустить port-forward для Tempo"
fi

# 5. Grafana
log "Настройка port-forward для Grafana (namespace: grafana)"
kubectl -n grafana port-forward svc/grafana 3000:80 > grafana.log 2>&1 &
PID_MAP["grafana:grafana"]=$!

if kill -0 "${PID_MAP[grafana:grafana]}" 2>/dev/null; then
    log "Port-forward для Grafana запущен успешно (PID: ${PID_MAP[grafana:grafana]})"
else
    log "Ошибка: не удалось запустить port-forward для Grafana"
fi

# 6. Spaceborscht Frontend
log "Настройка port-forward для Spaceborscht Frontend (namespace: spaceborscht)"
kubectl -n spaceborscht port-forward svc/frontend-service 8080:80 > spaceborscht-frontend.log 2>&1 &
PID_MAP["spaceborscht:frontend"]=$!

if kill -0 "${PID_MAP[spaceborscht:frontend]}" 2>/dev/null; then
    log "Port-forward для Spaceborscht Frontend запущен успешно (PID: ${PID_MAP[spaceborscht:frontend]})"
else
    log "Ошибка: не удалось запустить port-forward для Spaceborscht Frontend"
fi

# Выводим сводку всех запущенных процессов
echo ""
log "Сводка запущенных port-forward процессов:"
for key in "${!PID_MAP[@]}"; do
    IFS=':' read -r namespace resource <<< "$key"
    echo "  - $resource (namespace: $namespace) — PID: ${PID_MAP[$key]}"
done

echo ""
log "Все доступные endpoints:"
echo "  Loki: http://localhost:3100"
echo "  OpenTelemetry Collector: http://localhost:13133"
echo "  Prometheus: http://localhost:9090"
echo "  Tempo: http://localhost:3200"
echo "  Grafana: http://localhost:3000"
echo "  Frontend Service: http://localhost:8080"
