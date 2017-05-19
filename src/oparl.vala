/********************************************************************
# Copyright 2016-2017 Daniel 'grindhold' Brendle
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
    [CCode (cname="GETTEXT_PACKAGE")]
    const string GETTEXT_PACKAGE = "liboparl";

    /**
     * Syntactical errors that may occur when parsing an {@link OParl.Object}
     */
    public errordomain ParsingError {
        EXPECTED_OBJECT,
        EXPECTED_ROOT_OBJECT,
        EXPECTED_ARRAY,
        EXPECTED_VALUE,
        NO_DATA,
        INVALID_TYPE,
        INVALID_JSON,
        URL_NULL,
        URL_LOOP
    }

    /**
     * Represents severities of semantical errors / artefacts that do not conform with
     * the OParl 1.0 specification
     */
    public enum ErrorSeverity {
        INFO, // Nice to have
        WARNING, // Does not fulfill recommended
        ERROR // Violates the specification
    }

    /**
     * Represents a semantical inconsistency errors/warnings that may occur in an {@link OParl.Object}
     */
    public class ValidationResult : GLib.Object {
        public ErrorSeverity severity {get; internal set; default=ErrorSeverity.WARNING;}
        public string description {get; internal set; default="";}
        public string long_description {get; internal set; default="";}
        public string object_id {get; internal set; default="";}

        internal ValidationResult(ErrorSeverity s, string desc, string longdesc, string id) {
            this.severity = s;
            this.description = desc;
            this.long_description = longdesc;
            this.object_id = id;
        }
    }

    /**
     * An OParl object that has a method to unmarshall a JSON-representation
     * of itself
     */
    public interface Parsable {
        internal abstract void parse (Json.Node n) throws ParsingError;
    }

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
            Intl.setlocale(LocaleCategory.MESSAGES, "");
            Intl.textdomain(GETTEXT_PACKAGE);
            Intl.bind_textdomain_codeset(GETTEXT_PACKAGE, "utf-8");
            Intl.bindtextdomain(GETTEXT_PACKAGE, "/usr/local/share/locale");

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

            // These calls are needed to register the types of
            // every object-type against the glib type system.
            Type t = typeof(Object);
            t = typeof(Body);
            t = typeof(AgendaItem);
            t = typeof(Body);
            t = typeof(Consultation);
            t = typeof(File);
            t = typeof(LegislativeTerm);
            t = typeof(Location);
            t = typeof(Meeting);
            t = typeof(Membership);
            t = typeof(Organization);
            t = typeof(Paper);
            t = typeof(Person);
            t = typeof(System);
            Client.initialized = true;
        }

        public bool strict {get; set; default=true;}

        public string oparl_version { get; protected set; default="https://schema.oparl.org/1.0/"; }

        /**
         * Opens a connection to a new OParl-endpoint and yields
         * it as an {@link OParl.System} Object.
         *
         * The url you pass to the method must be the URL of a valid
         * OParl endpoint.
         */
        public System open(string url) throws ParsingError requires (url!=null) {
            lock(Client.initialized) {
                if (!Client.initialized)
                    Client.init();
            }
            int status;
            string data = this.resolve_url(url, out status);

            if (data != null) {
                var system = new System();
                var parser = new Json.Parser();
                system.set_client(this);

                try {
                    parser.load_from_data(data);
                } catch (GLib.Error e) {
                    throw new ParsingError.INVALID_JSON(_("JSON could not be parsed. Please check the OParl endpoint at '%s' against a linter").printf(url));
                }

                system.parse(parser.get_root());

                if (system.oparl_version != null) {
                    this.oparl_version = system.oparl_version;
                }

                return system;
            }

            throw new ParsingError.NO_DATA("You did not supply valid data");
        }

        /**
         * Takes a json-encoded OParl object as string, parses it and
         * returns the resulting OParl object
         */
        public List<OParl.Object> hydrate(string json) throws OParl.ParsingError {
            lock(Client.initialized) {
                if (!Client.initialized)
                    Client.init();
            }
            var parser = new Json.Parser();
            try {
                parser.load_from_data(json);
            } catch (GLib.Error e) {
                throw new ParsingError.INVALID_JSON(_("JSON could not be parsed:\n %s").printf(json));
            }
            // TODO: evaluate wheter the following todo is really necessary [It is necessary - eFrane]
            // TODO: check wheter object belongs to this client. if it does not throw exception
            var resolver = new Resolver(this);
            var ret = new List<OParl.Object>();
            try {
                ret.append(resolver.make_object(parser.get_root()));
                return ret;
            } catch (ParsingError.INVALID_TYPE e) {
                return resolver.parse_page(parser.get_root());
            }
        }

        /**
         * This signal is being triggered anytime an OParl.Client must resolve a url.
         *
         * It's up to you, to connect to this signal and implement it. Otherwise OParl
         * will have no data to operate on.
         * As this library is introspectable, it can potentially be used in many
         * programming languages. Any of those have their own best-practice patterns
         * and various methods of resolving an url by placing a HTTP request. In order
         * to not limit you as a programmer and not pull in dependencies by relying on
         * one single library, we let you decide how to handle HTTP requests in the
         * application.
         * Please be aware that liboparl likes to be fed with nice unicode-strings.
         *
         * Signal has an output parameter that needs to be set to the HTTP-status
         * code that the executed request returned. If no valid HTTP-status is
         * achievable, -1 is expected as status value.
         */
        public signal string? resolve_url (string url, out int status);

        /**
         * When this OParl.Client is not in strict mode, this signal will be triggered
         * whenever a non-critical spec-violation occurs. It will yield a ValidationResult
         * with further information on the topic and the id of the object that the error
         * was detected in.
         */
        public signal void shit_happened(ValidationResult vr);
    }

    /**
     * Resolves an objectlist-URL to a list of OParl.Objects
     */
    private class Resolver {
        private List<Object> result;
        private string? url;
        private Client c;

        public signal void new_page(List<Object> result);

        public Resolver(Client c, string? url="") {
            this.url = url;
            this.c = c;
            this.result = new List<Object>();
        }

        public unowned List<Object> resolve() throws ParsingError {
            if (this.url == null)
                throw new ParsingError.URL_NULL(_("URLs must not be null."));
            int status;
            string data = this.c.resolve_url(this.url, out status);
            var parser = new Json.Parser();
            try {
                parser.load_from_data(data);
            } catch (GLib.Error e) {
                throw new ParsingError.INVALID_JSON(_("JSON could not be parsed. Please check the OParl Object at '%s' against a linter").printf(this.url));
            }
            var visited_urls = new List<string>();
            visited_urls.append(this.url);
            this.parse(parser.get_root(), visited_urls);
            return this.result;
        }

        public Object make_object(Json.Node n) throws ParsingError {
            if (n.get_node_type() != Json.NodeType.OBJECT) {
                throw new ParsingError.EXPECTED_OBJECT(
                    "Can't make an object from a non-object"
                );
            }
            Json.Object el_obj = n.get_object();
            Json.Node ident = null;
            if (!el_obj.has_member("type")) {
                throw new ParsingError.INVALID_TYPE(
                    "Tried to make an object from a json without type"
                );
            }
            Json.Node type = el_obj.get_member("type");
            if (type.get_node_type() != Json.NodeType.VALUE) {
                ident = el_obj.get_member("id");
                if (ident.get_node_type() != Json.NodeType.VALUE) {
                    throw new ParsingError.EXPECTED_VALUE(
                        _("I need a string-value as type in object with id %s"),
                        ident.get_string()
                    );
                } else {
                    throw new ParsingError.EXPECTED_VALUE(
                        _("Tried to resolve an object that does not have a valid Id")
                    );
                }
            }

            string typestr = type.get_string().replace(c.oparl_version,"");

            Type t = Type.from_name("OParl"+typestr);
            if (!(t.is_a(typeof(OParl.Object)))) {
                throw new ParsingError.INVALID_TYPE(_("The type of this object is no valid OParl type: %s").printf(typestr));
            }
            var target = (Object)GLib.Object.new(t);
            target.set_client(this.c);

            try {
                (target as Parsable).parse(n);
            } catch (ParsingError.EXPECTED_ROOT_OBJECT e) {
                throw new ParsingError.EXPECTED_ROOT_OBJECT(_("I need an Object to parse: %s"), ident.get_string());
            }

            return target;
        }

        public unowned List<Object> parse_data(Json.Array arr) throws ParsingError {
            for (int i = 0; i < arr.get_length(); i++) {
                var element = arr.get_element(i);
                if (element.get_node_type() != Json.NodeType.OBJECT) {
                    throw new ParsingError.EXPECTED_OBJECT(_("I need an Object to parse: %s"), element.dup_string());
                }
                Object target = (Object)make_object(element);
                this.result.append(target);
            }
            return this.result;
        }

        public Object parse_url(string url) throws ParsingError requires (url != null) {
            int status;
            string data = this.c.resolve_url(url, out status);
            var parser = new Json.Parser();
            try {
                parser.load_from_data(data);
            } catch (GLib.Error e) {
                throw new ParsingError.INVALID_JSON(_("JSON could not be parsed. Please check the OParl Object at '%s' against a linter").printf(url));
            }
            var o = (Object)make_object(parser.get_root());
            return o;
        }

        public List<OParl.Object> parse_page(Json.Node n) throws OParl.ParsingError {
            this.parse(n, new List<string>(), false);
            var result = new List<Object>();
            foreach(OParl.Object o in this.result) {
                result.append(o);
            }
            return result;
        }

        public List<Object> parse_url_array(string[] urls) throws ParsingError {
            var result = new List<Object>();
            foreach(string url in urls) {
                Object target = this.parse_url(url);
                result.append(target);
            }
            return result;
        }

        private void parse(Json.Node n, List<string> visited_urls, bool follow_next=true) throws ParsingError {
            if (n.get_node_type() != Json.NodeType.OBJECT)
                throw new ParsingError.EXPECTED_ROOT_OBJECT(_("I need an Object to parse in '%s'"), n.dup_string());

            unowned Json.Object o = n.get_object();

            // Read in Member values
            unowned Json.Node item;
            item = o.get_member("data");
            if (item.get_node_type() != Json.NodeType.ARRAY) {
                throw new ParsingError.EXPECTED_VALUE(_("Attribute data must be an array in '%s'"), this.url);
            }
            var result = this.parse_data(item.get_array()).copy();
            this.new_page(result);
            item = o.get_member("links");
            if (item.get_node_type() != Json.NodeType.OBJECT) {
                throw new ParsingError.EXPECTED_VALUE(_("Attribute links must be an object in '%s'"), this.url);
            }
            Json.Object links = item.get_object();
            if (follow_next && links.has_member("next")) {
                var old_url = url;
                item = links.get_member("next");
                if (item.get_node_type() != Json.NodeType.VALUE) {
                    throw new ParsingError.EXPECTED_VALUE(_("Next-links must be strings in '%s'"), old_url);
                }
                string url = links.get_string_member("next");
                if (visited_urls.index(url) != -1) {
                    throw new ParsingError.URL_LOOP(_("The list '%s' links 'next' to one its previous pages"), old_url);
                }
                visited_urls.append(url);
                int status;
                string data = this.c.resolve_url(url, out status);
                var parser = new Json.Parser();
                try {
                    parser.load_from_data(data);
                } catch (GLib.Error e) {
                    throw new ParsingError.INVALID_JSON(_("JSON could not be parsed. Please check the OParl pagination-list at '%s' against a linter").printf(url));
                }
                this.parse(parser.get_root(), visited_urls);
            }
        }
    }
}
