FROM ruby:alpine

WORKDIR /usr/src/webrick_time

COPY . .

CMD ["ruby","server.rb"]
