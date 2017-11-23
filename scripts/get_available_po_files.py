#!/usr/bin/env python3

from sys import argv

if __name__ == '__main__':
    root = argv[1]
    langs = []
    with open(root + '/po/LINGUAS', 'r') as f:
        for lang in f.readlines():
            langs.append(lang.strip())

    print(langs)