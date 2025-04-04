# Contributing to Feathers UI

These styles and conventions described below must be followed in any commit or pull request created for [feathersui-openfl](https://github.com/feathersui/feathersui-openfl). Feel free to adopt these rules for other projects if you are using Feathers UI, but keep in mind that some of these rules are intentionally more strict than most projects require. As a library, Feathers UI needs to meet the needs of a variety of use-cases, and its coding practices are often designed to prevent conflicts that not all projects will necessarily encounter.

## Use of generative AI

No contributions to source code, documentation, or artwork may be created using generative AI tools. This includes Large Language Models (LLMs) and chatbots. This policy is to limit negative influence on code quality and to avoid potential copyright violations.

## Code Style

### Haxe 4 Syntax

Feathers UI targets Haxe version 4.0, and legacy syntax should be avoided.

For example, [function types](https://haxe.org/manual/types-function.html) should include parentheses around the parameters.

😃 Modern function types:

```haxe
(String) -> Bool // good
```

😡 Legacy function types:

```haxe
String -> Bool // bad
```

### Curly Braces

All conditional and loop expressions must include curly braces, even if the body contains one line only.

😃 With curly braces:

```haxe
// good
if (condition) {
	doSomething();
}
```

😡 Without curly braces:

```haxe
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

### General

- Avoid the use of abbreviations in names of symbols, except for commonly recognized acronyms, such as HTML.

### Classes

Names of classes should use camel case, and every word must start with an uppercase letter.

```haxe
class ClassNameWithCamelCase {}
```

If a class or interface name contains an acronym, all letters of the acryonym should be capitalized.

### Interfaces

Names of interfaces should use camel case, and must start with an uppercase letter I. Each additional word must start with an uppercase letter.

```haxe
interface IInterfaceNameWithCamelCase {}
```

### Enums

Names of enums should use camel case, and each word must start with an uppercase letter.

```haxe
enum EnumNameWithCamelCase {
	ENUM_VALUE_NAME;
	ANOTHER_ENUM_VALUE_NAME;
}
```

Names of enum values should use all uppercase, with underscores separating words.

If any value of an enum will accept parameters, the enum value names should instead use camel case, and each word must start with an uppercase letter.

```haxe
enum EnumNameWithCamelCase {
	EnumValueName(paramName:String);
	AnotherEnumValueName(paramName:Int);
}
```

All parameters must follow the same naming rules as local variables, and they must always have a type. 

### Functions

Names of functions should use camel case. The first word starts with a lowercase letter, and each additional word starts with an uppercase letter.

```haxe
function camelCaseFunctionName(camelCaseParamName:String):Void {}
```

All parameters must follow the same naming rules as local variables, and they must always have a type. The function's return type must always be specified.

### Constructors

If a constructor accepts parameters that correspond to public properties, the parameter names must match the property names. Use `this.` for assignment in the body of the constructor.

```haxe
public function new(text:String) {
	this.text = text;
}
```

### Variables

Names of variables should use camel case. The first word starts with a lowercase letter, and each additional word starts with an uppercase letter.

😃 Camel case:

```haxe
var camelCaseVariableName:Int = 0; // good
```

😡 Other cases:

```haxe
var snake_case_variable_name:Int = 0; // bad
```

If a variable name contains an acronym, all letters of the acryonym should be capitalized, _except_ when the acronym is the first word. Then, all letters of the acronym should be lowercase. For example, `htmlText` and `secondaryHTMLText`.

Local variables may omit the type if they have an initializer that allows the compiler to correctly infer the type. Public member variables must always declare a type. Private member variables may omit the type if it can be inferred, but if the variable is intended to be accessed by subclasses, declaring a type should be considered necessary.

Do not declare all local variables inside a function at the top of the function. Local variables should be declared as close to their first usage as possible.

Do not declare multiple local variables on the same line. Declare them separately.

😃 On separate lines:

```haxe
var a:Int = 0;
var b:Int = 1; // good
```

😡 On one line:

```haxe
var a:Int = 0, b:Int = 1; // bad
```

### Constants

Names of constants should use all uppercase, with underscores separating words.

```haxe
private static final NAME_OF_CONSTANT:Int = 0;
```

Constants should generally be declared with the `static` keyword.

### Properties

A typical property on a Feathers UI component will look similar to the code below:

```haxe
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

For getters and setters, use `get`, `set`, or `never`. Never use `default` or `null` because it will break compatibility with some supported workflows. Never use `@:isVar`. This means that a `private` _backing variable_ is always required. The backing variable name should match the name of the property, with a single underscore (`_`) character added at the beginning.

In general, `setInvalid()` should be called when the property of a UI component has changed. Always check to see if the value is different before calling `setInvalid()` to avoid updating for no reason. The response to changes to a property should go into the `update()` method.

Do not access children of a UI component in a getter or setter. It's often better to simply call `setInvalid()` and handle any changes in `update()`. If you must access a child in a getter or setter, you must handle the case where the child is `null` because it may not have been created yet (often, children won't be created until either `initialize()` or `update()` is called).

### Events

Names of event constants should use all uppercase, with underscores separating words. They should be declared with `inline var` (not `final`) and be of type `EventType<T>`.

```haxe
public static inline var NAME_OF_EVENT:EventType<FeathersEvent> = "nameOfEvent";
```

The value should match the name, but with modified casing. The value should use camel case. The first word starts with a lowercase letter, and each additional word starts with an uppercase letter.

## Event Listeners

Event listeners should be named in a way that avoids possible collisions in subclasses. Consider the class `MyComponent`:

```haxe
class MyComponent extends FeathersControl {}
```

To add a `MouseEvent.MOUSE_DOWN` listener inside this class, start the listener name with the name of the class. The first letter should be changed to lower-case, so use `myComponent` instead of `MyComponent`. Then, add an underscore `_` character. Then, add the event string, formatted in camel-case. For `MouseEvent.MOUSE_DOWN`, that's `mouseDown`. Finally, add `Handler` to the end of the name.

```haxe
private function myComponent_mouseDownHandler(event:MouseEvent):Void {}
```

If adding a listener to another object, format the class name the same. Then, add an extra underscore `_` character followed by the variable or property name of the other object. Finally add another underscore `_` character, followed by the event string and `Handler`. In the `MyComponent` class, to add a `MouseEvent.MOUSE_UP` listener to the `stage`, the name of the listener should look like this:

```haxe
private function myComponent_stage_mouseUpHandler(event:MouseEvent):Void {}
```

## Programmatic Animation

Feathers UI uses the [Actuate](https://lib.haxe.org/p/actuate) library for programmatic animation. There are a few best practices to remember when using Acutate in the Feathers UI codebase.

If a UI component has animation, the duration and easing function should be exposed as properties with `@:style` metadata.

The duration property must be of type `Float`, and it must be measured in seconds. The default duration value should generally be quick — under half a second.

```haxe
@:style
public var toggleDuration:Float = 0.15;
```

The easing function should be of type `IEasing` with a default value of `Quart.easeOut`.

```haxe
@:style
public var toggleEase:IEasing = Quart.easeOut;
```

🚨 **Never use `Actuate.tween()`.** Animations created with `Actuate.tween()` will often break when full [Dead Code Elimiation (DCE)](https://haxe.org/manual/cr-dce.html) is enabled in the Haxe compiler.

Instead, always use `Actuate.update()`. The following example demonstrates how to fade out a display object with its `alpha` property.

```haxe
Actuate.update((alpha:Float) -> {
    target.alpha = alpha;
}, duration, [target.alpha], [0.0]);
```
