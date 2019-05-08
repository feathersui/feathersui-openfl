/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.supportClasses;

import feathers.core.IMeasureObject;
import feathers.core.IUIControl;
import feathers.core.IValidating;

/**
	A view port for scrolling containers that extend `BaseScrollContainer`.

	@see `feathers.controls.supportClasses.BaseScrollContainer`

	@since 1.0.0
**/
interface IViewPort extends IUIControl extends IValidating extends IMeasureObject {
	public var visibleWidth(get, set):Null<Float>;
	public var visibleHeight(get, set):Null<Float>;
	public var minVisibleWidth(get, set):Null<Float>;
	public var minVisibleHeight(get, set):Null<Float>;
	public var maxVisibleWidth(default, set):Null<Float>;
	public var maxVisibleHeight(default, set):Null<Float>;
}
