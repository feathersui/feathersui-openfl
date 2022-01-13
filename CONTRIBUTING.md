# Contributing to Feathers UI

These styles and conventions described below must be followed in any commit or pull request created for feathersui-openfl. Feel free to adopt these rules for other projects if you are using Feathers UI, but keep in mind that some of these rules are intentionally more strict than most projects require. As a library, Feathers UI needs to meet the needs of a variety of use-cases, and its coding practices are often designed to prevent conflicts that not all projects will necessarily encounter.

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

### Curly Braces

All conditional and loop expressions must include curly braces, even if the body contains one line only.

😃 With curly braces:

```hx
// good
if (condition) {
	doSomething();
}
```

😡 Without curly braces:

```hx
if (condition) doSomething(); // bad
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

For getters and setters, use `get`, `set`, or `never`. Never use `default` or `null` because it will break compatibility with some supported workflows. Never use `@:isVar`. This means that a `private` backing variable is always required.

In general, `setInvalid()` should be called when the property of a UI component has changed. Always check to see if the value is different before calling `setInvalid()` to avoid updating for no reason. The response to changes to a property should go into the `update()` method.

Do not access children of a UI component in a getter or setter It's often better to simply call `setInvalid()` and handle any changes in `update()`. If you must access a child in a getter or setter, you must handle the case where the child is `null` because it has not been created yet.

## Event Listeners

Event listeners should be named to avoid collisions in subclasses. Consider the
class `MyComponent`:

```hx
class MyComponent extends FeathersControl {}
```

To add a `MouseEvent.MOUSE_DOWN` listener inside this class, start the listener name with the name of the class. The first letter should be changed to lower-case, so use `myComponent` instead of `MyComponent`. Then, add an underscore `_` character. Then, add the event string, formatted in camel-case. For `MouseEvent.MOUSE_DOWN`, that's `mouseDown`. Finally, add `Handler` to the end of the name.

```hx
private function myComponent_mouseDownHandler(event:MouseEvent):Void {}
```

If adding a listener to another object, format the class name the same. Then, add an extra underscore `_` character followed by the variable or property name of the other object. Finally add another underscore `_` character, followed byu the event string and `Handler`. In the `MyComponent` class, to add a `MouseEvent.MOUSE_UP` listener to the `stage`, the name of the listener should look like this:

```hx
private function myComponent_stage_mouseUpHandler(event:MouseEvent):Void {}
```