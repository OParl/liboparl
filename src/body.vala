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
     * Respresents a legislative body.
     */
    public class Body : Object, Parsable {
        private new static HashTable<string,string> name_map;

        /**
         * URL to the Website of the body
         */
        public string website {get; internal set;}

        /**
         * The date and time since the license that is
         * set in {@link OParl.Object.license} is valid.
         */
        public GLib.DateTime license_valid_since {get; internal set;}

        /**
         * The point in time since this body provides OParl
         *
         * Useful to estimate the quality of the delivered data.
         * As only from the time OParl setup happend, it can be
         * said for sure that all values are present in the
         * original sources.
         */
        public GLib.DateTime oparl_since {get; internal set;}

        /**
         * 8-digit municipality key. - It's a German thing.
         */
        public string ags {get; internal set;}

        /**
         * 12-digit regional key. - It's a German thing.
         */
        public string rgs {get; internal set;}

        /**
         * Additional URLs of websites representing the same
         * body.
         *
         * In here could e.g. be corresponding entries in
         * state libraries or the wikipedia.
         */
        public string[] equivalent {get; internal set;}

        /**
         * A contact email address.
         *
         * This address should at least provide contact to officials
         * of this body. Ideally it also provides contact to persons
         * responsible for the parliamentarian information system.
         */
        public string contact_email {get; internal set;}

        /**
         * Name or Idenitifier of the person/office that is descibed
         * in {@link OParl.Body.contact_email}.
         */
        public string contact_name {get; internal set;}

        /**
         * Type of the body
         */
        public string classification {get; internal set;}

        //  /**
        //   * Triggered whenever a new page of {@link OParl.Organization}s has arrived.
        //   * See OParl specification to see how paginated lists work.
        //   */
        //  public signal void incoming_organizations(List<Organization> organizations);
        //  /**
        //   * Triggered when the last page of organizations has been resolved successfully
        //   * See OParl specification to see how paginated lists work.
        //   */
        //  public signal void finished_organizations();
        internal string organization_url {get;set;default="";}
        public PageableSequence<Organization>? organization { get; internal set; }

        /**
         * Triggered whenever a new page of {@link OParl.Person}s has arrived.
         * See OParl specification to see how paginated lists work.
         */
        public signal void incoming_persons(List<Person> persons);
        /**
         * Triggered when the last page of persons has been resolved successfully
         * See OParl specification to see how paginated lists work.
         */
        public signal void finished_persons();
        internal string person_url {get;set;default="";}
        private bool person_resolved {get;set; default=false;}
        private List<Person>? person_p = null;
        /**
         * All persons inside this body
         */
        public unowned List<Person> get_person() throws ParsingError {
            lock (person_resolved) {
                if (!person_resolved && person_url != null) {
                    this.person_p = new List<Person>();
                    if (this.person_url != "") {
                        var pr = new Resolver(this.client, this.person_url);
                        pr.new_page.connect((list)=>{
                            var outlist = new List<Person>();
                            foreach (Object o in list) {
                                outlist.append((Person)o);
                            }
                            this.incoming_persons(outlist);
                        });
                        foreach (Object o in pr.resolve()) {
                            this.person_p.append((Person)o);
                        }
                    } else {
                        warning(_("Body without person url: %s"), this.id);
                    }
                    person_resolved = true;
                } else if (person_resolved) {
                    this.incoming_persons(this.person_p);
                }
            }
            this.finished_persons();
            return this.person_p;
        }

        /**
         * Triggered whenever a new page of {@link OParl.Meeting}s has arrived.
         * See OParl specification to see how paginated lists work.
         */
        public signal void incoming_meetings(List<Meeting> meetings);
        /**
         * Triggered when the last page of meetings has been resolved successfully
         * See OParl specification to see how paginated lists work.
         */
        public signal void finished_meetings();
        internal string meeting_url {get;set;default="";}
        private bool meeting_resolved {get;set; default=false;}
        private List<Meeting>? meeting_p = null;
        /**
         * All meetings conducted by this body
         */
        public unowned List<Meeting> get_meeting() throws ParsingError {
            lock (meeting_resolved) {
                if (!meeting_resolved && meeting_url != null) {
                    this.meeting_p = new List<Meeting>();
                    if (this.meeting_url != "") {
                        var pr = new Resolver(this.client, this.meeting_url);
                        pr.new_page.connect((list)=>{
                            var outlist = new List<Meeting>();
                            foreach(Object o in list) {
                                outlist.append((Meeting)o);
                            }
                            this.incoming_meetings(outlist);
                        });
                        foreach (Object o in pr.resolve()) {
                            this.meeting_p.append((Meeting)o);
                        }
                    } else {
                        warning(_("Body without meeting url: %s"),this.id);
                    }
                    meeting_resolved = true;
                } else if (meeting_resolved) {
                    this.incoming_meetings(this.meeting_p);
                }
            }
            this.finished_meetings();
            return this.meeting_p;
        }

        /**
         * Triggered whenever a new page of {@link OParl.Paper}s has arrived.
         * See OParl specification to see how paginated lists work.
         */
        public signal void incoming_papers(List<Paper> papers);
        /**
         * Triggered when the last page of papers has been resolved successfully
         * See OParl specification to see how paginated lists work.
         */
        public signal void finished_papers();
        internal string paper_url {get;set;default="";}
        private bool paper_resolved {get;set; default=false;}
        private List<Paper>? paper_p = null;
        /**
         * All papers ever used by this body
         */
        public unowned List<Paper> get_paper() throws ParsingError {
            lock (paper_resolved) {
                if (!paper_resolved && paper_url != null) {
                    this.paper_p = new List<Paper>();
                    if (this.paper_url != "") {
                        var pr = new Resolver(this.client, this.paper_url);
                        pr.new_page.connect((list)=>{
                            var outlist = new List<Paper>();
                            foreach (Object o in list) {
                                outlist.append((Paper)o);
                            }
                            this.incoming_papers(outlist);
                        });
                        foreach (Object o in pr.resolve()) {
                            this.paper_p.append((Paper)o);
                        }
                    } else {
                        warning(_("Body without paper url: %s"), this.id);
                    }
                    paper_resolved = true;
                } else if (paper_resolved) {
                    this.incoming_papers(this.paper_p);
                }
            }
            this.finished_papers();
            return this.paper_p;
        }

        private List<LegislativeTerm>? legislative_term_p = null;
        /**
         * All legislative terms of this body
         */
        public List<LegislativeTerm> legislative_term {
            get {
                return this.legislative_term_p;
            }
        }

        private Location? location_p = null;
        /**
         * The location that this body officially resides at.
         */
        public Location location {
            get {
                return this.location_p;
            }
        }

        internal string system_url {get;set; default="";}
        private bool system_resolved {get;set; default=false;}
        private System? system_p = null;
        /**
         * The system that this body belongs to
         */
        public System get_system() throws ParsingError {
            lock (system_resolved) {
                if (!system_resolved) {
                    var r = new Resolver(this.client);
                    if (this.system_url != "")
                        this.system_p = (System)r.parse_url(this.system_url);
                    else
                        warning(_("Body without system url: %s"), this.id);
                    system_resolved = true;
                }
            }
            return this.system_p;
        }

        internal override Body? root_body() {
            return this;
        }

        internal new static void populate_name_map() {
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

        internal new void parse(Json.Node n) throws ParsingError {
            base.parse(this, n);
            if (n.get_node_type() != Json.NodeType.OBJECT)
                throw new ParsingError.EXPECTED_ROOT_OBJECT("I need an Object to parse");
            unowned Json.Object o = n.get_object();

            // Read in Member values
            foreach (unowned string name in o.get_members()) {
                unowned Json.Node item = o.get_member(name);
                switch(name) {
                    // Direct Read-In
                    // - strings
                    case "website":
                    case "ags":
                    case "rgs":
                    case "contactEmail":
                    case "contactName":
                    case "classification":
                        this.parse_string(this, name, item, Body.name_map);
                        break;
                    // - dates
                    case "licenseValidSince":
                    case "oparlSince":
                        this.parse_datetime(this, name, item, Body.name_map);
                        break;
                    // - string[]
                    case "equivalent":
                        this.parse_array_of_string(this, name, item, Body.name_map);
                        break;
                    // To Resolve as external objectlist
                    case "organization":
                        this.parse_external_paginated(
                            this,
                            name,
                            new PageableSequence<Organization?>(this.client, ""),
                            item,
                            Body.name_map
                        );
                        break;
                    case "system":
                    case "person":
                    case "meeting":
                    case "paper":
                        this.parse_external(this, name, item, Body.name_map);
                        break;
                    // To Resolve as internal objectlist
                    case "legislativeTerm":
                        if (item.get_node_type() != Json.NodeType.ARRAY) {
                            throw new ParsingError.EXPECTED_VALUE(_("Attribute '%s' must be an array.").printf(name));
                        }
                        this.legislative_term_p = new List<LegislativeTerm>();
                        var r = new Resolver(this.client);
                        foreach (Object term in r.parse_data(item.get_array())) {
                            this.legislative_term_p.append((LegislativeTerm)term);
                        }
                        break;
                    // To resolve as internal object
                    case "location":
                        if (item.get_node_type() != Json.NodeType.OBJECT) {
                            throw new ParsingError.EXPECTED_VALUE(_("Attribute '%s' must be an object.").printf(name));
                        }
                        var r = new Resolver(this.client);
                        this.location_p = (Location)r.make_object(item);
                        break;
                }
            }
        }

        /**
         * {@inheritDoc}
         */
        public new unowned List<ValidationResult> validate() {
            base.validate();
            if (this.name == "") {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.ERROR,
                               _("Invalid 'name'"),
                               _("The 'name'-field contains an empty string. Each Body must "
                               + " contain a human readable name."),
                               this.id
                ));
            }
            if (this.name == null) {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.ERROR,
                               _("No 'name'"),
                               _("The 'name'-field must be present in a Body."),
                               this.id
                ));
            }
            if (this.organization == null) {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.ERROR,
                               _("Missing 'organization' field"),
                               _("The 'organization'-field must be present in each Body"),
                               this.id
                ));
            }
            if (this.person_url == "") {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.ERROR,
                               _("Empty 'person'"),
                               _("The 'person'-field contains an empty string. Each Body must"
                               + " supply its persons."),
                               this.id
                ));
            }
            if (this.person_url == null) {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.ERROR,
                               _("Missing 'person' field"),
                               _("The 'person'-field must be present in each Body"),
                               this.id
                ));
            }
            if (this.meeting_url == "") {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.ERROR,
                               _("Empty 'meeting'"),
                               _("The 'meeting'-field contains an empty string. Each Body must "
                               + "supply its meetings."),
                               this.id
                ));
            }
            if (this.meeting_url == null) {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.ERROR,
                               _("Missing 'meeting' field"),
                               _("The 'meeting'-field must be present in each Body"),
                               this.id
                ));
            }
            if (this.paper_url == "") {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.ERROR,
                               _("Empty 'paper'"),
                               _("The 'paper'-field contains an empty string. Each Body must "
                               + "supply its papers."),
                               this.id
                ));
            }
            if (this.paper_url == null) {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.ERROR,
                               _("Missing 'paper' field"),
                               _("The 'paper'-field must be present in each Body"),
                               this.id
                ));
            }
            if (this.legislative_term_p == null) {
                this.validation_results.append(new ValidationResult(
                               ErrorSeverity.ERROR,
                               _("Missing 'legislativeTerm' field"),
                               _("The 'legislativeTerm'-field must be present in each Body"),
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

            var system = this.get_system();
            if (system != null) {
                l.append(system);
            }

            foreach (LegislativeTerm lt in this.legislative_term) {
                l.append(lt);
            }

            var lo = this.location;
            if (lo != null) {
              l.append(lo);
            }

            foreach (Person p in this.get_person()) {
                l.append(p);
            }

            foreach (Organization o in this.organization) {
                l.append(o);
            }

            foreach (Meeting m in this.get_meeting()) {
                l.append(m);
            }

            foreach (Paper p in this.get_paper()) {
                l.append(p);
            }

            return l;
        }

        /**
         * Returns true if the given object is subordinate to this body
         */
        public bool is_root_of(Object o) throws ParsingError {
            return o.root_body() == this;
        }
    }
}
