#!/usr/bin/env python3
"""
@Author: King
@Date: 2023-05-03 21:46:45
@Email: linsy_king@sjtu.edu.cn
"""

import typer
import os
import shutil
import json
from .updater import Updater

app = typer.Typer(add_completion=False, help="Messenger CLI")
API_VERSION = "0.3.0"


class Messenger:
    config = None

    def __init__(self) -> None:
        """
        Check if `messager.json` exists and load it.
        """
        if os.path.exists("messenger.json"):
            with open("messenger.json", "r") as f:
                self.config = json.load(f)
            if "version" not in self.config:
                raise Exception("Messenger API version not found in the config file.")
            if self.config["version"] != API_VERSION:
                raise Exception(
                    f"Messenger API version not matched. I'm using v{API_VERSION}. You can edit messenger.json manually to upgrade/downgrade."
                )
        else:
            raise Exception(
                "messenger.json not found. Are you in the project initialized by the Messenger? Try `messenger init <your-project-name>`."
            )
        if not os.path.exists(".messenger"):
            print("Messenger files not found. Initializing...")
            os.system(f"git clone {self.config['template_repo']} .messenger --depth=1")

    def dump_config(self):
        with open("messenger.json", "w") as f:
            json.dump(self.config, f, indent=4, ensure_ascii=False)

    def add_scene(self, scene: str, raw: bool):
        if scene in self.config["scenes"]:
            raise Exception("Scene already exists.")
        self.config["scenes"][scene] = []
        self.dump_config()
        os.mkdir(f"src/Scenes/{scene}")
        if raw:
            Updater(
                [".messenger/scene/Raw/Model.elm"],
                [f"src/Scenes/{scene}/Model.elm"],
            ).rep(scene)
        else:
            Updater(
                [
                    ".messenger/scene/Layered/Model.elm",
                    ".messenger/scene/LayerBase.elm",
                ],
                [f"src/Scenes/{scene}/Model.elm", f"src/Scenes/{scene}/LayerBase.elm"],
            ).rep(scene)

    def update_scenes(self):
        """
        Update scene settings (AllScenes and SceneSettings)
        """
        scenes = self.config["scenes"]
        Updater([".messenger/scene/AllScenes.elm"], ["src/Scenes/AllScenes.elm"]).rep(
            "\n".join([f"import Scenes.{l}.Model as {l}" for l in scenes])
        ).rep(",\n".join([f'( "{l}", {l}.scene )' for l in scenes]))

    def add_component(self, name: str, scene: str, dir: str):
        """
        Add a component
        """

        if scene not in self.config["scenes"]:
            raise Exception("Scene doesn't exist.")

        if os.path.exists(f"src/Scenes/{scene}/{dir}/{name}"):
            raise Exception("Component already exists.")

        if not os.path.exists(f"src/Scenes/{scene}/{dir}"):
            os.mkdir(f"src/Scenes/{scene}/{dir}")

        if not os.path.exists(f"src/Scenes/{scene}/{dir}/ComponentBase.elm"):
            Updater(
                [".messenger/component/ComponentBase.elm"],
                [f"src/Scenes/{scene}/{dir}/ComponentBase.elm"],
            ).rep(scene)

        os.makedirs(f"src/Scenes/{scene}/{dir}/{name}", exist_ok=True)
        Updater(
            [
                ".messenger/component/UserComponent/Model.elm",
            ],
            [
                f"src/Scenes/{scene}/{dir}/{name}/Model.elm",
            ],
        ).rep(scene).rep(name)

    def format(self):
        os.system("elm-format src/ --yes")

    def add_layer(self, scene: str, layer: str, has_component: bool):
        """
        Add a layer to a scene
        """
        if scene not in self.config["scenes"]:
            raise Exception("Scene doesn't exist.")
        if layer in self.config["scenes"][scene]:
            raise Exception("Layer already exists.")
        if has_component and not os.path.exists(
            f"src/Scenes/{scene}/{dir}/ComponentBase.elm"
        ):
            raise Exception("Please first create a component.")
        self.config["scenes"][scene].append(layer)
        self.dump_config()
        os.mkdir(f"src/Scenes/{scene}/{layer}")
        if has_component:
            Updater(
                [
                    ".messenger/layer/ModelC.elm",
                ],
                [
                    f"src/Scenes/{scene}/{layer}/Model.elm",
                ],
            ).rep(scene).rep(layer)
        else:
            Updater(
                [
                    ".messenger/layer/Model.elm",
                ],
                [
                    f"src/Scenes/{scene}/{layer}/Model.elm",
                ],
            ).rep(scene).rep(layer)


def check_name(name: str):
    """
    Check if the the first character of the name is Capital
    """
    if name[0].islower():
        return name[0].capitalize() + name[1:]
    else:
        return name


@app.command()
def init(
    name: str,
    template_repo=typer.Option(
        "https://github.com/linsyking/messenger-templates",
        "--template-repo",
        "-t",
        help="Use customized repository for cloning templates.",
    ),
    template_tag=typer.Option(
        None,
        "--template-tag",
        "-b",
        help="Use the tag or branch of the repository to clone",
    ),
):
    input(
        f"""Thanks for using Messenger.
See https://github.com/linsyking/Messenger.git for more information.
Here is my plan:

- Create a directory named {name}
- Install the core Messenger library
- Install the elm packages needed

Press Enter to continue
"""
    )
    os.makedirs(name, exist_ok=True)
    os.chdir(name)
    if template_tag:
        os.system(f"git clone -b {template_tag} {template_repo} .messenger --depth=1")
    else:
        os.system(f"git clone {template_repo} .messenger --depth=1")
    shutil.copytree(".messenger/src/", "./src")
    shutil.copytree(".messenger/public/", "./public")
    shutil.copy(".messenger/.gitignore", "./.gitignore")
    shutil.copy(".messenger/Makefile", "./Makefile")
    shutil.copy(".messenger/elm.json", "./elm.json")

    os.makedirs("src/Scenes", exist_ok=True)
    os.makedirs("assets", exist_ok=True)

    print("Creating elm.json...")
    initObject = {"version": API_VERSION, "template_repo": template_repo, "scenes": {}}
    with open("messenger.json", "w") as f:
        json.dump(initObject, f, indent=4, ensure_ascii=False)
    print("Installing dependencies...")
    os.system("elm make")
    print("Done!")
    print(f"Now please go to {name} and add scenes and components.")


@app.command()
def component(
    scene: str,
    name: str,
    dir: str = typer.Option(
        "Components", "--dir", "-d", help="Directory to store components"
    ),
):
    name = check_name(name)
    scene = check_name(scene)
    msg = Messenger()
    input(
        f"You are going to create a component named {name} in {scene}/{dir}, continue?"
    )
    msg.add_component(name, scene, dir)
    msg.format()
    print("Done!")


@app.command()
def update():
    msg = Messenger()
    input(f"You are going to regenerate elm files based on settings, continue?")
    msg.update_scenes()
    msg.format()
    print("Done!")


@app.command()
def scene(
    name: str,
    raw: bool = typer.Option(False, "--raw", help="Use raw scene without layers"),
):
    name = check_name(name)
    msg = Messenger()
    input(f"You are going to create a scene named {name}, continue?")
    msg.add_scene(name, raw)
    msg.update_scenes()
    msg.format()
    print("Done!")


@app.command()
def layer(
    scene: str,
    layer: str,
    has_component: bool = typer.Option(
        False, "--with-component", "-c", help="Use components in this layer"
    ),
):
    scene = check_name(scene)
    layer = check_name(layer)
    msg = Messenger()
    input(
        f"You are going to create a layer named {layer} under scene {scene}, continue?"
    )
    msg.add_layer(scene, layer, has_component)
    msg.format()
    print("Done!")


if __name__ == "__main__":
    app()
