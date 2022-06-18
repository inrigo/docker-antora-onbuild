FROM antora/antora:3.0.1

RUN apk update
RUN apk add lighttpd
RUN apk add openjdk8-jre
RUN apk add graphviz

RUN yarn global add @antora/lunr-extension
RUN yarn global add asciidoctor-kroki

ARG KROKI_VERSION=0.17.2
RUN curl -LJ https://github.com/yuzutech/kroki/releases/download/v${KROKI_VERSION}/kroki-server-v${KROKI_VERSION}.jar -o /usr/local/lib/kroki-server.jar

ONBUILD COPY . /antora/
ONBUILD RUN generate.sh

WORKDIR /antora
COPY script/generate.sh /usr/local/bin/
COPY script/docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
