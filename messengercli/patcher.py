#!/usr/bin/env python3
'''
@Author: King
@Date: 2023-05-27 23:23:39
@Email: linsy_king@sjtu.edu.cn
'''

from git import Repo
import os

def patch():
    repo = Repo(".messenger")
    oldsha = repo.head.commit.hexsha
    print(f"Current commit: {oldsha}")
    remote = repo.remote()
    print(f"Pulling...")
    remote.pull()
    newsha = repo.head.commit.hexsha
    print(f"Current commit: {newsha}")
    if newsha == oldsha:
        print("No update found.")
        return
    else:
        # Create patch
        os.chdir(".messenger")
        print("Generating patch...")
        os.system(f"git format-patch {oldsha}..{newsha} --output fix.patch -- src/")
        os.chdir("..")
        print("Applying patch...")
        os.system("git am -3 .messenger/fix.patch")
