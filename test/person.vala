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
    public class PersonTest {
        private static GLib.HashTable<string,string> test_input;

        private static void init() {
            PersonTest.test_input = new GLib.HashTable<string,string>(GLib.str_hash, GLib.str_equal);

            PersonTest.test_input.insert("https://oparl.example.org/", Fixtures.system_sane);
            PersonTest.test_input.insert("https://oparl.example.org/bodies", Fixtures.body_list_sane);
            PersonTest.test_input.insert("https://oparl.example.org/body/0", Fixtures.body_sane);
            PersonTest.test_input.insert("https://oparl.example.org/body/0/people/", Fixtures.person_list_sane);
        }

        public static void add_tests () {
            PersonTest.init();

            Test.add_func ("/oparl/person/sane_input", () => {
                var client = new Client();
                TestHelper.mock_connect(ref client, PersonTest.test_input, null);
                System s;
                try {
                    s = client.open("https://oparl.example.org/");
                } catch (ParsingError e) {
                    GLib.assert_not_reached();
                }

                try {
                    Body b = s.get_body()[0];
                    Person p = b.get_person().nth_data(0);

                    assert (p.id == "https://oparl.example.org/person/0");
                    assert (p.get_body() != null);
                    assert (p.get_body() is OParl.Body);
                    assert (p.name == "Prof. Dr. Max Mustermann");
                    assert (p.family_name == "Mustermann");
                    assert (p.given_name == "Max");
                    assert (p.title != null);
                    assert (p.title[0] == "Prof.");
                    assert (p.title[1] == "Dr.");
                    assert (p.form_of_address == "Ratsfrau");
                    assert (p.gender == "male");
                    assert (p.email != null);
                    assert (p.email[0] == "max@mustermann.de");
                    assert (p.phone != null);
                    assert (p.phone[0] == "+493012345678");
                    assert (p.status != null);
                    assert (p.status[0] == "Bezirksbürgermeister");
                    assert (p.membership != null);
                    assert (p.membership.length() == 2);
                    assert (p.created.to_string() == "2011-11-11T11:11:00+0000");
                    assert (p.modified.to_string() == "2012-08-16T14:05:27+0000");
                } catch (ParsingError e) {
                    GLib.assert_not_reached();
                }
            });

            Test.add_func ("/oparl/person/wrong_id_type", () => {
                var client = new Client();
                TestHelper.mock_connect(ref client, PersonTest.test_input, "\"https://oparl.example.org/person/0\"");
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body()[0];
                    b.get_person().nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'id'"));
                }
            });

            Test.add_func ("/oparl/person/wrong_family_name_type", () => {
                var client = new Client();
                TestHelper.mock_connect(ref client, PersonTest.test_input, "\"Mustermann\"");
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body()[0];
                    b.get_person().nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'familyName'"));
                }
            });

            Test.add_func ("/oparl/person/wrong_given_name_type", () => {
                var client = new Client();
                TestHelper.mock_connect(ref client, PersonTest.test_input, "\"Max\"");
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body()[0];
                    b.get_person().nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'givenName'"));
                }
            });

            // TODO: check titles

            Test.add_func ("/oparl/person/wrong_form_of_address_type", () => {
                var client = new Client();
                TestHelper.mock_connect(ref client, PersonTest.test_input, "\"Ratsfrau\"");
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body()[0];
                    b.get_person().nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'formOfAddress'"));
                }
            });

            Test.add_func ("/oparl/person/wrong_gender_type", () => {
                var client = new Client();
                TestHelper.mock_connect(ref client, PersonTest.test_input, "\"male\"");
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body()[0];
                    b.get_person().nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'gender'"));
                }
            });
        }
    }
}
