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
	A skin for Feathers UI components that draws a line vertically from top to
	bottom at the horizontal center position, and filled on the left and right
	sides of the line.

	@since 1.0.0
**/
class VerticalLineSkin extends BaseGraphicsPathSkin {
	/**
		Creates a new `VerticalLineSkin` object.

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

		var centerX = this.actualWidth / 2.0;
		var minLineY = Math.min(this.actualHeight, thicknessOffset);
		var maxLineY = Math.max(minLineY, this.actualHeight - thicknessOffset);

		this.applyLineStyle(currentBorder);
		this.graphics.moveTo(centerX, minLineY);
		this.graphics.lineTo(centerX, maxLineY);
	}
}
