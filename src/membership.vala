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
    public class Membership : Object {
        private new static HashTable<string,string> name_map;

        public string role {get; set;}
        public bool voting_right {get; set;}
        public GLib.DateTime start_date {get; set;}
        public GLib.DateTime end_date {get; set;}

        public string person_url {get;set; default="";}
        private bool person_resolved {get;set; default=false;}
        private Person? person_p = null;
        public Person person {
            get {
                if (!person_resolved) {
                    var r = new Resolver(this.client);
                    this.person_p = (Person)r.parse_url(this.person_url);
                    person_resolved = true;
                }
                return this.person_p;
            }
        }

        public string organization_url {get;set; default="";}
        private bool organization_resolved {get;set; default=false;}
        private Organization? organization_p = null;
        public Organization organization {
            get {
                if (!organization_resolved) {
                    var r = new Resolver(this.client);
                    this.organization_p = (Organization)r.parse_url(this.organization_url);
                    organization_resolved = true;
                }
                return this.organization_p;
            }
        }

        public string on_behalf_of_url {get;set; default="";}
        private bool on_behalf_of_resolved {get;set; default=false;}
        private Organization? on_behalf_of_p = null;
        public Organization on_behalf_of {
            get {
                if (!on_behalf_of_resolved) {
                    var r = new Resolver(this.client);
                    this.on_behalf_of_p = (Organization)r.parse_url(this.on_behalf_of_url);
                    on_behalf_of_resolved = true;
                }
                return this.on_behalf_of_p;
            }
        }

        internal static void populate_name_map() {
            name_map = new GLib.HashTable<string,string>(str_hash, str_equal);
            name_map.insert("role", "role");
            name_map.insert("votingRight", "voting_right");
            name_map.insert("startDate", "start_date");
            name_map.insert("endDate", "end_date");
            name_map.insert("person", "person");
            name_map.insert("organization", "organization");
            name_map.insert("onBehalfOf","on_behalf_of");
        }

        public new void parse(Json.Node n) {
            base.parse(this, n);
            if (n.get_node_type() != Json.NodeType.OBJECT)
                throw new ValidationError.EXPECTED_OBJECT("I need an Object to parse");
            unowned Json.Object o = n.get_object();

            // Read in Member values
            foreach (unowned string name in o.get_members()) {
                unowned Json.Node item = o.get_member(name);
                switch(name) {
                    // Direct Read-In
                    // - strings
                    case "role":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set(Membership.name_map.get(name), item.get_string(),null);
                        break;
                    // - booleans
                    case "votingRight":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set_property(Membership.name_map.get(name), item.get_boolean());
                        break;
                    // - dates
                    case "startDate":
                    case "endDate":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        var tv = new GLib.TimeVal();
                        tv.from_iso8601(item.get_string());
                        var dt = new GLib.DateTime.from_timeval_utc(tv);
                        this.set_property(Object.name_map.get(name), dt);
                        break;
                    // To Resolve as external object
                    case "organization":
                    case "person":
                    case "onBehalfOf":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set(Membership.name_map.get(name)+"_url", item.get_string());
                        break;
                }
            }
        }
    }
}
