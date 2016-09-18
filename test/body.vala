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
    public class BodyTest {
        private static GLib.HashTable<string,string> test_input;

        private static void init() {
            BodyTest.test_input = new GLib.HashTable<string,string>(GLib.str_hash, GLib.str_equal);

            BodyTest.test_input.insert("https://oparl.example.org/", Fixtures.system_sane);
            BodyTest.test_input.insert("https://oparl.example.org/bodies", Fixtures.body_list_sane);
            BodyTest.test_input.insert("https://oparl.example.org/body/0/organizations/", Fixtures.organization_list_sane);
            BodyTest.test_input.insert("https://oparl.example.org/body/0/meetings/", Fixtures.meeting_list_sane);
            BodyTest.test_input.insert("https://oparl.example.org/body/0/people/", Fixtures.person_list_sane);
            BodyTest.test_input.insert("https://oparl.example.org/body/0/papers/", Fixtures.paper_list_sane);
        }

        public static void add_tests () {
            BodyTest.init();

            Test.add_func ("/oparl/body/sane_input", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return BodyTest.test_input.get(url);
                });
                System s;
                try {
                    s = client.open("https://oparl.example.org/");
                } catch (ParsingError e) {
                    GLib.assert_not_reached();
                }
                Body b = s.body.nth_data(0);

                assert (b.id == "https://oparl.example.org/body/0");
                assert (b.system != null);
                assert (b.system is OParl.System);
                assert (b.contact_email == "ris@beispielstadt.de");
                assert (b.contact_name == "RIS-Betreuung");
                assert (b.ags == "05315000");
                assert (b.rgs == "053150000000");
                assert (b.classification == "Kreisfreie Stadt");
                assert (b.equivalent.length == 2);
                assert (b.equivalent[0] == "http://d-nb.info/gnd/2015732-0");
                assert (b.equivalent[1] == "http://dbpedia.org/resource/Cologne");
                assert (b.short_name == "Köln");
                assert (b.name == "Stadt Köln, kreisfreie Stadt");
                assert (b.website == "http://www.beispielstadt.de/");
                assert (b.license == "http://creativecommons.org/licenses/by/4.0/");
                assert (b.license_valid_since.to_string() == "2015-01-01T14:28:31+0000");
                assert (b.oparl_since.to_string() == "2014-01-01T14:28:31+0000");
                assert (b.organization != null);
                assert (b.organization.nth_data(0) != null);
                assert (b.organization.nth_data(0) is Organization);
                assert (b.person != null);
                assert (b.person.nth_data(0) != null);
                assert (b.person.nth_data(0) is Person);
                assert (b.meeting != null);
                assert (b.meeting.nth_data(0) != null);
                assert (b.meeting.nth_data(0) is Meeting);
                assert (b.paper != null);
                assert (b.paper.nth_data(0) != null);
                assert (b.paper.nth_data(0) is Paper);
            });

            // TODO: activate these tests as soon as typechecks are implemented
            /*
            Test.add_func ("/oparl/body/wrong_id_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return BodyTest.test_input.get(url).replace(
                        "\"https://oparl.example.org/body/0\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.body.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {}
            });

            Test.add_func ("/oparl/body/wrong_system_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return BodyTest.test_input.get(url).replace(
                        "\"https://oparl.example.org/\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.body.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {}
            });

            Test.add_func ("/oparl/body/wrong_contact_email_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return BodyTest.test_input.get(url).replace(
                        "\"ris@beispielstadt.de\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.body.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {}
            });

            Test.add_func ("/oparl/body/wrong_contact_name_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return BodyTest.test_input.get(url).replace(
                        "\"RIS-Betreuung\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.body.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {}
            });

            Test.add_func ("/oparl/body/wrong_ags_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return BodyTest.test_input.get(url).replace(
                        "\"05315000\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.body.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {}
            });

            Test.add_func ("/oparl/body/wrong_rgs_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return BodyTest.test_input.get(url).replace(
                        "\"053150000000\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.body.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {}
            });

            Test.add_func ("/oparl/body/wrong_classification_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return BodyTest.test_input.get(url).replace(
                        "\"Kreisfreie Stadt\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.body.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {}
            });

            Test.add_func ("/oparl/body/wronga_equivalent_type", () => {
                // TODO: implement
            });

            Test.add_func ("/oparl/body/wrong_website_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return BodyTest.test_input.get(url).replace(
                        "\"http://www.beispielstadt.de/\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.body.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {}
            });

            Test.add_func ("/oparl/body/wrong_license_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return BodyTest.test_input.get(url).replace(
                        "\"http://creativecommons.org/licenses/by/4.0/\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.body.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {}
            });

            Test.add_func ("/oparl/body/wrong_license_valid_since_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return BodyTest.test_input.get(url).replace(
                        "\"2015-01-01T14:28:31.568+0000\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.body.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {}
            });

            Test.add_func ("/oparl/body/wrong_oparl_since_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return BodyTest.test_input.get(url).replace(
                        "\"2014-01-01T14:28:31.568+0000\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.body.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {}
            });
            */
        }
    }
}
