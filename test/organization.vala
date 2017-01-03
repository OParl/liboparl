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
    public class OrganizationTest {
        private static GLib.HashTable<string,string> test_input;

        private static void init() {
            OrganizationTest.test_input = new GLib.HashTable<string,string>(GLib.str_hash, GLib.str_equal);

            OrganizationTest.test_input.insert("https://oparl.example.org/", Fixtures.system_sane);
            OrganizationTest.test_input.insert("https://oparl.example.org/bodies", Fixtures.body_list_sane);
            OrganizationTest.test_input.insert("https://oparl.example.org/body/0", Fixtures.body_sane);
            OrganizationTest.test_input.insert("https://oparl.example.org/membership/1", Fixtures.membership_sane);
            OrganizationTest.test_input.insert("https://oparl.example.org/body/0/organizations/", Fixtures.organization_list_sane);
            OrganizationTest.test_input.insert("https://oparl.example.org/organization/0/meetings", Fixtures.meeting_list_sane);
        }

        public static void add_tests () {
            OrganizationTest.init();

            Test.add_func ("/oparl/organization/sane_input", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return OrganizationTest.test_input.get(url);
                });
                System s;
                try {
                    s = client.open("https://oparl.example.org/");
                } catch (ParsingError e) {
                    GLib.assert_not_reached();
                }

                try {
                    Body b = s.get_body().nth_data(0);
                    Organization o = b.get_organization().nth_data(0);

                    assert (o.id == "https://oparl.example.org/organization/0");
                    assert (o.get_body() != null);
                    assert (o.get_body() is OParl.Body);
                    assert (o.name == "Ausschuss für Haushalt und Finanzen");
                    assert (o.short_name == "Finanzausschuss");
                    GLib.Date x = o.start_date;
                    assert("%04u-%02u-%02u".printf(x.get_year(), x.get_month(), x.get_day()) == "2012-07-17");
                    GLib.Date e = o.end_date;
                    assert("%04u-%02u-%02u".printf(e.get_year(), e.get_month(), e.get_day()) == "2014-07-17");
                    assert (o.organization_type == "Gremium");
                    assert (o.location != null);
                    assert (o.location is Location);
                    assert (o.post.length == 3);
                    assert (o.post[0] == "Vorsitzender");
                    assert (o.post[1] == "1. Stellvertreter");
                    assert (o.post[2] == "Mitglied");
                    assert (o.get_meeting() != null);
                    assert (o.get_meeting().nth_data(0) is Meeting);
                    assert (o.get_membership() != null);
                    assert (o.get_membership().nth_data(0) is Membership);
                    assert (o.classification == "Ausschuss");
                    assert (o.keyword.length == 2);
                    assert (o.keyword[0] == "finanzen");
                    assert (o.keyword[1] == "haushalt");
                } catch (ParsingError e) {
                    GLib.assert_not_reached();
                }
            });

            Test.add_func ("/oparl/organization/wrong_body_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return OrganizationTest.test_input.get(url).replace(
                        "\"https://oparl.example.org/body/0\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body().nth_data(0);
                    b.get_organization().nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'id'"));
                }
            });

            Test.add_func ("/oparl/organization/wrong_start_date_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return OrganizationTest.test_input.get(url).replace(
                        "\"2012-07-17\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body().nth_data(0);
                    b.get_organization().nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'startDate'"));
                }
            });

            Test.add_func ("/oparl/organization/wrong_end_date_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return OrganizationTest.test_input.get(url).replace(
                        "\"2014-07-17\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body().nth_data(0);
                    b.get_organization().nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'endDate'"));
                }
            });

            Test.add_func ("/oparl/organization/wrong_organization_type_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return OrganizationTest.test_input.get(url).replace(
                        "\"Gremium\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body().nth_data(0);
                    b.get_organization().nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'organizationType'"));
                }
            });

            // TODO: maybe check post

            Test.add_func ("/oparl/organization/wrong_meeting_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return OrganizationTest.test_input.get(url).replace(
                        "\"https://oparl.example.org/organization/0/meetings\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body().nth_data(0);
                    b.get_organization().nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'meeting'"));
                }
            });

            // TODO: maybe check membership arrayy

            Test.add_func ("/oparl/organization/wrong_classification_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return OrganizationTest.test_input.get(url).replace(
                        "\"Ausschuss\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body().nth_data(0);
                    b.get_organization().nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'classification'"));
                }
            });

            Test.add_func ("/oparl/organization/validation_date", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return OrganizationTest.test_input.get(url).replace(
                        "\"2012-07-17\"","\"2016-01-04\""
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body().nth_data(0);
                    Organization o = b.get_organization().nth_data(0);
                    unowned List<ValidationResult> l = o.validate();
                    stdout.printf(l.nth_data(0).description+"\n");
                    assert (l.length() == 1);
                    assert (l.nth_data(0).description == "Invalid period");
                } catch (ParsingError e) {
                }
            });
        }
    }
}

