#!/usr/bin/env python3
"""
@Author: King
@Date: 2023-05-03 21:46:45
@Email: linsy_king@sjtu.edu.cn
"""

import typer
import os
import shutil

app = typer.Typer(add_completion=False)


class Messenger:
    def __init__(self) -> None:
        pass


@app.command()
def init(
    name: str,
    use_full: bool = typer.Option(
        True,
        prompt="""Thanks for using Messenger.
There are currently two main versions you can use.
The core version only has the basic framework. There are no core engine support. Use this version if you want to create your own game engine.
The full version includes a core engine template which has a basic 2D physics engine and high-performance game component support. It enables you to create a level quickly.
See more instructions on https://github.com/linsyking/Messenger.git
Do you want to install the full version of Messerger?""",
    ),
):
    if use_full:
        version = "full"
    else:
        version = "core"
    input(
        f"""Here is my plan:
- Create a directory named {name}
- Use the {version} Messenger version
- Elm install the packages needed
Press Enter to continue
"""
    )
    os.makedirs(name, exist_ok=True)
    os.chdir(name)
    os.system(
        f"git clone https://github.com/linsyking/Messenger.git .messenger --depth=1"
    )
    shutil.copytree(".messenger/Templates/core/", "./src")
    shutil.copy(".messenger/Templates/.gitignore", "./.gitignore")
    shutil.copy(".messenger/Templates/elm.json", "./elm.json")


if __name__ == "__main__":
    app()
