/*
	Feathers UI
	Copyright 2026 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import openfl.display.DisplayObject;

/**
	A layout with an optional "typical" item used for measurement when a layout
	doesn't have access to valid measurements, such as in virtual layouts.

	@since 1.4.0
**/
interface ITypicalItemLayout extends ILayout {
	/**
		An optional "typical" item that is used when an item's measurements are
		unknown.

		The `typicalItem` property should not be set if using a data container,
		such as `ListView`, `TreeView`, or `GridView`. The data container will
		populate this property automatically.

		@since 1.4.0
	**/
	public var typicalItem(get, set):DisplayObject;
}
