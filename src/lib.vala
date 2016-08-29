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

    /*public enum Type {
        AgendaItem,
        Body,
        Consultation,
        File,
        LegislativeTerm,
        Location,
        Meeting,
        Membership,
        Organization,
        Paper,
        Person,
        System
    }*/

    public class Client : GLib.Object {
        public System open(string url) {
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
        // Direct Read-In
        protected string id {get; set;}
        protected string name {get; set;}
        protected string? shortName {get; set; default=null;}
        protected string license {get; set;}
        protected GLib.DateTime created {get; set;}
        protected GLib.DateTime modified {get; set;}
        protected string keyword {get; set;}
        protected string web {get; set;}
        protected bool deleted {get; set;}

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
                        stdout.printf("foobar here\n");
                        target.set(name, item.get_string(),null);
                        stdout.printf("after here\n");
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
                        target.set_property(name, dt);
                        break;
                    // - booleans
                    case "deleted":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        target.set_property(name, item.get_boolean());
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

    public class System : OParl.Object {
        public string oparlVersion {get;set;}
        public string other_oparl_versions {get;set;}
        public string body {get;set;}
        public Body[]? bodies {get;set;}
        public string contactEmail {get;set;}
        public string contactName {get;set;}
        public string website {get;set;}
        public string vendor {get;set;}
        public string product {get;set;}

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
                        stdout.printf("name: %s\n",name);
                        this.set(name, item.get_string(),null);
                        stdout.printf("after name: %s\n",name);
                        break;
                    // To Resolve
                    case "body":
                        if (item.get_node_type() != Json.NodeType.ARRAY) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute '%s' must be an array".printf(name));
                        }
                        this.set_property("_"+name, item.get_boolean());
                        break;
                }
            }
        }
    }
    public class Body : Object {

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
}
