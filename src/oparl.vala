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
    public errordomain ValidationError {
        EXPECTED_OBJECT,
        EXPECTED_VALUE,
        MISSING_MANDATORY,
        EMPTY_MANDATORY,
        MISSING_OPTIONAL,
        EMPTY_OPTIONAL,
        NO_DATA,
        INVALID_TYPE
    }

    private const uint8 SEVERITY_MEDIUM= 0x1;
    private const uint8 SEVERITY_BAD = 0x2;

    public class Client : GLib.Object {
        private static bool initialized = false;

        public static void init() {
            Object.populate_name_map();
            System.populate_name_map();
            Body.populate_name_map();
            Person.populate_name_map();
            Membership.populate_name_map();
            Meeting.populate_name_map();
            Organization.populate_name_map();
            AgendaItem.populate_name_map();
            Paper.populate_name_map();
            Consultation.populate_name_map();
            LegislativeTerm.populate_name_map();
            File.populate_name_map();
            Location.populate_name_map();
        }

        public System open(string url) {
            if (!Client.initialized)
                Client.init();
            string data = this.resolve_url(url);
            if (data != null) {
                var system = new System();
                var parser = new Json.Parser();
                system.set_client(this);
                parser.load_from_data(data);
                system.parse(parser.get_root());
                return system;
            }
            throw new ValidationError.NO_DATA("You did not supply valid data");
        }

        public signal string? resolve_url (string url);
    }

    /**
     * Resolves an objectlist-URL to a list of OParl.Objects
     */
    private class Resolver {
        private List<Object> result;
        private string? url;
        private Client c;

        public Resolver(Client c, string? url="") {
            this.url = url;
            this.c = c;
            this.result = new List<Object>();
        }

        public unowned List<Object> resolve() {
            string data = this.c.resolve_url(this.url);
            var parser = new Json.Parser();
            parser.load_from_data(data);
            this.parse(parser.get_root());
            return this.result; 
        }

        public Object make_object(Json.Node n) {
            Json.Object el_obj = n.get_object();
            Json.Node type = el_obj.get_member("type");
            if (type.get_node_type() != Json.NodeType.VALUE)
                throw new ValidationError.EXPECTED_VALUE("I need a string-value as type");
            string typestr = type.get_string();
            switch (typestr) {
                case "https://schema.oparl.org/1.0/Body":
                    var target = new Body();
                    target.set_client(this.c);
                    target.parse(n);
                    return target;
                case "https://schema.oparl.org/1.0/AgendaItem":
                    var target = new AgendaItem();
                    target.set_client(this.c);
                    target.parse(n);
                    return target;
                case "https://schema.oparl.org/1.0/Consultation":
                    var target = new Consultation();
                    target.set_client(this.c);
                    target.parse(n);
                    return target;
                case "https://schema.oparl.org/1.0/File":
                    var target = new File();
                    target.set_client(this.c);
                    target.parse(n);
                    return target;
                case "https://schema.oparl.org/1.0/LegislativeTerm":
                    var target = new LegislativeTerm();
                    target.set_client(this.c);
                    target.parse(n);
                    return target;
                case "https://schema.oparl.org/1.0/Location":
                    var target = new Location();
                    target.set_client(this.c);
                    target.parse(n);
                    return target;
                case "https://schema.oparl.org/1.0/Meeting":
                    var target = new Meeting();
                    target.set_client(this.c);
                    target.parse(n);
                    return target;
                case "https://schema.oparl.org/1.0/Membership":
                    var target = new Membership();
                    target.set_client(this.c);
                    target.parse(n);
                    return target;
                case "https://schema.oparl.org/1.0/Organization":
                    var target = new Organization();
                    target.set_client(this.c);
                    target.parse(n);
                    return target;
                case "https://schema.oparl.org/1.0/Paper":
                    var target = new Paper();
                    target.set_client(this.c);
                    target.parse(n);
                    return target;
                case "https://schema.oparl.org/1.0/Person":
                    var target = new Person();
                    target.set_client(this.c);
                    target.parse(n);
                    return target;
                case "https://schema.oparl.org/1.0/System":
                    var target = new System();
                    target.set_client(this.c);
                    target.parse(n);
                    return target;
            }
            throw new ValidationError.INVALID_TYPE("The type of this object is no valid OParl type: %s".printf(typestr));
        }

        public unowned List<Object> parse_data(Json.Array arr) {
            arr.foreach_element((_,i,element) => {
                if (element.get_node_type() != Json.NodeType.OBJECT) {
                    throw new ValidationError.EXPECTED_OBJECT("I need an Object to parse");
                }
                Object target = (Object)make_object(element);
                this.result.append(target);
            });
            return this.result;
        }

        public Object parse_url(string url) {
            string data = this.c.resolve_url(url);
            var parser = new Json.Parser();
            parser.load_from_data(data);
            return (Object)make_object(parser.get_root());
        }


        public unowned List<Object> parse_url_array(string[] urls) {
            foreach(string url in urls) {
                Object target = this.parse_url(url);
                this.result.append(target);
            }
            return this.result;
        }

        private void parse(Json.Node n) {
            if (n.get_node_type() != Json.NodeType.OBJECT)
                throw new ValidationError.EXPECTED_OBJECT("I need an Object to parse");
            
            unowned Json.Object o = n.get_object();

            // Read in Member values
            unowned Json.Node item;
            item = o.get_member("data");
            if (item.get_node_type() != Json.NodeType.ARRAY) {
                throw new ValidationError.EXPECTED_VALUE("Attribute data must be an array");
            }
            this.parse_data(item.get_array());
            item = o.get_member("links");
            if (item.get_node_type() != Json.NodeType.OBJECT) {
                throw new ValidationError.EXPECTED_VALUE("Attribute links must be an object");
            }
            Json.Object links = item.get_object();
            if (links.has_member("next")) {
                string data = this.c.resolve_url(links.get_string_member("next"));
                var parser = new Json.Parser();
                parser.load_from_data(data);
                this.parse(parser.get_root());
            }
        }
    }
}