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
    public class ConsultationTest {
        private static GLib.HashTable<string,string> test_input;

        private static void init() {
            ConsultationTest.test_input = new GLib.HashTable<string,string>(GLib.str_hash, GLib.str_equal);

            ConsultationTest.test_input.insert("https://oparl.example.org/", Fixtures.system_sane);
            ConsultationTest.test_input.insert("https://oparl.example.org/bodies", Fixtures.body_list_sane);
            ConsultationTest.test_input.insert("https://oparl.example.org/meeting/0", Fixtures.meeting_sane);
            ConsultationTest.test_input.insert("https://oparl.example.org/agendaitem/0", Fixtures.agenda_item_sane);
            ConsultationTest.test_input.insert("https://oparl.example.org/organization/0", Fixtures.organization_sane);
            ConsultationTest.test_input.insert("https://oparl.example.org/body/0/papers/", Fixtures.paper_list_sane);
        }

        public static void add_tests () {
            ConsultationTest.init();

            Test.add_func ("/oparl/consultation/sane_input", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return ConsultationTest.test_input.get(url);
                });
                System s;
                try {
                    s = client.open("https://oparl.example.org/");
                } catch (ParsingError e) {
                    GLib.assert_not_reached();
                }
                Body b = s.body.nth_data(0);
                Paper p = b.paper.nth_data(0);
                Consultation c = p.consultation.nth_data(0);

                assert (c.id == "https://oparl.example.org/consultation/0");
                assert (c.agenda_item != null);
                assert (c.agenda_item is AgendaItem);
                assert (c.paper != null);
                assert (c.paper is Paper);
                assert (c.meeting != null);
                assert (c.meeting is Meeting);
                assert (c.organization != null);
                assert (c.organization.nth_data(0) is Organization);
                assert (c.authoritative == false);
                assert (c.role == "Beschlussfassung");
            });

            // TODO: comment in as soon as typechecks are in place
            /*
            Test.add_func ("/oparl/consultation/wrong_id_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return MembershipTest.test_input.get(url).replace(
                        "\"https://oparl.example.org/consultation/0\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.body.nth_data(0);
                    Paper p = b.paper.nth_data(0);
                    Consultation c = p.consultation.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {}
            });

            Test.add_func ("/oparl/consultation/wrong_agenda_item_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return MembershipTest.test_input.get(url).replace(
                        "\"https://oparl.example.org/agendaitem/0\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.body.nth_data(0);
                    Paper p = b.paper.nth_data(0);
                    Consultation c = p.consultation.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {}
            });

            Test.add_func ("/oparl/consultation/wrong_meeting_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return MembershipTest.test_input.get(url).replace(
                        "\"https://oparl.example.org/meeting/0\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.body.nth_data(0);
                    Paper p = b.paper.nth_data(0);
                    Consultation c = p.consultation.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {}
            });

            Test.add_func ("/oparl/consultation/wrong_authoritative_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return MembershipTest.test_input.get(url).replace(
                        "false", "\"1\""
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.body.nth_data(0);
                    Paper p = b.paper.nth_data(0);
                    Consultation c = p.consultation.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {}
            });

            Test.add_func ("/oparl/consultation/wrong_role_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return MembershipTest.test_input.get(url).replace(
                        "\"Beschlussfassung\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.body.nth_data(0);
                    Paper p = b.paper.nth_data(0);
                    Consultation c = p.consultation.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {}
            });
            // TODO: maybe check composite types
            */
        }
    }
}

