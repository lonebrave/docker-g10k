# Build webhook
FROM golang:1.24.2-alpine3.21 AS build-webhook
ENV WEBHOOK_VERSION=2.8.2
WORKDIR /go/src/github.com/adnanh/webhook
RUN apk add --update --no-cache -t build-deps curl gcc libc-dev libgcc
RUN curl -L --silent -o webhook.tar.gz https://github.com/adnanh/webhook/archive/${WEBHOOK_VERSION}.tar.gz && \
    tar -xzf webhook.tar.gz --strip 1
RUN go get -d -v
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /usr/local/bin/webhook

# Build g10k
FROM golang:1.24.2-alpine3.21 AS build-g10k
ENV G10K_VERSION=v0.9.10
WORKDIR /usr/src/g10k
RUN apk add --update --no-cache -t build-deps curl gcc make musl-dev git openssh bash
RUN curl -L --silent -o g10k.tar.gz https://github.com/xorpaul/g10k/archive/refs/tags/${G10K_VERSION}.tar.gz && \
    tar -xzf g10k.tar.gz --strip 1
RUN make g10k

# g10k image w/ webhook
FROM alpine:3.21.3
COPY --from=build-g10k /usr/src/g10k/g10k /usr/bin/
COPY --from=build-webhook /usr/local/bin/webhook /usr/local/bin/
COPY Dockerfile /Dockerfile
LABEL org.label-schema.maintainer="Nicholas Hasser <nick.hasser@gmail.com>" \
      org.label-schema.name="g10k" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.dockerfile="/Dockerfile"
RUN apk add --no-cache git openssh bash
RUN mkdir /code

# Puppet GID in the voxpupuli/puppetserver container is 999
# GID 999 in alpine is ping group
RUN adduser -u 999 -G ping -D puppet && \
    chown -R puppet:ping /code
USER puppet:ping
EXPOSE 9000
ENTRYPOINT [ "/usr/local/bin/webhook -hooks /var/webhook/hooks.json -verbose" ]
