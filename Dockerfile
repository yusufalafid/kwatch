FROM golang:alpine AS builder
ARG RELEASE_VERSION="v0.8.5"
LABEL maintainer="BKK <bkk@gmail.com>"

RUN apk update && \
    apk add git build-base && \
    rm -rf /var/cache/apk/* && \
    mkdir -p "/build"

WORKDIR /build
COPY go.mod go.sum /build/
RUN go mod download

COPY . /build/
RUN sed -i 's/dev/'"${RELEASE_VERSION}"'/g' version/version.go
RUN go mod tidy
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o kwatch .

FROM alpine:latest
RUN apk add --update ca-certificates
COPY --from=builder /build/kwatch /bin/kwatch
ENTRYPOINT ["/bin/kwatch"]