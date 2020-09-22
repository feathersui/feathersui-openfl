# Contributing to Feathers UI

## Code Style

### Haxe 4 Syntax

Feathers UI targets Haxe version 4.0, and legacy syntax should be avoided.

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

## API Design

### Properties

A typical property on a Feathers UI component will look similar to the code below:

```hx
private var _property:Int = 0;

@:flash.property
public var property(get, set):Int;

private function get_property():Int {
	return this._property;
}

private function set_property(value:Int):Int {
	if (this._property == value) {
		return this._property;
	}
	this._property = value;
	this.setInvalid(DATA);
	return this._property;
}
```

For getters and setters, use `get`, `set`, or `never`. Never use `default` or `null` because it will break compatibility with some supported workflows. This means that a `private` backing variable is always required.

All properties must include `@:flash.property` metadata. This metadata is used when Feathers UI is built as a _.swc_ file for ActionScript and when it is built as an npm bundle for JavaScript.

In general, `setInvalid()` should be called when the property of a UI component has changed. Always check to see if the value is different before calling `setInvalid()` to avoid updating for no reason. The response to changes to a property should go into the `update()` method.

Do not access children of a UI component in a getter or setter It's often better to simply call `setInvalid()` and handle any changes in `update()`. If you must access a child in a getter or setter, you must handle the case where the child is `null` because it has not been created yet.