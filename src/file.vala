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
     * Represents a file, e.g. a PDF, RTF or ODF-file and holds a set
     * of metadata as well as URLs to access the file.
     */
    public class File : Object {
        private new static HashTable<string,string> name_map;

        /**
         * The name that this file uses in a filesystem.
         *
         * This field is ''mandatory''
         */
        public string file_name {get; internal set;}

        /**
         * The mime-type of the file
         */
        public string mime_type {get; internal set;}

        /**
         * Date used for ultimatums e.t.c
         */
        public GLib.Date date {get; internal set;}

        /**
         * Size of the file in bytes
         */
        public int size {get; internal set;}

        /**
         * The sha1sum of the file
         */
        public string sha1_checksum {get; internal set;}

        /**
         * If it is feasible, this contains a plain-text representation of
         * the contents of the file.
         */
        public string text {get; internal set;}

        /**
         * URL to access the file
         */
        public string access_url {get; internal set;}

        /**
         * URL to download the file
         */
        public string download_url {get; internal set;}

        /**
         * External URL providing additional access possibilites
         *
         * Could be for example a link to a video streaming platform
         */
        public string external_service_url {get; internal set;}

        /**
         * The license the file is published under
         */
        public string file_license {get; internal set;}

        internal string master_file_url {get;set; default="";}
        private bool master_file_resolved {get;set; default=false;}
        private File? master_file_p = null;
        /**
         * The file that was used to derive this file from.
         */
        public File? get_master_file() throws ParsingError {
            if (!master_file_resolved) {
                var r = new Resolver(this.client);
                this.master_file_p = (File)r.parse_url(this.master_file_url);
                master_file_resolved = true;
            }
            return this.master_file_p;
        }

        internal string[] derivative_file_url {get; set; default={};}
        private bool derivative_file_resolved {get;set; default=false;}
        private List<File>? derivative_file_p = null;
        /**
         * Files that have been derived from this file.
         */
        public unowned List<File> get_derivative_file() throws ParsingError {
            if (!derivative_file_resolved && derivative_file_url != null) {
                this.derivative_file_p = new List<File>();
                var pr = new Resolver(this.client);
                foreach (Object o in pr.parse_url_array(this.derivative_file_url)) {
                    this.derivative_file_p.append((File)o);
                }
                derivative_file_resolved = true;
            }
            return this.derivative_file_p;
        }

        internal string[] meeting_url {get; set; default={};}
        private bool meeting_resolved {get;set; default=false;}
        private List<Meeting>? meeting_p = null;
        /**
         * Backreferences to meeting object
         *
         * This field if only set if the file was embedded in a {@link OParl.Meeting}
         */
        public unowned List<Meeting> get_meeting() throws ParsingError {
            if (!meeting_resolved && meeting_url != null) {
                this.meeting_p = new List<Meeting>();
                var pr = new Resolver(this.client);
                foreach (Object o in pr.parse_url_array(this.meeting_url)) {
                    this.meeting_p.append((Meeting)o);
                }
                meeting_resolved = true;
            }
            return this.meeting_p;
        }

        internal string[] agenda_item_url {get; set; default={};}
        private bool agenda_item_resolved {get;set; default=false;}
        private List<AgendaItem>? agenda_item_p = null;
        /**
         * Backreferences to agenda item object
         *
         * This field if only set if the file was embedded in a {@link OParl.AgendaItem}
         */
        public unowned List<AgendaItem> get_agenda_item() throws ParsingError {
            if (!agenda_item_resolved && agenda_item_url != null) {
                this.agenda_item_p = new List<AgendaItem>();
                var pr = new Resolver(this.client);
                foreach (Object o in pr.parse_url_array(this.agenda_item_url)) {
                    this.agenda_item_p.append((AgendaItem)o);
                }
                agenda_item_resolved = true;
            }
            return this.agenda_item_p;
        }

        internal string[] paper_url {get; set; default={};}
        private bool paper_resolved {get;set; default=false;}
        private List<Paper>? paper_p = null;
        /**
         * Backreferences to paper object
         *
         * This field if only set if the file was embedded in a {@link OParl.Paper}
         */
        public unowned List<Paper> get_paper() throws ParsingError {
            if (!paper_resolved && paper_url != null) {
                this.paper_p = new List<Paper>();
                var pr = new Resolver(this.client);
                foreach (Object o in pr.parse_url_array(this.paper_url)) {
                    this.paper_p.append((Paper)o);
                }
                paper_resolved = true;
            }
            return this.paper_p;
        }

        internal override Body? root_body() throws ParsingError {
            if (this.get_paper().length() > 0) {
                return this.get_paper().nth_data(0).root_body();
            } else if (this.get_meeting().length() > 0) {
                return this.get_meeting().nth_data(0).root_body();
            } else if (this.get_agenda_item().length() > 0) {
                return this.get_agenda_item().nth_data(0).root_body();
            } else {
                return null;
            }
        }

        internal new static void populate_name_map() {
            name_map = new GLib.HashTable<string,string>(str_hash, str_equal);
            name_map.insert("fileName", "file_name");
            name_map.insert("mimeType", "mime_type");
            name_map.insert("date", "date");
            name_map.insert("size", "size");
            name_map.insert("sha1Checksum", "sha1_checksum");
            name_map.insert("text", "text");
            name_map.insert("accessUrl", "access_url");
            name_map.insert("downloadUrl", "download_url");
            name_map.insert("externalServiceUrl", "external_service_url");
            name_map.insert("masterFile", "master_file");
            name_map.insert("derivativeFile", "derivative_file");
            name_map.insert("fileLicense", "file_license");
            name_map.insert("meeting", "meeting");
            name_map.insert("agendaItem", "agenda_item");
            name_map.insert("paper", "paper");
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
                    case "fileName":
                    case "mimeType":
                    case "sha1Checksum":
                    case "text":
                    case "accessUrl":
                    case "downloadUrl":
                    case "externalServiceUrl":
                    case "fileLicense":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        if (item.get_value_type() != typeof(string)) {
                            throw new ParsingError.INVALID_TYPE("Attribute '%s' must be a string".printf(name));
                        }
                        this.set(File.name_map.get(name), item.get_string(),null);
                        break;
                    // - dates
                    case "date":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        if (item.get_value_type() != typeof(string)) {
                            throw new ParsingError.INVALID_TYPE("Attribute '%s' must be a string".printf(name));
                        }
                        var dt = GLib.Date();
                        dt.set_parse(item.get_string());
                        this.set_property(File.name_map.get(name), dt);
                        break;
                    // - integers
                    case "size":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        if (item.get_value_type() != typeof(int64)) {
                            throw new ParsingError.INVALID_TYPE("Attribute '%s' must be an integer".printf(name));
                        }
                        this.set_property(File.name_map.get(name), item.get_int());
                        break;
                    // Url
                    case "masterFile":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        if (item.get_value_type() != typeof(string)) {
                            throw new ParsingError.INVALID_TYPE("Attribute '%s' must be a string".printf(name));
                        }
                        this.set(File.name_map.get(name)+"_url", item.get_string());
                        break;
                    case "derivativeFile":
                    case "meeting":
                    case "agendaItem":
                    case "paper":
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
                        this.set(File.name_map.get(name)+"_url", res);
                        break;
                }
            }
        }

        /**
         * See {@link Object.validation}
         */
        public new unowned List<ValidationResult> validate() {
            base.validate();
            if (this.access_url == null) {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.ERROR,
                               "Missing 'accessUrl' field",
                               "The 'accessUrl'-field must be present in each File",
                               this.id
                ));
            }
            if (this.access_url == "") {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.ERROR,
                               "Empty 'accessUrl'",
                               "The 'accessUrl'-field contains an empty string. Each File must "+
                               " supply an URL to access its contents.",
                               this.id
                ));
            }
            return this.validation_results;
        }
    }
}
