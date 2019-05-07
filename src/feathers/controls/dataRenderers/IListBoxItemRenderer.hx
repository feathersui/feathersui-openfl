/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.core.IUIControl;

interface IListBoxItemRenderer extends IUIControl {
	public var data(default, set):Dynamic;
	public var index(default, set):Int;
}
