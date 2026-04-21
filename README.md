# SpaceBorscht - Симулятор Запуска Ракеты

SpaceBorscht - учебное приложение для изучения observability (наблюдаемости) с использованием Prometheus, Grafana, Loki и Tempo. Симулирует запуск ракетной миссии с генерацией большого количества метрик, логов и трейсов.

Команды развертывания:
#Grafana
helm upgrade --install grafana grafana-community/grafana \
  --version 11.3.2 \
  --values=values-grafana.yaml\
  --values=dashboard-lesson.yml\
  --values=dashboard-loki.yml\
  --values=dashboard-service.yml\
  --values=dashboard-tempo.yml

#opentelemetry-collector
helm upgrade --install otel-collector open-telemetry/opentelemetry-collector \
  --version 0.133.0 \
  --values=values-otel_all.yaml
