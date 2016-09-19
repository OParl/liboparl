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
     * A specific topic to be discussed in a {@link OParl.Meeting}
     *
     * Agenda items are components of Meetings. Each agenda item deals
     * with a specific topic. Discussing this topic usually involves
     * working through several {@link OParl.Paper}s. The link between a
     * {@link OParl.Paper} and an agenda item is expressed throug
     * a {@link OParl.Consultation}
     */
    public class AgendaItem : Object {
        private new static HashTable<string,string> name_map;

        /**
         * Ordering number of this AgendaItem
         *
         * Be aware that the actual ordering from a developers view
         * is determined by the order of the objects in {@link OParl.Meeting.agenda_item}
         */
        public string number {get; set;}

        /**
         * Determines wheter this agenda item is to be discussed in public
         */
        public bool @public {get; set;}

        /**
         * Categorical information on which result the Consultations yielded
         *
         * Could be something like "accepted", "accepted with changes", "rejected"
         * "postponed" or similar stati.
         */
        public string result {get; set;}

        /**
         * More fine-grained text about how the agenda items resolution has been made.
         */
        public string resolution_text {get; set;}

        /**
         * Point-in-time when the discussion of this agenda item started
         *
         * Depending on wheter the agenda item is planned to happen in the
         * future or is designated to have happened in the past, this respectively
         * represents the //planned// start or ''could'' contain the actual
         * start.
         */
        public GLib.DateTime start {get; set;}

        /**
         * Point-in-time when the discussion of this agenda item ended
         *
         * Depending on wheter the agenda item is planned to happen in the
         * future or is designated to have happened in the past, this respectively
         * represents the //planned// end or ''could'' contain the actual
         * end.
         */
        public GLib.DateTime end {get; set;}

        private List<File>? auxiliary_file_p = new List<File>();
        /**
         * Miscellaneous files concerning this agenda item
         */
        public List<File> auxiliary_file {
            get {
                return this.auxiliary_file_p;
            }
        }

        private File? resolution_file_p = null;
        /**
         * A file representing the resolution
         */
        public File resolution_file {
            get {
                return this.resolution_file_p;
            }
        }

        internal string meeting_url {get;set; default="";}
        private bool meeting_resolved {get;set; default=false;}
        private Meeting? meeting_p = null;
        /**
         * The meeting this agenda item is discussed in
         */
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

        internal string consultation_url {get;set; default="";}
        private bool consultation_resolved {get;set; default=false;}
        private Consultation? consultation_p = null;
        /**
         * Represents all consulting that has been done in order
         * to make a resolution to this agenda item.
         */
        public Consultation consultation {
            get {
                if (!consultation_resolved) {
                    var r = new Resolver(this.client);
                    this.consultation_p = (Consultation)r.parse_url(this.consultation_url);
                    consultation_resolved = true;
                }
                return this.consultation_p;
            }
        }

        internal new static void populate_name_map() {
            name_map = new GLib.HashTable<string,string>(str_hash, str_equal);
            name_map.insert("meeting","meeting");
            name_map.insert("number","number");
            name_map.insert("public","public");
            name_map.insert("consultation","consultation");
            name_map.insert("result","result");
            name_map.insert("resolutionText","resolution_text");
            name_map.insert("resolutionFile","resolution_file");
            name_map.insert("auxiliaryFile","auxiliary_file");
            name_map.insert("start","start");
            name_map.insert("end","end");
        }

        internal override Body? root_body() {
            return this.meeting.root_body();
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
                    case "result":
                    case "resolutionText":
                    case "number":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set(AgendaItem.name_map.get(name), item.get_string(),null);
                        break;
                    // - booleans
                    case "public":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set_property(AgendaItem.name_map.get(name), item.get_boolean());
                        break;
                    // - dates
                    case "start":
                    case "end":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        var tv = GLib.TimeVal();
                        tv.from_iso8601(item.get_string());
                        var dt = new GLib.DateTime.from_timeval_utc(tv);
                        this.set_property(AgendaItem.name_map.get(name), dt);
                        break;
                    // To Resolve as external object/objectlist
                    case "meeting":
                    case "consultation":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set(AgendaItem.name_map.get(name)+"_url", item.get_string());
                        break;
                    // To Resolve as internal objectlist
                    case "auxiliaryFile":
                        if (item.get_node_type() != Json.NodeType.ARRAY) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be an array".printf(name));
                        }
                        var r = new Resolver(this.client);
                        foreach (Object term in r.parse_data(item.get_array())) {
                            this.auxiliary_file_p.append((File)term);
                        }
                        break;
                    // To resolve as internal object
                    case "resolutionFile":
                        if (item.get_node_type() != Json.NodeType.OBJECT) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be an object".printf(name));
                        }
                        var r = new Resolver(this.client);
                        this.resolution_file_p = (File)r.make_object(item);
                        break;
                }
            }
        }
    }
}
