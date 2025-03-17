/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.graphics.FillStyle;
import feathers.graphics.LineStyle;

/**
	A skin for Feathers UI components that draws a border at the bottom only.

	@since 1.0.0
**/
class UnderlineSkin extends BaseGraphicsPathSkin {
	/**
		Creates a new `UnderlineSkin` object.

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
			this.graphics.drawRect(0.0, 0.0, this.actualWidth, Math.max(0.0, this.actualHeight - thicknessOffset));
			this.graphics.endFill();
		}

		var minLineX = Math.min(this.actualWidth, thicknessOffset);
		var minLineY = Math.min(this.actualHeight, thicknessOffset);
		var maxLineX = Math.max(minLineX, this.actualWidth - thicknessOffset);
		var maxLineY = Math.max(minLineY, this.actualHeight - thicknessOffset);

		this.applyLineStyle(currentBorder);
		this.graphics.moveTo(minLineX, maxLineY);
		this.graphics.lineTo(maxLineX, maxLineY);
	}
}
