/********************************************************************
# Copyright 2017 Stefan 'eFrane' Graupner
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
     * Pageable Sequences wrap long OParl object lists into
     * manageable memory chunks that transparently handle paging
     * so that a client may still be able to iterate over all objects
     * with `foreach`.
     *
     * Internally, pageable sequences pass most of the actual list handling
     * to a Glib.Sequence and just take care of the nitty gritty that is
     * on-demand page loading.
     *
     * Usage:
     *
     * var seq = new PageableSequence<Meeting>(client, "https://oparl.example/api/meeting/")
     *
     * for obj in seq {
     *      // will iterate over all meetings in the list,
     *      // may have occasional delays during iteration
     *      // when new pages are fetched
     * }
     *
     * TODO: signal for on-requesting-next-page
     * TODO: signal for new-objects-received
     * TODO: probably should take care that the errors we throw here are passed through Object.handle_parse_error
     */
    public class PageableSequence<T> : GLib.Object {
        internal Client client;

        /**
         * The actual objects of this sequence
         */
        internal GLib.List<T>? objects;

        /**
         * URLs to the loaded pages
         */
        internal GLib.List<string> current_pages;

        /**
         * The next page to load if the last object is reached
         */
        public string next_page {
            get { return next_page; }
            internal set {
                bool needs_fetch = next_page == "";
                next_page = value;

                if (needs_fetch) {
                    try {
                        this.fetch_next_page();
                    } catch (ParsingError e) {
                        // silently dropped
                    }
                }
            }
            default = "";
        }

        /**
         * Total (known) object count of the sequence
         * (see: https://dev.oparl.org/spezifikation/#paginierung)
         *
         * If requested lists contain 'pagination' attributes,
         * the actual reported value is used.
         *
         * You should not rely on the accuracy of this value.
         */
        public uint total_element_count { get; internal set; default = 0; }

        /**
         * Total (known) page count of the sequence
         * (see: https://dev.oparl.org/spezifikation/#paginierung)
         *
         * If requested lists contain 'pagination' attributes,
         * the actual reported value is used.
         *
         * You should not rely on the accuracy of this value.
         */
        public uint total_page_count { get; internal set; default = 0; }

        /**
         * (known) object count per page of the sequence
         * (see: https://dev.oparl.org/spezifikation/#paginierung)
         *
         * If requested lists contain 'pagination' attributes,
         * the actual reported value is used.
         *
         * You should not rely on the accuracy of this value.
         */
        public uint element_count_per_page {  get; internal set; default = 100; }

        /**
         * Current page number
         * (see: https://dev.oparl.org/spezifikation/#paginierung)
         *
         * If requested lists contain 'pagination' attributes,
         * the actual reported value is used.
         *
         * You should not rely on the accuracy of this value.
         */
        public uint current_page {  get; internal set; default = 0; }

        //public signal new_page

        public PageableSequence(Client c, string first_page = "") throws ParsingError {
            this.objects = new List<T>();
            this.current_pages = new List<string>();

            this.client = c;
            this.next_page = first_page;

            this.fetch_next_page();
        }

        internal bool fetch_next_page() throws ParsingError {
            if (this.next_page == "") {
                return false;
            }

            if (this.current_pages.index(this.next_page) != -1) {
                throw new ParsingError.URL_LOOP(_("The list '%s' links 'next' to one of its previous pages").printf(this.next_page));
            }

            ResolveUrlResult res = this.client.resolve_url(this.next_page);
            this.parse_json(res.data);

            return true;
        }

        internal uint current_object_count() {
            return (uint)this.objects.length();
        }

        private void parse_json(string data) throws ParsingError {
            var parser = new Json.Parser();
            try {
                parser.load_from_data(data);
            } catch (GLib.Error e) {
                throw new ParsingError.INVALID_JSON(_("JSON could not be parsed. Please check the OParl Object at '%s' against a linter").printf(this.next_page));
            }

            this.current_pages.append(this.next_page);

            unowned Json.Node root = parser.get_root();
            if (root.get_node_type() != Json.NodeType.OBJECT) {
                throw new ParsingError.EXPECTED_ROOT_OBJECT(_("I need an Object to parse in '%s'"), root.dup_string());
            }

            unowned Json.Object o = root.get_object();

            uint new_elements_count = this.parse_object_data(o);
            this.parse_pagination(o, new_elements_count);

            this.parse_links(o);
        }

        private uint parse_object_data(Json.Object o) throws ParsingError {
            // check for list of objects on page
            if (o.get_member("data").get_node_type() != Json.NodeType.ARRAY) {
                throw new ParsingError.EXPECTED_VALUE(_("Attribute data must be an array in '%s'"), this.next_page);
            }

            Json.Array list_data = o.get_member("data").get_array();

            for (int i = 0; i < list_data.get_length(); i++) {
                var element = list_data.get_element(i);

                if (element.get_node_type() != Json.NodeType.OBJECT) {
                    throw new ParsingError.EXPECTED_OBJECT(_("I need an Object to parse: %s"), element.dup_string());
                }

                this.objects.append((T)this.make_object(element));
            }

            return list_data.get_length();
        }

        private void parse_pagination(Json.Object o, uint new_elements_count) {
            if (o.has_member("pagination")) {
                Json.Object pagination = o.get_member("pagination").get_object();

                if (pagination.has_member("totalElements")) {
                    this.total_element_count = (uint)pagination.get_int_member("totalElements");
                } else {
                    this.total_element_count = (uint)this.objects.length();
                }

                if (pagination.has_member("elementsPerPage")) {
                    this.element_count_per_page = (uint)pagination.get_int_member("elementsPerPage");
                } else {
                    this.element_count_per_page = new_elements_count;
                }

                if (pagination.has_member("currentPage")) {
                    this.current_page = (uint)pagination.get_int_member("currentPage");
                } else {
                    this.current_page = (uint)(this.current_pages.length() - 1);
                }

                if (pagination.has_member("totalPages")) {
                    this.total_page_count = (uint)pagination.get_int_member("totalPages");
                } else {
                    this.total_page_count = (uint)this.current_pages.length();
                }
            }
        }

        private void parse_links(Json.Object o) {
            if (!o.has_member("links")) {
                this.next_page = "";
            }

            // check for link information
            Json.Object links = o.get_member("links").get_object();
            if (links.has_member("next")) {
                this.next_page = links.get_string_member("next");
            } else {
                this.next_page = "";
            }

            // TODO: should we check for the other links? are they useful?
        }

        /**
         * Turn a Json.Node into an OParl.Object
         */
        private T make_object(Json.Node n) throws ParsingError {
            if (n.get_node_type() != Json.NodeType.OBJECT) {
                throw new ParsingError.EXPECTED_OBJECT(
                    "Can't make an object from a non-object"
                );
            }

            Json.Object el_obj = n.get_object();
            Json.Node ident = null;
            if (!el_obj.has_member("type")) {
                throw new ParsingError.INVALID_TYPE(
                    "Tried to make an object from a json without type"
                );
            }

            Json.Node type = el_obj.get_member("");
            if (type.get_node_type() != Json.NodeType.VALUE) {
                ident = el_obj.get_member("id");
                if (ident.get_node_type() != Json.NodeType.VALUE) {
                    throw new ParsingError.EXPECTED_VALUE(
                        _("I need a string-value as type in object with id %s"),
                        ident.get_string()
                    );
                } else {
                    throw new ParsingError.EXPECTED_VALUE(
                        _("Tried to resolve an object that does not have a valid Id")
                    );
                }
            }

            string typestr = type.get_string().replace(this.client.oparl_version,"");

            Type t = Type.from_name("OParl"+typestr);
            if (!(t.is_a(typeof(OParl.Object)))) {
                throw new ParsingError.INVALID_TYPE(_("The type of this object is no valid OParl type: %s").printf(typestr));
            }

            var target = (T)GLib.Object.new(t);
            (target as OParl.Object).set_client(this.client);

            try {
                (target as Parsable).parse(n);
            } catch (ParsingError.EXPECTED_ROOT_OBJECT e) {
                throw new ParsingError.EXPECTED_ROOT_OBJECT(_("I need an Object to parse: %s"), ident.get_string());
            }

            return target;
        }

        public new T? get(int index) throws ParsingError {
            if (index < this.objects.length()) {
                return this.objects.nth(index);
            }

            while (this.fetch_next_page()) {
                if (index < this.objects.length()) {
                    return this.objects.nth(index);
                }
            }

            return null;
        }
    }
}
