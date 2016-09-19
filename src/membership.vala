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
     * Represents the membership of an {@link OParl.Person} in
     * an {@link OParl.Organization}.
     */
    public class Membership : Object {
        private new static HashTable<string,string> name_map;

        /**
         * The role that the {@link OParl.Membership.person}
         * fulfills in {@link OParl.Membership.organization}
         *
         * May be used to distinguish different kinds of membership
         * of the same person in the same organization.
         */
        public string role {get; set;}

        /**
         * If the {@link OParl.Membership.person} has the right
         * to vote on resolutions {@link OParl.AgendaItem}s in {@link OParl.Meeting}s of
         * {@link OParl.Membership.organization}, this flag is true
         */
        public bool voting_right {get; set;}

        /**
         * The date at which the membership commenced
         */
        public GLib.Date start_date {get; set;}

        /**
         * The date at which the membership ended
         */
        public GLib.Date end_date {get; set;}

        internal string person_url {get;set; default="";}
        private bool person_resolved {get;set; default=false;}
        private Person? person_p = null;
        /**
         * The person that this membership concerns
         */
        public Person person {
            get {
                if (!person_resolved) {
                    var r = new Resolver(this.client);
                    this.person_p = (Person)r.parse_url(this.person_url);
                    person_resolved = true;
                }
                return this.person_p;
            }
            internal set {
                person_resolved = true;
                this.person_p = value;
            }
        }

        internal string organization_url {get;set; default="";}
        private bool organization_resolved {get;set; default=false;}
        private Organization? organization_p = null;
        /**
         * The organization that this membership concerns
         */
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

        internal string on_behalf_of_url {get;set; default="";}
        private bool on_behalf_of_resolved {get;set; default=false;}
        private Organization? on_behalf_of_p = null;
        /**
         * If {@link OParl.Membership.person} represents another {@link OParl.Organization}
         * in {@link OParl.Membership.organization}, this field will contain the represented
         * organization.
         */
        public Organization? on_behalf_of {
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
                    case "role":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set(Membership.name_map.get(name), item.get_string(),null);
                        break;
                    // - booleans
                    case "votingRight":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set_property(Membership.name_map.get(name), item.get_boolean());
                        break;
                    // - dates
                    case "startDate":
                    case "endDate":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        var dt = GLib.Date();
                        dt.set_parse(item.get_string());
                        this.set_property(Membership.name_map.get(name), dt);
                        break;
                    // To Resolve as external object
                    case "organization":
                    case "person":
                    case "onBehalfOf":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set(Membership.name_map.get(name)+"_url", item.get_string());
                        break;
                }
            }
        }
    }
}
