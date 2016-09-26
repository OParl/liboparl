#!/bin/sh

chmod 644 ${MESON_INSTALL_PREFIX}/include/oparl-0.2.h
chmod 755 ${MESON_INSTALL_PREFIX}/lib/x86_64-linux-gnu/liboparl-0.2.so
chmod 644 ${MESON_INSTALL_PREFIX}/lib/girepository-1.0/OParl-0.2.typelib
# TODO remove: workaround unitl pkconfig install_dir is available
# via release.
mv ${MESON_INSTALL_PREFIX}/lib/x86_64-linux-gnu/pkgconfig/oparl-0.2.pc /usr/local/lib/pkgconfig/
chmod 644 ${MESON_INSTALL_PREFIX}/lib/pkgconfig/oparl-0.2.pc

chmod 644 ${MESON_INSTALL_PREFIX}/share/vala/vapi/oparl-0.2.deps
chmod 644 ${MESON_INSTALL_PREFIX}/share/vala/vapi/oparl-0.2.vapi

chmod -R 644 ${MESON_INSTALL_PREFIX}/share/devhelp/books/oparl-0.2
chmod 755 ${MESON_INSTALL_PREFIX}/share/devhelp/books/oparl-0.2
chmod 755 ${MESON_INSTALL_PREFIX}/share/devhelp/books/oparl-0.2/img
