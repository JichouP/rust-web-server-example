FROM lukemathwalker/cargo-chef:latest AS chef
WORKDIR /app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder 
COPY --from=planner /app/recipe.json recipe.json
# Build dependencies - this is the caching Docker layer!
RUN cargo chef cook --release --recipe-path recipe.json
# Build application
COPY . .
RUN cargo build --release

# We do not need the Rust toolchain to run the binary!
FROM gcr.io/distroless/cc
WORKDIR /app
COPY --from=builder /app/target/release/rust-web-server-example /usr/local/bin/rust-web-server-example
ENTRYPOINT ["/usr/local/bin/rust-web-server-example"]
EXPOSE 8000
