#!/usr/bin/env python3
"""
@Author: King
@Date: 2023-05-12 12:34:46
@Email: linsy_king@sjtu.edu.cn
"""
from __future__ import annotations


class Updater:
    proto: list[str] = []
    target: list[str] = []
    dollar = 0

    def __init__(self, proto: list[str], target: list[str]) -> None:
        self.proto = proto
        self.target = target
        if len(proto) != len(target):
            raise Exception("Proto and target should have the same length.")

    def rep(self, to_rep: str) -> Updater:
        for proto, target in zip(self.proto, self.target):
            if self.dollar == 0:
                with open(proto, "r") as f:
                    content = f.read()
                content = content.replace(f"${0}", to_rep)
                # Write
                with open(target, "w") as f:
                    f.write(content)
            else:
                with open(target, "r") as f:
                    content = f.read()
                content = content.replace(f"${self.dollar}", to_rep)
                # Write
                with open(target, "w") as f:
                    f.write(content)
        self.dollar += 1
        return self
