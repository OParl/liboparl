#!/bin/sh

chmod 644 /usr/local/include/oparl-0.2.h
chmod 755 /usr/local/lib/x86_64-linux-gnu/liboparl-0.2.so
chmod 644 /usr/local/lib/girepository-1.0/OParl-0.2.typelib
# TODO remove: workaround unitl pkconfig install_dir is available
# via release.
mv /usr/local/lib/x86_64-linux-gnu/pkgconfig/oparl-0.2.pc /usr/local/lib/pkgconfig/
chmod 644 /usr/local/lib/pkgconfig/oparl-0.2.pc
chmod -R 644 /usr/local/share/devhelp/books/oparl-0.2
