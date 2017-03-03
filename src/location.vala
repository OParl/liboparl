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

namespace OParl {
    /**
     * Represents physical locations.
     */
    public class Location : EmbeddedObject, Parsable {
        private new static HashTable<string,string> name_map;

        /**
         * Textual description of the location
         */
        public string description {get; internal set;}

        /**
         * Represents the location through spatial data in the
         * geojson format.
         */
        public Json.Object geojson {get; internal set;}

        /**
         * Street and house number of the address
         */
        public string street_address {get; internal set;}

        /**
         * Room number if the addressed house has such.
         */
        public string room {get; internal set;}

        /**
         * Postal code of the address
         */
        public string postal_code {get; internal set;}

        /**
         * Sub-part of the locality e.g. district
         */
        public string sub_locality {get; internal set;}

        /**
         * The locality
         */
        public string locality {get; internal set;}

        internal string[] bodies_url {get; set; default={};}
        private bool bodies_resolved {get;set; default=false;}
        private List<Body>? bodies_p = null;
        /**
         * Backreferences to bodies
         */
        public unowned List<Body> get_bodies() throws ParsingError {
            lock (bodies_resolved) {
                if (!bodies_resolved && bodies_url != null) {
                    this.autoload();

                    this.bodies_p = new List<Body>();
                    var pr = new Resolver(this.client);
                    foreach (Object o in pr.parse_url_array(this.bodies_url)) {
                        this.bodies_p.append((Body)o);
                    }
                    bodies_resolved = true;
                }
            }
            return this.bodies_p;
        }

        internal string[] organizations_url {get; set; default={};}
        private bool organizations_resolved {get;set; default=false;}
        private List<Organization>? organizations_p = null;
        /**
         * Backreferences to organizations
         */
        public unowned List<Organization> get_organizations() throws ParsingError {
            lock (organizations_resolved) {
                if (!organizations_resolved && organizations_url != null) {
                    this.autoload();

                    this.organizations_p = new List<Organization>();
                    var pr = new Resolver(this.client);
                    foreach (Object o in pr.parse_url_array(this.organizations_url)) {
                        this.organizations_p.append((Organization)o);
                    }
                    organizations_resolved = true;
                }
            }
            return this.organizations_p;
        }

        internal string[] meetings_url {get; set; default={};}
        private bool meetings_resolved {get;set; default=false;}
        private List<Meeting>? meetings_p = null;
        /**
         * Backreferences to meetings
         */
        public unowned List<Meeting> get_meetings() throws ParsingError {
            lock (meetings_resolved) {
                if (!meetings_resolved && meetings_url != null) {
                    this.autoload();

                    this.meetings_p = new List<Meeting>();
                    var pr = new Resolver(this.client);
                    foreach (Object o in pr.parse_url_array(this.meetings_url)) {
                        this.meetings_p.append((Meeting)o);
                    }
                    meetings_resolved = true;
                }
            }
            return this.meetings_p;
        }

        internal string[] papers_url {get; set; default={};}
        private bool papers_resolved {get;set; default=false;}
        private List<Paper>? papers_p = null;
        /**
         * Backreferences to papers
         */
        public unowned List<Paper> get_papers() throws ParsingError {
            lock (papers_resolved) {
                if (!papers_resolved && papers_url != null) {
                    this.autoload();

                    this.papers_p = new List<Paper>();
                    var pr = new Resolver(this.client);
                    foreach (Object o in pr.parse_url_array(this.papers_url)) {
                        this.papers_p.append((Paper)o);
                    }
                    papers_resolved = true;
                }
            }
            return this.papers_p;
        }

        internal override Body? root_body() throws ParsingError {
            if (this.get_bodies().length() > 0) {
                return this.get_bodies().nth_data(0).root_body();
            } else if (this.get_organizations().length() > 0) {
                return this.get_organizations().nth_data(0).root_body();
            } else if (this.get_meetings().length() > 0) {
                return this.get_meetings().nth_data(0).root_body();
            } else if (this.get_papers().length() > 0) {
                return this.get_papers().nth_data(0).root_body();
            }  else {
                return null;
            }
        }

        internal new static void populate_name_map() {
            name_map = new GLib.HashTable<string,string>(str_hash, str_equal);
            name_map.insert("description", "description");
            name_map.insert("geojson", "geojson");
            name_map.insert("streetAddress", "street_address");
            name_map.insert("room", "room");
            name_map.insert("postalCode", "postal_code");
            name_map.insert("subLocality", "sub_locality");
            name_map.insert("locality", "locality");
            name_map.insert("bodies", "bodies");
            name_map.insert("organizations", "organizations");
            name_map.insert("meetings", "meetings");
            name_map.insert("papers", "papers");
        }

        internal new void parse(Json.Node n) throws ParsingError {
            base.parse(this, n);
            if (n.get_node_type() != Json.NodeType.OBJECT)
                throw new ParsingError.EXPECTED_ROOT_OBJECT("I need an Object to parse");
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
                        this.parse_string(this, name, item, Location.name_map);
                        break;
                    // Array of url
                    case "bodies":
                    case "organizations":
                    case "meetings":
                    case "papers":
                        this.parse_external_list(this, name, item, Location.name_map);
                        break;
                    // Json object
                    case "geojson":
                        if (item.get_node_type() != Json.NodeType.OBJECT) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a object in '%s'".printf(name, this.id));
                        }
                        this.set(Location.name_map.get(name), item.get_object());
                        break;
                }
            }
        }

        /**
         * {@inheritDoc}
         */
        public new List<OParl.Object> get_neighbors() throws ParsingError {
            var l = new List<OParl.Object>();


            foreach (Body b in this.get_bodies()) {
                l.append(b);
            }

            foreach (Meeting m in this.get_meetings()) {
                l.append(m);
            }

            foreach (Organization o in this.get_organizations()) {
                l.append(o);
            }

            foreach (Paper p in this.get_papers()) {
                l.append(p);
            }

            return l;
        }
    }
}
