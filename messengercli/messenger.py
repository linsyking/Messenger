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
from .patcher import patch

app = typer.Typer(add_completion=False, help="Messenger CLI")
API_VERSION = "0.2.5"


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
                    f"Messenger API version not matched. I'm using v{API_VERSION}. You can edit messenger.json manually to upgrade."
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

    def add_scene(self, scene: str):
        if scene in self.config["scenes"] or scene in self.config["sceneprotos"]:
            raise Exception("Scene already exists.")
        self.config["scenes"][scene] = []
        self.dump_config()
        os.mkdir(f"src/Scenes/{scene}")

        Updater(
            [
                ".messenger/scene/Sample/Export.elm",
                ".messenger/scene/Sample/Global.elm",
                ".messenger/scene/Sample/Model.elm",
                ".messenger/scene/Sample/LayerBase.elm",
                ".messenger/scene/Sample/SceneInit.elm",
            ],
            [
                f"src/Scenes/{scene}/Export.elm",
                f"src/Scenes/{scene}/Global.elm",
                f"src/Scenes/{scene}/Model.elm",
                f"src/Scenes/{scene}/LayerBase.elm",
                f"src/Scenes/{scene}/SceneInit.elm",
            ],
        ).rep(scene)

        # Modify Scene
        with open("src/Lib/Scene/Base.elm", "r") as f:
            scenebase = f.read()
        new_scenebase = scenebase.replace(
            "type SceneInitData\n    =",
            f"type SceneInitData\n    = {scene}InitData {scene}Init\n    |",
        ).replace(
            "import Lib.Env.Env exposing (Env)",
            f"import Lib.Env.Env exposing (Env)\nimport Scenes.{scene}.SceneInit exposing ({scene}Init)",
        )
        with open("src/Lib/Scene/Base.elm", "w") as f:
            f.write(new_scenebase)

    def update_scenes(self):
        """
        Update scene settings (AllScenes and SceneSettings)
        """
        scenes = self.config["scenes"]
        sceneprotos = self.config["sceneprotos"]
        Updater([".messenger/scene/AllScenes.elm"], ["src/Scenes/AllScenes.elm"]).rep(
            "\n".join(
                [
                    f"import Scenes.{l}.Export as {l}\nimport Scenes.{l}.Global as {l}G"
                    for l in scenes
                ]
                + [
                    f"import SceneProtos.{l}.Export as {l}\nimport SceneProtos.{l}.Global as {l}G"
                    for l in sceneprotos
                ]
                + [
                    (
                        "\n".join(
                            f"import Scenes.{l}.Export as {l}"
                            for l in sceneprotos[s]["levels"]
                        )
                    )
                    for s in sceneprotos
                ]
            )
        ).rep(
            ",\n".join(
                [f'( "{l}", {l}G.sceneToST {l}.scene )' for l in scenes]
                + [
                    (
                        ",\n".join(
                            f'( "{l}", {s}G.sceneToST <| {s}.genScene {l}.game )'
                            for l in sceneprotos[s]["levels"]
                        )
                    )
                    for s in sceneprotos
                ]
            )
        )

        Updater(
            [".messenger/scene/SceneSettings.elm"], ["src/Scenes/SceneSettings.elm"]
        ).rep(
            "\n".join(
                [f"import Scenes.{l}.Export as {l}" for l in scenes]
                + [f"import SceneProtos.{l}.Export as {l}" for l in sceneprotos]
            )
        ).rep(
            "\n    | ".join(
                [f"{l}DataT {l}.Data" for l in scenes]
                + [f"{l}DataT {l}.Data" for l in sceneprotos]
            )
        )

    def add_sceneproto(self, scene: str):
        """
        Add a sceneproto
        """
        if scene in self.config["scenes"] or scene in self.config["sceneprotos"]:
            raise Exception("Sceneproto already exists.")
        self.config["sceneprotos"][scene] = {"levels": [], "layers": []}
        self.dump_config()
        os.mkdir(f"src/SceneProtos/{scene}")
        os.mkdir(f"src/SceneProtos/{scene}/GameComponent")
        os.mkdir(f"src/SceneProtos/{scene}/GameComponents")

        Updater(
            [
                ".messenger/sceneproto/scene/Export.elm",
                ".messenger/sceneproto/scene/Global.elm",
                ".messenger/sceneproto/scene/Model.elm",
                ".messenger/sceneproto/scene/LayerBase.elm",
                ".messenger/sceneproto/scene/SceneInit.elm",
                ".messenger/sceneproto/gamecomponent/Base.elm",
                ".messenger/sceneproto/gamecomponent/Handler.elm",
            ],
            [
                f"src/SceneProtos/{scene}/Export.elm",
                f"src/SceneProtos/{scene}/Global.elm",
                f"src/SceneProtos/{scene}/Model.elm",
                f"src/SceneProtos/{scene}/LayerBase.elm",
                f"src/SceneProtos/{scene}/SceneInit.elm",
                f"src/SceneProtos/{scene}/GameComponent/Base.elm",
                f"src/SceneProtos/{scene}/GameComponent/Handler.elm",
            ],
        ).rep(scene)

        # Modify Scene
        with open("src/Lib/Scene/Base.elm", "r") as f:
            scenebase = f.read()
        new_scenebase = scenebase.replace(
            "type SceneInitData\n    =",
            f"type SceneInitData\n    = {scene}InitData {scene}Init\n    |",
        ).replace(
            "import Lib.Env.Env exposing (Env)",
            f"import Lib.Env.Env exposing (Env)\nimport SceneProtos.{scene}.SceneInit exposing ({scene}Init)",
        )
        with open("src/Lib/Scene/Base.elm", "w") as f:
            f.write(new_scenebase)

    def add_sceneproto_layer(self, sceneproto: str, layer: str):
        """
        Add a layer in one sceneproto
        """
        if sceneproto not in self.config["sceneprotos"]:
            raise Exception("Sceneproto does not exist.")
        if layer in self.config["sceneprotos"][sceneproto]["layers"]:
            raise Exception("Layer already exists.")
        self.config["sceneprotos"][sceneproto]["layers"].append(layer)
        self.dump_config()
        os.mkdir(f"src/SceneProtos/{sceneproto}/{layer}")

        Updater(
            [
                ".messenger/sceneproto/layer/Model.elm",
                ".messenger/sceneproto/layer/Global.elm",
                ".messenger/sceneproto/layer/Export.elm",
                ".messenger/sceneproto/layer/Common.elm",
            ],
            [
                f"src/SceneProtos/{sceneproto}/{layer}/Model.elm",
                f"src/SceneProtos/{sceneproto}/{layer}/Global.elm",
                f"src/SceneProtos/{sceneproto}/{layer}/Export.elm",
                f"src/SceneProtos/{sceneproto}/{layer}/Common.elm",
            ],
        ).rep(sceneproto).rep(layer)

    def update_sceneproto_layers(self, sceneproto: str):
        """
        Update layers of sceneproto
        """
        layers = self.config["sceneprotos"][sceneproto]["layers"]
        Updater(
            [".messenger/sceneproto/scene/LayerSettings.elm"],
            [f"src/SceneProtos/{sceneproto}/LayerSettings.elm"],
        ).rep(sceneproto).rep(
            "\n".join(
                [f"import SceneProtos.{sceneproto}.{l}.Export as {l}" for l in layers]
            )
        ).rep(
            "\n    | ".join([f"{l}Data {l}.Data" for l in layers])
        )

        Updater(
            [".messenger/sceneproto/scene/Common.elm"],
            [f"src/SceneProtos/{sceneproto}/Common.elm"],
        ).rep(sceneproto).rep(
            "\n".join(
                [
                    f"import SceneProtos.{sceneproto}.{l}.Export as {l}\nimport SceneProtos.{sceneproto}.{l}.Global as {l}G"
                    for l in layers
                ]
            )
        ).rep(
            ",\n".join(
                [
                    f"{l}G.getLayerT <| {l}.initLayer (addCommonData nullCommonData env) layerInitData"
                    for l in layers
                ]
            )
        )

    def add_level(self, sceneproto: str, level: str):
        """
        Add a level generated by sceneproto
        """
        if sceneproto not in self.config["sceneprotos"]:
            raise Exception("Sceneproto does not exist.")
        if level in self.config["sceneprotos"][sceneproto]["levels"]:
            raise Exception("Level already exists.")
        self.config["sceneprotos"][sceneproto]["levels"].append(level)
        self.dump_config()
        os.mkdir(f"src/Scenes/{level}")
        Updater(
            [".messenger/sceneproto/Export.elm"], [f"src/Scenes/{level}/Export.elm"]
        ).rep(level).rep(sceneproto)

    def add_component(self, name: str, dir=""):
        """
        Add a component
        """
        from os.path import join

        if not os.path.exists(join("src/Components", dir)):
            raise Exception("Directory doesn't exist.")
        if os.path.exists(join("src/Components", dir, name)):
            raise Exception("Component already exists.")
        dir = join(dir, name)
        os.mkdir(join("src/Components", dir))
        modPath = dir.replace("/", ".")
        Updater(
            [
                ".messenger/component/Sample/Sample.elm",
                ".messenger/component/Sample/Export.elm",
            ],
            [
                join("src/Components", dir, f"{name}.elm"),
                join("src/Components", dir, "Export.elm"),
            ],
        ).rep(modPath).rep(name)

    def add_gamecomponent(self, sceneproto: str, gc: str):
        """
        Add a GameComponent to a SceneProto
        """
        if sceneproto not in self.config["sceneprotos"]:
            raise Exception("SceneProto doesn't exist.")

        os.mkdir(f"src/SceneProtos/{sceneproto}/GameComponents/{gc}")
        Updater(
            [
                ".messenger/sceneproto/gamecomponent/Sample/Base.elm",
                ".messenger/sceneproto/gamecomponent/Sample/Export.elm",
                ".messenger/sceneproto/gamecomponent/Sample/Model.elm",
            ],
            [
                f"src/SceneProtos/{sceneproto}/GameComponents/{gc}/Base.elm",
                f"src/SceneProtos/{sceneproto}/GameComponents/{gc}/Export.elm",
                f"src/SceneProtos/{sceneproto}/GameComponents/{gc}/Model.elm",
            ],
        ).rep(sceneproto).rep(gc)

        # Modify GameComponent
        with open(f"src/SceneProtos/{sceneproto}/GameComponent/Base.elm", "r") as f:
            scenebase = f.read()
        new_scenebase = scenebase.replace(
            "type GameComponentInitData\n    =",
            f"type GameComponentInitData\n    = GC{gc}InitData {gc}Init\n    |",
        ).replace(
            "import Messenger.GeneralModel exposing (GeneralModel)",
            f"import Messenger.GeneralModel exposing (GeneralModel)\nimport SceneProtos.{sceneproto}.GameComponents.{gc}.Base exposing ({gc}Init)",
        )
        with open(f"src/SceneProtos/{sceneproto}/GameComponent/Base.elm", "w") as f:
            f.write(new_scenebase)

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
        self.config["scenes"][scene].append(layer)
        self.dump_config()
        os.mkdir(f"src/Scenes/{scene}/{layer}")

        Updater(
            [
                ".messenger/layer/Model.elm",
                ".messenger/layer/Global.elm",
                ".messenger/layer/Export.elm",
                ".messenger/layer/Common.elm",
            ],
            [
                f"src/Scenes/{scene}/{layer}/Model.elm",
                f"src/Scenes/{scene}/{layer}/Global.elm",
                f"src/Scenes/{scene}/{layer}/Export.elm",
                f"src/Scenes/{scene}/{layer}/Common.elm",
            ],
        ).rep(scene).rep(layer)
        if has_component:
            Updater(
                [
                    ".messenger/layer/Model_C.elm",
                    ".messenger/layer/Common_C.elm",
                ],
                [
                    f"src/Scenes/{scene}/{layer}/Model.elm",
                    f"src/Scenes/{scene}/{layer}/Common.elm",
                ],
            ).rep(scene).rep(layer)

    def update_layers(self, scene: str):
        """
        Update layer settings.
        """
        layers = self.config["scenes"][scene]

        Updater(
            [".messenger/scene/Sample/LayerSettings.elm"],
            [f"src/Scenes/{scene}/LayerSettings.elm"],
        ).rep(scene).rep(
            "\n".join([f"import Scenes.{scene}.{l}.Export as {l}" for l in layers])
        ).rep(
            "\n    | ".join([f"{l}Data {l}.Data" for l in layers])
        )
        Updater(
            [".messenger/scene/Sample/Common.elm"],
            [f"src/Scenes/{scene}/Common.elm"],
        ).rep(scene).rep(
            "\n".join(
                [
                    f"import Scenes.{scene}.{l}.Export as {l}\nimport Scenes.{scene}.{l}.Global as {l}G"
                    for l in layers
                ]
            )
        ).rep(
            ",\n".join(
                [
                    f"{l}G.getLayerT <| {l}.initLayer (addCommonData nullCommonData env) layerInitData"
                    for l in layers
                ]
            )
        )


@app.command()
def init(
    name: str,
    template_repo=typer.Option(
        "https://github.com/linsyking/messenger-templates",
        "--template-repo",
        "-t",
        help="Use customized repository for cloning templates.",
    ),
):
    input(
        f"""Thanks for using Messenger v{API_VERSION}.
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
    os.system(f"git clone {template_repo} .messenger --depth=1")
    shutil.copytree(".messenger/src/", "./src")
    shutil.copytree(".messenger/public/", "./public")
    shutil.copy(".messenger/.gitignore", "./.gitignore")
    shutil.copy(".messenger/Makefile", "./Makefile")
    shutil.copy(".messenger/make", "./make")
    shutil.copy(".messenger/elm.json", "./elm.json")

    os.makedirs("src/Scenes", exist_ok=True)
    os.makedirs("assets", exist_ok=True)
    os.makedirs("src/Components", exist_ok=True)
    os.makedirs("src/SceneProtos", exist_ok=True)

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
    name: str,
    dir=typer.Option(
        "", "--dir", "-d", help="Component module to create component in."
    ),
):
    msg = Messenger()
    input(f"You are going to create a component named {name}, continue?")
    msg.add_component(name, dir)
    msg.format()
    print("Done!")


@app.command()
def update(
    scene=typer.Option(False, "--scene", "-s", help="Update scenes."),
    scenelayer=typer.Option(
        None, "--scenelayer", "-sl", help="Update layers in that scene."
    ),
    sceneprotolayer=typer.Option(
        None,
        "--sceneprotolayer",
        "-spl",
        help="Update sceneproto layers in that sceneproto.",
    ),
):
    msg = Messenger()
    input(
        f"You are going to regenerate settings (including scenes, layers, sceneproto layers), continue?"
    )
    if scene:
        msg.update_scenes()
    if scenelayer is not None:
        msg.update_layers(scenelayer)
    if sceneprotolayer is not None:
        msg.update_sceneproto_layers(sceneprotolayer)
    msg.format()
    print("Done!")


@app.command()
def scene(name: str):
    msg = Messenger()
    input(f"You are going to create a scene named {name}, continue?")
    msg.add_scene(name)
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
    msg = Messenger()
    input(
        f"You are going to create a layer named {layer} under scene {scene}, continue?"
    )
    msg.add_layer(scene, layer, has_component)
    msg.update_layers(scene)
    msg.format()
    print("Done!")


@app.command()
def sceneproto(sceneproto: str):
    msg = Messenger()
    input(f"You are going to create a sceneproto named {sceneproto}, continue?")
    msg.add_sceneproto(sceneproto)
    msg.format()
    print("Done!")


@app.command()
def level(sceneproto: str, level: str):
    msg = Messenger()
    input(
        f"You are going to create a level named {level} under sceneproto {sceneproto}, continue?"
    )
    msg.add_level(sceneproto, level)
    msg.update_scenes()
    msg.format()
    print("Done!")


@app.command()
def protolayer(sceneproto: str, layer: str):
    msg = Messenger()
    input(
        f"You are going to create a layer named {layer} under sceneproto {sceneproto}, continue?"
    )
    msg.add_sceneproto_layer(sceneproto, layer)
    msg.update_sceneproto_layers(sceneproto)
    msg.format()
    print("Done!")


@app.command()
def gamecomponent(sceneproto: str, gc: str):
    msg = Messenger()
    input(
        f"You are going to create a game component named {gc} under sceneproto {sceneproto}, continue?"
    )
    msg.add_gamecomponent(sceneproto, gc)
    msg.format()
    print("Done!")


@app.command(help="Update Messenger core library")
def updatelib():
    msg = Messenger()
    input(f"You are going to update the core library of Messenger, continue?")
    patch()
    msg.format()
    print("Done!")


if __name__ == "__main__":
    app()
