FROM ubuntu:17.10

ENV LANG C.UTF-8

RUN apt-get update && \
    apt install -y valac valadoc gobject-introspection libjson-glib-dev libgirepository1.0-dev meson gettext git

ADD . /liboparl

RUN mkdir liboparl/build && \
    cd /liboparl/build && \
    meson .. && \
    ninja && \
    ninja install && \
    cp OParl-0.*.typelib /usr/lib/x86_64-linux-gnu/girepository-1.0/
