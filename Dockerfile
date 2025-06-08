FROM ruby:2.4.2-alpine3.6

ENV SETUPDIR=/setup
WORKDIR ${SETUPDIR}
ARG GEMFILE_DIR=.
COPY $GEMFILE_DIR/Gemfile* $GEMFILE_DIR/packages* ./

# Install build dependencies
RUN set -eux; \
    apk add --no-cache --virtual build-deps \
        build-base \
        zlib-dev \
        ;
RUN apk add --no-cache libstdc++

# Install Bundler
# RUN set -eux; gem install bundler
RUN set -eux; gem install bundler -v 1.17.3
# Install extra packages if needed
RUN set -eux; \
	if [ -e packages ]; then \
	    apk add --no-cache --virtual extra-pkgs $(cat packages); \
    fi

# Install gems from `Gemfile` via Bundler
# RUN set -eux; bundler install
RUN set -eux; /usr/local/bundle/bin/bundle install

# Remove build dependencies
RUN set -eux; apk del --no-cache build-deps

# Clean up
WORKDIR /srv/jekyll
RUN set -eux; \
    rm -rf \
        ${SETUPDIR} \
        /usr/gem/cache \
        /root/.bundle/cache \
    ;

EXPOSE 4000
ENTRYPOINT ["bundler", "exec", "jekyll", "serve"]
CMD ["--version"]
