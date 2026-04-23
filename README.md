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

Loki (логи --> трейсы):
Connections → Data sources → Add data source → Loki.
Name: Loki
URL: http://loki.ns-loki.svc.cluster.local:3100
Спускаемся до Derived fields → Add. # когда открываешь строку лога попробуй из неё выцепить что-то полезное, в час
# https://grafana.com/docs/grafana/next/datasources/loki/configure-loki-data-source/#derived-fields
Name: TraceID
Type: Regex in log line # Ищем прямо в тексте, т.е. это не json и не label. лог записан в JSON-формате, но хранитс
Regex: "trace_id"\s*:\s*"([^"]+)" # Шаблон для поиска, ищет в строке кусок вида trace_id=0ef9ff7908db2fbd0df5254adc737fce и
Internal link: выбираем Tempo. # то что ты нашел используй как ссылку в другой datasource
Query: ${__value.raw} # отправь то, что вытащий regexp


Tempo (трейсы --> логи):
Trace to logs:
- Data source: Loki
- Tags:
- Tag name: service.name
- New name: service_name
- Filter by trace ID: включить
Additional settings: Enable node graph
