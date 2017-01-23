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
     * Any natural person that does parliamentary work and is a member
     * of an {@link OParl.Organization} will be represented as a Person.
     */
    public class Person : Object, Parsable {
        private new static HashTable<string,string> name_map;

        /**
         * The person's family name
         */
        public string family_name {get; internal set;}

        /**
         * The person's given name
         */
        public string given_name {get; internal set;}

        /**
         * Determines how the person is to be addressed
         */
        public string form_of_address {get; internal set;}

        /**
         * Affix to be printed behind the name
         */
        public string affix {get; internal set;}

        /**
         * Academic titles
         */
        public string[] title {get; internal set;}

        /**
         * The gender of this person.
         *
         * If the gender of a person is unknown, it will likely be omitted
         */
        public string gender {get; internal set;}

        /**
         * Public phone numbers of the person
         */
        public string[] phone {get; internal set;}

        /**
         * Contact email addresses of the person
         */
        public string[] email {get; internal set;}

        /**
         * Stati / roles that the person fulfills in the municipality
         */
        public string[] status {get; internal set;}

        /**
         * A short biography / infotext regarding the person.
         *
         * You can expect this text to be maximum ~300 characters long.
         */
        public string life {get; internal set;}

        /**
         * Hints to where the information about the person's {@link OParl.Person.life} come from.
         */
        public string life_source {get; internal set;}

        internal string location_url {get;set; default="";}
        private bool location_resolved {get;set; default=false;}
        private Location? location_p = null;
        /**
         * The contact address of this Person
         */
        public Location get_location() throws ParsingError {
            if (!location_resolved) {
                var r = new Resolver(this.client);
                this.location_p = (Location)r.parse_url(this.location_url);
                location_resolved = true;
            }
            return this.location_p;
        }

        internal string body_url {get;set; default="";}
        private bool body_resolved {get;set; default=false;}
        private Body? body_p = null;
        /**
         * The body that this person belongs to
         */
        public Body get_body() throws ParsingError {
            if (!body_resolved) {
                var r = new Resolver(this.client);
                this.body_p = (Body)r.parse_url(this.body_url);
                body_resolved = true;
            }
            return this.body_p;
        }

        private List<Membership>? membership_p = new List<Membership>();
        /**
         * All memberships that this person has.
         */
        public List<Membership> membership {
            get {
                return this.membership_p;
            }
        }

        internal new static void populate_name_map() {
            name_map = new GLib.HashTable<string,string>(str_hash, str_equal);
            name_map.insert("familyName", "family_name");
            name_map.insert("givenName", "given_name");
            name_map.insert("formOfAddress", "form_of_address");
            name_map.insert("affix", "affix");
            name_map.insert("title", "title");
            name_map.insert("gender", "gender");
            name_map.insert("phone", "phone");
            name_map.insert("email", "email");
            name_map.insert("status", "status");
            name_map.insert("life", "life");
            name_map.insert("lifeSource", "life_source");
            name_map.insert("location", "location");
            name_map.insert("body", "body");
            name_map.insert("membership", "membership");
        }

        /**
         * Resolves the body this person orginiates from
         */
        internal override Body? root_body() throws ParsingError {
            return this.get_body();
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
                    case "familyName":
                    case "givenName":
                    case "formOfAddress":
                    case "affix":
                    case "gender":
                    case "life":
                    case "lifeSource":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        if (item.get_value_type() != typeof(string)) {
                            throw new ParsingError.INVALID_TYPE("Attribute '%s' must be a string".printf(name));
                        }
                        this.set(Person.name_map.get(name), item.get_string(),null);
                        break;
                    // - string[]
                    case "title":
                    case "phone":
                    case "email":
                    case "status":
                        if (item.get_node_type() != Json.NodeType.ARRAY) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be an array".printf(name));
                        }
                        Json.Array arr = item.get_array();
                        string[] res = new string[arr.get_length()];
                        for (int i = 0; i < arr.get_length(); i++ ) {
                            var element = arr.get_element(i);
                            if (element.get_node_type() != Json.NodeType.VALUE) {
                                throw new ParsingError.EXPECTED_VALUE("Element of '%s' must be a value".printf(name));
                            }
                            if (element.get_value_type() != typeof(string)) {
                                throw new ParsingError.INVALID_TYPE("Element of '%s' must be a string".printf(name));
                            }
                            res[i] = element.get_string();
                        }
                        this.set(Person.name_map.get(name), res);
                        break;
                    // To Resolve as external objectlist
                    case "body":
                    case "location":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        if (item.get_value_type() != typeof(string)) {
                            throw new ParsingError.INVALID_TYPE("Attribute '%s' must be a string".printf(name));
                        }
                        this.set(Person.name_map.get(name)+"_url", item.get_string());
                        break;
                    // To Resolve as internal objectlist
                    case "membership":
                        if (item.get_node_type() != Json.NodeType.ARRAY) {
                            throw new ParsingError.EXPECTED_ARRAY("Attribute '%s' must be an array".printf(name));
                        }
                        var r = new Resolver(this.client);
                        foreach (Object memb in r.parse_data(item.get_array())) {
                            (memb as Membership).set_person(this);
                            this.membership_p.append((Membership)memb);
                        }
                        break;
                }
            }
        }

        /**
         * {@inheritDoc}
         */
        public new List<OParl.Object> get_neighbors() throws ParsingError {
            var l = new List<OParl.Object>();

            var body = this.get_body();
            l.append(body);

            var location = this.get_location();
            l.append(location);

            foreach (Membership m in this.membership) {
                l.append(m);
            }

            return l;
        }
    }
}
