FROM ruby:3.1.1-alpine

RUN \
apk update \
&& apk upgrade \
&& apk --no-cache add ruby ruby-dev ruby-bundler ruby-json ruby-irb ruby-rake ruby-bigdecimal postgresql-dev \
&& apk --no-cache add bash git openssh \
&& apk --no-cache add make g++ \
&& rm -rf /var/cache/apk/*

WORKDIR /codepraise-api

COPY / .

RUN bundle install --without=test development

CMD rake worker:run:production & bundle exec puma -t 5:5 -p ${PORT:-3000}