ARG BASE_IMAGE=amd64/ruby
ARG BASE_TAG=3.4.1

FROM node:23.6.1-bookworm-slim AS node

FROM ${BASE_IMAGE}:${BASE_TAG} AS runtime

# Install runtime dependencies once, shared by the builder and all process images.
RUN install -d /etc/apt/keyrings \
  && curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub \
    | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg \
  && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
    > /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -yqq \
  && apt-get install -yqq --no-install-recommends \
    google-chrome-stable libreoffice \
    postgresql-client shared-mime-info tzdata \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app
# Retain the build argument used by heroku.yml for review-app builds.
ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV} \
    NODE_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

FROM runtime AS builder

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /opt/yarn-v1.22.22 /opt/yarn-v1.22.22
RUN ln -s /opt/yarn-v1.22.22/bin/yarn /usr/local/bin/yarn

# Changes to JavaScript dependencies must not invalidate the Ruby gem layer.
COPY Gemfile Gemfile.lock ./
RUN gem install bundler:4.0.16 --no-document \
  && bundle config --local frozen 1 \
  && bundle config --local without "development test" \
  && bundle install -j4 \
  && rm -rf /usr/local/bundle/cache/*.gem \
  && find /usr/local/bundle/gems/ -name "*.c" -delete \
  && find /usr/local/bundle/gems/ -name "*.o" -delete

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

COPY . .
RUN SECRET_KEY_BASE=dummy bundle exec rails assets:precompile \
  && rm -rf node_modules tmp/cache \
  && mkdir -p tmp/pids log storage \
  && chmod -R 0777 tmp log storage

FROM runtime AS application
COPY --from=builder /usr/src/app /usr/src/app
COPY --from=builder /usr/local/bundle /usr/local/bundle
EXPOSE 3000

FROM application AS worker
CMD ["bundle", "exec", "sidekiq", "-c", "3"]

FROM application AS release
CMD ["sh", "-c", "bundle exec rails db:migrate && bundle exec rake after_party:run"]

FROM application AS final
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
