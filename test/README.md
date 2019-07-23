# feathersui-openfl tests

Automated tests created with [munit](https://github.com/massiveinteractive/MassiveUnit).

## Run JS tests

To run JS tests, use the following command:


```sh
haxelib run munit test -js
```

To choose a specific web browser, add the `-browser` option:

```sh
haxelib run munit test -js -browser chrome
```

## Run SWF tests

To run tests in Adobe Flash Player, use the following command:

```sh
haxelib run munit test -swf
```

**Warning:** You may need to click to activate the plugin before the tests will run.

```sh
haxelib run munit test -swf -browser chrome
```

## Run Windows/macOS tests

To run tests in Neko, use the following command:

```sh
haxelib run openfl test cpp
```

## Run Neko tests

To run tests in Neko, use the following command:

```sh
haxelib run openfl test neko
```