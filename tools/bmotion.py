#!/usr/bin/python

import os
import os.path
import sys
import subprocess
import argparse
import tempfile

def main():
    parser = argparse.ArgumentParser(description='bMotion maintenance tool')
    parser.add_argument("-p", "--path",
                        help="path to EGGDROP install",
                        default="~/eggdrop")
    subparsers = parser.add_subparsers()

    parser_update = subparsers.add_parser('update', help="update bmotion's code")
    parser_update.set_defaults(func=update)

    parser_edit = subparsers.add_parser('edit', help="edit config files")
    parser_edit.add_argument("-f", "--file",
                            help="which file to edit",
                            choices=['eggdrop', 'bmotion'],
                            required=True)
    parser_edit.add_argument("--editor",
                            help="which editor to launch; default is EDITOR from env")
    parser_edit.set_defaults(func=edit)

    parser_cron = subparsers.add_parser('cron', help="add bmotion to startup")
    parser_cron.add_argument("-i", "--install",
                            help="install @reboot crontab if needed",
                            action="store_true", default=False)
    parser_cron.set_defaults(func=cron)

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


def cron(args):
    try:
        cron_text = subprocess.check_output(["crontab", "-l"])
    except:
        cron_text = ""

    if "eggdrop" in cron_text:
        print "--> eggdrop is started by cron"
        return
    
    print "--> eggdrop is not started by cron"

    # Yes, I know this isn't great
    if args.install:
        try:
            (fd, filename) = tempfile.mkstemp()
            fh = os.fdopen(fd, "w")
        except Exception, e:
            print "Unable to make temp file for updating cron"
            print e
            sys.exit(2)

        print >> fh, "@reboot %s" % os.path.join(os.path.expanduser(args.path), "eggdrop")
        fh.close()

        try:
            subprocess.check_call(["crontab", filename])
            print "--> Added eggdrop to @reboot cron" 
        except Exception, e:
            print "Failed to update crontab from %s" % filename
            print e

        try:
            os.unlink(filename)
        except:
            print "Unable to delete temporary file %s" % filename


if __name__ == "__main__":
    main()
