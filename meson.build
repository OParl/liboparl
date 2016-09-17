#********************************************************************+
# Copyright 2016 Daniel 'grindhold' Brendle
#
# This file is part of liboparl.
#
# liboparl is free software: you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public License
# as published by the Free Software Foundation, either
# version 3 of the License, or (at your option) any later
# version.
#
# liboparl is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with liboparl.
# If not, see http://www.gnu.org/licenses/.
#*********************************************************************

project ('oparl', ['vala','c'])

pkgconfig = import('pkgconfig')

api = '0.2'

glib = dependency('glib-2.0')
gobject = dependency('gobject-2.0')
json_glib = dependency('json-glib-1.0')
gio = dependency('gio-2.0')

oparl_lib_source = [
    'src/oparl.vala',
    'src/body.vala',
    'src/person.vala',
    'src/membership.vala',
    'src/meeting.vala',
    'src/system.vala',
    'src/object.vala',
    'src/organization.vala',
    'src/agenda_item.vala',
    'src/paper.vala',
    'src/consultation.vala',
    'src/legislative_term.vala',
    'src/location.vala',
    'src/file.vala'
]

oparl_test_source = [
    'test/main.vala',
    'test/fixtures.vala',
    'test/object.vala',
    'test/system.vala',
    'test/body.vala',
    'test/legislative_term.vala',
    'test/location.vala',
    'test/organization.vala',
    'test/person.vala',
    'test/membership.vala'
]

oparl_lib = library('oparl-'+api, oparl_lib_source,
                    dependencies: [glib, gobject, json_glib, gio],
                    vala_args: ['--gir=../OParl-'+api+'.gir'],
                    install:true)

oparl_test = executable('oparl_test', oparl_test_source,
                    dependencies: [glib,gobject, json_glib, gio],
                    link_with: oparl_lib)

g_ir_compiler = find_program('g-ir-compiler')
custom_target('oparl-typelib',
               command: [g_ir_compiler, '--output', '@OUTPUT@', meson.current_build_dir() + '/OParl-'+api+'.gir', '--shared-library', get_option('prefix') + '/' + get_option('libdir') + '/liboparl-'+api+'.so'],
               output: 'OParl-'+api+'.typelib',
               depends: oparl_lib,
               install: true,
               install_dir: get_option('libdir') + '/../girepository-1.0')

test('testlib', oparl_test)

libs = oparl_lib    # the library/libraries users need to link against
h = ['..','pkgconfig'] # subdirectories of ${prefix}/${includedir} to add to header path
pkgconfig.generate(libraries : libs,
              subdirs : h,
              version : api,
              name : 'liboparl',
              filebase : meson.current_build_dir()+'/oparl-'+api,
              subdirs : h,
              requires : 'glib-2.0 gobject-2.0 gio-2.0 json-glib-1.0',
              description : 'A library to access OParl civic information endpoints.')

install_headers(meson.current_build_dir()+'/oparl-'+api+'.h')

meson.add_install_script('fix_permissions.sh')
