# feathersui-openfl tests

Automated tests created with [munit](https://github.com/massiveinteractive/MassiveUnit).

## Run HTML/JS tests

To run HTML/JS tests in a web browser, run the following command:


```sh
haxelib run munit test -js
```

To choose a specific web browser, add the `-browser` option:

```sh
haxelib run munit test -js -browser chrome
```

## Run SWF tests

To run tests with the Adobe Flash Player plugin in a web browser, use the following command:

```sh
haxelib run munit test -swf
```

**Warning:** You may need to click to activate the plugin before the tests will run.

To choose a specific web browser that has the plugin installed, add the `-browser` option:

```sh
haxelib run munit test -swf -browser chrome
```

## Run Windows/macOS tests

To run CPP tests on Windows or macOS desktop, use the following command:

```sh
haxelib run openfl test cpp -final
```

## Run Neko tests

To run tests in Neko, use the following command:

```sh
haxelib run openfl test neko -final
```