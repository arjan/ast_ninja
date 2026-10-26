# Build and run AST Ninja.
#
#   docker build -t ast_ninja .
#   docker run -p 4000:4000 -e SECRET_KEY_BASE=$(mix phx.gen.secret) -e PHX_HOST=localhost ast_ninja
#
# Builder and runner share the same Debian release, so the ERTS bundled in
# the release links against the same glibc / OpenSSL it was built with.

ARG ELIXIR_VERSION=1.19.0
ARG OTP_VERSION=28.1
ARG DEBIAN_VERSION=bookworm-20250929-slim

ARG BUILDER_IMAGE="docker.io/hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="docker.io/debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} AS builder

RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential git ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV MIX_ENV=prod

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# Compile-time config first, so dependency compilation is cached
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

RUN mix assets.setup

COPY priv priv
COPY lib lib
COPY src src
COPY assets assets

# Compiles the app (and its colocated hooks) before bundling assets
RUN mix compile
RUN mix assets.deploy

COPY config/runtime.exs config/
COPY rel rel
RUN mix release


FROM ${RUNNER_IMAGE}

RUN apt-get update \
  && apt-get install -y --no-install-recommends libstdc++6 openssl libncurses6 locales ca-certificates \
  && rm -rf /var/lib/apt/lists/* \
  && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    MIX_ENV=prod

WORKDIR /app
RUN chown nobody /app

COPY --from=builder --chown=nobody:root /app/_build/prod/rel/ast_ninja ./

# Don't run the app as root
USER nobody

EXPOSE 4000

CMD ["/app/bin/ast_ninja", "start"]
