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
	A skin for Feathers UI components that draws a line horizontally from left
	to right at the vertical center position, and filled on the top and bottom
	sides of the line.

	@since 1.0.0
**/
class HorizontalLineSkin extends BaseGraphicsPathSkin {
	/**
		Creates a new `HorizontalLineSkin` object.

		@since 1.0.0
	**/
	public function new(?fill:FillStyle, ?border:LineStyle) {
		super(fill, border);
	}

	override private function draw():Void {
		var currentBorder = this.getCurrentBorder();
		var thicknessOffset = getLineThickness(currentBorder) / 2.0;

		var currentFill = this.getCurrentFill();
		if (currentFill != null) {
			this.applyFillStyle(currentFill);
			this.graphics.drawRect(0.0, 0.0, this.actualWidth, this.actualHeight);
			this.graphics.endFill();
		}

		var minLineX = Math.min(this.actualWidth, thicknessOffset);
		var maxLineX = Math.max(minLineX, this.actualWidth - thicknessOffset);
		var centerY = this.actualHeight / 2.0;

		this.applyLineStyle(currentBorder);
		this.graphics.moveTo(minLineX, centerY);
		this.graphics.lineTo(maxLineX, centerY);
	}
}
