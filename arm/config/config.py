#!/usr/bin/python3

# import os
# import re
import yaml

yamlfile = "/config/arm.yaml"

with open(yamlfile, "r") as f:
    cfg = yaml.load(f)
