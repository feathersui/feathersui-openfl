# feathersui-openfl tests

Automated tests created with [utest](https://lib.haxe.org/p/utest).

## Run Neko tests

To run tests with Neko, run the following command:

```sh
openfl test neko
```

## Run HashLink tests

To run tests with HashLink, run the following command:

```sh
openfl test hl
```

## Run Adobe AIR tests

To run tests with Adobe AIR, use the following command:

```sh
openfl test air
```

## Run Windows tests

To run CPP tests on Windows, use the following command:

```sh
openfl test windows
```

## Run macOS tests

To run CPP tests on macOS, use the following command:

```sh
openfl test mac
```

## Run Linux tests

To run CPP tests on Linux, use the following command:

```sh
openfl test linux
```

## Run HTML/JS tests

To run tests with HTML/JS, run the following command:

```sh
openfl test html5
```

You can also run tests headless in Chromium, WebKit and Firefox.

First, run the following commands one time to install dependencies:

```sh
npm ci
npx playwright install
npx playwright install-deps
```

Then, run the following commmands to run the tests:

```sh
haxelib run openfl build html5 -final -Dheadless_html5
node playwright-runner.js
```
