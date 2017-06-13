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
    class PageableSequence<T> : GLib.Object {
        private T type;

        internal Client client;

        /**
         * The actual objects of this sequence
         */
        private Sequence<OParl.Object> objects { get; set; default: null; };

        /**
         * URLs to the loaded pages
         */
        public List<string> current_pages { get; internal set; default: null; };

        /**
         * The next page to load if the last object is reached
         */
        public string next_page? { get; internal set; default: ""; };

        /**
         * Total (known) object count of the sequence
         * (see: https://dev.oparl.org/spezifikation/#paginierung)
         *
         * If requested lists contain 'pagination' attributes,
         * the actual reported value is used.
         *
         * You should not rely on the accuracy of this value.
         */
        public uint total_element_count { get; internal set; default: 0 };

        /**
         * Total (known) page count of the sequence
         * (see: https://dev.oparl.org/spezifikation/#paginierung)
         *
         * If requested lists contain 'pagination' attributes,
         * the actual reported value is used.
         *
         * You should not rely on the accuracy of this value.
         */
        public uint total_page_count { get; internal set; default: 0; }

        /**
         * (known) object count per page of the sequence
         * (see: https://dev.oparl.org/spezifikation/#paginierung)
         *
         * If requested lists contain 'pagination' attributes,
         * the actual reported value is used.
         *
         * You should not rely on the accuracy of this value.
         */
        public uint element_count_per_page {  get; internal set; default: 100; };

        /**
         * Current page number
         * (see: https://dev.oparl.org/spezifikation/#paginierung)
         *
         * If requested lists contain 'pagination' attributes,
         * the actual reported value is used.
         *
         * You should not rely on the accuracy of this value.
         */
        public uint current_page {  get; internal set; default: 0; }

        private int iterator_index { get; set; default: 0; };

        public PageableSequence(Client c, string first_page) {
            this.objects = new Sequence<T>();
            this.current_pages = new List<string>();

            this.client = c;
            this.next_page = first_page;

            this.fetch_next_page();
        }

        private function bool fetch_next_page() throws ParsingError {
            if (!this.next_page) {
                return false;
            }

            if (this.current_pages.contains(this.next_page)) {
                throw new ParsingError.URL_LOOP(_("The list '%s' links 'next' to one of its previous pages"), this.next_page))
            }

            string data = this.client.resolve_url(this.next_page, out status);
            this.parse_json(data);

            return true;
        }

        private void parse_data(string data) {
            var parser = new Json.Parser();

            try {
                parser.load_from_data(data);
            } catch (GLib.Error e) {
                throw new ParsingError.INVALID_JSON(_("JSON could not be parsed. Please check the OParl Object at '%s' against a linter").printf(this.next_page));
            }

            this.current_pages.append(this.next_page);

            unowned root = parser.get_root();
            if (root.get_node_type() != Json.NodeType.OBJECT) {
                throw new ParsingError.EXPECTED_ROOT_OBJECT(_("I need an Object to parse in '%s'"), root.dup_string());
            }

            unowned Json.Object o = root.get_object();
            unowned Json.Node item;

            // check for list of objects on page
            item = o.get_member("data");
            if (item.get_node_type() != Json.NodeType.Array) {
                throw new ParsingError.EXPECTED_VALUE(_("Attribute data must be an array in '%s'"), this.next_page);
            }

            for (entity in item) {
                this.objects.append((T)this.make_object(entity));
            }

            // check for pagination information
            item = o.get_member("links");
            if (item.has_member("next")) {
                this.next_page = item.get_string_member("next");
            }

            // TODO: should we check for the other links? are they useful?

            this.parse_pagination(o);
        }

        private Object make_object(Json.Node n) throws ParsingError {
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
            Json.Node type = el_obj.get_member("type");
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

            string typestr = type.get_string().replace(c.oparl_version,"");

            Type t = Type.from_name("OParl"+typestr);
            if (!(t.is_a(typeof(OParl.Object)))) {
                throw new ParsingError.INVALID_TYPE(_("The type of this object is no valid OParl type: %s").printf(typestr));
            }
            var target = (Object)GLib.Object.new(t);
            target.set_client(this.c);

            try {
                (target as Parsable).parse(n);
            } catch (ParsingError.EXPECTED_ROOT_OBJECT e) {
                throw new ParsingError.EXPECTED_ROOT_OBJECT(_("I need an Object to parse: %s"), ident.get_string());
            }

            return target;
        }

        private void parse_pagination(Json.Object o, uint new_elements_count) {
            if (o.has_member("pagination")) {
                unowned pagination = o.get_member("pagination");

                if (pagination.has_member("totalElements")) {
                    this.total_element_count = (uint)pagination.get_int_member("totalElements");
                } else {
                    this.total_element_count = (uint)this.objects.count();
                }

                if (pagination.has_member("elementsPerPage")) {
                    this.element_count_per_page = (uint)pagination.get_int_member("elementsPerPage");
                } else {
                    this.element_count_per_page = new_elements_count;
                }

                if (pagination.has_member("currentPage")) {
                    this.current_page = (uint)pagination.get_int_member("currentPage");
                } else {
                    this.current_page = (uint)(this.current_pages.count() - 1);
                }

                if (pagination.has_member("totalPages")) {
                    this.total_page_count = (uint)pagination.get_int_member("totalPages");
                } else {
                    this.total_page_count = (uint)this.current_pages.count();
                }
            }
        }

        public function T? get(int index) {
            unowned T? obj;

            if ((index < this.objects.count())
            || (index >= this.objects.count() && this.fetch_next_page())
            ) {
                obj = this.objects[index];
            }

            return obj;
        }

        public function Iterator iterator() {
            return this;
        }

        public function T? next_value() {
            unowned T? next = this[index];
            this.iterator_index += 1;

            return next;
        }
    }
}