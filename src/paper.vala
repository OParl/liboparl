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
     * Represents any kind of written document used in processes
     * described through OParl.
     */
    public class Paper : Object {
        private new static HashTable<string,string> name_map;

        /**
         * Idenitification number of the document.
         */
        public string reference {get;set;}

        /**
         * Type of document
         */
        public string paper_type {get;set;}

        /**
         * Date used as the start for ultimatums e.t.c
         */
        public GLib.Date date {get; set;}

        private File? main_file_p = null;
        /**
         * The file-representation of this document
         *
         * May be ommited if there is no file representing the document
         */
        public File main_file {
            get {
                return this.main_file_p;
            }
        }

        private List<Consultation>? consultation_p = new List<Consultation>();
        /**
         * Consultations in which this document has been discussed.
         */
        public List<Consultation> consultation {
            get {
                return this.consultation_p;
            }
        }


        private List<Location>? location_p = new List<Location>();
        /**
         * If the document has any spatial references this locations descibe them.
         */
        public List<Location> location {
            get {
                return this.location_p;
            }
        }

        private List<File>? auxiliary_file_p = new List<File>();
        /**
         * Related files to the document
         */
        public List<File> auxiliary_file {
            get {
                return this.auxiliary_file_p;
            }
        }

        internal string[] originator_person_url {get;set;}
        private bool originator_person_resolved {get;set; default=false;}
        private List<Person>? originator_person_p = null;
        /**
         * The person(s) that created this document
         */
        public unowned List<Person> get_originator_person() throws ParsingError {
            if (!originator_person_resolved && originator_person_url != null) {
                this.originator_person_p = new List<Person>();
                var pr = new Resolver(this.client);
                foreach (Object o in pr.parse_url_array(this.originator_person_url)) {
                    this.originator_person_p.append((Person)o);
                }
                originator_person_resolved = true;
            }
            return this.originator_person_p;
        }

        internal string[] under_direction_of_url {get;set;}
        private bool under_direction_of_resolved {get;set; default=false;}
        private List<Organization>? under_direction_of_p = null;
        /**
         * Organizations that are responsible for the content
         */
        public unowned List<Organization> get_under_direction_of() throws ParsingError {
            if (!under_direction_of_resolved && under_direction_of_url != null) {
                this.under_direction_of_p = new List<Organization>();
                var pr = new Resolver(this.client);
                foreach (Object o in pr.parse_url_array(this.under_direction_of_url)) {
                    this.under_direction_of_p.append((Organization)o);
                }
                under_direction_of_resolved = true;
            }
            return this.under_direction_of_p;
        }

        internal string[] originator_organization_url {get;set;}
        private bool originator_organization_resolved {get;set; default=false;}
        private List<Organization>? originator_organization_p = null;
        /**
         * If the creator of the document is one or more organization(s), they will be in this field.
         */
        public unowned List<Organization> get_originator_organization() throws ParsingError {
            if (!originator_organization_resolved && originator_organization_url != null) {
                this.originator_organization_p = new List<Organization>();
                var pr = new Resolver(this.client);
                foreach (Object o in pr.parse_url_array(this.originator_organization_url)) {
                    this.originator_organization_p.append((Organization)o);
                }
                originator_organization_resolved = true;
            }
            return this.originator_organization_p;
        }

        internal string[] superordinated_paper_url {get;set;}
        private bool superordinated_paper_resolved {get;set; default=false;}
        private List<Paper>? superordinated_paper_p = null;
        /**
         * Documents to be regarded superordinated to this document.
         */
        public unowned List<Paper> get_superordinated_paper() throws ParsingError {
            if (!superordinated_paper_resolved && superordinated_paper_url != null) {
                this.superordinated_paper_p = new List<Paper>();
                var pr = new Resolver(this.client);
                foreach (Object o in pr.parse_url_array(this.superordinated_paper_url)) {
                    this.superordinated_paper_p.append((Paper)o);
                }
                superordinated_paper_resolved = true;
            }
            return this.superordinated_paper_p;
        }

        internal string[] subordinated_paper_url {get;set;}
        private bool subordinated_paper_resolved {get;set; default=false;}
        private List<Paper>? subordinated_paper_p = null;
        /**
         * Documents to be regarded subordinated to this document.
         */
        public unowned List<Paper> get_subordinated_paper() throws ParsingError {
            if (!subordinated_paper_resolved && subordinated_paper_url != null) {
                this.subordinated_paper_p = new List<Paper>();
                var pr = new Resolver(this.client);
                foreach (Object o in pr.parse_url_array(this.subordinated_paper_url)) {
                    this.subordinated_paper_p.append((Paper)o);
                }
                subordinated_paper_resolved = true;
            }
            return this.subordinated_paper_p;
        }

        public string[] related_paper_url {get;set;}
        private bool related_paper_resolved {get;set; default=false;}
        private List<Paper>? related_paper_p = null;
        /**
         * Related documents.
         */
        public unowned List<Paper> get_related_paper() throws ParsingError {
            if (!related_paper_resolved && related_paper_url != null) {
                this.related_paper_p = new List<Paper>();
                var pr = new Resolver(this.client);
                foreach (Object o in pr.parse_url_array(this.related_paper_url)) {
                    this.related_paper_p.append((Paper)o);
                }
                related_paper_resolved = true;
            }
            return this.related_paper_p;
        }

        internal string body_url {get;set; default="";}
        private bool body_resolved {get;set; default=false;}
        private Body? body_p = null;
        /**
         * The body that this document belongs to
         */
        public Body get_body() throws ParsingError {
            if (!body_resolved) {
                var r = new Resolver(this.client);
                this.body_p = (Body)r.parse_url(this.body_url);
                body_resolved = true;
            }
            return this.body_p;
        }

        internal new static void populate_name_map() {
            name_map = new GLib.HashTable<string,string>(str_hash, str_equal);
            name_map.insert("body","body");
            name_map.insert("reference","reference");
            name_map.insert("date","date");
            name_map.insert("paperType","paper_type");
            name_map.insert("relatedPaper","related_paper");
            name_map.insert("subordinatedPaper","subordinated_paper");
            name_map.insert("superordinatedPaper","superordinated_paper");
            name_map.insert("mainFile","main_file");
            name_map.insert("auxiliaryFile","auxiliary_file");
            name_map.insert("location","location");
            name_map.insert("originatorPerson","originator_person");
            name_map.insert("underDirectionOf","under_direction_of");
            name_map.insert("originatorOrganization","originator_organization");
            name_map.insert("consultation","consultation");
        }

        internal override Body? root_body() {
            return this.get_body();
        }

        internal new void parse(Json.Node n) throws ParsingError{
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
                    case "reference":
                    case "paperType":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set(Paper.name_map.get(name), item.get_string(),null);
                        break;
                    // - dates
                    case "date":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        var dt = GLib.Date();
                        dt.set_parse(item.get_string());
                        this.set_property(Paper.name_map.get(name), dt);
                        break;
                    // To Resolve as external objectlist
                    case "relatedPaper":
                    case "subordinatedPaper":
                    case "superordinatedPaper":
                    case "originatorPerson":
                    case "underDirectionOf":
                    case "originatorOrganization":
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
                        this.set(Paper.name_map.get(name)+"_url", res);
                        break;
                    // To Resolve as internal objectlist
                    case "auxiliaryFile":
                        if (item.get_node_type() != Json.NodeType.ARRAY) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be an array".printf(name));
                        }
                        var r = new Resolver(this.client);
                        foreach (Object af in r.parse_data(item.get_array())) {
                            this.auxiliary_file_p.append((File)af);
                        }
                        break;
                    case "consultation":
                        if (item.get_node_type() != Json.NodeType.ARRAY) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be an array".printf(name));
                        }
                        var r = new Resolver(this.client);
                        foreach (Object cons in r.parse_data(item.get_array())) {
                            (cons as Consultation).set_paper(this);
                            this.consultation_p.append((Consultation)cons);
                        }
                        break;
                    case "location":
                        if (item.get_node_type() != Json.NodeType.ARRAY) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be an array".printf(name));
                        }
                        var r = new Resolver(this.client);
                        foreach (Object loc in r.parse_data(item.get_array())) {
                            this.location_p.append((Location)loc);
                        }
                        break;
                    // To resolve as internal object
                    case "mainFile":
                        if (item.get_node_type() != Json.NodeType.OBJECT) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be an object".printf(name));
                        }
                        var r = new Resolver(this.client);
                        this.main_file_p = (File)r.make_object(item);
                        break;
                    case "body":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set(Paper.name_map.get(name)+"_url", item.get_string());
                        break;
    
                }
            }
        }
    }
}
