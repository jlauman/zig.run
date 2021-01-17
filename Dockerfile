FROM alpine:latest

WORKDIR /usr/local

RUN apk update --no-cache &&\
    apk add xz &&\
    wget https://ziglang.org/download/0.7.1/zig-linux-x86_64-0.7.1.tar.xz &&\
    xz -dc zig-linux-x86_64-0.7.1.tar.xz | tar -x &&\
    rm zig-linux-x86_64-0.7.1.tar.xz &&\
    mv zig-linux-x86_64-0.7.1 zig    

RUN apk update --no-cache &&\
    apk add iproute2 lighttpd &&\
    adduser -D -h /home/web -s /bin/sh web &&\
    mkdir /home/web/tmp; chown -R web.web /home/web

ENV PATH="/usr/local/zig:$PATH"

# RUN echo 'export PATH="/usr/local/zig:$PATH"' > /etc/profile.d/zig.sh &&\
#     adduser -D -h /home/web -s /bin/sh web
    # chown -R web.wheel /var/log/lighttpd

# RUN echo 'export PATH="/usr/local/zig:$PATH"' > /etc/profile.d/zig.sh &&\
#     adduser -D -u 1000 -h /home/web -s /bin/sh web &&\
#     chown -R web.wheel /var/log/lighttpd

# COPY --from=zig --chown=0:0 /usr/local/zig /usr/local/zig
COPY --chown=web:web ./web/bin /home/web/bin
COPY --chown=web:web ./web/doc /home/web/doc
COPY --chown=root:root ./app /app
RUN chmod 440 /app/init.sh /app/*.conf
# RUN chmod 440 /app/init.sh /app/*.conf &&\
#     chown -R 0:0 /home/web/bin /home/web/doc

# USER web
# WORKDIR /home/web
# CMD [ "sh" ]

CMD [ "/bin/sh", "/app/init.sh" ]
