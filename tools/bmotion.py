#!/usr/bin/python

import os
import sys
import subprocess
import argparse

def main():
    parser = argparse.ArgumentParser(description='bMotion maintenance tool')
    parser.add_argument("-p", "--path",
                        help="path to EGGDROP install",
                        default="~/eggdrop")
    subparsers = parser.add_subparsers()

    parser_update = subparsers.add_parser('update')
    parser_update.set_defaults(func=update)

    parser_edit = subparsers.add_parser('edit')
    parser_edit.add_argument("-f", "--file",
                            help="which file to edit",
                            choices=['eggdrop', 'bmotion'],
                            required=True)
    parser_edit.add_argument("--editor",
                            help="which editor to launch; default is EDITOR from env")
    parser_edit.set_defaults(func=update)

    args = parser.parse_args()
    args.func(args)

def update(args):
    print "--> Attempting to update bMotion from github"
    try:
        subprocess.call(['/usr/bin/git', 'pull'], cwd=args.path)
    except Exception, e:
        print "    Oh no :( it all broke"
        print e

def edit(args):
    if args.file == "eggdrop":
        print "--> Editing eggdrop config"
        if args.editor == None:
            editor = os.getenv("EDITOR")
            if editor == None:
                print "    Cannot edit without EDITOR being set in your environment, or --editor on my command line"
                sys.exit(1)
        else:
            editor = args.editor

        try:
            subprocess.call([editor, os.path.join(args.path, 'eggdrop.conf')])
        except Exception, e:
            print "    Unable to launch editor, sorry :("
            print e


