/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.graphics.LineStyle;
import feathers.graphics.FillStyle;

/**
	A skin for Feathers components that draws a line at the bottom.

	@since 1.0.0
**/
class OverAndUnderlineSkin extends BaseGraphicsPathSkin {
	public function new() {
		super();
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
		// overline
		this.graphics.moveTo(thicknessOffset, thicknessOffset);
		this.graphics.lineTo(this.actualWidth - thicknessOffset, thicknessOffset);
		// underline
		this.graphics.moveTo(thicknessOffset, this.actualHeight - thicknessOffset);
		this.graphics.lineTo(this.actualWidth - thicknessOffset, this.actualHeight - thicknessOffset);
	}
}
