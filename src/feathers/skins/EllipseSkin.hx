/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.graphics.FillStyle;
import feathers.graphics.LineStyle;

/**
	A skin for Feathers UI components that draws an ellipse. The ellipse's fill
	and border may be styled.

	@since 1.0.0
**/
class EllipseSkin extends BaseGraphicsPathSkin {
	/**
		Creates a new `EllipseSkin` object.

		@since 1.0.0
	**/
	public function new(?fill:FillStyle, ?border:LineStyle) {
		super(fill, border);
	}

	override private function drawPath():Void {
		var currentBorder = this.getCurrentBorder();
		var thickness = getLineThickness(currentBorder);
		var thicknessOffset = thickness / 2.0;

		var drawWidth = Math.max(0.0, this.actualWidth - thickness);
		var drawHeight = Math.max(0.0, this.actualHeight - thickness);

		this.graphics.drawEllipse(thicknessOffset, thicknessOffset, drawWidth, drawHeight);
	}
}
