/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import openfl.events.IEventDispatcher;

/**
	An object that may contain extra data for use with the parent container's
	layout.

	@see `feathers.layout.ILayout`

	@since 1.0.0
**/
interface ILayoutObject extends IEventDispatcher {
	/**
		Determines if the `ILayout` of the parent container should measure and
		position this object or ignore it.

		In the following example, the object is excluded from the layout:

		```hx
		object.includeInLayout = false;
		```

		@since 1.0.0
	**/
	public var includeInLayout(default, set):Bool;

	/**
		Optional, extra data used by some `ILayout` implementations.

		@since 1.0.0
	**/
	public var layoutData(default, set):ILayoutData;
}
