# ---- Build Stage ----
FROM elixir:1.10-alpine as builder
ENV MIX_ENV=prod

RUN apk add --update nodejs nodejs-npm

RUN mix local.rebar --force && mix local.hex --force

COPY mix.exs .
COPY mix.lock .

RUN mix deps.get && mix deps.compile

COPY lib lib
COPY config config

COPY assets/ assets
RUN cd assets && npm install && npm run deploy
RUN mix phx.digest

RUN mix release


# ---- Application Stage ----
FROM alpine:3
RUN apk add --no-cache --update bash openssl
WORKDIR /app
COPY --from=builder _build/prod/rel/ast_ninja/ .
EXPOSE 4000
CMD ["/app/bin/ast_ninja", "start"]
