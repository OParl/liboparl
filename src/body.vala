namespace OParl {
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

        public new void parse(Json.Node n) {
        }
    }
}
