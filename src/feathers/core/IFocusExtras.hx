/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.display.DisplayObject;

/**
	A container that may have extra children that aren't accessible from the
	standard display list functions like `getChildAt()`, but those "extra"
	children may still need to receive focus. An example of this would be a
	container with "chrome", such as the header and footer in
	`feathers.controls.Panel`.

	 @since 1.0.0
**/
interface IFocusExtras extends IFocusObject {
	/**
		Extra display objects that are not accessible through standard display
		list functions like `getChildAt()`, but should appear before those
		children in the focus order.

		May return `null` if there are no extra children.

		 @since 1.0.0
	**/
	var focusExtrasBefore(get, never):Array<DisplayObject>;

	/**
		Extra display objects that are not accessible through standard display
		list functions like `getChildAt()`, but should appear after those
		children in the focus order.

		May return `null` if there are no extra children.

		@since 1.0.0
	**/
	var focusExtrasAfter(get, never):Array<DisplayObject>;
}
