FROM ruby:3.0-alpine

RUN apk add --no-cache build-base sqlite-libs sqlite-dev git && \
    gem install specific_install && \
    gem specific_install -l https://github.com/fattymiller/viotel-mailcatcher.git && \
    apk del --rdepends --purge build-base sqlite-dev

EXPOSE 1080
EXPOSE 25

ENTRYPOINT ["mailcatcher", "--foreground"]
CMD ["--ip", "0.0.0.0", "--smtp-port", "25"]
