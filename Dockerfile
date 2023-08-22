ARG BASE_IMAGE=amd64/ruby
ARG BASE_TAG=3.2.2
ARG BASE_IMAGE=${BASE_IMAGE}:${BASE_TAG}

FROM ${BASE_IMAGE} AS builder

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
#RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
#RUN apt-get install -y ./google-chrome-stable_current_amd64.deb

#RUN apt-get install -yqq wget 
#RUN wget http://archive.ubuntu.com/ubuntu/pool/main/libu/libu2f-host/libu2f-udev_1.1.4-1_all.deb
#RUN dpkg -i libu2f-udev_1.1.4-1_all.deb
#
#RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_arm64.deb
#RUN apt-get install ./google-chrome*.deb --yes

#RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
#RUN sh -c 'echo "deb [arch=$(dpkg --print-architecture)] https://dl-ssl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
#
#RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

#RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
#RUN apt-get install -y ./google-chrome-stable_current_amd64.deb

#RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \ 
#    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
#RUN apt-get update && apt-get -y install google-chrome-stable

#RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
#RUN dpkg -i google-chrome-stable_current_amd64.deb

# Mostly working
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
#RUN apt update
#RUN apt install google-chrome-stable -y

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  git \
  google-chrome-stable \
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

#RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
#RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'

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
COPY --from=builder /usr/bin/google-chrome /usr/bin/google-chrome
COPY --from=builder /usr/bin/google-chrome-stable /usr/bin/google-chrome-stable
COPY --from=builder /opt/google/chrome/ /opt/google/chrome/

EXPOSE 3000
