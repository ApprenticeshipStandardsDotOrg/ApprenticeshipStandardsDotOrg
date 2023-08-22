ARG BASE_IMAGE=ruby
ARG BASE_TAG=3.2.2
ARG BASE_IMAGE=${BASE_IMAGE}:${BASE_TAG}

FROM ${BASE_IMAGE} AS builder

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  git \
  nodejs \
  shared-mime-info \
  tzdata \
  vim \
  yarn \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

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

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  nodejs \
  postgresql-client \
  tzdata \
  vim \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR $RAILS_ROOT

COPY --from=builder $RAILS_ROOT $RAILS_ROOT
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

EXPOSE 3000
