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
    public class TestHelper {
        public static ulong mock_connect(ref Client client, GLib.HashTable<string,string> test_input, string? replaced) {
            return client.resolve_url.connect((url) => {
                string data = test_input.get(url);
                if (replaced != null) {
                    data = data.replace(replaced, "1");
                }
                return new ResolveUrlResult(data, true, 200);
            });
        }

        public static ulong mock_connect_extra(ref Client client, GLib.HashTable<string,string> test_input, string old_value, string new_value) {
            return client.resolve_url.connect((url) => {
                string data = test_input.get(url).replace(old_value, new_value);
                return new ResolveUrlResult(data, true, 200);
            });
        }
    }
}
