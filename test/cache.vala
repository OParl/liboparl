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
    public class CacheTest {
        private static GLib.HashTable<string,string> test_input;

        private static void init() {
            CacheTest.test_input = new GLib.HashTable<string,string>(GLib.str_hash, GLib.str_equal);

            CacheTest.test_input.insert("https://oparl.example.org/", Fixtures.system_sane);
            CacheTest.test_input.insert("https://oparl.example.org/bodies", Fixtures.body_list_sane);
            CacheTest.test_input.insert("https://oparl.example.org/body/0", Fixtures.body_sane);
            CacheTest.test_input.insert("https://oparl.example.org/body/0/people/", Fixtures.person_list_sane);
        }

        public static void add_tests() {
            CacheTest.init();

            Test.add_func("/oparl/cache/load_body_twice", () => {
                var client = new Client();
                client.cache = new TestCache();
                ulong handle = client.resolve_url.connect((url)=>{
                    return CacheTest.test_input.get(url);
                });
                System s;
                try {
                    s = client.open("https://oparl.example.org/");
                } catch (ParsingError e) {
                    GLib.assert_not_reached();
                }
                try {
                    Body b = s.get_body().nth_data(0);
                    Person p = b.get_person().nth_data(0);
                    p.get_body();
                } catch (ParsingError e) {
                    GLib.assert_not_reached();
                }
                client.disconnect(handle);
                client.resolve_url.connect((url)=>{
                    if (url == "https://oparl.example.org/body/0") {
                        GLib.assert_not_reached();
                    }
                    return CacheTest.test_input.get(url);
                });
                try {
                    s = client.open("https://oparl.example.org/");
                } catch (ParsingError e) {
                    GLib.assert_not_reached();
                }
                try {
                    Body b = s.get_body().nth_data(0);
                    Person p = b.get_person().nth_data(0);
                    p.get_body();
                } catch (ParsingError e) {
                    GLib.assert_not_reached();
                }
            });

        }
    }

    private class TestCache : OParl.Cache, GLib.Object {
        private GLib.HashTable<string,OParl.Object> content;
        public TestCache() {
            this.content = new GLib.HashTable<string,OParl.Object>(GLib.str_hash, GLib.str_equal);
        }

        public bool has_object(string id) {
            return this.content.contains(id);
        }
        public void set_object(OParl.Object o) {
            this.content.insert(o.id, o);
        }
        public OParl.Object? get_object(string id) {
            return this.content.get(id);
        }
        public void invalidate(string id) {
            this.content.remove(id);
        }
    }
}

