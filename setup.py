#!/usr/bin/env python3

from setuptools import setup

setup(
    entry_points={
        "console_scripts": ["messengerc=messengercli.command_line:main"],
    }
)
