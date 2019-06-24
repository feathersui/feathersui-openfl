# Feathers UI Components Explorer

This example app demonstrates many of the UI components available in [Feathers UI for Haxe and OpenFL](https://feathersui.com/openfl/).

## Run this example

This project includes an [*project.xml*](https://lime.software/docs/project-files/xml-format/) file that configures all options for [OpenFL](https://www.openfl.org/). This file makes it easy to buid from the command line, and many IDEs can parse this file to configure a Haxe project to use OpenFL.

### Prerequisites

The following software must be installed before you can run this example:

* [Haxe 4.0.0-rc.3](https://haxe.org/download/version/4.0.0-rc.3/)
* [OpenFL 8.9](https://lib.haxe.org/p/openfl/)

### Command Line

Run the [**openfl**](https://www.openfl.org/learn/haxelib/docs/tools/) tool in your terminal:

```sh
openfl test html5
```

In addition to `html5`, other supported targets include `windows`, `mac`, `android`, and `ios`. See [Lime Command Line Tools: Basic Commands](https://lime.software/docs/command-line-tools/basic-commands/) for complete details about the available commands.

### Visual Studio Code

> Be sure to install the [Haxe](https://marketplace.visualstudio.com/items?itemName=nadako.vshaxe) and [Lime](https://marketplace.visualstudio.com/items?itemName=openfl.lime-vscode-extension) extensions first.

1. From the **File** menu, choose **Open Folder…**
1. Find the *components-explorer* folder that contains this *README* file and open it.
1. From the **Debug** menu, choose **Add Configuration…**
1. Choose **Lime** from the list of available debug environments.
1. From the **Debug** menu, choose **Start Debugging**.
