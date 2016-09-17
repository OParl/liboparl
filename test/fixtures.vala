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

    public const string body_list_sane = """
    {
        "pagination": {
            "totalElements":1,
            "elementsPerPage":1,
            "currentPage":1,
            "totalPages":1
        },
        "data": [
            """+ body_sane +"""
        ],
        "links":{}
    }
    """;

    // TODO: enter meeting organization and paper urls as soon as fixtures are available
    public const string body_sane = """
    {
        "id": "https://oparl.example.org/body/0",
        "type": "https://schema.oparl.org/1.0/Body",
        "system": "https://oparl.example.org/",
        "contactEmail": "ris@beispielstadt.de",
        "contactName": "RIS-Betreuung",
        "ags": "05315000",
        "rgs": "053150000000",
        "equivalent": [
            "http://d-nb.info/gnd/2015732-0",
            "http://dbpedia.org/resource/Cologne"
        ],
        "shortName": "Köln",
        "name": "Stadt Köln, kreisfreie Stadt",
        "website": "http://www.beispielstadt.de/",
        "license": "http://creativecommons.org/licenses/by/4.0/",
        "licenseValidSince": "2015-01-01T14:28:31.568+0000",
        "oparlSince": "2014-01-01T14:28:31.568+0000",
        "organization": "https://oparl.example.org/body/0/organizations/",
        "person": "https://oparl.example.org/body/0/people/",
        "meeting": "https://oparl.example.org/body/0/meetings/",
        "paper": "https://oparl.example.org/body/0/papers/",
        "legislativeTerm": [
        {
            "id": "https://oparl.example.org/term/21",
            "type": "https://schema.oparl.org/1.0/LegislativeTerm",
            "body": "https://oparl.example.org/body/0",
            "name": "21. Wahlperiode",
            "startDate": "2010-12-03",
            "endDate": "2013-12-03"
        }
        ],
        "location": {
            "id": "https://oparl.example.org/location/0",
            "type": "https://schema.oparl.org/1.0/Location",
            "description": "Rathaus der Beispielstadt, Ratshausplatz 1, 12345 Beispielstadt",
            "streetAddress": "Rathausplatz 1",
            "room": "1337",
            "postalCode": "13337",
            "subLocality": "Beispielbezirk",
            "locality": "Beispielstadt",
            "bodies": [
                "https://oparl.example.org/body/0"
            ],
            "organizations": [
            ],
            "meetings": [
            ],
            "papers": [
            ],
            "geojson": {
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": [
                        50.1234,
                        10.4321
                    ]
                },
                "properties": {
                    "name": "Rathausplatz"
                }
            }
        },
        "classification": "Kreisfreie Stadt",
        "created": "2014-01-08T14:28:31.568+0100",
        "modified": "2014-01-08T14:28:31.568+0100"
    }
    """;

    public const string organization_sane = """
    {
        "id": "https://oparl.example.org/organization/0",
        "type": "https://schema.oparl.org/1.0/Organization",
        "body": "https://oparl.example.org/body/0",
        "name": "Ausschuss für Haushalt und Finanzen",
        "shortName": "Finanzausschuss",
        "startDate": "2012-07-17",
        "endDate": "2014-07-17",
        "organizationType": "Gremium",
        "location": {
            "id": "https://oparl.example.org/location/0",
            "type": "https://schema.oparl.org/1.0/Location",
            "description": "Rathaus der Beispielstadt, Ratshausplatz 1, 12345 Beispielstadt",
            "streetAddress": "Rathausplatz 1",
            "room": "1337",
            "postalCode": "13337",
            "subLocality": "Beispielbezirk",
            "locality": "Beispielstadt",
            "bodies": [
                "https://oparl.example.org/body/0"
            ],
            "organizations": [
            ],
            "meetings": [
            ],
            "papers": [
            ],
            "geojson": {
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": [
                        50.1234,
                        10.4321
                    ]
                },
                "properties": {
                    "name": "Rathausplatz"
                }
            }
        },
        "post": [
            "Vorsitzender",
            "1. Stellvertreter",
            "Mitglied"
        ],
        "meeting": "https://oparl.example.org/organization/0/meetings",
        "membership": [
            "https://oparl.example.org/memberships/27"
        ],
        "classification": "Ausschuss",
        "keyword": [
            "finanzen",
            "haushalt"
        ],
        "created": "2012-07-16",
        "modified": "2012-08-16"
    }
    """;

    public const string organization_list_sane = """
    {
        "pagination": {
            "totalElements":1,
            "elementsPerPage":1,
            "currentPage":1,
            "totalPages":1
        },
        "data": [
            """+ organization_sane +"""
        ],
        "links":{}
    }
    """;

    // TODO: add meeting when fixture is available
    public const string meeting_list_sane = """
    {
        "pagination": {
            "totalElements":1,
            "elementsPerPage":1,
            "currentPage":1,
            "totalPages":1
        },
        "data": [
        ],
        "links":{}
    }
    """;
}
