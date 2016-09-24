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
    public class LegislativeTermTest {
        private static GLib.HashTable<string,string> test_input;

        private static void init() {
            LegislativeTermTest.test_input = new GLib.HashTable<string,string>(GLib.str_hash, GLib.str_equal);

            LegislativeTermTest.test_input.insert("https://oparl.example.org/", Fixtures.system_sane);
            LegislativeTermTest.test_input.insert("https://oparl.example.org/bodies", Fixtures.body_list_sane);
            LegislativeTermTest.test_input.insert("https://oparl.example.org/body/0", Fixtures.body_sane);
        }

        public static void add_tests () {
            LegislativeTermTest.init();

            Test.add_func ("/oparl/legislative_term/sane_input", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return LegislativeTermTest.test_input.get(url);
                });
                System s;
                try {
                    s = client.open("https://oparl.example.org/");
                } catch (ParsingError e) {
                    GLib.assert_not_reached();
                }

                try {
                    Body b = s.get_body().nth_data(0);
                    LegislativeTerm l = b.legislative_term.nth_data(0);

                    assert (l.id == "https://oparl.example.org/term/21");
                    assert (l.get_body() != null);
                    assert (l.get_body() is OParl.Body);
                    assert (l.name == "21. Wahlperiode");
                    GLib.Date x = l.start_date;
                    assert("%04u-%02u-%02u".printf(x.get_year(), x.get_month(), x.get_day()) == "2010-12-03");
                    GLib.Date e = l.end_date;
                    assert("%04u-%02u-%02u".printf(e.get_year(), e.get_month(), e.get_day()) == "2013-12-03");
                } catch (ParsingError e) {
                    GLib.assert_not_reached();
                }
            });

            Test.add_func ("/oparl/legislative_term/wrong_id_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return LegislativeTermTest.test_input.get(url).replace(
                        "\"https://oparl.example.org/term/21\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body().nth_data(0);
                    b.legislative_term.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'id'"));
                }
            });

            Test.add_func ("/oparl/legislative_term/wrong_body_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return LegislativeTermTest.test_input.get(url).replace(
                        "\"https://oparl.example.org/body/0\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body().nth_data(0);
                    b.legislative_term.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'id'"));
                }
            });

            Test.add_func ("/oparl/legislative_term/wrong_name_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return LegislativeTermTest.test_input.get(url).replace(
                        "\"21. Wahlperiode\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body().nth_data(0);
                    b.legislative_term.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'name'"));
                }
            });

            Test.add_func ("/oparl/legislative_term/wrong_start_date_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return LegislativeTermTest.test_input.get(url).replace(
                        "\"2010-12-03\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body().nth_data(0);
                    b.legislative_term.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'startDate'"));
                }
            });

            Test.add_func ("/oparl/legislative_term/wrong_end_date_type", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return LegislativeTermTest.test_input.get(url).replace(
                        "\"2013-12-03\"", "1"
                    );
                });
                try {
                    System s = client.open("https://oparl.example.org/");
                    Body b = s.get_body().nth_data(0);
                    b.legislative_term.nth_data(0);
                    GLib.assert_not_reached();
                } catch (ParsingError e) {
                    assert(e.message.contains("'endDate'"));
                }
            });
        }
    }
}
