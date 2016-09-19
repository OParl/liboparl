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

/**
 * OParl
 *
 * The library that equips you with anything you need to acces RIS systems.
 *
 * This library implements the OParl specification in version 1.0. OParl
 * is the definition of JSON-endpoints that provide their users with
 * valuable data about political decision-making processes.
 *
 * Specification [PLAIN]: [[https://oparl.org/wp-content/themes/oparl/spec/OParl-1.0.txt]]
 * Specification [PDF]: [[https://oparl.org/wp-content/themes/oparl/spec/OParl-1.0.pdf]]
 */
namespace OParl {
    /**
     * Syntactical errors that may occur when parsing an {@link OParl.Object}
     */
    public errordomain ParsingError {
        EXPECTED_OBJECT,
        EXPECTED_VALUE,
        NO_DATA,
        INVALID_TYPE
    }

    /**
     * Represents severities of semantical errors / artefacts that do not conform with
     * the OParl 1.0 specification
     */
    public enum ErrorSeverity {
        WARNING,
        ERROR
    }

    /**
     * Represents a semantical inconsistency errors/warnings that may occur in an {@link OParl.Object}
     */
    public class ValidationResult {
        public ErrorSeverity severity {get; internal set; default=ErrorSeverity.WARNING;}
        public string description {get; internal set; default="";}
        public string long_description {get; internal set; default="";}
        public string object_id {get; internal set; default="";}

        private ValidationResult(ErrorSeverity s, string desc, string longdesc, string id) {
            this.severity = s;
            this.description = desc;
            this.long_description = longdesc;
            this.object_id = id;
        }
    }

    private const uint8 SEVERITY_MEDIUM= 0x1;
    private const uint8 SEVERITY_BAD = 0x2;

    /**
     * The programmer's entrypoint into OParl endpoints
     *
     * When you want to start to work with OParl endpoints, the first
     * thing that you do is creating a client. From here on you can
     * retrieve your first {@link OParl.System}-Object. From this
     * object you can explore all other objects simply by following
     * the relations.
     */
    public class Client : GLib.Object {
        private static bool initialized = false;

        private static void init() {
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

        /**
         * Opens a connection to a new OParl-endpoint and yields
         * it as an {@link OParl.System} Object.
         *
         * The url you pass to the method must be the URL of a valid
         * OParl endpoint.
         */
        public System open(string url) throws ParsingError {
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
            throw new ParsingError.NO_DATA("You did not supply valid data");
        }

        /**
         * This signal is being triggered anytime an OParl.Client must resolve a url.
         *
         * It's up to you, to connect to this singal and implement it. Otherwise OParl
         * will have no data to operate on.
         * As this library is introspectable, it can potentially be used in many
         * programming languages. Any of those have their own best-practice patterns
         * and various methods of resolving an url by placing a HTTP request. In order
         * to not limit you as a programmer and not pull in dependencies by relying on
         * one single library, we let you decide how to handle HTTP requests in the
         * application.
         * Please be aware that liboparl likes to be feeded with nice unicode-strings.
         */
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

        public unowned List<Object> resolve() throws ParsingError {
            string data = this.c.resolve_url(this.url);
            var parser = new Json.Parser();
            parser.load_from_data(data);
            this.parse(parser.get_root());
            return this.result; 
        }

        public Object make_object(Json.Node n) throws ParsingError {
            Json.Object el_obj = n.get_object();
            Json.Node type = el_obj.get_member("type");
            if (type.get_node_type() != Json.NodeType.VALUE)
                throw new ParsingError.EXPECTED_VALUE("I need a string-value as type");
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
            throw new ParsingError.INVALID_TYPE("The type of this object is no valid OParl type: %s".printf(typestr));
        }

        public unowned List<Object> parse_data(Json.Array arr) throws ParsingError {
            arr.foreach_element((_,i,element) => {
                if (element.get_node_type() != Json.NodeType.OBJECT) {
                    throw new ParsingError.EXPECTED_OBJECT("I need an Object to parse");
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

        private void parse(Json.Node n) throws ParsingError {
            if (n.get_node_type() != Json.NodeType.OBJECT)
                throw new ParsingError.EXPECTED_OBJECT("I need an Object to parse");
            
            unowned Json.Object o = n.get_object();

            // Read in Member values
            unowned Json.Node item;
            item = o.get_member("data");
            if (item.get_node_type() != Json.NodeType.ARRAY) {
                throw new ParsingError.EXPECTED_VALUE("Attribute data must be an array");
            }
            this.parse_data(item.get_array());
            item = o.get_member("links");
            if (item.get_node_type() != Json.NodeType.OBJECT) {
                throw new ParsingError.EXPECTED_VALUE("Attribute links must be an object");
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
