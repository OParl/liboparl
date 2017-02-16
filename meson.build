#********************************************************************+
# Copyright 2016-2017 Daniel 'grindhold' Brendle
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

project ('oparl', 'vala', 'c')

# build options
opt_build_valadoc = get_option('build_valadoc')
opt_build_test    = get_option('build_test')

pkgconfig = import('pkgconfig')

api = '0.2'
revision = api + '.1'

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
    'test/membership.vala',
    'test/meeting.vala',
    'test/agenda_item.vala',
    'test/paper.vala',
    'test/consultation.vala',
    'test/file.vala',
]

libtype = 'so'
if (host_machine.system() == 'darwin')
    libtype = 'dylib'
endif

oparl_lib = library('oparl-'+api, oparl_lib_source,
                    dependencies: [glib, gobject, gio, json_glib],
                    vala_args: ['--gir=../OParl-'+api+'.gir'],
                    install: true)

g_ir_compiler = find_program('g-ir-compiler')
custom_target('oparl-typelib',
               command: [
                    g_ir_compiler,
                    '--output', '@OUTPUT@', meson.current_build_dir() + '/OParl-'+api+'.gir',
                    '--shared-library', get_option('prefix') + '/' + get_option('libdir') + '/liboparl-'+api+'.'+libtype
               ],
               output: 'OParl-'+api+'.typelib',
               depends: oparl_lib,
               install: true,
               install_dir: get_option('libdir') + '/girepository-1.0')

if opt_build_test == true
  oparl_test = executable('oparl_test', oparl_test_source,
                     dependencies: [glib,gobject, json_glib, gio],
                     link_with: oparl_lib)

  test('testlib', oparl_test)
endif

if opt_build_valadoc == true
  valadoc = find_program('valadoc')
  custom_target('apidocs',
                 input: oparl_lib_source,
                 command: [valadoc, '-o', 'devhelp/oparl-0.2', '--doclet', 'devhelp', '@INPUT@',
                '--pkg','json-glib-1.0', '--force'],
                 output: 'devhelp',
  )
endif

oparl_dep = declare_dependency(
    link_with: oparl_lib,
    include_directories:  include_directories(meson.current_build_dir())
)

libs = oparl_lib    # the library/libraries users need to link against
h = ['..','pkgconfig'] # subdirectories of ${prefix}/${includedir} to add to header path
pkgconfig.generate(libraries : libs,
              subdirs : h,
              version : revision,
              name : 'liboparl',
              filebase : meson.current_build_dir()+'/oparl-' + api,
              subdirs : h,
              requires : 'glib-2.0 gobject-2.0 gio-2.0 json-glib-1.0',
              description : 'A library to access OParl civic information endpoints.',
              install: true)

run_command('touch', meson.current_build_dir()+'/oparl-'+api+'.h')
install_headers(meson.current_build_dir()+'/oparl-'+api+'.h')

if opt_build_valadoc == true
  install_subdir(meson.current_build_dir()+'/devhelp/oparl-'+api+'/oparl-'+api, install_dir: get_option('datadir')+'/devhelp/books')
endif

run_command('touch', meson.current_build_dir()+'/oparl-'+api+'.vapi')
install_data('oparl-'+api+'.deps', install_dir: get_option('datadir') + '/vala/vapi')
install_data(meson.current_build_dir()+'/oparl-'+api+'.vapi', install_dir: get_option('datadir') + '/vala/vapi')
