# Alpine, because why not??
FROM alpine:3.14

# Install wget and cleanup
RUN apk add --no-cache wget && \
    rm -rf /var/cache/apk/*

# Eat copypasta...
COPY cmd/prometheus                         /bin/prometheus \
     cmd/promtool                           /bin/promtool \
     a11y/prometheus.yml                    /etc/prometheus/prometheus.yml \
     console_libraries                      /usr/share/prometheus/console_libraries/ \
     consoles                               /usr/share/prometheus/consoles/

# Set where the work is...
WORKDIR /prometheus

# Lets go running...
RUN ln -s /usr/share/prometheus/console_libraries /usr/share/prometheus/consoles/ /etc/prometheus/ && \
    chown -R nobody:nobody /etc/prometheus /prometheus

ENV APP_PORT 9090

HEALTHCHECK --interval=30s --timeout=10s \
    CMD wget -qO- http://localhost:9090/-/ready || exit 1

LABEL org="CivicActions" \
      title="A11ytheus" \
      description="An A11y flavor of Prometheus to monitor GovA11y" \
      version="1.0" \
      maintainer="Bentley Hensel <bentley.hensel@civicactions.com>"

USER       nobody
EXPOSE $APP_PORT
VOLUME     [ "/prometheus" ]
ENTRYPOINT [ "/bin/prometheus" ]

CMD        [ "--config.file=/etc/prometheus/prometheus.yml", \
             "--storage.tsdb.path=/prometheus", \
             "--web.console.libraries=/usr/share/prometheus/console_libraries", \
             "--web.console.templates=/usr/share/prometheus/consoles" ]
