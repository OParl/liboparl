/********************************************************************
# Copyright 2014 Daniel 'grindhold' Brendle
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
    public class Body : Object {
        private new static HashTable<string,string> name_map;

        // Directly Resolvable
        public string website {get; set;}
        public GLib.DateTime license_valid_since {get; set;}
        public GLib.DateTime oparl_since {get; set;}
        public string ags {get; set;}
        public string rgs {get; set;}
        public string[] equivalent {get; set;}
        public string contact_email {get; set;}
        public string contact_url {get; set;}
        public string classification {get; set;}

        // Indirectly Resolvable
        public string organization_url {get;set;}
        private bool organization_resolved {get;set; default=false;}
        private List<Organization>? organization_p = null;
        public List<Organization> organization {
            get {
                if (!organization_resolved) {
                    this.organization_p = new List<Organization>();
                    var pr = new PageResolver(this.client, this.organization_url);
                    foreach (Object o in pr.resolve()) {
                        this.organization_p.append((Organization)o);
                    }
                    organization_resolved = true;
                }
                return this.organization_p;
            }
        }

        public string person_url {get;set;}
        private bool person_resolved {get;set; default=false;}
        private List<Person>? person_p = null;
        public List<Person> person {
            get {
                if (!person_resolved) {
                    this.person_p = new List<Person>();
                    var pr = new PageResolver(this.client, this.person_url);
                    foreach (Object o in pr.resolve()) {
                        this.person_p.append((Person)o);
                    }
                    person_resolved = true;
                }
                return this.person_p;
            }
        }

        public string meeting_url {get;set;}
        private bool meeting_resolved {get;set; default=false;}
        private List<Meeting>? meeting_p = null;
        public List<Meeting> meeting {
            get {
                if (!meeting_resolved) {
                    this.meeting_p = new List<Meeting>();
                    var pr = new PageResolver(this.client, this.meeting_url);
                    foreach (Object o in pr.resolve()) {
                        this.meeting_p.append((Meeting)o);
                    }
                    meeting_resolved = true;
                }
                return this.meeting_p;
            }
        }

        public string paper_url {get;set;}
        private bool paper_resolved {get;set; default=false;}
        private List<Paper>? paper_p = null;
        public List<Paper> paper {
            get {
                if (!paper_resolved) {
                    this.paper_p = new List<Paper>();
                    var pr = new PageResolver(this.client, this.paper_url);
                    foreach (Object o in pr.resolve()) {
                        this.paper_p.append((Paper)o);
                    }
                    paper_resolved = true;
                }
                return this.paper_p;
            }
        }

        public string legislative_term_url {get;set;}
        private bool legislative_term_resolved {get;set; default=false;}
        private List<LegislativeTerm>? legislative_term_p = null;
        public List<LegislativeTerm> legislative_term {
            get {
                if (!legislative_term_resolved) {
                    this.legislative_term_p = new List<LegislativeTerm>();
                    var pr = new PageResolver(this.client, this.legislative_term_url);
                    foreach (Object o in pr.resolve()) {
                        this.legislative_term_p.append((LegislativeTerm)o);
                    }
                    legislative_term_resolved = true;
                }
                return this.legislative_term_p;
            }
        }

        private string location_url {get;set; default="";}
        private bool location_resolved {get;set; default=false;}
        private Location? location_p = null;
        public Location location {
            get {
                if (!location_resolved) {
                    // TODO: Resolve
                    location_resolved = true;
                }
                return this.location;
            }
        }

        private string system_url {get;set; default="";}
        private bool system_resolved {get;set; default=false;}
        private System? system_p = null;
        public System system {
            get {
                if (!system_resolved) {
                    // TODO: Resolve
                    system_resolved = true;
                }
                return this.system;
            }
        }

        internal static void populate_name_map() {
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
                    case "website":
                    case "ags":
                    case "rgs":
                    case "contact_email":
                    case "contact_url":
                    case "classification":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set(Body.name_map.get(name), item.get_string(),null);
                        break;
                    // To Resolve as external objectlist
                    case "organization":
                    case "person":
                    case "meeting":
                    case "paper":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set(Body.name_map.get(name)+"_url", item.get_string());
                        break;
                    // To Resolve as internal objectlist
                    case "legislativeTerm":
                        if (item.get_node_type() != Json.NodeType.ARRAY) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be an array".printf(name));
                        }
                        break;
                }
            }
        }
    }
}
/*
    TODO:
        public GLib.DateTime license_valid_since {get; set;}
        public GLib.DateTime oparl_since {get; set;}
        public string[] equivalent {get; set;}
*/
