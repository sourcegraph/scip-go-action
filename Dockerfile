FROM cgr.dev/chainguard/wolfi-base@sha256:0c79f2ee04e77203c3bc487ef237faac05e99ffbc05d67a1c53e86ba58100f37

RUN apk add --no-cache curl
RUN curl -L https://sourcegraph.com/.api/src-cli/src_linux_amd64 -o /usr/local/bin/src
RUN chmod +x /usr/local/bin/src

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
