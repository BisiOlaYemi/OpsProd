# syntax=docker/dockerfile:1.7

FROM nginxinc/nginx-unprivileged:1.27-alpine AS runtime

USER 101

COPY --chown=101:101 nginx.conf /etc/nginx/nginx.conf
COPY --chown=101:101 default.conf /etc/nginx/conf.d/default.conf
COPY --chown=101:101 html/ /usr/share/nginx/html/

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/healthz || exit 1
