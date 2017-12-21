FROM vault

WORKDIR /vault
ADD tls tls/

RUN apk update && apk add ca-certificates
RUN cp tls/ca.cert /usr/local/share/ca-certificates
RUN update-ca-certificates

ENV SKIP_SETCAP true
