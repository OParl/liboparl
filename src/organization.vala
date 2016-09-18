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
     * Used to map groups of people that have a functional role inside
     * a body. This may e.g. be fractions or committees
     */
    public class Organization : Object {
        private new static HashTable<string,string> name_map;

        /**
         * Positions that this organization is destined to.
         */
        public string[] post {get; set;}

        /**
         * Rough categorisation of this organization.
         *
         * Values may be "commitee", "party", "fraction"
         * or similar. "miscellaneous" is also an option
         */
        public string organization_type {get; set;}

        /**
         * URL to a website of the organization
         */
        public string website {get; set;}

        /**
         * More fine-grained  categorisation of this
         * organization.
         */
        public string classification {get; set;}

        /**
         * The date on which this organization was founded
         */
        public GLib.Date start_date {get; set;}

        /**
         * The date on which this organization ceased to exist
         */
        public GLib.Date end_date {get; set;}

        internal string body_url {get;set; default="";}
        private bool body_resolved {get;set; default=false;}
        private Body? body_p = null;
        /**
         * The body that this organization belongs to.
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

        internal string external_body_url {get;set; default="";}
        private bool external_body_resolved {get;set; default=false;}
        private Body? external_body_p = null;
        /**
         * An external OParl body that also represents this organization
         *
         * Links to an external OParl-System.
         */
        public Body external_body {
            get {
                if (!external_body_resolved) {
                    var r = new Resolver(this.client);
                    this.external_body_p = (Body)r.parse_url(this.external_body_url);
                    external_body_resolved = true;
                }
                return this.external_body_p;
            }
        }

        internal string sub_organization_of_url {get;set; default="";}
        private bool sub_organization_of_resolved {get;set; default=false;}
        private Organization? sub_organization_of_p = null;
        /**
         * Returns the organization that is superordinated to this
         * organization
         */
        public Organization sub_organization_of {
            get {
                if (!sub_organization_of_resolved) {
                    var r = new Resolver(this.client);
                    this.sub_organization_of_p = (Organization)r.parse_url(this.sub_organization_of_url);
                    sub_organization_of_resolved = true;
                }
                return this.sub_organization_of_p;
            }
        }

        internal string[] membership_url {get; set; default={};}
        private bool membership_resolved {get;set; default=false;}
        private List<Membership>? membership_p = null;
        /**
         * All memberships that are known for this organization
         */
        public List<Membership> membership {
            get {
                if (!membership_resolved && membership_url != null) {
                    this.membership_p = new List<Membership>();
                    var pr = new Resolver(this.client);
                    foreach (Object o in pr.parse_url_array(this.membership_url)) {
                        this.membership_p.append((Membership)o);
                    }
                    membership_resolved = true;
                }
                return this.membership_p;
            }
        }

        private Location? location_p = null;
        /**
         * The location that this organization resides at.
         */
        public Location location {
            get {
                return this.location_p;
            }
        }

        internal string meeting_url {get;set;}
        private bool meeting_resolved {get;set; default=false;}
        private List<Meeting>? meeting_p = null;
        /**
         * All meetings that this organization participated in
         */
        public List<Meeting> meeting {
            get {
                if (!meeting_resolved && meeting_url != null) {
                    this.meeting_p = new List<Meeting>();
                    var pr = new Resolver(this.client, this.meeting_url);
                    foreach (Object o in pr.resolve()) {
                        this.meeting_p.append((Meeting)o);
                    }
                    meeting_resolved = true;
                }
                return this.meeting_p;
            }
        }

        internal new static void populate_name_map() {
            name_map = new GLib.HashTable<string,string>(str_hash, str_equal);
            name_map.insert("body", "body");
            name_map.insert("membership", "membership");
            name_map.insert("meeting", "meeting");
            name_map.insert("post", "post");
            name_map.insert("subOrganizationOf", "sub_organization_of");
            name_map.insert("organizationType", "organization_type");
            name_map.insert("classification", "classification");
            name_map.insert("startDate", "start_date");
            name_map.insert("endDate", "end_date");
            name_map.insert("website", "website");
            name_map.insert("location", "location");
            name_map.insert("externalBody", "external_body");
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
                    // - strings
                    case "organizationType":
                    case "website":
                    case "classification":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set(Organization.name_map.get(name), item.get_string(),null);
                        break;
                    // - string[]
                    case "post":
                        if (item.get_node_type() != Json.NodeType.ARRAY) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be an array".printf(name));
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
                        this.set(Organization.name_map.get(name), res);
                        break;
                    // - dates
                    case "startDate":
                    case "endDate":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        var dt = new GLib.Date();
                        dt.set_parse(item.get_string());
                        this.set_property(Organization.name_map.get(name), dt);
                        break;
                    // To Resolve as external objectlist
                    case "meeting":
                    case "body":
                    case "subOrganizationOf":
                    case "externalBody":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set(Organization.name_map.get(name)+"_url", item.get_string());
                        break;
                    // To Resolve as internal object
                    case "location":
                        if (item.get_node_type() != Json.NodeType.OBJECT) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be an object".printf(name));
                        }
                        var r = new Resolver(this.client);
                        this.location_p = (Location)r.make_object(item);
                        break;
                    // Array of url
                    case "membership":
                        if (item.get_node_type() != Json.NodeType.ARRAY) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a array".printf(name));
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
                        this.set(Organization.name_map.get(name)+"_url", res);
                        break;
                }
            }
        }
    }
}
