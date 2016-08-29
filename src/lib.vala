namespace OParl {
    public errordomain ValidationError {
        EXPECTED_OBJECT,
        EXPECTED_VALUE,
        MISSING_MANDATORY,
        EMPTY_MANDATORY,
        MISSING_OPTIONAL,
        EMPTY_OPTIONAL,
        NO_DATA,
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
                parser.load_from_data(data);
                system.parse(parser.get_root());
                return system;
            }
            throw new ValidationError.NO_DATA("You did not supply valid data");
        }

        public signal string? resolve_url (string url);
    }

    public class Object : GLib.Object {
        public static HashTable<string,string> name_map;
        // Direct Read-In
        protected string id {get; set;}
        protected string name {get; set;}
        protected string? short_name {get; set; default=null;}
        protected string license {get; set;}
        protected GLib.DateTime created {get; set;}
        protected GLib.DateTime modified {get; set;}
        protected string keyword {get; set;}
        protected string web {get; set;}
        protected bool deleted {get; set;}

        internal Client client;


        public virtual void set_client(Client c) {
            this.client = c;
        }

        internal static void populate_name_map() {
            name_map = new HashTable<string,string>(str_hash, str_equal);
            name_map.insert("id","id");
            name_map.insert("name","name");
            name_map.insert("shortName","short_name");
            name_map.insert("license","license");
            name_map.insert("created","created");
            name_map.insert("modified","modified");
            name_map.insert("keyword","keyword");
            name_map.insert("web","web");
            name_map.insert("deleted","deleted");
        }

        public virtual void parse(Object target, Json.Node n) {
            // Prepare object
            if (n.get_node_type() != Json.NodeType.OBJECT)
                throw new ValidationError.EXPECTED_OBJECT("I need an Object to parse");
            unowned Json.Object o = n.get_object();

            // Read in Member values
            foreach (unowned string name in o.get_members()) {
                unowned Json.Node item = o.get_member(name);
                switch(name) {
                    // Direct Read-in
                    // - strings
                    case "id": 
                    case "name":
                    case "shortName":
                    case "license": 
                    case "keyword": 
                    case "web":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        target.set(Object.name_map.get(name), item.get_string(),null);
                        break;
                    // - dates
                    case "created":
                    case "modified":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        var tv = new GLib.TimeVal();
                        tv.from_iso8601(item.get_string());
                        var dt = new GLib.DateTime.from_timeval_utc(tv);
                        target.set_property(Object.name_map.get(name), dt);
                        break;
                    // - booleans
                    case "deleted":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        target.set_property(Object.name_map.get(name), item.get_boolean());
                        break;
                    default:
                        break;
                }
            }
        }

        public virtual void validate() {
            uint8 error_severity = 0x0;
            GLib.Value v = new GLib.Value(typeof(string));
            string[] mandatories = {"id", "name", "license", "keyword"};
            foreach (string name in mandatories) {
                this.get_property(name, ref v);
                if (v.get_string() ==  null) {
                    GLib.warning("Mandatory field %s must not be null!", name);
                    error_severity |= SEVERITY_BAD;
                } else if (v.get_string() == "") {
                    GLib.warning("Mandatory field %s must not be empty!", name);
                    error_severity |= SEVERITY_BAD;
                }
            }
            string[] optionals =  {"shortName"};
            foreach (string name in optionals) {
                this.get_property(name, ref v);
                if (v.get_string() ==  null) {
                    GLib.warning("Optional field %s must shoult not be null!", name);
                    error_severity |= SEVERITY_MEDIUM;
                } else if (v.get_string() == "") {
                    GLib.warning("Optional field %s must shoult not be empty!", name);
                    error_severity |= SEVERITY_MEDIUM;
                }
            }
        } 
    }

    private class PageResolver<K> {
        private string url;
        private Client c;

        public PageResolver(Client c, string url) {
            this.url = url;
            this.c = c;
        }

        public List<K> resolve() {
            string data = this.c.resolve_url(this.url);
            var parser = new Json.Parser();
            parser.load_from_data(data);
            List<K> list = new List<K>();
            this.parse(parser.get_root(), list);
            return list;
        }

        private void next_page(Json.Node n, out List<K> list) {
        }

        private void parse(Json.Node n, out List<K> list) {
            if (n.get_node_type() != Json.NodeType.OBJECT)
                throw new ValidationError.EXPECTED_OBJECT("I need an Object to parse");
            
            unowned Json.Object o = n.get_object();

            // Read in Member values
            foreach (unowned string name in o.get_members()) {
                unowned Json.Node item = o.get_member(name);
                switch(name) {
                    case "data":
                        if (item.get_node_type() != Json.NodeType.ARRAY) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be an array".printf(name));
                        }
                        var data_node = o.get_member(name);
                        data_node.get_array().foreach_element((_,i,element) => {
                            if (element.get_node_type() != Json.NodeType.OBJECT) {
                                throw new ValidationError.EXPECTED_OBJECT("I need an Object to parse");
                            }
                            var el_obj = element.get_object();
                            K target = new K();
                            target.parse(el_obj);
                            list.append(k);
                        });
                        break;
                    case "pagination":
                        break;
                    case "links":
                        break;
                }
            }
        }
    }

    public class System : OParl.Object {
        private static HashTable<string,string> name_map;

        public string oparl_version {get;set;}
        public string other_oparl_versions {get;set;}
        public string contact_email {get;set;}
        public string contact_name {get;set;}
        public string website {get;set;}
        public string vendor {get;set;}
        public string product {get;set;}

        public string body_url {get;set;}
        private bool body_resolved {get;set;}
        private List<Body>? body_p = null;
        public List<Body>? body {
            get {
                if (!body_resolved) {
                    body = (new PageResolver<Body>(this.client, body_url)).resolve();
                }
            }
            set{
                this.body_p = value;
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
        }

        public System() {
            base();
        }

        public new void parse(Json.Node n) {
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
                        stdout.printf("name: %s\n",name);
                        /*
                        if (item.get_node_type() != Json.NodeType.ARRAY) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be an array".printf(name));
                        }
                        stdout.printf("after name: %s\n",name);
                        this.set_property("_"+name, item.get_boolean());*/
                        break;
                }
            }
        }
    }
    public class Body : Object {
        private static HashTable<string,string> name_map;

        public System system;
        public string website;
        public GLib.DateTime license_valid_since;
        public GLib.DateTime oparl_since;
        public string ags;
        public string rgs;
        public string[] equivalent;
        public string contact_email;
        public string contact_url;
        public Organization[] organization;
        public Person[] person;
        public Meeting[] meeting;
        public Paper[] paper;
        public LegislativeTerm[] legislative_term;
        public string classification;
        public Location location;

        internal static void populate_name_map() {
            name_map = new GLib.HashTable<string,string>(str_hash, str_equal);
            name_map.insert("system", "system");
            name_map.insert("website", "website");
            name_map.insert("licenseValidSince", "license_valid_since");
            name_map.insert("oparlSince", "oparl_since");
            name_map.insert("ags","ags");
            name_map.insert("rgs","rgs");
            name_map.insert("equivalent","equivalent");
            name_map.insert("contactEmail","contact_email");
            name_map.insert("contactName","contact_name");
            name_map.insert("organization","organization");
            name_map.insert("person","person");
            name_map.insert("meeting","meeting");
            name_map.insert("paper","paper");
            name_map.insert("legislativeTerm","legislative_term");
            name_map.insert("classification","classification");
            name_map.insert("location","location");
        }

        public void parse() {
        }
    }
    public class Person : Object {
        public Person() {
    
        }
        public override void validate () {
        }
        private void parse() {
        }
    }
    public class Membership : Object {

    }
    public class Organization : Object {

    }
    public class Meeting : Object {

    }
    public class AgendaItem : Object {

    }
    public class Consultation : Object {

    }
    public class Paper : Object {

    }
    public class File : Object {

    }
    public class Location : Object {

    }
    public class LegislativeTerm : Object {

    }
}
