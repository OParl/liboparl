/********************************************************************
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
*********************************************************************/

using OParl;

namespace OParlTest {
    public class ObjectTest {
        private static GLib.HashTable<string,string> test_input;

        private static void init() {
            ObjectTest.test_input = new GLib.HashTable<string,string>(GLib.str_hash, GLib.str_equal);

            ObjectTest.test_input.insert("https://oparl.example.org/", Fixtures.object_sane);
            ObjectTest.test_input.insert("https://oparl.example.org/va", Fixtures.object_sane_vendor_attrs);
        }

        public static void add_tests () {
            ObjectTest.init();

            Test.add_func ("/oparl/object/sane_input", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return ObjectTest.test_input.get(url);
                });
                System s;
                try {
                    s = client.open("https://oparl.example.org/");
                } catch (ParsingError e) {
                    GLib.assert_not_reached();
                }
                assert (s.id == "https://oparl.example.org/");
                assert (s.name == "Testsystem und so");
                assert (s.short_name == "Testsystem");
                assert (s.license == "CC-BY-SA");
                assert (s.web == "https://foobar.invalid");
                assert (!s.deleted);
                assert (s.keyword[0] == "some" && s.keyword[1] == "neat" && s.keyword[2] == "object");
                assert (s.created.to_string() == "2016-01-01T13:12:22+0000");
                assert (s.modified.to_string() == "2016-05-23T21:18:29+0000");
            });

            Test.add_func ("/oparl/object/wrong_id_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return ObjectTest.test_input.get(url).replace(
                        "\"https://oparl.example.org/\"", "1"
                    );
                });
                try {
                    client.open("https://oparl.example.org/");
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'id'"));
                }
            });

            Test.add_func ("/oparl/object/wrong_name_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return ObjectTest.test_input.get(url).replace(
                        "\"Testsystem und so\"", "1"
                    );
                });
                try {
                    client.open("https://oparl.example.org/");
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'name'"));
                }
            });

            Test.add_func ("/oparl/object/wrong_short_name_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return ObjectTest.test_input.get(url).replace(
                        "\"Testsystem\"", "1"
                    );
                });
                try {
                    client.open("https://oparl.example.org/");
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'shortName'"));
                }
            });

            Test.add_func ("/oparl/object/wrong_license_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return ObjectTest.test_input.get(url).replace(
                        "\"CC-BY-SA\"", "1"
                    );
                });
                try {
                    client.open("https://oparl.example.org/");
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'license'"));
                }
            });

            Test.add_func ("/oparl/object/wrong_created_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return ObjectTest.test_input.get(url).replace(
                        "\"2016-01-01T13:12:22+00:00\"", "1"
                    );
                });
                try {
                    client.open("https://oparl.example.org/");
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'created'"));
                }
            });

            Test.add_func ("/oparl/object/wrong_modified_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return ObjectTest.test_input.get(url).replace(
                        "\"2016-05-23T21:18:29+00:00\"", "1"
                    );
                });
                try {
                    client.open("https://oparl.example.org/");
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'modified'"));
                }
            });

            Test.add_func ("/oparl/object/wrong_keyword_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return ObjectTest.test_input.get(url).replace(
                        "[\"some\",\"neat\",\"object\"]", "1"
                    );
                });
                try {
                    client.open("https://oparl.example.org/");
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'keyword'"));
                }
            });

            Test.add_func ("/oparl/object/wrong_web_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return ObjectTest.test_input.get(url).replace(
                        "\"https://foobar.invalid\"", "1"
                    );
                });
                try {
                    client.open("https://oparl.example.org/");
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'web'"));
                }
            });

            Test.add_func ("/oparl/object/wrong_deleted_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return ObjectTest.test_input.get(url).replace(
                        "false", "1"
                    );
                });
                try {
                    client.open("https://oparl.example.org/");
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'deleted'"));
                }
            });

            Test.add_func ("/oparl/object/vendor_attributes", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return ObjectTest.test_input.get(url);
                });
                System s;
                try {
                    s = client.open("https://oparl.example.org/va");
                } catch (ParsingError e) {
                    GLib.assert_not_reached();
                }
                assert (s.vendor_attributes.get("ris:state") == "old");
                assert (s.vendor_attributes.get("ris:vendor") == "somerisvendor");
            });

            Test.add_func ("/oparl/object/refresh", () => {
                var client = new Client();
                ulong handle = client.resolve_url.connect((url)=>{
                    return ObjectTest.test_input.get(url);
                });
                System s;
                try {
                    s = client.open("https://oparl.example.org/va");
                } catch (ParsingError e) {
                    GLib.assert_not_reached();
                }
                assert (s.name == "Testsystem und so");
                client.disconnect(handle);
                client.resolve_url.connect((url)=>{
                    return ObjectTest.test_input.get(url).replace(
                        "Testsystem und so", "Systemtest"
                    );
                });
                try {
                    s.refresh();
                } catch (ParsingError e) {
                    GLib.assert_not_reached();
                }
                assert (s.name == "Systemtest");
            });
        }
    }
}
