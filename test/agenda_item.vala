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
    public class AgendaItemTest {
        private static GLib.HashTable<string,string> test_input;

        private static void init() {
            AgendaItemTest.test_input = new GLib.HashTable<string,string>(GLib.str_hash, GLib.str_equal);

            AgendaItemTest.test_input.insert("https://oparl.example.org/", Fixtures.system_sane);
            AgendaItemTest.test_input.insert("https://oparl.example.org/bodies", Fixtures.body_list_sane);
            AgendaItemTest.test_input.insert("https://oparl.example.org/meeting/0", Fixtures.meeting_sane);
            AgendaItemTest.test_input.insert("https://oparl.example.org/consultation/0", Fixtures.consultation_sane);
            AgendaItemTest.test_input.insert("https://oparl.example.org/body/0/meetings/", Fixtures.meeting_list_sane);
            AgendaItemTest.test_input.insert("https://oparl.example.org/agendaitem/0", Fixtures.agenda_item_sane);
        }

        public static void add_tests () {
            AgendaItemTest.init();

            Test.add_func ("/oparl/agenda_item/sane_input", () => {
                var client = new Client();
                TestHelper.mock_connect(ref client, AgendaItemTest.test_input, null);
                System s;
                try {
                    s = client.open("https://oparl.example.org/");
                } catch (ParsingError e) {
                    GLib.assert_not_reached();
                }

                try {
                    Body b = s.get_body()[0];
                    Meeting m = b.get_meeting().nth_data(0);
                    AgendaItem a = m.agenda_item.nth_data(0);

                    assert (a.id == "https://oparl.example.org/agendaitem/0");
                    assert (a.get_meeting() != null);
                    assert (a.get_meeting() is Meeting);
                    assert (a.number == "10.1");
                    assert (a.name == "Satzungsänderung für Ausschreibungen");
                    assert (a.@public == true);
                    assert (a.get_consultation() != null);
                    assert (a.get_consultation() is Consultation);
                    assert (a.result == "Geändert beschlossen");
                    assert (a.resolution_text == "Der Beschluss weicht wie folgt vom Antrag ab: ...");
                    assert (a.resolution_file != null);
                    assert (a.resolution_file is OParl.File);
                    assert (a.auxiliary_file != null);
                    assert (a.auxiliary_file.nth_data(0) is OParl.File);
                    assert (a.start.to_string() == "2012-02-06T12:01:00+0000");
                    assert (a.end.to_string() == "2012-02-08T14:05:27+0000");
                } catch (ParsingError e) {
                    GLib.assert_not_reached();
                }
            });

            // Currently conflicts with file fixture because it reads in an agendaItem
            // from an array that contains this agendaItemId, too...
            Test.add_func ("/oparl/agenda_item/wrong_id_type", () => {
                Test.skip("Due to fixture conflict with file_sane fixture");

                var client = new Client();
                TestHelper.mock_connect(ref client, AgendaItemTest.test_input, "\"https://oparl.example.org/agendaitem/0\"");
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body()[0];
                    Meeting m = b.get_meeting().nth_data(0);
                    m.agenda_item.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    //assert(e.message.contains("'id'"));
                }
            });

            Test.add_func ("/oparl/agenda_item/wrong_meeting_type", () => {
                Test.skip("Due to fixture conflict with meeting_sane fixture");
                var client = new Client();
                TestHelper.mock_connect(ref client, AgendaItemTest.test_input, "\"https://oparl.example.org/meeting/0\"");
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body()[0];
                    Meeting m = b.get_meeting().nth_data(0);
                    m.agenda_item.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'meetings'"));
                }
            });

            Test.add_func ("/oparl/agenda_item/wrong_number_type", () => {
                var client = new Client();
                TestHelper.mock_connect(ref client, AgendaItemTest.test_input, "\"10.1\"");
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body()[0];
                    Meeting m = b.get_meeting().nth_data(0);
                    m.agenda_item.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'number'"));
                }
            });

            Test.add_func ("/oparl/agenda_item/wrong_name_type", () => {
                var client = new Client();
                TestHelper.mock_connect(ref client, AgendaItemTest.test_input, "\"Satzungsänderung für Ausschreibungen\"");
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body()[0];
                    Meeting m = b.get_meeting().nth_data(0);
                    m.agenda_item.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'name'"));
                }
            });

            Test.add_func ("/oparl/agenda_item/wrong_public_type", () => {
                var client = new Client();
                TestHelper.mock_connect_extra(ref client, AgendaItemTest.test_input, "true", "\"1\"");
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body()[0];
                    Meeting m = b.get_meeting().nth_data(0);
                    m.agenda_item.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'public'"));
                }
            });

            Test.add_func ("/oparl/agenda_item/wrong_consultation_type", () => {
                var client = new Client();
                TestHelper.mock_connect(ref client, AgendaItemTest.test_input, "\"https://oparl.example.org/consultation/0\"");
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body()[0];
                    Meeting m = b.get_meeting().nth_data(0);
                    m.agenda_item.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'consultation'"));
                }
            });

            Test.add_func ("/oparl/agenda_item/wrong_result_type", () => {
                var client = new Client();
                TestHelper.mock_connect(ref client, AgendaItemTest.test_input, "\"Geändert beschlossen\"");
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body()[0];
                    Meeting m = b.get_meeting().nth_data(0);
                    m.agenda_item.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'result'"));
                }
            });

            Test.add_func ("/oparl/agenda_item/wrong_resolution_text_type", () => {
                var client = new Client();
                TestHelper.mock_connect(ref client, AgendaItemTest.test_input, "\"Der Beschluss weicht wie folgt vom Antrag ab: ...\"");
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body()[0];
                    Meeting m = b.get_meeting().nth_data(0);
                    m.agenda_item.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'resolutionText'"));
                }
            });

            Test.add_func ("/oparl/agenda_item/wrong_start_type", () => {
                var client = new Client();
                TestHelper.mock_connect(ref client, AgendaItemTest.test_input, "\"2012-02-06T12:01:00+00:00\"");
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body()[0];
                    Meeting m = b.get_meeting().nth_data(0);
                    m.agenda_item.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'start'"));
                }
            });

            Test.add_func ("/oparl/agenda_item/wrong_end_type", () => {
                var client = new Client();
                TestHelper.mock_connect(ref client, AgendaItemTest.test_input, "\"2012-02-08T14:05:27+00:00\"");
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body()[0];
                    Meeting m = b.get_meeting().nth_data(0);
                    m.agenda_item.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'end'"));
                }
            });
            // TODO: maybe check for composite types
        }
    }
}
