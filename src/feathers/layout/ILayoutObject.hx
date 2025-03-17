/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import openfl.events.IEventDispatcher;

/**
	An object that may contain extra data for use with the parent container's
	layout.

	@event feathers.events.FeathersEvent.LAYOUT_DATA_CHANGE Dispatched when
	`ILayoutObject.layoutData` changes.

	@see `feathers.layout.ILayout`

	@since 1.0.0
**/
@:event(feathers.events.FeathersEvent.LAYOUT_DATA_CHANGE)
interface ILayoutObject extends IEventDispatcher {
	/**
		Determines if the `ILayout` of the parent container should measure and
		position this object or ignore it.

		When the value of the `includeInLayout` property changes, the object
		will dispatch an event of type `FeathersEvent.LAYOUT_DATA_CHANGE`.

		In the following example, the object is excluded from the layout:

		```haxe
		object.includeInLayout = false;
		```

		@see `feathers.events.FeathersEvent.LAYOUT_DATA_CHANGE`

		@since 1.0.0
	**/
	public var includeInLayout(get, set):Bool;

	/**
		Optional, extra data used by some `ILayout` implementations.

		When the value of the `includeInLayout` property changes, the object
		will dispatch an event of type `FeathersEvent.LAYOUT_DATA_CHANGE`.

		@see `feathers.events.FeathersEvent.LAYOUT_DATA_CHANGE`

		@since 1.0.0
	**/
	public var layoutData(get, set):ILayoutData;
}
