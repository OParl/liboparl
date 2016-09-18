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
    public class Object : GLib.Object {
        public static HashTable<string,string> name_map;
        // Direct Read-In
        public string id {get; protected set;}
        public string name {get; protected set;}
        public string? short_name {get; protected set; default=null;}
        public string license {get; protected set;}
        public GLib.DateTime created {get; protected set;}
        public GLib.DateTime modified {get; protected set;}
        public string[] keyword {get; protected set;}
        public string web {get; protected set;}
        public bool deleted {get; protected set;}

        internal Client client;


        public virtual void set_client(Client c) {
            this.client = c;
        }

        internal static void populate_name_map() {
            name_map = new HashTable<string,string>(str_hash, str_equal);
            name_map.insert("id","id");
            name_map.insert("name","name");
            name_map.insert("shortName","short_name");
            name_map.insert("license","license");
            name_map.insert("created","created");
            name_map.insert("modified","modified");
            name_map.insert("keyword","keyword");
            name_map.insert("web","web");
            name_map.insert("deleted","deleted");
        }

        internal virtual void parse(Object target, Json.Node n) throws ValidationError {
            // Prepare object
            if (n.get_node_type() != Json.NodeType.OBJECT)
                throw new ValidationError.EXPECTED_OBJECT("I need an Object to parse");
            unowned Json.Object o = n.get_object();

            // Read in Member values
            foreach (unowned string name in o.get_members()) {
                unowned Json.Node item = o.get_member(name);
                switch(name) {
                    // Direct Read-in
                    // - strings
                    case "id": 
                    case "name":
                    case "shortName":
                    case "license": 
                    case "web":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        target.set(Object.name_map.get(name), item.get_string(),null);
                        break;
                    // - string[]
                    case "keyword":
                        if (item.get_node_type() != Json.NodeType.ARRAY) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be an array".printf(name));
                        }
                        Json.Array arr = item.get_array();
                        string[] res = new string[arr.get_length()];
                        item.get_array().foreach_element((_,i,element) => {
                            if (element.get_node_type() != Json.NodeType.VALUE) {
                                GLib.warning("Omitted array-element in '%s' because it was no Json-Value".printf(name));
                                return;
                            }
                            res[i] = element.get_string();
                        });
                        this.set(Object.name_map.get(name), res);
                        break;
                    // - dates
                    case "created":
                    case "modified":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        var tv = new GLib.TimeVal();
                        tv.from_iso8601(item.get_string());
                        var dt = new GLib.DateTime.from_timeval_utc(tv);
                        target.set_property(Object.name_map.get(name), dt);
                        break;
                    // - booleans
                    case "deleted":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        target.set_property(Object.name_map.get(name), item.get_boolean());
                        break;
                    default:
                        break;
                }
            }
        }

        public virtual void validate() {
            uint8 error_severity = 0x0;
            GLib.Value v = new GLib.Value(typeof(string));
            string[] mandatories = {"id", "name", "license", "keyword"};
            foreach (string name in mandatories) {
                this.get_property(name, ref v);
                if (v.get_string() ==  null) {
                    GLib.warning("Mandatory field %s must not be null!", name);
                    error_severity |= SEVERITY_BAD;
                } else if (v.get_string() == "") {
                    GLib.warning("Mandatory field %s must not be empty!", name);
                    error_severity |= SEVERITY_BAD;
                }
            }
            string[] optionals =  {"shortName"};
            foreach (string name in optionals) {
                this.get_property(name, ref v);
                if (v.get_string() ==  null) {
                    GLib.warning("Optional field %s must should not be null!", name);
                    error_severity |= SEVERITY_MEDIUM;
                } else if (v.get_string() == "") {
                    GLib.warning("Optional field %s must should not be empty!", name);
                    error_severity |= SEVERITY_MEDIUM;
                }
            }
        } 
    }
}
