FROM golang:1.13.0 as build

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download all dependencies
RUN go mod download

# Copy the source from the current directory to the Working Directory inside the container
COPY main.go .
COPY Makefile .

# Build the Go app
RUN make linux

######## Start a new stage from scratch #######
FROM alpine:latest as runtime

RUN apk add --update \
    python \
    curl \
    which \
    bash

WORKDIR /app/workdir

COPY ./templates /app/workdir/templates/

ENV PATH="${PATH}:/app/bin"

# Copy the Pre-built binary file from the previous stage
COPY --from=build /app/bin/demo-linux-amd64 /app/bin/demo

EXPOSE 80

ENTRYPOINT ["/app/bin/demo"]
