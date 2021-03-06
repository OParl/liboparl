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
    public class MeetingTest {
        private static GLib.HashTable<string,string> test_input;

        private static void init() {
            MeetingTest.test_input = new GLib.HashTable<string,string>(GLib.str_hash, GLib.str_equal);

            MeetingTest.test_input.insert("https://oparl.example.org/", Fixtures.system_sane);
            MeetingTest.test_input.insert("https://oparl.example.org/bodies", Fixtures.body_list_sane);
            MeetingTest.test_input.insert("https://oparl.example.org/organization/0", Fixtures.organization_sane);
            MeetingTest.test_input.insert("https://oparl.example.org/person/0", Fixtures.person_sane);
            MeetingTest.test_input.insert("https://oparl.example.org/body/0/meetings/", Fixtures.meeting_list_sane);
            MeetingTest.test_input.insert("https://oparl.example.org/body/0", Fixtures.body_sane);
        }

        public static void add_tests () {
            MeetingTest.init();

            Test.add_func ("/oparl/meeting/sane_input", () => {
                var client = new Client();
                TestHelper.mock_connect(ref client, MeetingTest.test_input, null);
                System s;
                try {
                    s = client.open("https://oparl.example.org/");
                } catch (ParsingError e) {
                    GLib.assert_not_reached();
                }

                try {
                    Body b = s.get_body().nth_data(0);
                    Meeting m = b.get_meeting().nth_data(0);

                    assert (m.id == "https://oparl.example.org/meeting/0");
                    assert (m.name == "4. Sitzung des Finanzausschusses");
                    assert (m.start.to_string() == "2013-01-04T08:00:00+0000");
                    assert (m.end.to_string() == "2013-01-04T12:00:00+0000");
                    assert (m.location != null);
                    assert (m.location is Location);
                    assert (m.get_organization() != null);
                    assert (m.get_organization().nth_data(0) is Organization);
                    assert (m.get_participant() != null);
                    assert (m.get_participant().nth_data(0) is Person);
                    assert (m.invitation != null);
                    assert (m.invitation is OParl.File);
                    assert (m.results_protocol != null);
                    assert (m.results_protocol is OParl.File);
                    assert (m.verbatim_protocol != null);
                    assert (m.verbatim_protocol is OParl.File);
                    assert (m.auxiliary_file != null);
                    assert (m.auxiliary_file.nth_data(0) is OParl.File);
                    assert (m.agenda_item != null);
                    assert (m.agenda_item.nth_data(0) is AgendaItem);
                    assert (m.created.to_string() == "2012-01-06T12:01:00+0000");
                    assert (m.modified.to_string() == "2012-01-08T14:05:27+0000");
                } catch (ParsingError e) {
                    GLib.assert_not_reached();
                }
            });

            Test.add_func ("/oparl/meeting/wrong_id_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    var data = MeetingTest.test_input.get(url);
                    if (url == "https://oparl.example.org/body/0/meetings/")
                        data = data.replace(
                            "\"https://oparl.example.org/meeting/0\"", "1"
                        );
                    return new ResolveUrlResult(data, true, 200);
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body().nth_data(0);
                    b.get_meeting().nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'id'"));
                }
            });

            Test.add_func ("/oparl/meeting/wrong_cancelled_type", () => {
                var client = new Client();
                TestHelper.mock_connect_extra(ref client, MeetingTest.test_input, "\"cancelled\": false", "\"cancelled\": \"1\"");
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body().nth_data(0);
                    b.get_meeting().nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'cancelled'"));
                }
            });

            Test.add_func ("/oparl/meeting/wrong_start_type", () => {
                var client = new Client();
                TestHelper.mock_connect(ref client, MeetingTest.test_input, "\"2013-01-04T08:00:00+00:00\"");
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body().nth_data(0);
                    b.get_meeting().nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'start'"));
                }
            });

            Test.add_func ("/oparl/meeting/wrong_end_type", () => {
                var client = new Client();
                TestHelper.mock_connect(ref client, MeetingTest.test_input, "\"2013-01-04T12:00:00+00:00\"");
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body().nth_data(0);
                    b.get_meeting().nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'end'"));
                }
            });
            // TODO: maybe check for all fields with composite types

            Test.add_func ("/oparl/meeting/validation_date", () => {
                var client = new Client();
                TestHelper.mock_connect_extra(ref client, MeetingTest.test_input, "\"2013-01-04T12:00:00+00:00\"", "\"2013-01-04T06:00:00+00:00\"");
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body().nth_data(0);
                    Meeting m = b.get_meeting().nth_data(0);
                    unowned List<ValidationResult> l = m.validate();
                    assert (l.length() == 1);
                    assert (l.nth_data(0).description == "Invalid period");
                } catch (ParsingError e) {
                }
            });
        }
    }
}
