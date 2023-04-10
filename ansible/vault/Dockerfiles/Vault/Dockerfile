FROM vault:1.13.1

RUN apk add --no-cache \
    bash \
    ca-certificates 

RUN mkdir -p /vault/data/ && \
    mkdir -p /vault/config/ && \
    mkdir -p /vault/policies/ && \
    chown vault:vault -R /vault/

COPY ./data/config/*.hcl /vault/config/
COPY ./data/policies/*.hcl /vault/policies/

ENTRYPOINT [ "vault" ]
