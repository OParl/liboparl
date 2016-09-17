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
    public class Consultation : Object {
        private new static HashTable<string,string> name_map;

        public string role {get; set;}
        public bool authoritative {get; set;}

        private string paper_url {get;set; default="";}
        private bool paper_resolved {get;set; default=false;}
        private Paper? paper_p = null;
        public Paper paper {
            get {
                if (!paper_resolved) {
                    var r = new Resolver(this.client);
                    this.paper_p = (Paper)r.parse_url(this.paper_url);
                    paper_resolved = true;
                }
                return this.paper_p;
            }
        }

        protected string agenda_item_url {get;set; default="";}
        private bool agenda_item_resolved {get;set; default=false;}
        private AgendaItem? agenda_item_p = null;
        public AgendaItem agenda_item {
            get {
                if (!agenda_item_resolved) {
                    var r = new Resolver(this.client);
                    this.agenda_item_p = (AgendaItem)r.parse_url(this.agenda_item_url);
                    agenda_item_resolved = true;
                }
                return this.agenda_item_p;
            }
        }

        protected string meeting_url {get;set; default="";}
        private bool meeting_resolved {get;set; default=false;}
        private Meeting? meeting_p = null;
        public Meeting meeting {
            get {
                if (!meeting_resolved) {
                    var r = new Resolver(this.client);
                    this.meeting_p = (Meeting)r.parse_url(this.meeting_url);
                    meeting_resolved = true;
                }
                return this.meeting_p;
            }
        }

        public string[] organization_url {get;set;}
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

        internal static void populate_name_map() {
            name_map = new GLib.HashTable<string,string>(str_hash, str_equal);
            name_map.insert("paper","paper");
            name_map.insert("agendaItem","agenda_item");
            name_map.insert("meeting","meeting");
            name_map.insert("organization","organization");
            name_map.insert("authoritative","authoritative");
            name_map.insert("role","role");
        }

        public new void parse(Json.Node n) throws ValidationError {
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
                        this.set(Consultation.name_map.get(name), item.get_string(),null);
                        break;
                    // - booleans
                    case "authoritative":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set_property(Consultation.name_map.get(name), item.get_boolean());
                        break;
                    // To Resolve as array of url
                    case "organization":
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
                        this.set(Consultation.name_map.get(name)+"_url", res);
                        break;
                    case "meeting":
                    case "agendaItem":
                    case "paper":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set(Consultation.name_map.get(name)+"_url", item.get_string());
                        break;
    
                }
            }
        }
    }
}
