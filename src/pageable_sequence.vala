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
     */
    class PageableSequence<T> : GLib.Object {
        private T type;

        internal Client client;

        /**
         * The actual objects of this sequence
         */
        private Sequence<OParl.Object> objects { get; set; default: null; };

        /**
         * URLs to the currently in-memory pages
         */
        public List<string> current_pages { get; internal set; };

        /**
         * The next page to load if the last object is reached
         */
        public string next_page? { get; internal set; default: "" };

        /**
         * The next page to load if the first object is reached
         */
        public string previous_page? { get; internal set; default: "" };

        private uint active_pages = 1;

        /**
         * Total (known) object count of the sequence
         * (see: https://dev.oparl.org/spezifikation/#paginierung)
         *
         * If requested lists contain 'pagination' attributes,
         * the actual reported values may be used
         */
        public uint count { default: 0 };

        /**
         * Requested per page object count
         */
        public uint count_per_page { default: 100 };

        public PageableSequence(Client c, string current_page, uint active_pages = 1) {
            this.objects = new Sequence<T>();
            this.current_pages = new List<string>();

            this.client = c;
            this.current_pages.append(current_page);
            this.active_pages = active_pages;
        }

        public function bool has_next_object() {
            // TODO: check the various conditions for next object truthiness
            return true;
        }

        public function Iterator iterator() {
            return new Iterator(this);
        }

        public class Iterator {
            private int index;
            private PageableSequence sequence;

            public Iterator(PageableSequence sequence) {
                this.sequence = sequence;
                this.index = 0;
            }

            public bool next() {
                return this.sequence.has_next_object();
            }

            public OParl.Object get() {
                // return current object
            }
        }
    }
}