/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.style;

/**
	An object that supports styling.

	@since 1.0.0
**/
interface IStyleObject {
	/**
		Determines if the style object and its children should be styled by a
		theme or not.

		In the following example, the object's theme is disabled.

		```haxe
		object.themeEnabled = false;
		```

		@since 1.0.0
	**/
	public var themeEnabled(get, set):Bool;
}
