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
     * Respresents a legislative body.
     */
    public class Body : Object {
        private new static HashTable<string,string> name_map;

        /**
         * URL to the Website of the body
         */
        public string website {get; set;}

        /**
         * The date and time since the license that is
         * set in {@link OParl.Object.license} is valid.
         */
        public GLib.DateTime license_valid_since {get; set;}

        /**
         * The point in time since this body provides OParl
         *
         * Useful to estimate the quality of the delivered data.
         * As only from the time OParl setup happend, it can be
         * said for sure that all values are present in the
         * original sources.
         */
        public GLib.DateTime oparl_since {get; set;}

        /**
         * 8-digit municipality key. - It's a German thing.
         */
        public string ags {get; set;}

        /**
         * 12-digit regional key. - It's a German thing.
         */
        public string rgs {get; set;}

        /**
         * Additional URLs of websites representing the same
         * body.
         *
         * In here could e.g. be corresponding entries in
         * state libraries or the wikipedia.
         */
        public string[] equivalent {get; set;}

        /**
         * A contact email address.
         *
         * This address should at least provide contact to officials
         * of this body. Ideally it also provides contact to persons
         * responsible for the parliamentarian information system.
         */
        public string contact_email {get; set;}

        /**
         * Name or Idenitifier of the person/office that is descibed
         * in {@link OParl.Body.contact_email}.
         */
        public string contact_name {get; set;}

        /**
         * Type of the body
         */
        public string classification {get; set;}

        internal string organization_url {get;set;}
        private bool organization_resolved {get;set; default=false;}
        private List<Organization>? organization_p = null;
        /**
         * All groups of persons inside this body
         */
        public List<Organization> organization {
            get {
                if (!organization_resolved && organization_url != null) {
                    this.organization_p = new List<Organization>();
                    var pr = new Resolver(this.client, this.organization_url);
                    foreach (Object o in pr.resolve()) {
                        this.organization_p.append((Organization)o);
                    }
                    organization_resolved = true;
                }
                return this.organization_p;
            }
        }

        internal string person_url {get;set;}
        private bool person_resolved {get;set; default=false;}
        private List<Person>? person_p = null;
        /**
         * All persons inside this body
         */
        public List<Person> person {
            get {
                if (!person_resolved && person_url != null) {
                    this.person_p = new List<Person>();
                    var pr = new Resolver(this.client, this.person_url);
                    foreach (Object o in pr.resolve()) {
                        this.person_p.append((Person)o);
                    }
                    person_resolved = true;
                }
                return this.person_p;
            }
        }

        internal string meeting_url {get;set;}
        private bool meeting_resolved {get;set; default=false;}
        private List<Meeting>? meeting_p = null;
        /**
         * All meetings conducted by this body
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

        internal string paper_url {get;set;}
        private bool paper_resolved {get;set; default=false;}
        private List<Paper>? paper_p = null;
        /**
         * All papers ever used by this body
         */
        public List<Paper> paper {
            get {
                if (!paper_resolved && paper_url != null) {
                    this.paper_p = new List<Paper>();
                    var pr = new Resolver(this.client, this.paper_url);
                    foreach (Object o in pr.resolve()) {
                        this.paper_p.append((Paper)o);
                    }
                    paper_resolved = true;
                }
                return this.paper_p;
            }
        }

        private List<LegislativeTerm>? legislative_term_p = new List<LegislativeTerm>();
        /**
         * All legislative terms of this body
         */
        public List<LegislativeTerm> legislative_term {
            get {
                return this.legislative_term_p;
            }
        }

        private Location? location_p = null;
        /**
         * The location that this body officially resides at.
         */
        public Location location {
            get {
                return this.location_p;
            }
        }

        internal string system_url {get;set; default="";}
        private bool system_resolved {get;set; default=false;}
        private System? system_p = null;
        /**
         * The system that this body belongs to
         */
        public System system {
            get {
                if (!system_resolved) {
                    var r = new Resolver(this.client);
                    this.system_p = (System)r.parse_url(this.system_url);
                    system_resolved = true;
                }
                return this.system_p;
            }
        }

        internal override Body? root_body() {
            return this;
        }

        internal new static void populate_name_map() {
            name_map = new GLib.HashTable<string,string>(str_hash, str_equal);
            name_map.insert("system", "system");
            name_map.insert("website", "website");
            name_map.insert("licenseValidSince", "license_valid_since");
            name_map.insert("oparlSince", "oparl_since");
            name_map.insert("ags","ags");
            name_map.insert("rgs","rgs");
            name_map.insert("equivalent","equivalent");
            name_map.insert("contactEmail","contact_email");
            name_map.insert("contactName","contact_name");
            name_map.insert("organization","organization");
            name_map.insert("person","person");
            name_map.insert("meeting","meeting");
            name_map.insert("paper","paper");
            name_map.insert("legislativeTerm","legislative_term");
            name_map.insert("classification","classification");
            name_map.insert("location","location");
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
                    case "website":
                    case "ags":
                    case "rgs":
                    case "contactEmail":
                    case "contactName":
                    case "classification":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set(Body.name_map.get(name), item.get_string(),null);
                        break;
                    // - dates
                    case "licenseValidSince":
                    case "oparlSince":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        var tv = GLib.TimeVal();
                        tv.from_iso8601(item.get_string());
                        var dt = new GLib.DateTime.from_timeval_utc(tv);
                        this.set_property(Body.name_map.get(name), dt);
                        break;
                    // - string[]
                    case "equivalent":
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
                        this.set(Body.name_map.get(name), res);
                        break;
                    // To Resolve as external objectlist
                    case "system":
                    case "organization":
                    case "person":
                    case "meeting":
                    case "paper":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set(Body.name_map.get(name)+"_url", item.get_string());
                        break;
                    // To Resolve as internal objectlist
                    case "legislativeTerm":
                        if (item.get_node_type() != Json.NodeType.ARRAY) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be an array".printf(name));
                        }
                        var r = new Resolver(this.client);
                        foreach (Object term in r.parse_data(item.get_array())) {
                            this.legislative_term_p.append((LegislativeTerm)term);
                        }
                        break;
                    // To resolve as internal object
                    case "location":
                        if (item.get_node_type() != Json.NodeType.OBJECT) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be an object".printf(name));
                        }
                        var r = new Resolver(this.client);
                        this.location_p = (Location)r.make_object(item);
                        break;
                }
            }
        }
    }
}
