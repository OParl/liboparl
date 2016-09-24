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
     * Represent a gathering of one or more {@link OParl.Organization}s
     * at a specific point in time and a specific {@link OParl.Location}
     */
    public class Meeting : Object {
        private new static HashTable<string,string> name_map;

        /**
         * Current state of the meeting.
         *
         * Values may be //planned//, //invitations sent//
         * or //conducted//
         */
        public string meeting_state {get; set;}

        /**
         * If this meeting has been cancelled this field will be set to true
         */
        public bool cancelled {get;set;}

        /**
         * The beginning of this meeting
         *
         * If the meeting is set in the future, this is the planned
         * starting time of the meeting. If the meeting has already
         * been conducted, it ''may be'' the actual starting time.
         */
        public GLib.DateTime start {get; set;}

        /**
         * The end of this meeting
         *
         * If the meeting is set in the future, this is the planned
         * ending time of the meeting. If the meeting has already
         * been conducted, it ''may be'' the actual ending time.
         */
        public GLib.DateTime end {get; set;}
        
        private Location? location_p = new Location();
        /**
         * The location this meeting takes place at.
         */
        public Location location {
            get {
                return this.location_p;
            }
        }

        private File? invitation_p = null;
        /**
         * The invitation that has been sent to prospective attendants
         */
        public File invitation {
            get {
                return this.invitation_p;
            }
        }

        private File? results_protocol_p = null;
        /**
         * A protocol containing the results of the meeting.
         *
         * This is only present after the meeting has been conducted
         */
        public File? results_protocol {
            get {
                return this.results_protocol_p;
            }
        }

        private File? verbatim_protocol_p = null;
        /**
         * A protocol containing a transcript of the speeches given atthe meeting.
         *
         * This is only present after the meeting has been conducted
         */
        public File? verbatim_protocol {
            get {
                return this.verbatim_protocol_p;
            }
        }

        private List<File>? auxiliary_file_p = new List<File>();
        /**
         * Auxiliary files concerning the meeting
         */
        public List<File> auxiliary_file {
            get {
                return this.auxiliary_file_p;
            }
        }

        private List<AgendaItem>? agenda_item_p = new List<AgendaItem>();
        /**
         * A well structured list of topics that are to be discussed
         * or have been discussed.
         */
        public List<AgendaItem> agenda_item {
            get {
                return this.agenda_item_p;
            }
        }

        internal string[] organization_url {get; set; default={};}
        private bool organization_resolved {get;set; default=false;}
        private List<Organization>? organization_p = null;
        /**
         * All organizations that attend the meeting
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

        internal string[] participant_url {get; set; default={};}
        private bool participant_resolved {get;set; default=false;}
        private List<Person>? participant_p = null;
        /**
         * All persons that participate in the meeting
         */
        public unowned List<Person> get_participant() throws ParsingError {
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

        /**
         * Tries to determine which system this object originates from
         *
         * It is to be noted that the OParl system currently does not
         * explicitly specify which system an object originates from when
         * there is more than one backreference inside the object
         */
        internal override Body? root_body() throws ParsingError {
            if (this.get_organization().length() > 0)
                return this.get_organization().nth_data(0).get_body();
            else if (this.get_participant().length() > 0)
                return this.get_participant().nth_data(0).get_body();
            else
                return null;
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
                    case "meetingState":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        if (item.get_value_type() != typeof(string)) {
                            throw new ParsingError.INVALID_TYPE("Attribute '%s' must be a string".printf(name));
                        }
                        this.set(Meeting.name_map.get(name), item.get_string(),null);
                        break;
                    // - booleans
                    case "cancelled":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        if (item.get_value_type() != typeof(bool)) {
                            throw new ParsingError.INVALID_TYPE("Attribute '%s' must be a boolean".printf(name));
                        }
                        this.set_property(Meeting.name_map.get(name), item.get_boolean());
                        break;
                    // - dates
                    case "start":
                    case "end":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        if (item.get_value_type() != typeof(string)) {
                            throw new ParsingError.INVALID_TYPE("Attribute '%s' must be a string".printf(name));
                        }
                        var tv = GLib.TimeVal();
                        tv.from_iso8601(item.get_string());
                        var dt = new GLib.DateTime.from_timeval_utc(tv);
                        this.set_property(Meeting.name_map.get(name), dt);
                        break;
                    // To Resolve as external objectlist
                    case "organization":
                    case "participant":
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
                        this.set(Meeting.name_map.get(name)+"_url", res);
                        break;
                    // To Resolve as internal objectlist
                    case "agendaItem":
                        if (item.get_node_type() != Json.NodeType.ARRAY) {
                            throw new ParsingError.EXPECTED_ARRAY("Attribute '%s' must be an array".printf(name));
                        }
                        var r = new Resolver(this.client);
                        foreach (Object term in r.parse_data(item.get_array())) {
                            this.agenda_item_p.append((AgendaItem)term);
                        }
                        break;
                    case "auxiliaryFile":
                        if (item.get_node_type() != Json.NodeType.ARRAY) {
                            throw new ParsingError.EXPECTED_ARRAY("Attribute '%s' must be an array".printf(name));
                        }
                        var r = new Resolver(this.client);
                        foreach (Object file in r.parse_data(item.get_array())) {
                            this.auxiliary_file_p.append((File)file);
                        }
                        break;
                    // To Resolve as internal object
                    case "location":
                        if (item.get_node_type() != Json.NodeType.OBJECT) {
                            throw new ParsingError.EXPECTED_OBJECT("Attribute '%s' must be an object".printf(name));
                        }
                        var r = new Resolver(this.client);
                        this.location_p = (Location)r.make_object(item);
                        break;
                    case "resultsProtocol":
                        if (item.get_node_type() != Json.NodeType.OBJECT) {
                            throw new ParsingError.EXPECTED_OBJECT("Attribute '%s' must be an object".printf(name));
                        }
                        var r = new Resolver(this.client);
                        this.results_protocol_p = (File)r.make_object(item);
                        break;
                    case "verbatimProtocol":
                        if (item.get_node_type() != Json.NodeType.OBJECT) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be an object".printf(name));
                        }
                        var r = new Resolver(this.client);
                        this.verbatim_protocol_p = (File)r.make_object(item);
                        break;
                    case "invitation":
                        if (item.get_node_type() != Json.NodeType.OBJECT) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be an object".printf(name));
                        }
                        var r = new Resolver(this.client);
                        this.invitation_p = (File)r.make_object(item);
                        break;
                }
            }
        }
    }
}
