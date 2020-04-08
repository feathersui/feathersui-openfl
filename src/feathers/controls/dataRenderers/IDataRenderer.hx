/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.core.IUIControl;

/**
	A type of UI component that displays arbitrary data from a component such as
	`ListView`.

	@since 1.0.0
**/
interface IDataRenderer extends IUIControl {
	/**
		The data to render.

		@since 1.0.0
	**/
	public var data(get, set):Dynamic;
}
