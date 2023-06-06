FROM --platform=linux/amd64 ruby:3.2.0

RUN apt-get update && apt-get install -y --no-install-recommends \
    npm \
    build-essential \
    git \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN npm install -g yarn@latest

WORKDIR /opt/webapps/app

COPY Rakefile Gemfile Gemfile.lock ./

RUN gem install bundler && bundle install --jobs 20 --retry 5

COPY package.json yarn.lock ./

RUN yarn install --check-files && yarn sass-migrator division **/*.scss
