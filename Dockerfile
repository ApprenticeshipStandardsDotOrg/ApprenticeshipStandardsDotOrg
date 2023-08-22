ARG BASE_IMAGE=ruby
ARG BASE_TAG=3.2.2-alpine
ARG BASE_IMAGE=${BASE_IMAGE}:${BASE_TAG}

FROM ${BASE_IMAGE} AS builder

RUN apk update && apk upgrade && apk add --update --no-cache \
  build-base \
  curl-dev \
  gcompat \
  git \
  nodejs \
  postgresql-dev \
  shared-mime-info \
  tzdata \
  vim \
  yarn && rm -rf /var/cache/apk/*

ARG RAILS_ROOT=/usr/src/app/
WORKDIR $RAILS_ROOT

ARG RAILS_ENV=production
ARG NODE_ENV=production

COPY Gemfile* package.json yarn.lock $RAILS_ROOT
RUN gem install bundler:2.3.25 \
  && bundle config --local frozen 1 \
  && bundle config --local without "development test" \
  && bundle install -j4 \
  && rm -rf /usr/local/bundle/cache/*.gem \
  && find /usr/local/bundle/gems/ -name "*.c" -delete \
  && find /usr/local/bundle/gems/ -name "*.o" -delete

RUN yarn install --frozen-lockfile

COPY . .

RUN SECRET_KEY_BASE=dummy bundle exec bin/rails assets:precompile

### BUILD STEP DONE ###

FROM ${BASE_IMAGE} AS final

ARG RAILS_ROOT=/usr/src/app/

ENV RAILS_ENV=production
ENV NODE_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true

RUN apk update && apk upgrade && apk add --update --no-cache \
  bash \
  build-base \
#  chromium \
#  chromium-chromedriver \
  nodejs \
  postgresql-client \
  tzdata \
  vim && rm -rf /var/cache/apk/*

WORKDIR $RAILS_ROOT

COPY --from=builder $RAILS_ROOT $RAILS_ROOT
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

EXPOSE 3000
