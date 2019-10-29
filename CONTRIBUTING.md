# Contributing to Feathers UI

## Code Style

### Haxe 4 Syntax

Feathers UI targets Haxe version 4, and legacy syntax should be avoided.

For example, [function types](https://haxe.org/manual/types-function.html) should include parentheses around the parameters.

😃 Modern function types:

```hx
(String) -> Bool // good
```

😡 Legacy function types:

```hx
String -> Bool // bad
```

### Formatting

All code must be formatted before each commit — use [Haxe Formatter](https://github.com/HaxeCheckstyle/haxe-formatter) with default settings.

**Tip:** If you are using [Visual Studio Code](https://github.com/vshaxe/vshaxe), you set the `editor.formatOnSave` setting to `true` for the Haxe language, and your changes will be formatted automatically:

```json
"[haxe]": {
	"editor.formatOnSave": true
}
```