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
     * Represents the membership of an {@link OParl.Person} in
     * an {@link OParl.Organization}.
     */
    public class Membership : EmbeddedObject, Parsable {
        private new static HashTable<string,string> name_map;

        /**
         * The role that the {@link OParl.Membership.get_person}
         * fulfills in {@link OParl.Membership.get_organization}
         *
         * May be used to distinguish different kinds of membership
         * of the same person in the same organization.
         */
        public string role {get; internal set;}

        /**
         * If the {@link OParl.Membership.get_person} has the right
         * to vote on resolutions {@link OParl.AgendaItem}s in {@link OParl.Meeting}s of
         * {@link OParl.Membership.get_organization}, this flag is true
         */
        public bool voting_right {get; internal set;}

        /**
         * The date at which the membership commenced
         */
        public GLib.DateTime start_date {get; internal set;}

        /**
         * The date at which the membership ended
         */
        public GLib.DateTime end_date {get; internal set;}

        internal string person_url {get;set; default="";}
        private bool person_resolved {get;set; default=false;}
        private Person? person_p = null;
        /**
         * The person that this membership concerns
         */
        public Person get_person() throws ParsingError {
            lock (person_resolved) {
                if (!person_resolved) {
                    this.autoload();

                    var r = new Resolver(this.client);
                    if (this.person_url != "")
                        this.person_p = (Person)r.parse_url(this.person_url);
                    else
                        warning(_("Membership without person url: %s"), this.id);
                    person_resolved = true;
                }
            }
            return this.person_p;
        }

        /**
         * Set the person if this membership has been parsed as
         * embedded object of a person
         */
        internal void set_person(Person p) {
            person_resolved = true;
            this.person_p = p;
        }

        internal string organization_url {get;set; default="";}
        private bool organization_resolved {get;set; default=false;}
        private Organization? organization_p = null;
        /**
         * The organization that this membership concerns
         */
        public Organization get_organization() throws ParsingError {
            lock (organization_resolved) {
                if (!organization_resolved) {
                    this.autoload();

                    var r = new Resolver(this.client);
                    if (this.organization_url != "")
                        this.organization_p = (Organization)r.parse_url(this.organization_url);
                    else
                        warning(_("Membership without organization url: %s"), this.id);
                    organization_resolved = true;
                }
            }
            return this.organization_p;
        }

        internal string on_behalf_of_url {get;set; default="";}
        private bool on_behalf_of_resolved {get;set; default=false;}
        private Organization? on_behalf_of_p = null;
        /**
         * If {@link OParl.Membership.get_person} represents another {@link OParl.Organization}
         * in {@link OParl.Membership.get_organization}, this method will yield the represented
         * organization.
         */
        public Organization? get_on_behalf_of() throws ParsingError {
            lock (on_behalf_of_resolved) {
                if (!on_behalf_of_resolved) {
                    this.autoload();

                    var r = new Resolver(this.client);
                    if (this.on_behalf_of_url != "")
                        this.on_behalf_of_p = (Organization)r.parse_url(this.on_behalf_of_url);
                    on_behalf_of_resolved = true;
                }
            }
            return this.on_behalf_of_p;
        }

        internal new static void populate_name_map() {
            name_map = new GLib.HashTable<string,string>(str_hash, str_equal);
            name_map.insert("role", "role");
            name_map.insert("votingRight", "voting_right");
            name_map.insert("startDate", "start_date");
            name_map.insert("endDate", "end_date");
            name_map.insert("person", "person");
            name_map.insert("organization", "organization");
            name_map.insert("onBehalfOf","on_behalf_of");
        }

        internal override Body? root_body() throws ParsingError {
            return this.get_person().get_body();
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
                    // - strings
                    case "role":
                        this.parse_string(this, name, item, Membership.name_map);
                        break;
                    // - booleans
                    case "votingRight":
                        this.parse_bool(this, name, item, Membership.name_map);
                        break;
                    // - dates
                    case "startDate":
                    case "endDate":
                        this.parse_date(this, name, item, Membership.name_map);
                        break;
                    // To Resolve as external object
                    case "organization":
                    case "person":
                    case "onBehalfOf":
                        this.parse_external(this, name, item, Membership.name_map);
                        break;
                }
            }
        }

        /**
         * {@inheritDoc}
         */
        public new unowned List<ValidationResult> validate() {
            base.validate();

            if (this.start_date != null
            && this.end_date != null
            && this.start_date.compare(this.end_date) > 0)
            {
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

            var person = this.get_person();
            if (person != null) {
                l.append(person);
            }

            var on_behalf_of = this.get_on_behalf_of();
            if (on_behalf_of != null) {
                l.append(on_behalf_of);
            }

            var organization = this.get_organization();
            if (organization != null) {
                l.append(organization);
            }

            return l;
        }
    }
}
