# We use a multistage build to reduce the final image size,
# even if it's still fairly heavy. Doing so reduces the total
# images size by about ~4.2x (from ~2GB -> 470 MB).
#
# Note: Distroless gets us another 50 MB of savings (~10%),
#       but is a lot more annoying to use as a builder base.
FROM ubuntu:latest as builder
ARG PROTOBUF_VERSION=21.6
ARG PROTOC_GEN_C_VERSION=1.4.1

ENV PROTOBUF_VERSION ${PROTOBUF_VERSION}
ENV PROTOC_GEN_C_VERSION ${PROTOC_GEN_C_VERSION}

# Build libraries
RUN apt-get update
RUN apt-get install -y build-essential autoconf libtool pkg-config wget

# Proto libraries
RUN wget https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protobuf-all-${PROTOBUF_VERSION}.tar.gz
RUN tar -xzf protobuf-all-${PROTOBUF_VERSION}.tar.gz
RUN wget https://github.com/protobuf-c/protobuf-c/releases/download/v${PROTOC_GEN_C_VERSION}/protobuf-c-${PROTOC_GEN_C_VERSION}.tar.gz
RUN tar -xzf protobuf-c-${PROTOC_GEN_C_VERSION}.tar.gz

# Build protoc base
WORKDIR /protobuf-${PROTOBUF_VERSION}/
RUN ./autogen.sh
RUN ./configure
RUN make -j$(nproc) install
RUN ldconfig

# Build protoc-gen
WORKDIR /protobuf-c-${PROTOC_GEN_C_VERSION}/
RUN ./configure
RUN make -j$(nproc) install
RUN ldconfig

FROM ubuntu:latest
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib /usr/local/lib
