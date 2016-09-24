#!/usr/bin/python3
#********************************************************************
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
#*********************************************************************

"""
Example for using OParl in Python 3
"""
import gi
gi.require_version('OParl', '0.2')
from gi.repository import OParl

import urllib.request

def resolve(_, url):
    try:
        x = urllib.request.urlopen(url).read()
        return x.decode('utf-8')
    except Exception as e:
        return None

print ("Gonna ask an OParl system for its name…")
client = OParl.Client()
client.connect("resolve_url", resolve) 
system = client.open("https://api.kleineanfragen.de/oparl/v1")
print ("It says, it's name is: '"+system.get_name()+"'")
print (" - Yours, liboparl")
