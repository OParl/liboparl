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
    public class ObjectTest {
        private static GLib.HashTable<string,string> test_input;

        private static void init() {
            ObjectTest.test_input = new GLib.HashTable<string,string>(GLib.str_hash, GLib.str_equal);

            ObjectTest.test_input.insert("https://api.testoparl.invalid/oparl/v1/", """
            {
                "id": "https://api.testoparl.invalid/oparl/v1/",
                "type": "https://schema.oparl.org/1.0/System",
                "name": "Testsystem und so",
                "shortName": "Testsystem"
            }
            """);
        }

        public static void add_tests () {
            ObjectTest.init();
            Test.add_func ("/oparl/object/sane_input",
            () => {
                var client = new Client();
                client.resolve_url.connect((url)=>{
                    return ObjectTest.test_input.get(url);
                });
                System s = client.open("https://api.testoparl.invalid/oparl/v1/");
                assert (s.id == "https://api.testoparl.invalid/oparl/v1/");
                assert (s.name == "Testsystem und so");
                assert (s.short_name == "Testsystem");
            });
        }
    }
}
