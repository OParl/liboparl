namespace OParl {
    public errordomain ValidationError {
        EXPECTED_OBJECT,
        EXPECTED_VALUE,
        MISSING_MANDATORY,
        EMPTY_MANDATORY,
        MISSING_OPTIONAL,
        EMPTY_OPTIONAL
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

    public abstract class Object : GLib.Object {
        protected string id;
        protected string name;
        protected string? shortName = null;
        protected string license;
        protected GLib.DateTime created;
        protected GLib.DateTime modified;
        protected string keyword;
        protected string web;
        protected bool deleted;

        public virtual void parse(Json.Node n) {
            // Prepare object
            if (n.get_node_type() != Json.NodeType.OBJECT)
                throw new ValidationError.EXPECTED_OBJECT("I need an Object to parse");
            unowned Json.Object o = n.get_object();

            // Read in Member values
            foreach (unowned string name in o.get_members()) {
                unowned Json.Node item = o.get_member(name);
                switch(name) {
                    case "id": 
                    case "name":
                    case "shortName":
                    case "license": 
                    case "keyword": 
                    case "web":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute must be a value");
                        }
                        this.set_property(name, item.get_string());
                        break;
                    case "created":
                    case "modified":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute must be a value");
                        }
                        var tv = new GLib.TimeVal();
                        tv.from_iso8601(item.get_string());
                        var dt = new GLib.DateTime.from_timeval_utc(tv);
                        this.set_property(name, dt);
                        break;
                    case "deleted":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute must be a value");
                        }
                        this.set_property(name, item.get_boolean());
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

    public class System : Object {
        private string oparl_version;
        private string other_oparl_versions;
        private string body;
        private Body[]? bodies;
        private string contactEmail;
        private string contactName;
        private string website;
        private string vendor;
        private string product;

        public override void parse(Json.Node n) {
            base.parse(n);
            if (n.get_node_type() != Json.NodeType.OBJECT)
                throw new ValidationError.EXPECTED_OBJECT("I need an Object to parse");
            unowned Json.Object o = n.get_object();

            // Read in Member values
            foreach (unowned string name in o.get_members()) {
                unowned Json.Node item = o.get_member(name);
                switch(name) {
                    case "oparlVersion": 
                    case "otherOparlVersion":
                    case "contactEmail": 
                    case "contactName": 
                    case "website": 
                    case "vendor": 
                    case "product": 
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute must be a value");
                        }
                        this.set_property(name, item.get_string());
                        break;
                    case "body":
                        if (item.get_node_type() != Json.NodeType.ARRAY) {
                            throw new ValidationError.EXPECTED_VALUE("Attribute must be an array");
                        }
                        this.set_property(name, item.get_boolean());
                        break;
                }
            }
        }

        public string get_oparl_version() {
            return this.oparl_version;
        }
        public string get_other_oparl_versions() {
            return this.other_oparl_versions;
        }
        public string get_contact_email() {
            return this.contactEmail;
        }
        public string get_contact_name() {
            return this.contactName;
        }
        public string get_website() {
            return this.website;
        }
        public string get_vendor() {
            return this.vendor;
        }
        public string get_product() {
            return this.product;
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
