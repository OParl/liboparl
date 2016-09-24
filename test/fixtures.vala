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
        "id": "https://oparl.example.org/",
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
        "location": """+ location_sane +""",
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
        "location": """ + location_sane + """,
        "post": [
            "Vorsitzender",
            "1. Stellvertreter",
            "Mitglied"
        ],
        "meeting": "https://oparl.example.org/organization/0/meetings",
        "membership": [
            "https://oparl.example.org/membership/1"
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

    public const string person_sane = """
    {
        "id": "https://oparl.example.org/person/0",
        "type": "https://schema.oparl.org/1.0/Person",
        "body": "https://oparl.example.org/body/0",
        "name": "Prof. Dr. Max Mustermann",
        "familyName": "Mustermann",
        "givenName": "Max",
        "title": [
            "Prof.",
            "Dr."
        ],
        "formOfAddress": "Ratsfrau",
        "gender": "male",
        "email": ["max@mustermann.de"],
        "phone": ["+493012345678"],
        "status": [
            "Bezirksbürgermeister"
        ],
        "membership": [
            {
                "id": "https://oparl.example.org/membership/0",
                "type": "https://schema.oparl.org/1.0/Membership",
                "organization": "https://oparl.example.org/organization/0",
                "role": "Vorsitzende",
                "votingRight": true,
                "startDate": "2013-12-03"
            },
            {
                "id": "https://oparl.example.org/membership/1",
                "type": "https://schema.oparl.org/1.0/Membership",
                "organization": "https://oparl.example.org/organization/0",
                "onBehalfOf": "https://oparl.example.org/organization/0",
                "role": "Sachkundige Bürgerin",
                "votingRight": false,
                "startDate": "2013-12-03",
                "endDate": "2014-07-28"
            }
        ],
        "created": "2011-11-11T11:11:00+00:00",
        "modified": "2012-08-16T14:05:27+00:00"
    }
    """;

    public const string person_list_sane = """
    {
        "pagination": {
            "totalElements":1,
            "elementsPerPage":1,
            "currentPage":1,
            "totalPages":1
        },
        "data": [
            """ + person_sane + """
        ],
        "links":{}
    }
    """;

    public const string membership_sane = """
    {
        "id": "https://oparl.example.org/membership/1",
        "type": "https://schema.oparl.org/1.0/Membership",
        "organization": "https://oparl.example.org/organization/0",
        "onBehalfOf": "https://oparl.example.org/organization/0",
        "person": "https://oparl.example.org/person/0",
        "role": "Sachkundige Bürgerin",
        "votingRight": false,
        "startDate": "2013-12-03",
        "endDate": "2014-07-28"
    }
    """;

    public const string meeting_sane = """
    {
        "id": "https://oparl.example.org/meeting/0",
        "type": "https://schema.oparl.org/1.0/Meeting",
        "name": "4. Sitzung des Finanzausschusses",
        "start": "2013-01-04T08:00:00+00:00",
        "end": "2013-01-04T12:00:00+00:00",
        "location": """ + location_sane + """,
        "organization": [
            "https://oparl.example.org/organization/0"
        ],
        "participant": [
            "https://oparl.example.org/person/0"
        ],
        "invitation": """ + file_sane + """,
        "resultsProtocol": """ + file_sane + """,
        "verbatimProtocol": """ + file_sane + """,
        "auxiliaryFile": ["""+ file_sane + """],
        "agendaItem": ["""+ agenda_item_sane + """],
        "created": "2012-01-06T12:01:00+00:00",
        "modified": "2012-01-08T14:05:27+00:00"
    }
    """;

    public const string meeting_list_sane = """
    {
        "pagination": {
            "totalElements":1,
            "elementsPerPage":1,
            "currentPage":1,
            "totalPages":1
        },
        "data": [
            """ + meeting_sane + """
        ],
        "links":{}
    }
    """;

    public const string location_sane = """
    {
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
            "https://oparl.example.org/organization/0"
        ],
        "meetings": [
            "https://oparl.example.org/meeting/0"
        ],
        "papers": [
            "https://oparl.example.org/paper/0"
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
    }
    """;

    public const string file_sane = """
    {
        "id": "https://oparl.example.org/file/0",
        "type": "https://schema.oparl.org/1.0/File",
        "name": "Nachtrags-Tagesordnung",
        "fileName": "nachtrag-TO.pdf",
        "mimeType": "application/pdf",
        "date": "2012-01-08",
        "sha1Checksum": "da39a3ee5e6b4b0d3255bfef95601890afd80709",
        "size": 82930,
        "accessUrl": "https://oparl.example.org/file/0.pdf",
        "downloadUrl": "https://oparl.example.org/file/download/0.pdf",
        "externalServiceUrl": "https://www.youtube.com/watch?v=MKp30C3MwVk",
        "masterFile" : "https://oparl.example.org/file/0",
        "derivativeFile" : ["https://oparl.example.org/file/0"],
        "fileLicense": "http://www.wtfpl.net/wp-content/uploads/2012/12/wtfpl-badge-1.png",
        "modified": "2012-01-08T14:05:27+00:00",
        "text": "blablatextblabla",
        "meeting": [ "https://oparl.example.org/meeting/0"],
        "agendaItem": [ "https://oparl.example.org/agendaitem/0"],
        "paper": [ "https://oparl.example.org/paper/0"]
    }
    """;

    public const string paper_sane = """
    {
        "id": "https://oparl.example.org/paper/0",
        "type": "https://schema.oparl.org/1.0/Paper",
        "body": "https://oparl.example.org/body/0",
        "name": "Antwort auf Anfrage 1200/2014",
        "reference": "1234/2014",
        "date": "2014-04-04",
        "paperType": "Beantwortung einer Anfrage",
        "relatedPaper": [
            "https://oparl.example.org/paper/0"
        ],
        "mainFile": {
            "id": "https://oparl.example.org/file/57737",
            "type": "https://schema.oparl.org/1.0/File",
            "name": "Anlage 1 zur Anfrage",
            "fileName": "anlage_1_zur_anfrage.pdf",
            "mimeType": "application/pdf",
            "date": "2013-01-04",
            "sha1Checksum": "d749751af44a32c818b9b1e1515251c67734f5d2",
            "size": 82930,
            "accessUrl": "https://oparl.example.org/file/57737.pdf",
            "downloadUrl": "https://oparl.example.org/file/download/57737.pdf",
            "license": "http://www.opendefinition.org/licenses/cc-by",
            "created": "2013-01-04T07:54:13+01:00",
            "modified": "2013-01-04T07:54:13+01:00"
        },
        "auxiliaryFile": [ """ + file_sane + """ ],
        "location": [
            {
                "id": "https://oparl.example.org/locations/0",
                "type": "https://schema.oparl.org/1.0/Location",
                "description": "Honschaftsstraße 312, Köln",
                "geometry": {
                    "type": "Point",
                    "coordinates": [
                        7.03291,
                        50.98249
                    ]
                }
            }
        ],
        "originatorPerson": [
            "https://oparl.example.org/person/0"
        ],
        "originatorOrganization": [
            "https://oparl.example.org/organization/0"
        ],
        "consultation": [""" + consultation_sane + """],
        "underDirectionOf": [
            "https://oparl.example.org/organization/0"
        ],
        "created": "2013-01-08T12:05:27+00:00",
        "modified": "2013-01-08T12:05:27+00:00"
    }
    """;

    public const string paper_list_sane = """
    {
        "pagination": {
            "totalElements":1,
            "elementsPerPage":1,
            "currentPage":1,
            "totalPages":1
        },
        "data": [
            """+ paper_sane +"""
        ],
        "links":{}
    }
    """;

    public const string agenda_item_sane = """
    {
        "id": "https://oparl.example.org/agendaitem/0",
        "type": "https://schema.oparl.org/1.0/AgendaItem",
        "meeting": "https://oparl.example.org/meeting/0",
        "number": "10.1",
        "name": "Satzungsänderung für Ausschreibungen",
        "public": true,
        "consultation": "https://oparl.example.org/consultation/0",
        "result": "Geändert beschlossen",
        "resolutionText": "Der Beschluss weicht wie folgt vom Antrag ab: ...",
        "resolutionFile": """+ file_sane +""",
        "auxiliaryFile": ["""+ file_sane +"""],
        "start": "2012-02-06T12:01:00+00:00",
        "end": "2012-02-08T14:05:27+00:00",
        "created": "2012-01-06T12:01:00+00:00",
        "modified": "2012-08-16T14:05:27+00:00"
    }
    """;

    public const string consultation_sane = """
    {
        "id": "https://oparl.example.org/consultation/0",
        "type": "https://schema.oparl.org/1.0/Consultation",
        "agendaItem": "https://oparl.example.org/agendaitem/0",
        "meeting": "https://oparl.example.org/meeting/0",
        "organization": ["https://oparl.example.org/organization/0"],
        "authoritative": false,
        "role": "Beschlussfassung"
    }
    """;
}
