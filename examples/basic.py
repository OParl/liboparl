#!/usr/bin/env python3
#********************************************************************
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
#*********************************************************************

"""
Example for using OParl in Python 3
"""
import gi
gi.require_version('OParl', '0.2')
from gi.repository import OParl

import urllib.request

def resolve(_, url, status):
    try:
        req = urllib.request.urlopen(url)
        status= req.getcode()
        data = req.read()
        return data.decode('utf-8')
    except urllib.error.HTTPError as e:
        status = e.getcode()
        return None
    except Exception as e:
        status = -1
        return None

print ("Gonna ask an OParl system for its name…")
client = OParl.Client()
client.connect("resolve_url", resolve) 
system = client.open("https://dev.oparl.org/api/v1/system")
print ("It says, it's name is: '"+system.get_name()+"'")
print (" - Yours, liboparl")
