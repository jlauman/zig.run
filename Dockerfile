FROM docker.io/alpine:latest

WORKDIR /usr/local

RUN apk add --no-cache iproute2 procps xz lighttpd &&\
    wget https://ziglang.org/download/0.7.1/zig-linux-x86_64-0.7.1.tar.xz &&\
    xz -dc zig-linux-x86_64-0.7.1.tar.xz | tar -x &&\
    rm zig-linux-x86_64-0.7.1.tar.xz &&\
    mv zig-linux-x86_64-0.7.1 zig    

RUN adduser -D -h /home/web -s /bin/sh web &&\
    mkdir /home/web/tmp &&\
    chown -R web.web /home/web &&\
    adduser zig -D -h /home/web

ENV PATH="/usr/local/zig:$PATH"

COPY --chown=web:web ./web/bin /home/web/bin
COPY --chown=web:web ./web/doc /home/web/doc
COPY --chown=web:web ./web/src /home/web/src
COPY --chown=root:root ./app /app

RUN chmod 440 /app/*.conf &&\
    chmod 755 /app/init.sh &&\
    chown web /var/log/lighttpd &&\
    chmod g-s /home/web &&\
    chmod -R o-rwx /home/web/bin /home/web/tmp &&\
    chmod -R go-rwx /home/web/doc /home/web/src &&\
    chown -R zig.web /home/web/tmp &&\
    chmod 330 /home/web/tmp &&\
    mkdir /home/web/.cache &&\
    chown zig.zig /home/web/.cache &&\
    chown zig.zig /home/web/bin/play.cgi &&\
    chmod ug+s /home/web/bin/play.cgi &&\
    chmod o+rx /home/web/bin/play.cgi

WORKDIR /home/web
# USER web
# CMD [ "sh" ]

CMD [ "/bin/sh", "/app/init.sh" ]
