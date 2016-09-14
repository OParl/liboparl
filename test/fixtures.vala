/********************************************************************
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
*********************************************************************/

using OParl;

namespace OParlTest.Fixtures {
    public const string object_sane = """
    {
        "id": "https://api.testoparl.invalid/oparl/v1/",
        "type": "https://schema.oparl.org/1.0/System",
        "name": "Testsystem und so",
        "shortName": "Testsystem",
        "license": "CC-BY-SA",
        "created": "2016-01-01T13:12:22+00:00",
        "modified": "2016-05-23T21:18:29+00:00",
        "keyword": ["some","neat","object"],
        "web": "https://foobar.invalid",
        "deleted": false
    }
    """;

    public const string system_sane = """
    {
        "id": "https://oparl.example.org/",
        "type": "https://schema.oparl.org/1.0/System",
        "oparlVersion": "https://schema.oparl.org/1.0/",
        "body": "https://oparl.example.org/bodies",
        "name": "Beispiel-System",
        "contactEmail": "info@example.org",
        "contactName": "Allgemeiner OParl Kontakt",
        "website": "http://www.example.org/",
        "vendor": "http://example-software.com/",
        "product": "http://example-software.com/oparl-server/",
        "otherOparlVersions": [
            "https://oparl2.example.org/"
        ]
    }
    """;
}
