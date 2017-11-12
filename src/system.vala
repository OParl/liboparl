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
     * The System object represents one OParl endpoint for a
     * specific version of OParl.
     *
     * It's also the entrypoint for access to a server.
     */
    public class System : OParl.Object, Parsable {
        private new static HashTable<string,string> name_map;

        /**
         * The URL of the OParl specification that this
         * server implements.
         */
        public string oparl_version {get; internal set;}

        /**
         * A list of URLs to other OParl endpoints of this
         * server that support other versions of OParl
         */
        public string[] other_oparl_versions {get; internal set;}

        /**
         * An email address for requests regarding OParl.
         * If any questions to this endpoint arise, an email to this address
         * should get you in contact with an administrator / other responsible
         * person.
         */
        public string contact_email {get; internal set;}

        /**
         * The name of a contact person that is responsible for this OParl
         * endpoint.
         */
        public string contact_name {get; internal set;}

        /**
         * URL of the parliamentarian information system that feeds this
         * OParl endpoint.
         */
        public string website {get; internal set;}

        /**
         * URL of the vendor of this OParl server software
         */
        public string vendor {get; internal set;}

        /**
         * URL to the product page of this OParl server software
         */
        public string product {get; internal set;}

        /**
         * Triggered whenever a new page of {@link OParl.Body}s has arrived.
         * See OParl specification to see how paginated lists work.
         */
        public signal void incoming_bodies(List<Body> bodies);
        /**
         * Triggered when the last page of bodies has been resolved successfully
         * See OParl specification to see how paginated lists work.
         */
        public signal void finished_bodies();
        internal string body_url {get;set;}
        private bool body_resolved {get;set; default=false;}

        private unowned PageableBody? body_p { get; set; }
        public unowned PageableBody? get_body() throws ParsingError {
            lock (body_resolved) {
                if (!body_resolved && this.body_url != null) {
                    this.body_p = new PageableBody(this.client, this.body_url);
                }
            }

            return this.body_p;
        }

        //  private List<Body>? body_p = null;
        //  /**
        //   * A list of all bodies that exist on this system.
        //   */
        //  public unowned List<Body>? get_body() throws ParsingError {
        //      lock (body_resolved) {
        //          if (!body_resolved) {
        //              this.body_p = new List<Body>();
        //              if (this.body_url != "") {
        //                  var pr = new Resolver(this.client, this.body_url);
        //                  pr.new_page.connect((list)=>{
        //                      var outlist = new List<Body>();
        //                      foreach (Object o in list) {
        //                          outlist.append((Body)o);
        //                      }
        //                      this.incoming_bodies(outlist);
        //                  });
        //                  foreach (Object o in pr.resolve()) {
        //                      this.body_p.append((Body)o);
        //                  }
        //              } else {
        //                  warning(_("System without body-list: %s"), this.id);
        //              }
        //              body_resolved = true;
        //          } else if (body_resolved) {
        //              this.incoming_bodies(this.body_p);
        //          }
        //      }
        //      this.finished_bodies();
        //      return this.body_p;
        //  }

        internal override Body? root_body() {
            return null;
        }

        internal new static void populate_name_map() {
            name_map = new GLib.HashTable<string,string>(str_hash, str_equal);
            name_map.insert("oparlVersion", "oparl_version");
            name_map.insert("otherOparlVersions", "other_oparl_versions");
            name_map.insert("contactEmail", "contact_email");
            name_map.insert("contactName", "contact_name");
            name_map.insert("website", "website");
            name_map.insert("vendor", "vendor");
            name_map.insert("product", "product");
            name_map.insert("body", "body");
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
                    case "oparlVersion":
                    case "contactEmail":
                    case "contactName":
                    case "website":
                    case "vendor":
                    case "product":
                        this.parse_string(this, name, item, System.name_map);
                        break;
                    // string[]
                    case "otherOparlVersions":
                        this.parse_array_of_string(this, name, item, System.name_map);
                        break;
                    // To Resolve
                    case "body":
                        this.parse_external(this, name, item, System.name_map);
                        break;
                }
            }
        }

        /**
         * {@inheritDoc}
         */
        public new unowned List<ValidationResult> validate() {
            base.validate();
            if (this.oparl_version == null) {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.ERROR,
                               _("Missing oparlVersion field"),
                               _("The field 'oparlVersion' must be set."),
                               this.id
                ));
            }
            // TODO: check for all known valid values here?
            if (this.oparl_version == "") {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.ERROR,
                               _("Empty oparlVersion field"),
                               _("The field 'oparlVersion' must not be an empty string."),
                               this.id
                ));
            }
            if (this.body_url == null) {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.ERROR,
                               _("Missing body field"),
                               _("The field 'body' must be set."),
                               this.id
                ));
            }
            if (this.body_url == "") {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.ERROR,
                               _("Empty body field"),
                               _("The field 'body' must not be an empty string."),
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

            foreach (Body b in this.get_body()) {
                l.append(b);
            }

            return l;
        }
    }
}
