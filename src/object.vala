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
        public string id {get; protected set;}

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
         */
        /* TODO: Verify and append to docblock if true:
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

        internal virtual void parse(Object target, Json.Node n) throws ParsingError {
            // Prepare object
            if (n.get_node_type() != Json.NodeType.OBJECT)
                throw new ParsingError.EXPECTED_OBJECT("I need an Object to parse");
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
                    case "web":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        if (item.get_value_type() != typeof(string)) {
                            throw new ParsingError.INVALID_TYPE("Attribute '%s' must be a string".printf(name));
                        }
                        target.set(Object.name_map.get(name), item.get_string(),null);
                        break;
                    // - string[]
                    case "keyword":
                        if (item.get_node_type() != Json.NodeType.ARRAY) {
                            throw new ParsingError.EXPECTED_ARRAY("Attribute '%s' must be an array".printf(name));
                        }
                        Json.Array arr = item.get_array();
                        string[] res = new string[arr.get_length()];
                        item.get_array().foreach_element((_,i,element) => {
                            if (element.get_node_type() != Json.NodeType.VALUE) {
                                GLib.warning("Omitted array-element in '%s' because it was no Json-Value".printf(name));
                                return;
                            }
                            res[i] = element.get_string();
                        });
                        this.set(Object.name_map.get(name), res);
                        break;
                    // - dates
                    case "created":
                    case "modified":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        if (item.get_value_type() != typeof(string)) {
                            throw new ParsingError.INVALID_TYPE("Attribute '%s' must be a string".printf(name));
                        }
                        var tv = GLib.TimeVal();
                        tv.from_iso8601(item.get_string());
                        var dt = new GLib.DateTime.from_timeval_utc(tv);
                        target.set_property(Object.name_map.get(name), dt);
                        break;
                    // - booleans
                    case "deleted":
                        if (item.get_node_type() != Json.NodeType.VALUE) {
                            throw new ParsingError.EXPECTED_VALUE("Attribute '%s' must be a value".printf(name));
                        }
                        if (item.get_value_type() != typeof(bool)) {
                            throw new ParsingError.INVALID_TYPE("Attribute '%s' must be a boolean ".printf(name));
                        }
                        target.set_property(Object.name_map.get(name), item.get_boolean());
                        break;
                    default:
                        break;
                }
            }
        }

        protected List<ValidationResult>? validation_results = null;

        /**
         * ''NOT IMPLEMENTED YET'' - Will yield a detailed report on where
         * an Object violates the OParl 1.0 specification.
         */
        public virtual unowned List<ValidationResult> validate() {
            this.validation_results = new List<ValidationResult>();
            if (this.id == null) {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.ERROR,
                               "Invalid 'id'",
                               "The 'id'-field contains no id. The id field must contain a valid"+
                               "url that can be used to retrieve the object via HTTP.",
                               "<id invalid>"
                ));
            }
            if (this.id == "") {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.ERROR,
                               "Invalid 'id'",
                               "The 'id'-field is an empty string. The id field must contain a valid"+
                               "url that can be used to retrieve the object via HTTP.",
                               "<id invalid>"
                ));
            }
            if (this.license == null && (this is System)) {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.WARNING,
                               "Invalid 'license'",
                               "The 'license'-field does not contain any value. It is recommended to "+
                               "specify the license for all subordinated objects either in the System"+
                               " object or in the Body objects",
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
                               "Body with no 'system'",
                               "This Body does not have a System.",
                               this.id
                    ));
                }
                if (rootsystem.license == null) {
                    this.validation_results.append(new ValidationResult(
                               ErrorSeverity.WARNING,
                               "Invalid 'license'",
                               "The 'license'-field does not contain any value. It is recommended to "+
                               "specify the license for all subordinated objects either in the System"+
                               " object or in the Body objects",
                               this.id
                    ));
                }
            }
            if (this.license == "") {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.ERROR,
                               "Invalid 'license'",
                               "The 'license'-field contains an empty string. Please specify a valid "+
                               "license",
                               this.id
                ));
            }
            if (this.license == null && !(this is System || this is Body)) {
                Body rootbody = null;
                try {
                    rootbody = this.root_body();
                } catch (ParsingError e) {}
                System rootsystem = this.root_system();
                if (rootbody.license == null && rootsystem.license == null ) {
                    this.validation_results.append(new ValidationResult(
                               ErrorSeverity.ERROR,
                               "Invalid 'license'",
                               "Neither the superordinated Body nor the superordinated Body "+
                               "specify a license for this object. Please either add a license "+
                               "to this object or add one to the containing System or Body",
                               this.id
                    ));
                }
            }
            return this.validation_results;
        } 

        public void complete() {
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
    }
}
