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
    public class PaperTest {
        private static GLib.HashTable<string,string> test_input;

        private static void init() {
            PaperTest.test_input = new GLib.HashTable<string,string>(GLib.str_hash, GLib.str_equal);

            PaperTest.test_input.insert("https://oparl.example.org/", Fixtures.system_sane);
            PaperTest.test_input.insert("https://oparl.example.org/bodies", Fixtures.body_list_sane);
            PaperTest.test_input.insert("https://oparl.example.org/meeting/0", Fixtures.meeting_sane);
            PaperTest.test_input.insert("https://oparl.example.org/body/0/papers/", Fixtures.paper_list_sane);
            PaperTest.test_input.insert("https://oparl.example.org/body/0", Fixtures.body_sane);
            PaperTest.test_input.insert("https://oparl.example.org/paper/0", Fixtures.paper_sane);
            PaperTest.test_input.insert("https://oparl.example.org/person/0", Fixtures.person_sane);
            PaperTest.test_input.insert("https://oparl.example.org/organization/0", Fixtures.organization_sane);
        }

        public static void add_tests () {
            PaperTest.init();

            Test.add_func ("/oparl/paper/sane_input", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return PaperTest.test_input.get(url);
                });
                System s;
                try {
                    s = client.open("https://oparl.example.org/");
                } catch (ParsingError e) {
                    GLib.assert_not_reached();
                }
                Body b = s.body.nth_data(0);
                Paper p = b.paper.nth_data(0);

                assert (p.id == "https://oparl.example.org/paper/0");
                assert (p.body != null);
                assert (p.body is Body);
                assert (p.name == "Antwort auf Anfrage 1200/2014");
                assert (p.reference == "1234/2014");
                GLib.Date x = p.date;
                assert("%04u-%02u-%02u".printf(x.get_year(), x.get_month(), x.get_day()) == "2014-04-04");
                assert (p.paper_type == "Beantwortung einer Anfrage");
                assert (p.related_paper != null);
                assert (p.related_paper.nth_data(0) is Paper);
                assert (p.main_file != null);
                assert (p.main_file is OParl.File);
                assert (p.auxiliary_file != null);
                assert (p.auxiliary_file.nth_data(0) is OParl.File);
                assert (p.location != null);
                assert (p.location.nth_data(0) is Location);
                assert (p.originator_person != null);
                assert (p.originator_person.nth_data(0) is Person);
                assert (p.originator_organization != null);
                assert (p.originator_organization.nth_data(0) is Organization);
                assert (p.consultation != null);
                assert (p.consultation.nth_data(0) is Consultation);
                assert (p.under_direction_of != null);
                assert (p.under_direction_of.nth_data(0) is Organization);
                assert (p.created.to_string() == "2013-01-08T12:05:27+0000");
                assert (p.modified.to_string() == "2013-01-08T12:05:27+0000");
            });

            // TODO: uncomment when typechecking is in place
            /*
            Test.add_func ("/oparl/paper/wrong_id_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return PaperTest.test_input.get(url).replace(
                        "\"https://oparl.example.org/paper/0\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.body.nth_data(0);
                    Paper p = b.paper.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {}
            });

            Test.add_func ("/oparl/paper/wrong_body_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return PaperTest.test_input.get(url).replace(
                        "\"https://oparl.example.org/body/0\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.body.nth_data(0);
                    Paper p = b.paper.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {}
            });

            Test.add_func ("/oparl/paper/wrong_name_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return PaperTest.test_input.get(url).replace(
                        "\"Antwort auf Anfrage 1200/2014\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.body.nth_data(0);
                    Paper p = b.paper.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {}
            });

            Test.add_func ("/oparl/paper/wrong_reference_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return PaperTest.test_input.get(url).replace(
                        "\"1234/2014\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.body.nth_data(0);
                    Paper p = b.paper.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {}
            });

            Test.add_func ("/oparl/paper/wrong_date_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return PaperTest.test_input.get(url).replace(
                        "\"2014-04-04\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.body.nth_data(0);
                    Paper p = b.paper.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {}
            });

            Test.add_func ("/oparl/paper/wrong_paper_type_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return PaperTest.test_input.get(url).replace(
                        "\"Beantwortung einer Anfrage\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.body.nth_data(0);
                    Paper p = b.paper.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {}
            });
            // TODO: add tests for wrong composite types?
            */

        }
    }
}
