#!/usr/bin/python

import os
import os.path
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
    parser_edit.set_defaults(func=edit)

    args = parser.parse_args()
    args.path = os.path.expanduser(args.path)
    args.func(args)

def update(args):
    print "--> Attempting to update bMotion from github"
    try:
        subprocess.call(['/usr/bin/git', 'pull'], cwd=os.path.join(args.path, 'scripts', 'bmotion'))
    except Exception, e:
        print "    Oh no :( it all broke"
        print e

def edit(args):
    if args.file == "eggdrop":
        print "--> Editing eggdrop config"
        filename = "eggdrop.conf"
    elif args.file == "bmotion":
        print "--> Editing bmotion config"
        filename = "scripts/bmotion/local/settings.tcl"
    else:
        print "Invalid file to edit specified!"

    if args.editor == None:
        editor = os.getenv("EDITOR")
        if editor == None:
            print "    Cannot edit without EDITOR being set in your environment, or --editor on my command line"
            sys.exit(1)
    else:
        editor = args.editor

    try:
        subprocess.call([editor, os.path.join(args.path, filename)])
    except Exception, e:
        print "    Unable to launch editor, sorry :("
        print e


if __name__ == "__main__":
    main()
