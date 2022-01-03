/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

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
			this.graphics.drawRect(thicknessOffset, 0.0, Math.max(0.0, this.actualWidth - thickness), this.actualHeight);
			this.graphics.endFill();
		}

		var minLineX = Math.min(this.actualWidth, thicknessOffset);
		var minLineY = Math.min(this.actualHeight, thicknessOffset);
		var maxLineX = Math.max(minLineX, this.actualWidth - thicknessOffset);
		var maxLineY = Math.max(minLineY, this.actualHeight - thicknessOffset);

		this.applyLineStyle(currentBorder);
		// left
		this.graphics.moveTo(minLineX, minLineY);
		this.graphics.lineTo(minLineX, maxLineY);
		// right
		this.graphics.moveTo(maxLineX, minLineY);
		this.graphics.lineTo(maxLineX, maxLineY);
	}
}
