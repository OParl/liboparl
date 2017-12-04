FROM ubuntu:17.10
RUN apt-get update
RUN apt install -y valac valadoc gobject-introspection libjson-glib-dev libgirepository1.0-dev meson gettext git

RUN git clone https://github.com/oparl/liboparl
RUN mkdir liboparl/build
WORKDIR /liboparl/build
RUN meson ..
RUN ninja
RUN ninja install
RUN cp OParl-0.*.typelib /usr/lib/x86_64-linux-gnu/girepository-1.0/

WORKDIR /liboparl
