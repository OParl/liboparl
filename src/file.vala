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
    public class File : Object {
        private new static HashTable<string,string> name_map;

        public string file_name {get; set;}
        public string mime_type {get; set;}
        public GLib.Date date {get; set;}
        public int size {get; set;}
        public string sha1_checksum {get; set;}
        public string text {get; set;}
        public string access_url {get; set;}
        public string download_url {get; set;}
        public string external_service_url {get; set;}
        public string file_license {get; set;}
        
        public string master_file_url {get;set; default="";}
        private bool master_file_resolved {get;set; default=false;}
        private File? master_file_p = null;
        public File master_file {
            get {
                if (!master_file_resolved) {
                    var r = new Resolver(this.client);
                    this.master_file_p = (File)r.parse_url(this.master_file_url);
                    master_file_resolved = true;
                }
                return this.master_file_p;
            }
        }

        protected string[] derivative_file_url {get; set; default={};}
        private bool derivative_file_resolved {get;set; default=false;}
        private List<File>? derivative_file_p = null;
        public List<File> derivative_file {
            get {
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
        }

        protected string[] meeting_url {get; set; default={};}
        private bool meeting_resolved {get;set; default=false;}
        private List<Meeting>? meeting_p = null;
        public List<Meeting> meeting {
            get {
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
        }

        protected string[] agenda_item_url {get; set; default={};}
        private bool agenda_item_resolved {get;set; default=false;}
        private List<AgendaItem>? agenda_item_p = null;
        public List<AgendaItem> agenda_item {
            get {
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
        }

        protected string[] paper_url {get; set; default={};}
        private bool paper_resolved {get;set; default=false;}
        private List<Paper>? paper_p = null;
        public List<Paper> paper {
            get {
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
        }

        internal static void populate_name_map() {
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
                    case "fileName":
                    case "mimeType":
                    case "sha1Checksum":
                    case "text":
                    case "accessUrl":
                    case "downloadUrl":
                    case "externalServiceUrl":
                    case "fileLicense":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set(File.name_map.get(name), item.get_string(),null);
                        break;
                    // - dates
                    case "date":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        var dt = new GLib.Date();
                        dt.set_parse(item.get_string());
                        this.set_property(File.name_map.get(name), dt);
                        break;
                    // - integers
                    case "size":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set_property(File.name_map.get(name), item.get_int());
                        break;
                    // Url
                    case "masterFile":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set(File.name_map.get(name)+"_url", item.get_string());
                        break;
                    case "derivativeFile":
                    case "meeting":
                    case "agendaItem":
                    case "paper":
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
                        this.set(File.name_map.get(name)+"_url", res);
                        break;
                }
            }
        }
    }
}
