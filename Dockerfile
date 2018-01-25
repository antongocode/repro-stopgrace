FROM alpine:3.6

COPY gracetest /

RUN chmod +x /gracetest

ENTRYPOINT ["/gracetest"]