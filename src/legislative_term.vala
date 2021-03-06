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
     * Represents a legislative term
     */
    public class LegislativeTerm : EmbeddedObject, Parsable {
        private new static HashTable<string,string> name_map;

        /**
         * The date at which the legislative term started
         */
        public GLib.DateTime start_date {get; internal set;}
        /**
         * The date at which the legislative term ended
         */
        public GLib.DateTime end_date {get; internal set;}

        internal string body_url {get;set; default="";}
        private bool body_resolved {get;set; default=false;}
        private Body? body_p = null;
        /**
         * The body that references this legislative term
         */
        public Body get_body() throws ParsingError {
            lock (body_resolved) {
                if (!body_resolved) {
                    this.autoload();

                    var r = new Resolver(this.client);

                    try {
                        if (this.body_url != "") {
                            this.body_p = (Body)r.parse_url(this.body_url);
                        } else {
                            throw new ParsingError.EXPECTED_OBJECT(_("Legislative term without body url"));
                        }
                    } catch (ParsingError e) {
                        this.handle_parse_error(e);
                    }


                    body_resolved = true;
                }
            }
            return this.body_p;
        }

        internal new static void populate_name_map() {
            name_map = new GLib.HashTable<string,string>(str_hash, str_equal);
            name_map.insert("body","body");
            name_map.insert("startDate","start_date");
            name_map.insert("endDate","end_date");
        }

        /**
         * determines the body this object originates from
         */
        internal override Body? root_body() throws ParsingError {
            return this.get_body();
        }

        internal new void parse(Json.Node n) throws ParsingError {
            base.parse(this, n);
            if (n.get_node_type() != Json.NodeType.OBJECT)
                throw new ParsingError.EXPECTED_ROOT_OBJECT(_("I need an Object to parse"));
            unowned Json.Object o = n.get_object();

            // Read in Member values
            foreach (unowned string name in o.get_members()) {
                unowned Json.Node item = o.get_member(name);
                switch(name) {
                    // Direct Read-In
                    // - dates
                    case "startDate":
                    case "endDate":
                        this.parse_date(this, name, item, LegislativeTerm.name_map);
                        break;
                    // External object
                    case "body":
                        this.parse_external(this, name, item, LegislativeTerm.name_map);
                        break;
                }
            }
        }

        /**
         * {@inheritDoc}
         */
        public new unowned List<ValidationResult> validate() {
            base.validate();
            if (this.start_date.compare(this.end_date) > 0) {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.INFO,
                               _("Invalid period"),
                               _("The startDate must be an earlier date than the endDate"),
                               this.id
                ));
            }
            return this.validation_results;
        }

        /**
         * {@inheritDoc}
         */
        public override List<OParl.Object> get_neighbors() throws ParsingError {
            var l = new List<OParl.Object>();

            var body = this.get_body();
            if (body != null) {
                l.append(body);
            }

            return l;
        }

    }
}
