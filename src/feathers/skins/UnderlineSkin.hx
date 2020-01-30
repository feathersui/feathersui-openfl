/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.graphics.LineStyle;
import feathers.graphics.FillStyle;

/**
	A skin for Feathers UI components that draws a border at the bottom only.

	@since 1.0.0
**/
class UnderlineSkin extends BaseGraphicsPathSkin {
	/**
		Creates a new `UnderlineSkin` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

	override private function draw():Void {
		var currentBorder = this.getCurrentBorder();
		var thicknessOffset = getLineThickness(currentBorder) / 2.0;

		var currentFill = this.getCurrentFill();
		if (currentFill != null) {
			this.applyFillStyle(currentFill);
			this.graphics.drawRect(0.0, 0.0, this.actualWidth, this.actualHeight - thicknessOffset);
			this.graphics.endFill();
		}
		this.applyLineStyle(currentBorder);
		this.graphics.moveTo(thicknessOffset, this.actualHeight - thicknessOffset);
		this.graphics.lineTo(this.actualWidth - thicknessOffset, this.actualHeight - thicknessOffset);
	}
}
