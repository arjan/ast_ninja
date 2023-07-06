# syntax=docker/dockerfile:experimental

# This experimental syntax needs to be enabled for --mount=type=cache to work
#
# It's a buildkit feature (see https://docs.docker.com/develop/develop-images/build_enhancements/)
#
# Buildkit basically creates a dependency tree which enables it to execute quite a few stages
# and other processes in parallel
#
# It will also skip stages completely if buildkit determines they aren't needed
#
# You might wonder why this is useful
#
# Let's say you add a test stage to your dockerfile which depends on your build stage
# By default the last stage in your Dockerfile is the build target (docker build --target <stage> .)
# Now if I run a docker build with --target test, it will ONLY execute the steps needed for that stage
# and others are skipped
#
# We need to be up-to-date with the master branch before we can merge so in CI we run the
# tests in jenkins only for the feature branches
# These tests are skipped in master yet we can still use the same multistage dockerfile,
# only the target is different
#
# Parts of the stage dependencies will still be the same like the deps stage in this file
# This means it will still use the docker cache created when running the test stage when you
# build the actual release
#
# I also recommend creating a .dockerignore file (especially for local use) to make sure
# the docker context stays as small as possible and you don't copy files into your stages
# that you don't need/want
#
# My current .dockerignore contents:
#
# .elixir_ls
# .git
# assets/node_modules
# deps
# _build

# Dependency stage
FROM docker.io/hexpm/elixir:1.14.5-erlang-26.0.1-debian-bullseye-20230522-slim AS deps

# In case you're behind a proxy
ARG http_proxy
ARG https_proxy=$http_proxy

WORKDIR /app

COPY config ./config
COPY mix.exs mix.lock ./

ENV MIX_ENV prod

# Use the hex and rebar cache directories as cache mounts
RUN --mount=type=cache,target=~/.hex/packages/hexpm,sharing=locked \
    --mount=type=cache,target=~/.cache/rebar3,sharing=locked \
      mix do \
      local.rebar --force,\
      local.hex --force,\
      deps.get --only prod


# Build Phoenix assets
# Using stretch for now because it includes Python
# Otherwise you get errors, could use a smaller image though
FROM node:13.13.0-stretch AS assets
WORKDIR /app/assets

COPY --from=deps /app/deps /app/deps/
COPY assets/package.json assets/package-lock.json ./
# Use the npm cache directory as a cache mount
RUN --mount=type=cache,target=~/.npm,sharing=locked \
      npm --prefer-offline --no-audit --progress=false \
      --loglevel=error ci

COPY assets/ ./

RUN npm run deploy


# Create Phoenix digest
FROM deps AS digest
COPY --from=assets /app/priv ./priv
RUN mix phx.digest


# Create release
#
# phx.digest also does a partial compile
# I tested doing the "mix do compile, phx.digest, release" in a single stage
# This made things quite a bit worse
# It meant it would do a complete recompile even if just a single line of code changed
# With the stages separated most of the compilation is cached
#
# On my machine (quadcore mobile i7 from a few years ago) it only takes around 5 seconds
# after I change a single line of code to build a new image because almost everything is cached
# Initial build time (including pulling all images which depends on your network speed) it takes
# around 1 minute and 20 seconds
FROM digest AS release
ENV MIX_ENV prod
COPY lib ./lib
RUN mix do compile, release


# Create the actual image that will be deployed
FROM alpine:3.11.3 as deploy

# openssl might not be needed if ssl is handled outside the application (ex. kubernetes ingress)
# It adds around 0.6Mb to the image size
# I'm thinking about creating multiple nodes and having them communicate between each other through ssl
# so I leave it for now
# If anyone knows when to include it or when not to, please share :)
RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
      apk add openssl ncurses-libs

# Don't run the app as root
USER nobody

# Set WORKDIR after setting user to nobody so it automatically gets the right permissions
# When the app starts it will need to be able to create a tmp directory in /app
WORKDIR /app

# Include chown to make sure the files have the correct permissions
# You might think you could do a "RUN chown -R nobody: /app" after the copy
# DON'T do this, it will add an extra layer which adds about 10Mb to the image
# Considering an image for a new phoenix app ends up around 20Mb that's a huge difference
COPY --from=release --chown=nobody: /app/_build/prod/rel/ast_ninja ./

# SECRET_KEY_BASE will be provided when running the application
ENV HOME=/app \
    SECRET_KEY_BASE=

EXPOSE 4000

# To test the image locally:
# docker build -t ast_ninja .
# docker run -p 4000:4000 --env SECRET_KEY_BASE="<your secret key base>" ast_ninja
ENTRYPOINT ["bin/ast_ninja"]
CMD ["start"]
