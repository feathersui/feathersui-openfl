/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.core.InvalidationFlag;

/**
	A skin for Feathers components that draws a rectangle. The rectangle's fill
	and border may be styled, and the corners may be rounded.

	@since 1.0.0
**/
class RectangleSkin extends BaseGraphicsPathSkin {
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
		var currentBorder = this.getCurrentBorder();
		var thickness = getLineThickness(currentBorder);
		var thicknessOffset = thickness / 2.0;

		if (this.cornerRadius == 0.0 || this.cornerRadius == null) {
			this.graphics.drawRect(thicknessOffset, thicknessOffset, this.actualWidth - thickness, this.actualHeight - thickness);
		} else {
			this.graphics.drawRoundRect(thicknessOffset, thicknessOffset, this.actualWidth - thickness, this.actualHeight - thickness, this.cornerRadius,
				this.cornerRadius);
		}
	}
}
