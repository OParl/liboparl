FROM ubuntu:17.10

# Set system locale to something sensible (en_US.UTF-8)

ARG locale='en_US.UTF-8'

ENV DEBIAN_FRONTEND noninteractive
RUN apt update && apt install -y locales
RUN echo "${locale} UTF-8" > /etc/locale.gen && \
    locale-gen ${locale} && \
    dpkg-reconfigure locales && \
    /usr/sbin/update-locale LANG=${locale}
ENV LC_ALL ${locale}

RUN apt update && \
    apt install -y valac valadoc gobject-introspection libjson-glib-dev libgirepository1.0-dev meson gettext git

RUN mkdir /opt/liboparl
ADD . /opt/liboparl

WORKDIR /opt/liboparl
RUN mkdir build && \
    cd build && \
    meson && \
    ninja && \
    ninja install

RUN apt-get remove valac valadoc libjson-glib-dev libgirepository1.0-dev meson
RUN rm -rf /opt/liboparl