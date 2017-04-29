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
     * A Consultation represents the consultation of a
     * {@link OParl.Paper} in regards of an {@link OParl.AgendaItem}
     */
    public class Consultation : EmbeddedObject, Parsable {
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
            lock (paper_resolved) {
                if (!paper_resolved) {
                    this.autoload();

                    var r = new Resolver(this.client);
                    if (this.paper_url != "")
                        this.paper_p = (Paper)r.parse_url(this.paper_url);
                    else
                        warning(_("Consultation has no paper: %s"), id);
                    paper_resolved = true;
                }
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
            lock (agenda_item_resolved) {
                if (!agenda_item_resolved) {
                    this.autoload();

                    var r = new Resolver(this.client);
                    if (this.agenda_item_url != "")
                        this.agenda_item_p = (AgendaItem)r.parse_url(this.agenda_item_url);
                    else
                        warning(_("Consultation without paper url: %s"), this.id);
                    agenda_item_resolved = true;
                }
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
            lock (meeting_resolved) {
                if (!meeting_resolved) {
                    this.autoload();

                    var r = new Resolver(this.client);
                    if (this.meeting_url != "")
                        this.meeting_p = (Meeting)r.parse_url(this.meeting_url);
                    else
                        warning(_("Consultation without meeting url: %s"), this.id);
                    meeting_resolved = true;
                }
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
            lock (organization_resolved) {
                if (!organization_resolved && organization_url != null) {
                    this.autoload();

                    this.organization_p = new List<Organization>();
                    var pr = new Resolver(this.client);
                    foreach (Object o in pr.parse_url_array(this.organization_url)) {
                        this.organization_p.append((Organization)o);
                    }
                    organization_resolved = true;
                }
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
                throw new ParsingError.EXPECTED_ROOT_OBJECT(_("I need an Object to parse"));
            unowned Json.Object o = n.get_object();

            // Read in Member values
            foreach (unowned string name in o.get_members()) {
                unowned Json.Node item = o.get_member(name);
                switch(name) {
                    // Direct Read-In
                    // - strings
                    case "role":
                        this.parse_string(this, name, item, Consultation.name_map);
                        break;
                    // - booleans
                    case "authoritative":
                        this.parse_bool(this, name, item, Consultation.name_map);
                        break;
                    // To Resolve as array of url
                    case "organization":
                        this.parse_external_list(this, name, item, Consultation.name_map);
                        break;
                    case "meeting":
                    case "agendaItem":
                    case "paper":
                        this.parse_external(this, name, item, Consultation.name_map);
                        break;
                }
            }
        }

        /**
         * {@inheritDoc}
         */
        public override List<OParl.Object> get_neighbors() throws ParsingError {
            var l = new List<OParl.Object>();

            var paper = this.get_paper();
            if (paper != null) {
                l.append(paper);
            }

            var agenda_item = this.get_agenda_item();
            if (agenda_item != null) {
                l.append(agenda_item);
            }

            var meeting = this.get_meeting();
            if (meeting != null) {
                l.append(meeting);
            }

            foreach (Organization o in this.get_organization()) {
                l.append(o);
            }

            return l;
        }
    }
}
