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
    public class Location : Object {
        private new static HashTable<string,string> name_map;

        public string description {get; set;}
        public Json.Object geojson {get; set;}
        public string street_address {get; set;}
        public string room {get; set;}
        public string postal_code {get; set;}
        public string sub_locality {get; set;}
        public string locality {get; set;}

        private string[] bodies_url {get; set; default={};}
        private bool bodies_resolved {get;set; default=false;}
        private List<Body>? bodies_p = null;
        public List<Body> bodies {
            get {
                if (!bodies_resolved && bodies_url != null) {
                    this.bodies_p = new List<Body>();
                    var pr = new Resolver(this.client);
                    foreach (Object o in pr.parse_url_array(this.bodies_url)) {
                        this.bodies_p.append((Body)o);
                    }
                    bodies_resolved = true;
                }
                return this.bodies_p;
            }
        }

        private string[] organization_url {get; set; default={};}
        private bool organization_resolved {get;set; default=false;}
        private List<Organization>? organization_p = null;
        public List<Organization> organization {
            get {
                if (!organization_resolved && organization_url != null) {
                    this.organization_p = new List<Organization>();
                    var pr = new Resolver(this.client);
                    foreach (Object o in pr.parse_url_array(this.organization_url)) {
                        this.organization_p.append((Organization)o);
                    }
                    organization_resolved = true;
                }
                return this.organization_p;
            }
        }

        private string[] meetings_url {get; set; default={};}
        private bool meetings_resolved {get;set; default=false;}
        private List<Meeting>? meetings_p = null;
        public List<Meeting> meetings {
            get {
                if (!meetings_resolved && meetings_url != null) {
                    this.meetings_p = new List<Meeting>();
                    var pr = new Resolver(this.client);
                    foreach (Object o in pr.parse_url_array(this.meetings_url)) {
                        this.meetings_p.append((Meeting)o);
                    }
                    meetings_resolved = true;
                }
                return this.meetings_p;
            }
        }

        private string[] papers_url {get; set; default={};}
        private bool papers_resolved {get;set; default=false;}
        private List<Paper>? papers_p = null;
        public List<Paper> papers {
            get {
                if (!papers_resolved && papers_url != null) {
                    this.papers_p = new List<Paper>();
                    var pr = new Resolver(this.client);
                    foreach (Object o in pr.parse_url_array(this.papers_url)) {
                        this.papers_p.append((Paper)o);
                    }
                    papers_resolved = true;
                }
                return this.papers_p;
            }
        }

        internal static void populate_name_map() {
            name_map = new GLib.HashTable<string,string>(str_hash, str_equal);
            name_map.insert("description", "description");
            name_map.insert("geojson", "geojson");
            name_map.insert("streetAddress", "street_address");
            name_map.insert("room", "room");
            name_map.insert("postalCode", "postal_code");
            name_map.insert("subLocality", "sub_locality");
            name_map.insert("locality", "locality");
            name_map.insert("bodies", "bodies");
            name_map.insert("organization", "organization");
            name_map.insert("meetings", "meetings");
            name_map.insert("papers", "papers");
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
                    case "description":
                    case "streetAddress":
                    case "room":
                    case "postalCode":
                    case "subLocality":
                    case "locality":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set(Location.name_map.get(name), item.get_string(),null);
                        break;
                    // Array of url
                    case "bodies":
                    case "organization":
                    case "meetings":
                    case "papers":
                        if (item.get_node_type() != Json.NodeType.ARRAY) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a array".printf(name));
                        }
                        var arr = item.get_array();
                        var res = new string[arr.get_length()];
                        arr.foreach_element((_,i,element) => {
                            if (element.get_node_type() != Json.NodeType.VALUE) {
                                GLib.warning("Omitted array-element in '%s' because it was no Json-Value".printf(name));
                                return;
                            }
                            res[i] = element.get_string();
                        });
                        this.set(Location.name_map.get(name)+"_url", res);
                        break;
                    // Json object
                    case "geojson":
                        if (item.get_node_type() != Json.NodeType.OBJECT) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a object".printf(name));
                        }
                        this.set(Location.name_map.get(name), item.get_object());
                        break;
                }
            }
        }
    }
}