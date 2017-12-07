#!/usr/bin/env python3
# ********************************************************************
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
# *********************************************************************

"""
Example for using OParl in Python 3

Requires `requests` to be installed.
"""
import gi
import requests
from requests import HTTPError

gi.require_version('OParl', '0.2')
from gi.repository import OParl


def resolve(_, url: str):
    req = requests.get(url)

    content = req.content.decode('utf-8')

    try:
        req.raise_for_status()
    except HTTPError as e:
        print("HTTP status code error: ", e)
        return OParl.ResolveUrlResult(resolved_data=content, success=False, status_code=req.status_code)

    return OParl.ResolveUrlResult(resolved_data=content, success=True, status_code=req.status_code)


def main():
    print("Gonna ask an OParl system for its name…")
    client = OParl.Client()
    client.connect("resolve_url", resolve)
    system = client.open("https://dev.oparl.org/api/oparl/v1/system")
    print("It says, it's name is: '" + system.get_name() + "'")
    print(" - Yours, liboparl")


if __name__ == "__main__":
    main()
