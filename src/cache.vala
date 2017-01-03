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
     * Represents a Cache for OParl JSONs. Single objects
     * can be cached identified by their id's. If the system
     * tries to resolve a single object via it's url, it is
     * going to ask the cache for the object first.
     */
    public interface Cache : GLib.Object {
        /**
         * Should return the object with the given id if it's in the cache
         */
        public abstract OParl.Object? get_object(string id);
        /**
         * Should return true if the object is in the cache.
         */
        public abstract bool has_object(string id);
        /**
         * Enters the given object. The id to store the object
         * is in the given {@link OParl.Object.id}
         */
        public abstract void set_object(OParl.Object o);
        /**
         * Removes the object with the given id from the cache
         */
        public abstract void invalidate(string id);
    }

    /**
     * A dummy implementation of {@link OParl.Cache} that
     * behaves as if there was no cache.
     */
    private class NoCache : Cache, GLib.Object {
        public OParl.Object? get_object(string id) {
            return null;
        }
        public bool has_object(string id) {
            return false;
        }
        public void set_object(OParl.Object o) {}
        public void invalidate(string id) {}
    }
}
