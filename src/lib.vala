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
    private class PageResolver {
        private unowned List<Object> result;
        private string url;
        private Client c;

        public PageResolver(Client c, string url, List<Object> l) {
            this.url = url;
            this.c = c;
            this.result = l;
        }

        public unowned List<Object> resolve() {
            string data = this.c.resolve_url(this.url);
            var parser = new Json.Parser();
            parser.load_from_data(data);
            this.parse(parser.get_root());
            return this.result; 
        }

        private Object make_object(Json.Node n) {
            Json.Object el_obj = n.get_object();
            Json.Node type = el_obj.get_member("type");
            if (type.get_node_type() != Json.NodeType.VALUE)
                throw new ValidationError.EXPECTED_VALUE("I need a string-value as type");
            string typestr = type.get_string();
            switch (typestr) {
                case "https://schema.oparl.org/1.0/Body":
                    var target = new Body();
                    target.parse(n);
                    return target;
                case "https://schema.oparl.org/1.0/AgendaItem":
                    var target = new AgendaItem();
                    target.parse(n);
                    return target;
                case "https://schema.oparl.org/1.0/Consultation":
                    var target = new Consultation();
                    target.parse(n);
                    return target;
                case "https://schema.oparl.org/1.0/File":
                    var target = new File();
                    target.parse(n);
                    return target;
                case "https://schema.oparl.org/1.0/LegislativeTerm":
                    var target = new LegislativeTerm();
                    target.parse(n);
                    return target;
                case "https://schema.oparl.org/1.0/Location":
                    var target = new Location();
                    target.parse(n);
                    return target;
                case "https://schema.oparl.org/1.0/Meeting":
                    var target = new Meeting();
                    target.parse(n);
                    return target;
                case "https://schema.oparl.org/1.0/Membership":
                    var target = new Membership();
                    target.parse(n);
                    return target;
                case "https://schema.oparl.org/1.0/Organization":
                    var target = new Organization();
                    target.parse(n);
                    return target;
                case "https://schema.oparl.org/1.0/Paper":
                    var target = new Paper();
                    target.parse(n);
                    return target;
                case "https://schema.oparl.org/1.0/Person":
                    var target = new Person();
                    target.parse(n);
                    return target;
                case "https://schema.oparl.org/1.0/System":
                    var target = new System();
                    target.parse(n);
                    return target;
            }
            throw new ValidationError.INVALID_TYPE("The type of this object is no valid OParl type: %s".printf(typestr));
        } 

        private void next_page(Json.Node n, out List<Object> list) {
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
            item.get_array().foreach_element((_,i,element) => {
                if (element.get_node_type() != Json.NodeType.OBJECT) {
                    throw new ValidationError.EXPECTED_OBJECT("I need an Object to parse");
                }
                Object target = (Object)make_object(element);
                this.result.append(target);
            });
            item = o.get_member("pagination");
            item = o.get_member("links");
            //TODO: if pagination hints to more pages, load and call recurse results into this func
        }
    }
}
