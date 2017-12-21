FROM djenriquez/vault-ui

ADD tls /vault/tls/

RUN apk update && apk add ca-certificates
RUN cp /vault/tls/ca.cert /usr/local/share/ca-certificates
RUN update-ca-certificates
