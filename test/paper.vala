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
                TestHelper.mock_connect(ref client, PaperTest.test_input, null);
                System s;
                try {
                    s = client.open("https://oparl.example.org/");
                } catch (ParsingError e) {
                    GLib.assert_not_reached();
                }
                try {
                    Body b = s.get_body()[0];
                    Paper p = b.get_paper().nth_data(0);

                    assert (p.id == "https://oparl.example.org/paper/0");
                    assert (p.get_body() != null);
                    assert (p.get_body() is Body);
                    assert (p.name == "Antwort auf Anfrage 1200/2014");
                    assert (p.reference == "1234/2014");
                    assert (p.date.to_string() == "2014-04-04T00:00:00+0000");
                    assert (p.paper_type == "Beantwortung einer Anfrage");
                    assert (p.get_related_paper() != null);
                    assert (p.get_related_paper().nth_data(0) is Paper);
                    assert (p.main_file != null);
                    assert (p.main_file is OParl.File);
                    assert (p.auxiliary_file != null);
                    assert (p.auxiliary_file.nth_data(0) is OParl.File);
                    assert (p.location != null);
                    assert (p.location.nth_data(0) is Location);
                    assert (p.get_originator_person() != null);
                    assert (p.get_originator_person().nth_data(0) is Person);
                    assert (p.get_originator_organization() != null);
                    assert (p.get_originator_organization().nth_data(0) is Organization);
                    assert (p.consultation != null);
                    assert (p.consultation.nth_data(0) is Consultation);
                    assert (p.get_under_direction_of() != null);
                    assert (p.get_under_direction_of().nth_data(0) is Organization);
                    assert (p.created.to_string() == "2013-01-08T12:05:27+0000");
                    assert (p.modified.to_string() == "2013-01-08T12:05:27+0000");
                } catch (ParsingError e) {
                    GLib.assert_not_reached();
                }
            });

            Test.add_func ("/oparl/paper/wrong_id_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    var data = PaperTest.test_input.get(url);
                    if (url == "https://oparl.example.org/body/0/papers/") {
                        data = data.replace(
                            "\"https://oparl.example.org/paper/0\"", "1"
                        );
                    }
                    return new ResolveUrlResult(data, true, 200);
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body()[0];
                    b.get_paper().nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'id'"));
                }
            });

            Test.add_func ("/oparl/paper/wrong_body_type", () => {
                var client = new Client();
                TestHelper.mock_connect(ref client, PaperTest.test_input, "\"https://oparl.example.org/body/0\"");
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body()[0];
                    b.get_paper().nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'id'"));
                }
            });

            Test.add_func ("/oparl/paper/wrong_name_type", () => {
                var client = new Client();
                TestHelper.mock_connect(ref client, PaperTest.test_input, "\"Antwort auf Anfrage 1200/2014\"");
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body()[0];
                    b.get_paper().nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'name'"));
                }
            });

            Test.add_func ("/oparl/paper/wrong_reference_type", () => {
                var client = new Client();
                TestHelper.mock_connect(ref client, PaperTest.test_input, "\"1234/2014\"");
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body()[0];
                    b.get_paper().nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'reference'"));
                }
            });

            Test.add_func ("/oparl/paper/wrong_date_type", () => {
                var client = new Client();
                TestHelper.mock_connect(ref client, PaperTest.test_input, "\"2014-04-04\"");
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body()[0];
                    b.get_paper().nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'date'"));
                }
            });

            Test.add_func ("/oparl/paper/wrong_paper_type_type", () => {
                var client = new Client();
                TestHelper.mock_connect(ref client, PaperTest.test_input, "\"Beantwortung einer Anfrage\"");
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body()[0];
                    b.get_paper().nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'paperType'"));
                }
            });
            // TODO: add tests for wrong composite types?

        }
    }
}
