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

namespace OParl {
    /**
     * This class represents aspects that are common to any
     * Object yielded by an OParl endpoint.
     */
    public abstract class Object : GLib.Object {
        public static HashTable<string,string> name_map;

        /**
         * Contains a unique identifier, the object's URL to be precise.
         * This field is ''mandatory'' for any Object
         */
        public string id {get; protected set; default=null;}

        /**
         * Contains the original type attribute of an object
         */
        public string oparl_type { get; protected set; default="invalid type"; }

        /**
         * Used to contain the name of an object. This field is mandatory
         * for most objects.
         */
        public string name {get; protected set;}

        /**
         * Contains a short form of the object's name when this is
         * convenient. An example may be "Congress" instead of "United
         * States Congress"
         */
        public string? short_name {get; protected set; default=null;}

        /**
         * Determines which license the data of the object is published
         * under.
         *
         * If license is used in a {@link OParl.System} or an
         * {@link OParl.Body} object, it means that all their subordinated
         * objects are published under the same license.
         * Single objects may override this collective license by specifying
         * their own license-property.
         * It is ''recommended'' to use one license per {@link OParl.System}
         */
        public string license {get; protected set;}

        /**
         * A timestamp that determines when the object has been
         * created. This is ''mandatory'' for all objects
         */
        public GLib.DateTime created {get; protected set;}

        /**
         * A timestamp that determines when the object has last been changed.
         * Servers guarantee that this timestamp is always accurate. For a
         * client it's the best way to check for changes in objects.
         * It's ''mandatory'' for all objects.
         * If an object has been deleted, this timestamp contains the date and
         * time of deletion.
         */
        public GLib.DateTime modified {get; protected set;}

        /**
         * Contains an array of tags that are meant to ''optionally'' categorize
         * the object.
         */
        public string[] keyword {get; protected set;}

        /**
         * Represents a hyperlink to this object in the parliamentarian information
         * system that feeds the OParl endpoint. This is ''optional'' as not every
         * OParl endpoint must have a webbased parliamentarian information system
         * behind it.
         */
        public string web {get; protected set;}

        /**
         * Determines whether the object has been deleted. ''mandatory''
         */
        public bool deleted {get; protected set;}

        /**
         * Vendor Attributes
         *
         * Vendor attributes allow OParl-providers to deliver additional data
         * That has not been standadized in the OParl standard.
         */
        public HashTable<string, string> vendor_attributes {get; protected set;}

        /**
         * A reference to the client that made this object.
         */
        internal Client client;

        internal virtual void set_client(Client c) {
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

        /**
         * Triggers {@OParl.Client.shit_happened if the client is in non-strict-mode.
         * Otherwise it raises the error regularly
         */
        protected void handle_parse_error(ParsingError e) throws ParsingError {
            if (this.client.strict) {
                string annotated_message = e.message + _("Error occured in '%s'.").printf(this.id);
                e.message = annotated_message;
                throw e;
            } else {
                this.client.shit_happened(new ValidationResult(
                    ErrorSeverity.ERROR,
                    e.message,
                    "",
                    this.id
                ));
            }
        }

        /**
         * Verify the validity of a string attribute in an incoimg
         * JSON object and write it into the given target if all checks succeed
         */
        protected void parse_string(Object target, string name, Json.Node item, HashTable<string,string> name_map) throws OParl.ParsingError {
            try {
                if (item.get_node_type() != Json.NodeType.VALUE) {
                    throw new ParsingError.EXPECTED_VALUE(_("Attribute '%s' must be a value.").printf(name));
                }
                if (item.get_value_type() != typeof(string)) {
                    throw new ParsingError.INVALID_TYPE(_("Attribute '%s' must be a string.").printf(name));
                }
                target.set(name_map.get(name), item.get_string(),null);
            } catch (ParsingError e) {
                this.handle_parse_error(e);
            }
        }

        /**
         * Verify the validity of an array of string in an incoimg
         * JSON object and write it into the given target if all checks succeed
         */
        protected void parse_array_of_string(Object target, string name, Json.Node item, HashTable<string,string> name_map) throws OParl.ParsingError {
            try {
                if (item.get_node_type() != Json.NodeType.ARRAY) {
                    throw new ParsingError.EXPECTED_ARRAY(_("Attribute '%s' must be an array.").printf(name));
                }
                Json.Array arr = item.get_array();
                string[] res = new string[arr.get_length()];
                for (int i = 0; i < item.get_array().get_length(); i++ ) {
                    var element = item.get_array().get_element(i);
                    if (element.get_node_type() != Json.NodeType.VALUE) {
                        GLib.warning(_("Omitted array-element in '%s' because it was no Json-Value.").printf(name));
                        return;
                    }
                    if (element.get_value_type() != typeof(string)) {
                        throw new ParsingError.INVALID_TYPE(_("Arrayelement of '%s' must be a string.").printf(name));
                    }
                    res[i] = element.get_string();
                }
                this.set(name_map.get(name), res);
            } catch (ParsingError e) {
                this.handle_parse_error(e);
            }
        }

        /**
         * Verify the validity of a datetime in an incoimg
         * JSON object and write it into the given target if all checks succeed
         */
        protected void parse_datetime(Object target, string name, Json.Node item, HashTable<string,string> name_map, bool is_date=false) throws OParl.ParsingError {
            try {
                if (item.get_node_type() != Json.NodeType.VALUE) {
                    throw new ParsingError.EXPECTED_VALUE(_("Attribute '%s' must be a value.").printf(name));
                }
                if (item.get_value_type() != typeof(string)) {
                    throw new ParsingError.INVALID_TYPE(_("Attribute '%s' must be a string.").printf(name));
                }

                var tv = GLib.TimeVal();

                if (is_date) {
                    tv.from_iso8601(item.get_string()+"T00:00:00+00:00");
                } else {
                    tv.from_iso8601(item.get_string());
                }

                var dt = new GLib.DateTime.from_timeval_utc(tv);
                target.set_property(name_map.get(name), dt);
            } catch (ParsingError e) {
                this.handle_parse_error(e);
            }
        }

        /**
         * Verify the validity of a date in an incoimg
         * JSON object and write it into the given target if all checks succeed
         */
        protected void parse_date(Object target, string name, Json.Node item, HashTable<string,string> name_map) throws OParl.ParsingError {
            this.parse_datetime(target, name, item, name_map, true);
        }

        /**
         * Verify the validity of a boolean in an incoimg
         * JSON object and write it into the given target if all checks succeed
         */
        protected void parse_bool(Object target, string name, Json.Node item, HashTable<string,string> name_map) throws OParl.ParsingError {
            try {
                if (item.get_node_type() != Json.NodeType.VALUE) {
                    throw new ParsingError.EXPECTED_VALUE(_("Attribute '%s' must be a value.").printf(name));
                }
                if (item.get_value_type() != typeof(bool)) {
                    throw new ParsingError.INVALID_TYPE(_("Attribute '%s' must be a boolean.").printf(name));
                }
                target.set_property(name_map.get(name), item.get_boolean());
            } catch (ParsingError e) {
                this.handle_parse_error(e);
            }
        }

        protected void parse_int(Object target, string name, Json.Node item, HashTable<string,string> name_map) throws OParl.ParsingError {
            try {
                if (item.get_node_type() != Json.NodeType.VALUE) {
                    throw new ParsingError.EXPECTED_VALUE(_("Attribute '%s' must be a value.").printf(name));
                }
                if (item.get_value_type() != typeof(int64)) {
                    throw new ParsingError.INVALID_TYPE(_("Attribute '%s' must be an integer.").printf(name));
                }
                target.set_property(name_map.get(name), item.get_int());
            } catch (ParsingError e) {
                this.handle_parse_error(e);
            }
        }

        /**
         * Verify the validity of a string that represents an external object or
         * an external object list. Beware: liboparl does not know anything about
         * the validity of URLs. The resolve_url signal hands this over to you at resolve time.
         * There you may check the URLs validity with the HTTP library of your choice
         * When the check succeed the string will be written into a property with the
         * name of the field suffixed with "_url"
         */
        protected void parse_external(Object target, string name, Json.Node item, HashTable<string,string> name_map) throws OParl.ParsingError {
            try {
                if (item.get_node_type() != Json.NodeType.VALUE) {
                    throw new ParsingError.EXPECTED_VALUE(_("Attribute '%s' must be a value.").printf(name));
                }
                if (item.get_value_type() != typeof(string)) {
                    throw new ParsingError.INVALID_TYPE(_("Attribute '%s' must be a string.").printf(name));
                }
                this.set(name_map.get(name)+"_url", item.get_string());
            } catch (ParsingError e) {
                this.handle_parse_error(e);
            }
        }

        /**
         * Parses an array of URLs into a property
         */
        protected void parse_external_list(Object target, string name, Json.Node item, HashTable<string,string> name_map) throws OParl.ParsingError {
            try {
                if (item.get_node_type() != Json.NodeType.ARRAY) {
                    throw new ParsingError.EXPECTED_VALUE(_("Attribute '%s' must be a array.").printf(name));
                }
                var arr = item.get_array();
                var res = new string[arr.get_length()];
                for (int i = 0; i < arr.get_length(); i++) {
                    var element = arr.get_element(i);
                    if (element.get_node_type() != Json.NodeType.VALUE) {
                        throw new ParsingError.EXPECTED_VALUE(_("Element of '%s' must be a value.").printf(name));
                    }
                    if (element.get_value_type() != typeof(string)) {
                        throw new ParsingError.INVALID_TYPE(_("Element of '%s' must be a string.").printf(name));
                    }
                    res[i] = element.get_string();
                }
                this.set(name_map.get(name)+"_url", res);
            } catch (ParsingError e) {
                this.handle_parse_error(e);
            }
        }

        internal virtual void parse(Object target, Json.Node n) throws ParsingError {
            // Prepare object
            if (n.get_node_type() != Json.NodeType.OBJECT)
                throw new ParsingError.EXPECTED_ROOT_OBJECT(_("I need an Object to parse"));
            unowned Json.Object o = n.get_object();

            // Read in Member values
            foreach (unowned string name in o.get_members()) {
                unowned Json.Node item = o.get_member(name);
                switch(name) {
                    // Direct Read-in
                    // - type
                    case "type":
                        this.oparl_type = item.get_string();
                        break;

                    // - strings
                    case "id":
                    case "name":
                    case "shortName":
                    case "license":
                    case "web":
                        this.parse_string(target, name, item, Object.name_map);
                        break;
                    // - string[]
                    case "keyword":
                        this.parse_array_of_string(target, name, item, Object.name_map);
                        break;
                    // - dates
                    case "created":
                    case "modified":
                        this.parse_datetime(target, name, item, Object.name_map);
                        break;
                    // - booleans
                    case "deleted":
                        this.parse_bool(target, name, item, Object.name_map);
                        break;
                    default:
                        if (item.get_node_type() == Json.NodeType.VALUE &&
                                item.get_value_type() == typeof(string) &&
                                ":" in name) {
                            if (this.vendor_attributes == null)
                                this.vendor_attributes = new HashTable<string,string>(str_hash, str_equal);
                            this.vendor_attributes.set(name, item.get_string());
                        }
                        break;
                }
            }
        }

        protected List<ValidationResult>? validation_results = null;

        /**
         * Will yield a detailed report on where
         * an Object violates the OParl 1.0 specification.
         */
        public virtual unowned List<ValidationResult> validate() {
            this.validation_results = new List<ValidationResult>();
            if (this.id == null) {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.ERROR,
                               _("Invalid 'id'"),
                               _("The 'id'-field contains no id. The id field must contain a valid"
                               + "url that can be used to retrieve the object via HTTP."),
                               _("<id invalid>")
                ));
            }
            if (this.id == "") {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.ERROR,
                               _("Invalid 'id'"),
                               _("The 'id'-field contains no id. The id field must contain a valid"
                               + "url that can be used to retrieve the object via HTTP."),
                               _("<id invalid>")
                ));
            }
            if (this.license == null && (this is System)) {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.WARNING,
                               _("Invalid 'license'"),
                               _("The 'license'-field does not contain any value. It is recommended to "
                               + "specify the license for all subordinated objects either in the System"
                               + " object or in the Body objects"),
                               this.id
                ));
            }
            if (this.license == null && this is Body) {
                System rootsystem = null;
                try {
                    rootsystem = (this as Body).get_system();
                } catch (ParsingError e) {
                    this.validation_results.append(new ValidationResult(
                               ErrorSeverity.ERROR,
                               _("Body with no 'system'"),
                               _("This Body does not have a System."),
                               this.id
                    ));
                }
                if (rootsystem.license == null) {
                    this.validation_results.append(new ValidationResult(
                               ErrorSeverity.WARNING,
                               _("Invalid 'license'"),
                               _("The 'license'-field does not contain any value. It is recommended to "
                               + "specify the license for all subordinated objects either in the System"
                               + " object or in the Body objects"),
                               this.id
                    ));
                }
            }
            if (this.license == "") {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.ERROR,
                               _("Invalid 'license'"),
                               _("The 'license'-field contains an empty string. Please specify a valid "
                               + "license"),
                               this.id
                ));
            }
            if (this.license == null && !(this is System || this is Body)) {
                Body rootbody = null;
                try {
                    rootbody = this.root_body();
                } catch (ParsingError e) {}

                System rootsystem = this.root_system(); // root_system already gracefully evaluates to null

                if (rootbody == null || rootsystem == null) {
                    this.validation_results.append(new ValidationResult(
                        ErrorSeverity.ERROR,
                        _("Can't resolve root body or root system"),
                        _("Every object needs to have license information. Typically, most "
                        + "objects inherit their license from a superordinated Body or "
                        + "system object of which neither could be resolved in this instance."),
                        this.id
                    ));
                }
                else if (rootbody.license == null && rootsystem.license == null ) {
                    this.validation_results.append(new ValidationResult(
                               ErrorSeverity.ERROR,
                               _("Invalid 'license'"),
                               _("Neither the superordinated Body nor the superordinated Body "
                               + "specify a license for this object. Please either add a license "
                               + "to this object or add one to the containing System or Body"),
                               this.id
                    ));
                }
            }
            return this.validation_results;
        }

        /**
         * Each object should implement this method as means to resolve the
         * body that this object originates from
         */
        internal abstract Body? root_body() throws ParsingError;

        /**
         * Tries to resolve which system this object
         * belongs to.
         * This method leverages the root_body method
         * to get the system.
         */
        internal virtual System? root_system() {
            try {
                Body? b = root_body();
                return b == null ? null : b.get_system();
            } catch (ParsingError e) {
                return null;
            }
        }

        /**
         * Fetches the object again and overrides the properties by newly
         * obtained values
         */
        public void refresh() throws OParl.ParsingError {
            var r = new Resolver(this.client);
            Object updated_obj = null;

            try {
                if (this.id == null) {
                    throw new ParsingError.EXPECTED_VALUE(_("Expected valid id attribute, encountered: '%s'.").printf(name));
                }

                updated_obj = r.parse_url(this.id);
                if (updated_obj == null) {
                    throw new ParsingError.EXPECTED_OBJECT(_("Could not parse updated object."));
                }
            } catch (OParl.ParsingError e) {
                this.handle_parse_error(e);
            }

            Type type = updated_obj.get_type();

            if (updated_obj.deleted) {
                this.deleted = true;
                return;
            }

            foreach (var property in ((ObjectClass)type.class_ref()).list_properties()) {
                if (property.name == "id") continue;
                var v = Value(property.value_type);
                updated_obj.get_property(property.name, ref v);
                if (v.holds(property.value_type)) {
                    this.set_property(property.name, v);
                }
            }
        }

        /**
         * Returns a list of all Objects that this Object is connected with
         */
        public abstract List<OParl.Object> get_neighbors() throws ParsingError;
    }

    /**
     * All OParl.Objects that can be loaded as embedded
     * object inherit from this class. They may have fields
     * that have been loaded incompletely as defined by the
     * spec. This class provides the means to load them
     * fully on the fly if needed.
     */
    public abstract class EmbeddedObject : Object {
        /**
         * If the object has been loaded as an embedded object
         * and thus has some unloaded fields, this property will
         * be {{{false}}}
         */
        public bool fully_loaded { get; protected set; }

        /**
         * Causes the object to refresh and thus load omitted
         * fields
         */
        public void autoload() throws OParl.ParsingError {
            try {
                if (!this.fully_loaded) {
                    this.refresh();
                    this.fully_loaded = true;
                }
            } catch (ParsingError e) {
                this.handle_parse_error(e);
            }
        }
    }
}
