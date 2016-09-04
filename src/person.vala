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
    public class Person : Object {
        private new static HashTable<string,string> name_map;

        public string family_name {get; set;}
        public string given_name {get; set;}
        public string form_of_address {get; set;}
        public string affix {get; set;}
        public string[] title {get; set;}
        public string gender {get; set;}
        public string phone {get; set;}
        public string email {get; set;}
        public string[] status {get; set;}
        public string life {get; set;}
        public string life_source {get; set;}

        public string location_url {get;set; default="";}
        private bool location_resolved {get;set; default=false;}
        private Location? location_p = null;
        public Location location {
            get {
                if (!location_resolved) {
                    // TODO: Resolve
                    location_resolved = true;
                }
                return this.location;
            }
        }

        public string body_url {get;set; default="";}
        private bool body_resolved {get;set; default=false;}
        private Body? body_p = null;
        public Body body {
            get {
                if (!body_resolved) {
                    // TODO: Resolve
                    body_resolved = true;
                }
                return this.body;
            }
        }

        private List<Membership>? membership_p = new List<Membership>();
        public List<Membership> membership {
            get {
                return this.membership_p;
            }
        }

        internal static void populate_name_map() {
            name_map = new GLib.HashTable<string,string>(str_hash, str_equal);
            name_map.insert("familyName", "family_name");
            name_map.insert("givenName", "given_name");
            name_map.insert("formOfAddress", "form_of_address");
            name_map.insert("affix", "affix");
            name_map.insert("title", "title");
            name_map.insert("gender", "gender");
            name_map.insert("phone", "phone");
            name_map.insert("email", "email");
            name_map.insert("status", "status");
            name_map.insert("life", "life");
            name_map.insert("lifeSource", "life_source");
            name_map.insert("location", "location");
            name_map.insert("body", "body");
            name_map.insert("membership", "membership");
        }

        public new void parse(Json.Node n) {
        }
    }
}
