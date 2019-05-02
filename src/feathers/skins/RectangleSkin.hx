/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.core.InvalidationFlag;
import feathers.core.IStateObserver;

/**
	A skin for Feathers components that draws a rectangle. The rectangle's fill
	and border may be styled, and the recatangle may be rounded.

	@since 1.0.0
**/
class RectangleSkin extends BaseGraphicsPathSkin implements IStateObserver {
	public function new() {
		super();
	}

	/**
		The rectangle may optionally have rounded corners, and this sets their
		radius.

		@since 1.0.0
	**/
	public var cornerRadius(default, set):Null<Float> = null;

	private function set_cornerRadius(value:Float):Float {
		if (this.cornerRadius == value) {
			return this.cornerRadius;
		}
		this.cornerRadius = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.cornerRadius;
	}

	override private function drawPath():Void {
		if (this.cornerRadius == 0.0) {
			this.graphics.drawRect(0.0, 0.0, this.actualWidth, this.actualHeight);
		} else {
			this.graphics.drawRoundRect(0.0, 0.0, this.actualWidth, this.actualHeight, this.cornerRadius, this.cornerRadius);
		}
	}
}
