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
    public class MembershipTest {
        private static GLib.HashTable<string,string> test_input;

        private static void init() {
            MembershipTest.test_input = new GLib.HashTable<string,string>(GLib.str_hash, GLib.str_equal);

            MembershipTest.test_input.insert("https://oparl.example.org/", Fixtures.system_sane);
            MembershipTest.test_input.insert("https://oparl.example.org/bodies", Fixtures.body_list_sane);
            MembershipTest.test_input.insert("https://oparl.example.org/organization/0", Fixtures.organization_sane);
            MembershipTest.test_input.insert("https://oparl.example.org/body/0/people/", Fixtures.person_list_sane);
        }

        public static void add_tests () {
            MembershipTest.init();

            Test.add_func ("/oparl/membership/sane_input", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return MembershipTest.test_input.get(url);
                });
                System s;
                try {
                    s = client.open("https://oparl.example.org/");
                } catch (ValidationError e) {
                    GLib.assert_not_reached();
                }
                Body b = s.body.nth_data(0);
                Person p = b.person.nth_data(0);
                Membership m = p.membership.nth_data(1);

                assert (m.id == "https://oparl.example.org/membership/1");
                assert (m.organization != null);
                assert (m.organization is OParl.Organization);
                assert (m.person != null);
                assert (m.person is OParl.Person);
                assert (m.role == "Sachkundige Bürgerin");
                assert (m.voting_right == false);
                GLib.Date x = m.start_date;
                assert("%04u-%02u-%02u".printf(x.get_year(), x.get_month(), x.get_day()) == "2013-12-03");
                GLib.Date e = m.end_date;
                assert("%04u-%02u-%02u".printf(e.get_year(), e.get_month(), e.get_day()) == "2014-07-28");
            });

            // TODO: comment in when typechecks are in place
            /*
            Test.add_func ("/oparl/membership/wrong_id_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return MembershipTest.test_input.get(url).replace(
                        "\"https://oparl.example.org/memberships/1\"", "1"
                    );
                });
                try {
                    System s = client.open("https://api.testoparl.invalid/oparl/v1/");
                    Body b = s.body.nth_data(0);
                    Person p = b.person.nth_data(0);
                    Membership m = p.membership.nth_data(1);
                    GLib.assert_not_reached();
                } catch (ValidationError e) {}
            });

            Test.add_func ("/oparl/membership/wrong_organization_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return MembershipTest.test_input.get(url).replace(
                        "\"https://oparl.example.org/organization/0\"", "1"
                    );
                });
                try {
                    System s = client.open("https://api.testoparl.invalid/oparl/v1/");
                    Body b = s.body.nth_data(0);
                    Person p = b.person.nth_data(0);
                    Membership m = p.membership.nth_data(1);
                    GLib.assert_not_reached();
                } catch (ValidationError e) {}
            });

            Test.add_func ("/oparl/membership/wrong_role_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return MembershipTest.test_input.get(url).replace(
                        "\"Sachkundige Bürgerin\"", "1"
                    );
                });
                try {
                    System s = client.open("https://api.testoparl.invalid/oparl/v1/");
                    Body b = s.body.nth_data(0);
                    Person p = b.person.nth_data(0);
                    Membership m = p.membership.nth_data(1);
                    GLib.assert_not_reached();
                } catch (ValidationError e) {}
            });

            Test.add_func ("/oparl/membership/wrong_voting_right_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return MembershipTest.test_input.get(url).replace(
                        "false", "\"foobar\""
                    );
                });
                try {
                    System s = client.open("https://api.testoparl.invalid/oparl/v1/");
                    Body b = s.body.nth_data(0);
                    Person p = b.person.nth_data(0);
                    Membership m = p.membership.nth_data(1);
                    GLib.assert_not_reached();
                } catch (ValidationError e) {}
            });

            Test.add_func ("/oparl/membership/wrong_start_date_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return MembershipTest.test_input.get(url).replace(
                        "\"2013-12-03\"", "1"
                    );
                });
                try {
                    System s = client.open("https://api.testoparl.invalid/oparl/v1/");
                    Body b = s.body.nth_data(0);
                    Person p = b.person.nth_data(0);
                    Membership m = p.membership.nth_data(1);
                    GLib.assert_not_reached();
                } catch (ValidationError e) {}
            });

            Test.add_func ("/oparl/membership/wrong_end_date_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return MembershipTest.test_input.get(url).replace(
                        "\"2014-07-28\"", "1"
                    );
                });
                try {
                    System s = client.open("https://api.testoparl.invalid/oparl/v1/");
                    Body b = s.body.nth_data(0);
                    Person p = b.person.nth_data(0);
                    Membership m = p.membership.nth_data(1);
                    GLib.assert_not_reached();
                } catch (ValidationError e) {}
            });
            */
        }
    }
}
