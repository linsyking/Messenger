#!/usr/bin/env python3

import typer
import os
import shutil
import json
from .updater import Updater

app = typer.Typer(add_completion=False, help="Messenger CLI")
API_VERSION = "1.0.0"


class Messenger:
    config = None

    def __init__(self) -> None:
        """
        Check if `messenger.json` exists and load it.
        """
        if os.path.exists("messenger.json"):
            with open("messenger.json", "r") as f:
                self.config = json.load(f)
            if "version" not in self.config:
                raise Exception("Messenger API version not found in the config file.")
            if self.config["version"] != API_VERSION:
                raise Exception(
                    f"Messenger configuration file API version not matched. I'm using v{API_VERSION}. You can edit messenger.json manually to upgrade/downgrade."
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

    def add_level(self, name: str, sceneproto: str):
        """
        Add a level
        """
        if sceneproto not in self.config["sceneprotos"]:
            raise Exception("Sceneproto doesn't exist.")
        if name in self.config["scenes"]:
            raise Exception("Level or scene already exists.")
        self.config["scenes"][name] = []
        self.dump_config()
        os.mkdir(f"src/Scenes/{name}")
        raw = self.config["sceneprotos"][sceneproto]["raw"]
        if raw:
            Updater(
                [".messenger/sceneproto/Raw/Level.elm"],
                [f"src/Scenes/{name}/Model.elm"],
            ).rep(name).rep(sceneproto)
        else:
            Updater(
                [".messenger/sceneproto/Layered/Level.elm"],
                [f"src/Scenes/{name}/Model.elm"],
            ).rep(name).rep(sceneproto)

    def add_scene(self, scene: str, raw: bool, is_proto: bool, init: bool):
        """
        Add a scene
        """
        if is_proto:
            if not os.path.exists(f"src/SceneProtos"):
                os.mkdir(f"src/SceneProtos")
            if scene in self.config["sceneprotos"]:
                raise Exception("Sceneproto already exists.")
            self.config["sceneprotos"][scene] = {"raw": raw, "layers": []}
            self.dump_config()
            os.mkdir(f"src/SceneProtos/{scene}")

            Updater(
                [".messenger/scene/Init.elm"],
                [f"src/SceneProtos/{scene}/Init.elm"],
            ).rep("SceneProtos").rep(scene)
            if raw:
                Updater(
                    [".messenger/sceneproto/Raw/Model.elm"],
                    [f"src/SceneProtos/{scene}/Model.elm"],
                ).rep(scene)
            else:
                Updater(
                    [
                        ".messenger/sceneproto/Layered/Model.elm",
                        ".messenger/sceneproto/SceneBase.elm",
                    ],
                    [
                        f"src/SceneProtos/{scene}/Model.elm",
                        f"src/SceneProtos/{scene}/SceneBase.elm",
                    ],
                ).rep(scene)
        else:
            if scene in self.config["scenes"]:
                raise Exception("Scene already exists.")
            self.config["scenes"][scene] = {"layers": []}
            self.dump_config()
            os.mkdir(f"src/Scenes/{scene}")
            if init:
                Updater(
                    [".messenger/scene/Init.elm"],
                    [f"src/Scenes/{scene}/Init.elm"],
                ).rep("Scenes").rep(scene)
            if raw:
                Updater(
                    [".messenger/scene/Raw/Model.elm"],
                    [f"src/Scenes/{scene}/Model.elm"],
                ).rep(scene)
            else:
                Updater(
                    [
                        ".messenger/scene/Layered/Model.elm",
                        ".messenger/scene/SceneBase.elm",
                    ],
                    [
                        f"src/Scenes/{scene}/Model.elm",
                        f"src/Scenes/{scene}/SceneBase.elm",
                    ],
                ).rep(scene)

    def update_scenes(self):
        """
        Update scene settings (AllScenes and SceneSettings)
        """
        scenes = self.config["scenes"]
        Updater([".messenger/scene/AllScenes.elm"], ["src/Scenes/AllScenes.elm"]).rep(
            "\n".join([f"import Scenes.{l}.Model as {l}" for l in scenes])
        ).rep(",\n".join([f'( "{l}", {l}.scene )' for l in scenes]))

    def add_component(
        self, name: str, scene: str, dir: str, is_proto: bool, init: bool
    ):
        """
        Add a component
        """
        if is_proto:
            if scene not in self.config["sceneprotos"]:
                raise Exception("Sceneproto doesn't exist.")

            if os.path.exists(f"src/SceneProtos/{scene}/{dir}/{name}"):
                raise Exception("Component already exists.")

            if not os.path.exists(f"src/SceneProtos/{scene}/{dir}"):
                os.mkdir(f"src/SceneProtos/{scene}/{dir}")

            if not os.path.exists(f"src/SceneProtos/{scene}/SceneBase.elm"):
                Updater(
                    [".messenger/sceneproto/SceneBase.elm"],
                    [f"src/SceneProtos/{scene}/SceneBase.elm"],
                ).rep(scene)

            if not os.path.exists(f"src/SceneProtos/{scene}/{dir}/ComponentBase.elm"):
                Updater(
                    [".messenger/component/ComponentBase.elm"],
                    [f"src/SceneProtos/{scene}/{dir}/ComponentBase.elm"],
                ).rep("SceneProtos").rep(scene).rep(dir)

            os.makedirs(f"src/SceneProtos/{scene}/{dir}/{name}", exist_ok=True)
            Updater(
                [
                    ".messenger/component/UserComponent/Model.elm",
                ],
                [
                    f"src/SceneProtos/{scene}/{dir}/{name}/Model.elm",
                ],
            ).rep("SceneProtos").rep(scene).rep(dir).rep(name)

            if init:
                Updater(
                    [".messenger/component/Init.elm"],
                    [f"src/SceneProtos/{scene}/{dir}/{name}/Init.elm"],
                ).rep("SceneProtos").rep(scene).rep(dir).rep(name)
        else:
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
                ).rep("Scenes").rep(scene).rep(dir)

            if not os.path.exists(f"src/Scenes/{scene}/SceneBase.elm"):
                Updater(
                    [".messenger/scene/SceneBase.elm"],
                    [f"src/Scenes/{scene}/SceneBase.elm"],
                ).rep(scene)
            os.makedirs(f"src/Scenes/{scene}/{dir}/{name}", exist_ok=True)
            Updater(
                [
                    ".messenger/component/UserComponent/Model.elm",
                ],
                [
                    f"src/Scenes/{scene}/{dir}/{name}/Model.elm",
                ],
            ).rep("Scenes").rep(scene).rep(dir).rep(name)

            if init:
                Updater(
                    [".messenger/component/Init.elm"],
                    [f"src/Scenes/{scene}/{dir}/{name}/Init.elm"],
                ).rep("Scenes").rep(scene).rep(dir).rep(name)

    def format(self):
        os.system("elm-format src/ --yes")

    def add_layer(
        self,
        scene: str,
        layer: str,
        has_component: bool,
        is_proto: bool,
        dir: str,
        init: bool,
    ):
        """
        Add a layer to a scene
        """
        if is_proto:
            if scene not in self.config["sceneprotos"]:
                raise Exception("Scene doesn't exist.")
            if layer in self.config["sceneprotos"][scene]["layers"]:
                raise Exception("Layer already exists.")
            if has_component and not os.path.exists(
                f"src/SceneProtos/{scene}/{dir}/ComponentBase.elm"
            ):
                raise Exception("Please first create a component.")

            if not os.path.exists(f"src/SceneProtos/{scene}/SceneBase.elm"):
                Updater(
                    [".messenger/sceneproto/SceneBase.elm"],
                    [f"src/SceneProtos/{scene}/SceneBase.elm"],
                ).rep(scene)
            self.config["sceneprotos"][scene]["layers"].append(layer)
            self.dump_config()
            os.mkdir(f"src/SceneProtos/{scene}/{layer}")
            if init:
                Updater(
                    [".messenger/layer/Init.elm"],
                    [f"src/SceneProtos/{scene}/{layer}/Init.elm"],
                ).rep("SceneProtos").rep(scene).rep(layer)
            if has_component:
                Updater(
                    [
                        ".messenger/layer/ModelC.elm",
                    ],
                    [
                        f"src/SceneProtos/{scene}/{layer}/Model.elm",
                    ],
                ).rep("SceneProtos").rep(scene).rep(layer).rep(dir)
            else:
                Updater(
                    [
                        ".messenger/layer/Model.elm",
                    ],
                    [
                        f"src/SceneProtos/{scene}/{layer}/Model.elm",
                    ],
                ).rep("SceneProtos").rep(scene).rep(layer)
        else:
            if scene not in self.config["scenes"]:
                raise Exception("Scene doesn't exist.")
            if layer in self.config["scenes"][scene]["layers"]:
                raise Exception("Layer already exists.")
            if has_component and not os.path.exists(
                f"src/Scenes/{scene}/{dir}/ComponentBase.elm"
            ):
                raise Exception("Please first create a component.")

            if not os.path.exists(f"src/Scenes/{scene}/SceneBase.elm"):
                Updater(
                    [".messenger/scene/SceneBase.elm"],
                    [f"src/Scenes/{scene}/SceneBase.elm"],
                ).rep(scene)
            self.config["scenes"][scene]["layers"].append(layer)
            self.dump_config()
            os.mkdir(f"src/Scenes/{scene}/{layer}")
            if init:
                Updater(
                    [".messenger/layer/Init.elm"],
                    [f"src/Scenes/{scene}/{layer}/Init.elm"],
                ).rep("Scenes").rep(scene).rep(layer)
            if has_component:
                Updater(
                    [
                        ".messenger/layer/ModelC.elm",
                    ],
                    [
                        f"src/Scenes/{scene}/{layer}/Model.elm",
                    ],
                ).rep("Scenes").rep(scene).rep(layer).rep(dir)
            else:
                Updater(
                    [
                        ".messenger/layer/Model.elm",
                    ],
                    [
                        f"src/Scenes/{scene}/{layer}/Model.elm",
                    ],
                ).rep("Scenes").rep(scene).rep(layer)


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
    initObject = {
        "version": API_VERSION,
        "template_repo": template_repo,
        "scenes": {},
        "sceneprotos": {},
    }
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
    compdir: str = typer.Option(
        "Components", "--cdir", "-cd", help="Directory to store components"
    ),
    is_proto: bool = typer.Option(
        False, "--proto", "-p", help="Create layer in sceneproto"
    ),
    init: bool = typer.Option(False, "--init", "-i", help="Create a `Init.elm` file"),
):
    name = check_name(name)
    scene = check_name(scene)
    compdir = check_name(compdir)
    msg = Messenger()
    input(
        f"You are going to create a component named {name} in {'SceneProtos' if is_proto else 'Scenes'}/{scene}/{compdir}, continue?"
    )
    msg.add_component(name, scene, compdir, is_proto, init)
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
    is_proto: bool = typer.Option(
        False, "--proto", "-p", help="Create layer in sceneproto"
    ),
    init: bool = typer.Option(False, "--init", "-i", help="Create a `Init.elm` file"),
):
    name = check_name(name)
    msg = Messenger()
    input(
        f"You are going to create a {'raw ' if raw else ''}{'sceneproto' if is_proto else 'scene'} named {name}, continue?"
    )
    msg.add_scene(name, raw, is_proto, init)
    msg.update_scenes()
    msg.format()
    print("Done!")


@app.command()
def level(sceneproto: str, name: str):
    name = check_name(name)
    sceneproto = check_name(sceneproto)
    msg = Messenger()
    input(
        f"You are going to create a level named {name} from sceneproto {sceneproto}, continue?"
    )
    msg.add_level(name, sceneproto)
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
    compdir: str = typer.Option(
        "Components", "--cdir", "-cd", help="Directory of components in the scene"
    ),
    is_proto: bool = typer.Option(
        False, "--proto", "-p", help="Create layer in sceneproto"
    ),
    init: bool = typer.Option(False, "--init", "-i", help="Create a `Init.elm` file"),
):
    scene = check_name(scene)
    layer = check_name(layer)
    msg = Messenger()
    input(
        f"You are going to create a layer named {layer} under {'sceneproto' if is_proto else 'scene'} {scene}, continue?"
    )
    msg.add_layer(scene, layer, has_component, is_proto, compdir, init)
    msg.format()
    print("Done!")


if __name__ == "__main__":
    app()
