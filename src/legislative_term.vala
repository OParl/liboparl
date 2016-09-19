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

namespace OParl {
    /**
     * Represents a legislative term
     */
    public class LegislativeTerm : Object {
        private new static HashTable<string,string> name_map;

        /**
         * The date at which the legislative term started
         */
        public GLib.Date start_date {get; set;}
        /**
         * The date at which the legislative term ended
         */
        public GLib.Date end_date {get; set;}

        internal string body_url {get;set; default="";}
        private bool body_resolved {get;set; default=false;}
        private Body? body_p = null;
        /**
         * The body that references this legislative term
         */
        public Body body {
            get {
                if (!body_resolved) {
                    var r = new Resolver(this.client);
                    this.body_p = (Body)r.parse_url(this.body_url);
                    body_resolved = true;
                }
                return this.body_p;
            }
        }

        internal new static void populate_name_map() {
            name_map = new GLib.HashTable<string,string>(str_hash, str_equal);
            name_map.insert("body","body");
            name_map.insert("startDate","start_date");
            name_map.insert("endDate","end_date");
        }

        internal new void parse(Json.Node n) throws ParsingError {
            base.parse(this, n);
            if (n.get_node_type() != Json.NodeType.OBJECT)
                throw new ParsingError.EXPECTED_OBJECT("I need an Object to parse");
            unowned Json.Object o = n.get_object();

            // Read in Member values
            foreach (unowned string name in o.get_members()) {
                unowned Json.Node item = o.get_member(name);
                switch(name) {
                    // Direct Read-In
                    // - dates
                    case "startDate":
                    case "endDate":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        var dt = GLib.Date();
                        dt.set_parse(item.get_string());
                        this.set_property(LegislativeTerm.name_map.get(name), dt);
                        break;
                    // External object
                    case "body":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set(LegislativeTerm.name_map.get(name)+"_url", item.get_string());
                        break;
                }
            }
        }
    }
}
