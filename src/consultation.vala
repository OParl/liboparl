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
     * A Consultation represents the consultation of a
     * {@link OParl.Paper} in regards of an {@link OParl.AgendaItem}
     */
    public class Consultation : Object {
        private new static HashTable<string,string> name_map;

        /**
         * The function of this consultation.
         *
         * Coud be //hearing// for example.
         */
        public string role {get; internal set;}

        /**
         * If this consultation bears decisive power, the flag shall be true
         */
        public bool authoritative {get; internal set;}

        internal string paper_url {get;set; default="";}
        private bool paper_resolved {get;set; default=false;}
        private Paper? paper_p = null;
        /**
         * Returns paper that this consultation references
         */
        public Paper get_paper() throws ParsingError {
            if (!paper_resolved) {
                var r = new Resolver(this.client);
                this.paper_p = (Paper)r.parse_url(this.paper_url);
                paper_resolved = true;
            }
            return this.paper_p;
        }

        /**
         * Used to internally set the backreference to a paper
         * when it is being parsed as an internal object of
         * a paper
         */
        internal void set_paper(Paper p) {
            paper_resolved = true;
            this.paper_p = p;
        }

        internal string agenda_item_url {get;set; default="";}
        private bool agenda_item_resolved {get;set; default=false;}
        private AgendaItem? agenda_item_p = null;
        /**
         * Returns the agenda item that this consultation references
         */
        public AgendaItem get_agenda_item() throws ParsingError {
            if (!agenda_item_resolved) {
                var r = new Resolver(this.client);
                this.agenda_item_p = (AgendaItem)r.parse_url(this.agenda_item_url);
                agenda_item_resolved = true;
            }
            return this.agenda_item_p;
        }

        internal string meeting_url {get;set; default="";}
        private bool meeting_resolved {get;set; default=false;}
        private Meeting? meeting_p = null;
        /**
         * The meeting that this consultation happen(s/ed) at
         */
        public Meeting get_meeting() throws ParsingError {
            if (!meeting_resolved) {
                var r = new Resolver(this.client);
                this.meeting_p = (Meeting)r.parse_url(this.meeting_url);
                meeting_resolved = true;
            }
            return this.meeting_p;
        }

        internal string[] organization_url {get;set;}
        private bool organization_resolved {get;set; default=false;}
        private List<Organization>? organization_p = null;
        /**
         * The organizations conducting the consultation.
         */
        public unowned List<Organization> get_organization() throws ParsingError {
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

        internal override Body? root_body() throws ParsingError {
            return this.get_meeting().root_body();
        }

        internal new static void populate_name_map() {
            name_map = new GLib.HashTable<string,string>(str_hash, str_equal);
            name_map.insert("paper","paper");
            name_map.insert("agendaItem","agenda_item");
            name_map.insert("meeting","meeting");
            name_map.insert("organization","organization");
            name_map.insert("authoritative","authoritative");
            name_map.insert("role","role");
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
                        if (item.get_value_type() != typeof(string)) {
                            throw new ParsingError.INVALID_TYPE("Attribute '%s' must be a string".printf(name));
                        }
                        this.set(Consultation.name_map.get(name), item.get_string(),null);
                        break;
                    // - booleans
                    case "authoritative":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        if (item.get_value_type() != typeof(bool)) {
                            throw new ParsingError.INVALID_TYPE("Attribute '%s' must be a boolean".printf(name));
                        }
                        this.set_property(Consultation.name_map.get(name), item.get_boolean());
                        break;
                    // To Resolve as array of url
                    case "organization":
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
                                throw new ParsingError.INVALID_TYPE("Element '%s' must be a string".printf(name));
                            }
                            res[i] = element.get_string();
                        }
                        this.set(Consultation.name_map.get(name)+"_url", res);
                        break;
                    case "meeting":
                    case "agendaItem":
                    case "paper":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        if (item.get_value_type() != typeof(string)) {
                            throw new ParsingError.INVALID_TYPE("Attribute '%s' must be a string".printf(name));
                        }
                        this.set(Consultation.name_map.get(name)+"_url", item.get_string());
                        break;
    
                }
            }
        }
    }
}
