/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.graphics.LineStyle;
import feathers.graphics.FillStyle;

/**
	A skin for Feathers UI components that draws a border on the left and
	right sides, but not the top and bottom.

	@since 1.0.0
**/
class LeftAndRightBorderSkin extends BaseGraphicsPathSkin {
	/**
		Creates a new `LeftAndRightBorderSkin` object.

		@since 1.0.0
	**/
	public function new(?fill:FillStyle, ?border:LineStyle) {
		super(fill, border);
	}

	override private function draw():Void {
		var currentBorder = this.getCurrentBorder();
		var thickness = getLineThickness(currentBorder);
		var thicknessOffset = thickness / 2.0;

		var currentFill = this.getCurrentFill();
		if (currentFill != null) {
			this.applyFillStyle(currentFill);
			this.graphics.drawRect(0.0, thicknessOffset, this.actualWidth, this.actualHeight - thickness);
			this.graphics.endFill();
		}
		this.applyLineStyle(currentBorder);
		// left
		this.graphics.moveTo(thicknessOffset, thicknessOffset);
		this.graphics.lineTo(thicknessOffset, this.actualHeight - thicknessOffset);
		// right
		this.graphics.moveTo(this.actualWidth - thicknessOffset, thicknessOffset);
		this.graphics.lineTo(this.actualWidth - thicknessOffset, this.actualHeight - thicknessOffset);
	}
}
