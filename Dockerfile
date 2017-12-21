FROM ubuntu:17.10

# Set system locale to something sensible (en_US.UTF-8)

ARG locale='en_US.UTF-8'

ENV DEBIAN_FRONTEND noninteractive
RUN apt update && apt install -y --no-install-recommends locales && \
    rm -rf /var/lib/apt/lists/* && \
    echo "${locale} UTF-8" > /etc/locale.gen && \
    locale-gen ${locale} && \
    dpkg-reconfigure locales && \
    /usr/sbin/update-locale LANG=${locale}
ENV LC_ALL ${locale}

# Install build deps and build liboparl

RUN apt update && \
    apt install -y --no-install-recommends \
    valac \
    valadoc \
    gobject-introspection \
    libjson-glib-dev \
    libgirepository1.0-dev \
    meson \
    gettext \
    git && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /opt/liboparl
ADD . /opt/liboparl

WORKDIR /opt/liboparl
RUN mkdir build && \
    cd build && \
    meson --buildtype=release --prefix=/usr && \
    ninja && \
    ninja install

# Let's cleanup after ourselves

RUN rm -rf /usr/share/meson && \
    apt remove --purge -y \
    build-essential \
    valac \
    valadoc \
    libjson-glib-dev \
    libgirepository1.0-dev \
    meson \
    gettext \
    git && \
    apt autoremove -y && apt update && \
    apt install -y --no-install-recommends gir1.2-json-1.0 && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /opt/liboparl && \
    apt clean