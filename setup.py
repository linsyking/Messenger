#!/usr/bin/env python3

from setuptools import setup

setup(
    entry_points={
        "console_scripts": ["messenger=messengercli.command_line:main"],
    }
)
