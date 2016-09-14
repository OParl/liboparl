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
    public class System : OParl.Object {
        private new static HashTable<string,string> name_map;

        public string oparl_version {get;set;}
        public string other_oparl_versions {get;set;}
        public string contact_email {get;set;}
        public string contact_name {get;set;}
        public string website {get;set;}
        public string vendor {get;set;}
        public string product {get;set;}

        public string body_url {get;set;}
        private bool body_resolved {get;set; default=false;}
        private List<Body>? body_p = null;
        public List<Body>? body {
            get {
                if (!body_resolved) {
                    this.body_p = new List<Body>();
                    var pr = new Resolver(this.client, this.body_url);
                    foreach (Object o in pr.resolve()) {
                        this.body_p.append((Body)o);
                    }
                    body_resolved = true;
                }
                return this.body_p;
            }
        }
    
        internal static void populate_name_map() {
            name_map = new GLib.HashTable<string,string>(str_hash, str_equal);
            name_map.insert("oparlVersion", "oparl_version");
            name_map.insert("otherOparlVersions", "other_oparl_versions");
            name_map.insert("contactEmail", "contact_email");
            name_map.insert("contactName", "contact_name");
            name_map.insert("website", "website");
            name_map.insert("vendor", "vendor");
            name_map.insert("product", "product");
            name_map.insert("body", "body");
        }

        public System() {
            base();
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
                    case "oparlVersion": 
                    case "otherOparlVersion":
                    case "contactEmail": 
                    case "contactName": 
                    case "website": 
                    case "vendor": 
                    case "product": 
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        this.set(System.name_map.get(name), item.get_string(),null);
                        break;
                    // To Resolve
                    case "body":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be an array".printf(name));
                        }
                        this.set(System.name_map.get(name)+"_url", item.get_string());
                        break;
                }
            }
        }
    }
}
