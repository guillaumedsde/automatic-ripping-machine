#!/usr/bin/python3

from environs import Env

env = Env()
env.read_env()

cfg = dict(env.dump())