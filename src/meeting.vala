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
    public class Meeting : Object {
        private new static HashTable<string,string> name_map;

        public string meeting_state {get; set;}
        public bool cancelled {get;set;}
        public GLib.DateTime start {get; set;}
        public GLib.DateTime end {get; set;}
        

        private Location? location_p = null;
        public Location location {
            get {
                return this.location_p;
            }
        }

        private string invitation_url {get;set; default="";}
        private bool invitation_resolved {get;set; default=false;}
        private File? invitation_p = null;
        public File invitation {
            get {
                if (!invitation_resolved) {
                    // TODO: Resolve
                    invitation_resolved = true;
                }
                return this.invitation;
            }
        }

        private string results_protocol_url {get;set; default="";}
        private bool results_protocol_resolved {get;set; default=false;}
        private File? results_protocol_p = null;
        public File results_protocol {
            get {
                if (!results_protocol_resolved) {
                    // TODO: Resolve
                    results_protocol_resolved = true;
                }
                return this.results_protocol;
            }
        }

        private string verbatim_protocol_url {get;set; default="";}
        private bool verbatim_protocol_resolved {get;set; default=false;}
        private File? verbatim_protocol_p = null;
        public File verbatim_protocol {
            get {
                if (!verbatim_protocol_resolved) {
                    // TODO: Resolve
                    verbatim_protocol_resolved = true;
                }
                return this.verbatim_protocol;
            }
        }

        private List<File>? auxiliary_file_p = new List<File>();
        public List<File> auxiliary_file {
            get {
                return this.auxiliary_file_p;
            }
        }

        private List<AgendaItem>? agenda_item_p = new List<AgendaItem>();
        public List<AgendaItem> agenda_item {
            get {
                return this.agenda_item_p;
            }
        }

        private string[] organization_url {get; set; default={};}
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

        private string[] participant_url {get; set; default={};}
        private bool participant_resolved {get;set; default=false;}
        private List<Person>? participant_p = null;
        public List<Person> participant {
            get {
                if (!participant_resolved && participant_url != null) {
                    this.participant_p = new List<Person>();
                    var pr = new Resolver(this.client);
                    foreach (Object o in pr.parse_url_array(this.participant_url)) {
                        this.participant_p.append((Person)o);
                    }
                    participant_resolved = true;
                }
                return this.participant_p;
            }
        }

        internal new static void populate_name_map() {
            name_map = new GLib.HashTable<string,string>(str_hash, str_equal);
            name_map.insert("meetingState", "meeting_state");
            name_map.insert("cancelled", "cancelled");
            name_map.insert("start", "start");
            name_map.insert("end", "end");
            name_map.insert("location", "location");
            name_map.insert("organization", "organization");
            name_map.insert("participant", "participant");
            name_map.insert("invitation", "invitation");
            name_map.insert("resultsProtocol", "results_protocol");
            name_map.insert("verbatimProtocol", "verbatim_protocol");
            name_map.insert("auxiliaryFile", "auxiliary_file");
            name_map.insert("agendaItem", "agenda_item");
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
                    // - strings
                    case "meetingState":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set(Meeting.name_map.get(name), item.get_string(),null);
                        break;
                    // - booleans
                    case "cancelled":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set_property(Meeting.name_map.get(name), item.get_boolean());
                        break;
                    // - dates
                    case "start":
                    case "end":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        var tv = new GLib.TimeVal();
                        tv.from_iso8601(item.get_string());
                        var dt = new GLib.DateTime.from_timeval_utc(tv);
                        this.set_property(Meeting.name_map.get(name), dt);
                        break;
                    // To Resolve as external objectlist
                    case "organization":
                    case "participant":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set(Meeting.name_map.get(name)+"_url", item.get_string());
                        break;
                    // To Resolve as internal objectlist
                    case "agendaItem":
                        if (item.get_node_type() != Json.NodeType.ARRAY) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be an array".printf(name));
                        }
                        var r = new Resolver(this.client);
                        foreach (Object term in r.parse_data(item.get_array())) {
                            this.agenda_item_p.append((AgendaItem)term);
                        }
                        break;
                    // To Resolve as internal object
                    case "location":
                        if (item.get_node_type() != Json.NodeType.OBJECT) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be an object".printf(name));
                        }
                        var r = new Resolver(this.client);
                        this.set(Meeting.name_map.get(name)+"_p", (Location)r.make_object(item));
                        break;
                    case "resultsProtocol":
                    case "verbatimProtocol":
                    case "invitation":
                        if (item.get_node_type() != Json.NodeType.OBJECT) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be an object".printf(name));
                        }
                        var r = new Resolver(this.client);
                        this.set(Meeting.name_map.get(name)+"_p", (File)r.make_object(item));
                        break;
                }
            }
        }
    }
}
