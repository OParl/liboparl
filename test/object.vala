/********************************************************************
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
*********************************************************************/

using OParl;

namespace OParlTest {
    public class ObjectTest {
        private static GLib.HashTable<string,string> test_input;

        private static void init() {
            ObjectTest.test_input = new GLib.HashTable<string,string>(GLib.str_hash, GLib.str_equal);

            ObjectTest.test_input.insert("https://api.testoparl.invalid/oparl/v1/", Fixtures.object_sane);
        }

        public static void add_tests () {
            ObjectTest.init();

            Test.add_func ("/oparl/object/sane_input", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return ObjectTest.test_input.get(url);
                });
                System s = client.open("https://api.testoparl.invalid/oparl/v1/");
                assert (s.id == "https://api.testoparl.invalid/oparl/v1/");
                assert (s.name == "Testsystem und so");
                assert (s.short_name == "Testsystem");
                assert (s.license == "CC-BY-SA");
                assert (s.web == "https://foobar.invalid");
                assert (!s.deleted);
                assert (s.keyword[0] == "some" && s.keyword[1] == "neat" && s.keyword[2] == "object");
                assert (s.created.to_string() == "2016-01-01T13:12:22+0000");
                assert (s.modified.to_string() == "2016-05-23T21:18:29+0000");
            });

            //TODO: These are tests that check acceptance of wrong types
            //      Activate when type checking is completed
            /*
            Test.add_func ("/oparl/object/wrong_id_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return ObjectTest.test_input.get(url).replace(
                        "\"https://api.testoparl.invalid/oparl/v1/\"", "1"
                    );
                });
                try {
                    System s = client.open("https://api.testoparl.invalid/oparl/v1/");
                    GLib.assert_not_reached();
                } catch (ValidationError e) {}
            });

            Test.add_func ("/oparl/object/wrong_name_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return ObjectTest.test_input.get(url).replace(
                        "\"Testsystem und so\"", "1"
                    );
                });
                try {
                    System s = client.open("https://api.testoparl.invalid/oparl/v1/");
                    GLib.assert_not_reached();
                } catch (ValidationError e) {}
            });

            Test.add_func ("/oparl/object/wrong_short_name_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return ObjectTest.test_input.get(url).replace(
                        "\"Testsystem\"", "1"
                    );
                });
                try {
                    System s = client.open("https://api.testoparl.invalid/oparl/v1/");
                    GLib.assert_not_reached();
                } catch (ValidationError e) {}
            });

            Test.add_func ("/oparl/object/wrong_short_name_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return ObjectTest.test_input.get(url).replace(
                        "\"Testsystem\"", "1"
                    );
                });
                try {
                    System s = client.open("https://api.testoparl.invalid/oparl/v1/");
                    GLib.assert_not_reached();
                } catch (ValidationError e) {}
            });

            Test.add_func ("/oparl/object/wrong_license_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return ObjectTest.test_input.get(url).replace(
                        "\"CC-BY-SA\"", "1"
                    );
                });
                try {
                    System s = client.open("https://api.testoparl.invalid/oparl/v1/");
                    GLib.assert_not_reached();
                } catch (ValidationError e) {}
            });

            Test.add_func ("/oparl/object/wrong_created_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return ObjectTest.test_input.get(url).replace(
                        "\"2016-01-01T13:12:22+00:00\"", "1"
                    );
                });
                try {
                    System s = client.open("https://api.testoparl.invalid/oparl/v1/");
                    GLib.assert_not_reached();
                } catch (ValidationError e) {}
            });

            Test.add_func ("/oparl/object/wrong_modified_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return ObjectTest.test_input.get(url).replace(
                        "\"2016-05-23T21:18:29+00:00\"", "1"
                    );
                });
                try {
                    System s = client.open("https://api.testoparl.invalid/oparl/v1/");
                    GLib.assert_not_reached();
                } catch (ValidationError e) {}
            });
            */
            Test.add_func ("/oparl/object/wrong_keyword_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return ObjectTest.test_input.get(url).replace(
                        "[\"some\",\"neat\",\"object\"]", "1"
                    );
                });
                try {
                    System s = client.open("https://api.testoparl.invalid/oparl/v1/");
                    GLib.assert_not_reached();
                } catch (OParl.ValidationError e) {}
            });
            /*
            Test.add_func ("/oparl/object/wrong_web_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return ObjectTest.test_input.get(url).replace(
                        "\"https://foobar.invalid\"", "1"
                    );
                });
                try {
                    System s = client.open("https://api.testoparl.invalid/oparl/v1/");
                    GLib.assert_not_reached();
                } catch (ValidationError e) {}
            });

            Test.add_func ("/oparl/object/wrong_web_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return ObjectTest.test_input.get(url).replace(
                        "false", "1"
                    );
                });
                try {
                    System s = client.open("https://api.testoparl.invalid/oparl/v1/");
                    GLib.assert_not_reached();
                } catch (ValidationError e) {}
            });
            */
        }
    }
}
