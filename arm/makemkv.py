#!/usr/bin/python3

import sys
import os
import logging
import subprocess
import time
import shlex

from config import cfg


def makemkv(logfile, devpath, label):
    """
    Rip Blurays with MakeMKV\n
    logfile = Location of logfile to redirect MakeMKV logs to\n
    devpath = Path to disc\n
    label = Name of dvd to create subdirectory\n

    Returns path to ripped files.
    """

    logging.info("Starting MakeMKV rip. Method is " + cfg['RIPMETHOD'])

    # get MakeMKV disc number
    logging.debug("Getting MakeMKV disc number")
    cmd = 'makemkvcon -r info disc:9999  |grep {0} |grep -oP \'(?<=:).*?(?=,)\''.format(
                devpath
    )

    try:
        mdisc = subprocess.check_output(
            cmd,
            shell=True
        ).decode("utf-8")
        logging.info("MakeMKV disc number: " + mdisc.strip())
        # print("mdisc is: " + mdisc)
    except subprocess.CalledProcessError as mdisc_error:
        err = "Call to makemkv failed with code: " + str(mdisc_error.returncode) + "(" + str(mdisc_error.output) + ")"
        logging.error(err)
        # print("Error: " + err)
        return

    # get filesystem in order
    rawpath = os.path.join(cfg['RAWPATH'], label)
    logging.info("Destination is " + rawpath)

    if not os.path.exists(rawpath):
        try:
            os.makedirs(rawpath)
        except OSError:
            # logging.error("Couldn't create the base file path: " + rawpath + " Probably a permissions error")
            err = "Couldn't create the base file path: " + rawpath + " Probably a permissions error"
    else:
        logging.info(rawpath + " exists.  Adding timestamp.")
        ts = round(time.time() * 100)
        rawpath = os.path.join(cfg['RAWPATH'], label + "_" + str(ts))
        logging.info("rawpath is " + rawpath)
        try:
            os.makedirs(rawpath)
        except OSError:
            # logging.error("Couldn't create the base file path: " + rawpath + " Probably a permissions error")
            err = "Couldn't create the base file path: " + rawpath + " Probably a permissions error"
            sys.exit(err)

    # rip bluray
    if cfg['RIPMETHOD'] == "backup":
        cmd = 'makemkvcon backup --decrypt {0} -r disc:{1} {2}>> {3}'.format(
            cfg['MKV_ARGS'],
            mdisc.strip(),
            shlex.quote(rawpath),
            logfile
        )
        logging.info("Backing up with the following command: " + cmd)
    elif cfg['RIPMETHOD'] == "mkv":
        cmd = 'makemkvcon mkv {0} -r dev:{1} all {2} --minlength={3}>> {4}'.format(
            cfg['MKV_ARGS'],
            devpath,
            shlex.quote(rawpath),
            cfg['MINLENGTH'],
            logfile
        )
        logging.info("Ripping with the following command: " + cmd)
    else:
        logging.info("I'm confused what to do....  Passing on MakeMKV")

    try:
        mkv = subprocess.run(
            cmd,
            shell=True
        )
        # ).decode("utf-8")
        # print("mkv is: " + mkv)
        logging.debug("The exit code for MakeMKV is: " + str(mkv.returncode))
    except subprocess.CalledProcessError as mdisc_error:
        err = "Call to MakeMKV failed with code: " + str(mdisc_error.returncode) + "(" + str(mdisc_error.output) + ")"
        logging.error(err)
        # print("Error: " + mkv)
        return None

    os.system("eject " + devpath)

    logging.info("Exiting MakeMKV processing with return value of: " + rawpath)
    return(rawpath)