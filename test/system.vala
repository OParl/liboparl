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
    public class SystemTest {
        private static GLib.HashTable<string,string> test_input;

        private static void init() {
            SystemTest.test_input = new GLib.HashTable<string,string>(GLib.str_hash, GLib.str_equal);

            SystemTest.test_input.insert("https://oparl.example.org/", Fixtures.system_sane);
        }

        public static void add_tests () {
            SystemTest.init();

            Test.add_func ("/oparl/system/sane_input", () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return SystemTest.test_input.get(url);
                });
                System s;
                try {
                    s = client.open("https://oparl.example.org/");
                } catch (ValidationError e) {
                    GLib.assert_not_reached();
                }
                assert (s.id == "https://oparl.example.org/");
                assert (s.name == "Beispiel-System");
                assert (s.oparl_version == "https://schema.oparl.org/1.0/");
                // TODO: test bodies
                assert (s.short_name == null);
                assert (s.license == null);
                assert (s.web == null);
                assert (!s.deleted);
                assert (s.keyword.length == 0);
                assert (s.created == null);
                assert (s.modified == null);
                assert (s.contact_email == "info@example.org");
                assert (s.contact_name == "Allgemeiner OParl Kontakt");
                assert (s.website == "http://www.example.org/");
                assert (s.vendor == "http://example-software.com/");
                assert (s.product == "http://example-software.com/oparl-server/");
                assert (s.other_oparl_versions[0] == "https://oparl2.example.org/");
                assert (s.other_oparl_versions.length == 1);
            });
        }
    }
}
