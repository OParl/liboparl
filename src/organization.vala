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
     * Used to map groups of people that have a functional role inside
     * a body. This may e.g. be fractions or committees
     */
    public class Organization : Object, Parsable {
        private new static HashTable<string,string> name_map;

        /**
         * Positions that this organization is destined to.
         */
        public string[] post {get; internal set;}

        /**
         * Rough categorisation of this organization.
         *
         * Values may be "commitee", "party", "fraction"
         * or similar. "miscellaneous" is also an option
         */
        public string organization_type {get; internal set;}

        /**
         * URL to a website of the organization
         */
        public string website {get; internal set;}

        /**
         * More fine-grained  categorisation of this
         * organization.
         */
        public string classification {get; internal set;}

        /**
         * The date on which this organization was founded
         */
        public GLib.DateTime start_date {get; internal set;}

        /**
         * The date on which this organization ceased to exist
         */
        public GLib.DateTime end_date {get; internal set;}

        internal string body_url {get;set; default="";}
        private bool body_resolved {get;set; default=false;}
        private Body? body_p = null;
        /**
         * The body that this organization belongs to.
         */
        public Body get_body() throws ParsingError {
            if (!body_resolved) {
                var r = new Resolver(this.client);
                if (this.body_url != "")
                    this.body_p = (Body)r.parse_url(this.body_url);
                else
                    warning("Organization without body url: %s", this.id);
                body_resolved = true;
            }
            return this.body_p;
        }

        internal string external_body_url {get;set; default="";}
        private bool external_body_resolved {get;set; default=false;}
        private Body? external_body_p = null;
        /**
         * An external OParl body that also represents this organization
         *
         * Links to an external OParl-System.
         */
        public Body? get_external_body() throws ParsingError {
            if (!external_body_resolved) {
                var r = new Resolver(this.client);
                if (this.external_body_url != "")
                    this.external_body_p = (Body)r.parse_url(this.external_body_url);
                external_body_resolved = true;
            }
            return this.external_body_p;
        }

        internal string sub_organization_of_url {get;set; default="";}
        private bool sub_organization_of_resolved {get;set; default=false;}
        private Organization? sub_organization_of_p = null;
        /**
         * Returns the organization that is superordinated to this
         * organization
         */
        public Organization? get_sub_organization_of() throws ParsingError {
            if (!sub_organization_of_resolved) {
                var r = new Resolver(this.client);
                if (this.sub_organization_of_url != "")
                    this.sub_organization_of_p = (Organization)r.parse_url(this.sub_organization_of_url);
                sub_organization_of_resolved = true;
            }
            return this.sub_organization_of_p;
        }

        internal string[] membership_url {get; set; default={};}
        private bool membership_resolved {get;set; default=false;}
        private List<Membership>? membership_p = null;
        /**
         * All memberships that are known for this organization
         */
        public unowned List<Membership> get_membership() throws ParsingError {
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
        public unowned List<Meeting> get_meeting() throws ParsingError {
            if (!meeting_resolved && meeting_url != null) {
                this.meeting_p = new List<Meeting>();
                if (this.meeting_url != "") {
                    var pr = new Resolver(this.client, this.meeting_url);
                    foreach (Object o in pr.resolve()) {
                        this.meeting_p.append((Meeting)o);
                    }
                } else {
                    warning("Organization without meeting url: %s", this.id);
                }
                meeting_resolved = true;
            }
            return this.meeting_p;
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

        internal override Body? root_body() throws ParsingError {
            return this.get_body();
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
                    case "organizationType":
                    case "website":
                    case "classification":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        if (item.get_value_type() != typeof(string)) {
                            throw new ParsingError.INVALID_TYPE("Attribute '%s' must be a string".printf(name));
                        }
                        this.set(Organization.name_map.get(name), item.get_string(),null);
                        break;
                    // - string[]
                    case "post":
                        if (item.get_node_type() != Json.NodeType.ARRAY) {
                            throw new ParsingError.EXPECTED_ARRAY("Attribute '%s' must be an array".printf(name));
                        }
                        Json.Array arr = item.get_array();
                        string[] res = new string[arr.get_length()];
                        for (int i = 0; i < arr.get_length(); i++) {
                            var element = arr.get_element(i);
                            if (element.get_node_type() != Json.NodeType.VALUE) {
                                throw new ParsingError.EXPECTED_VALUE("Element of '%s' must be a value".printf(name));
                            }
                            if (element.get_value_type() != typeof(string)) {
                                throw new ParsingError.INVALID_TYPE("Element of '%s' must be a string".printf(name));
                            }
                            res[i] = element.get_string();
                        }
                        this.set(Organization.name_map.get(name), res);
                        break;
                    // - dates
                    case "startDate":
                    case "endDate":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        if (item.get_value_type() != typeof(string)) {
                            throw new ParsingError.INVALID_TYPE("Attribute '%s' must be a string".printf(name));
                        }
                        var tv = GLib.TimeVal();
                        tv.from_iso8601(item.get_string()+"T00:00:00+00:00");
                        var dt = new GLib.DateTime.from_timeval_utc(tv);
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
                        if (item.get_value_type() != typeof(string)) {
                            throw new ParsingError.INVALID_TYPE("Attribute '%s' must be a string".printf(name));
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
                        for (int i = 0; i < arr.get_length(); i++) {
                            var element = arr.get_element(i);
                            if (element.get_node_type() != Json.NodeType.VALUE) {
                                throw new ParsingError.EXPECTED_VALUE("Element of '%s' must be a value".printf(name));
                            }
                            if (element.get_value_type() != typeof(string)) {
                                throw new ParsingError.INVALID_TYPE("Element of '%s' must be a string".printf(name));
                            }
                            res[i] = element.get_string();
                        }
                        this.set(Organization.name_map.get(name)+"_url", res);
                        break;
                }
            }
        }

        /**
         * See {@link Object.validation}
         */
        public new unowned List<ValidationResult> validate() {
            base.validate();
            if (this.start_date.compare(this.end_date) > 0) {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.INFO,
                               "Invalid period",
                               "The startDate must be an earlier date than the endDate",
                               this.id
                ));
            }
            return this.validation_results;
        }

        /**
         * {@inheritDoc}
         */
        public new List<OParl.Object> get_neighbors() throws ParsingError {
            var l = new List<OParl.Object>();

            var body = this.get_body();
            if (body != null) {
                l.append(body);
            }

            foreach (Membership m in this.get_membership()) {
                l.append(m);
            }

            foreach (Meeting m in this.get_meeting()) {
                l.append(m);
            }

            var parentOrg = this.get_sub_organization_of();
            if (parentOrg != null) {
                l.append(parentOrg);
            }

            var location = this.location;
            if (location != null) {
                l.append(location);
            }

            return l;
        }
    }
}
