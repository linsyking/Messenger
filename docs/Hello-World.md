# Hello World Project

Now we have some basic ideas of the Messenger, and we can start creating a new project with Messenger.

First, make sure you have installed [Python](https://www.python.org/) >= 3.7.

Then, install the `elm-messenger` package:

```bash
pip install elm-messenger
```

Then you are able to run `messenger` commands.

Try this:

```bash
messenger --help
```

to see the help message.

## Creating a project

Since you are doing an elm project, we assume that the following binaries are available in your path:

- git
- elm
- elm-format
- make (or bash)

To create a project named `hello`, type:

```bash
messenger init hello
```

Then follow the instructions to initialize the project.

After that, go to the `hello` directory, check if it looks like this:

```
.
├── assets
├── elm.json
├── elm-stuff
├── Makefile
├── make
├── messenger.json
├── public
└── src
```

If you want to use git to track your project, you can `git init` here.

## Adding Scenes and Layers

Now there are no scenes and layers, so you cannot successfully compile the project.

To add a scene named `Home`, type:

```bash
messenger scene Home
```

To add a layer named `GameLayer` under the scene `Home`, type:

```bash
messenger layer Home GameLayer
```

Now try to make the project:

```bash
# If you have make
make

# If not, use bash script
./make
```

It should compile. Open the `index.html` file to see the result. It should be a white space.

**Note.** If your scene is not "Home", you have to change the `initScene` in `src/MainConfig.elm` to your scene name.

## Hello World!

Now choose one beautiful background image, say `helloworld.jpg`, save it to `assets/img/`.

We want to show this picture together with "Hello World!" on it.

Now we need to import that asset. It's very simple. Edit `src/Lib/Resources/Base.elm`, change the following lines:

```elm
allTexture : List ( String, String )
allTexture =
    [ ( "bg", getResourcePath "img/helloworld.jpg" )
    ]
```

(If you are using different images, please change the name)

Then we are all done! Simple, right?

Now go to `src/Scenes/Home/GameLayer/Model.elm`, edit the last part:

```elm
viewModel : EnvC -> Model -> Renderable
viewModel env _ =
    Canvas.group []
        [ renderSprite env.globalData [ Canvas.Settings.Advanced.filter "blur(5px)" ] ( 0, 0 ) ( 1920, 0 ) "bg"
        , renderTextWithColor env.globalData 100 "Hello World!" "Times New Roman" Color.blue ( 700, 100 )
        ]
```

(You need to import some functions)

Now see the result:

![](imgs/helloworld.png)

You can also try to resize the browser and see its response.
