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
	A skin for Feathers UI components that draws a circle. The circle's fill
	and border may be styled.

	@since 1.0.0
**/
class CircleSkin extends BaseGraphicsPathSkin {
	/**
		Creates a new `CircleSkin` object.

		@since 1.0.0
	**/
	public function new(?fill:FillStyle, ?border:LineStyle) {
		super(fill, border);
	}

	override private function drawPath():Void {
		var radius = this.getRadius();
		this.graphics.drawCircle(this.actualWidth / 2.0, this.actualHeight / 2.0, radius);
	}

	private inline function getRadius():Float {
		var currentBorder = this.getCurrentBorder();
		var thicknessOffset = getLineThickness(currentBorder) / 2.0;

		var shorterSide = this.actualWidth;
		if (shorterSide > this.actualHeight) {
			shorterSide = this.actualHeight;
		}
		var radius = (shorterSide / 2.0) - thicknessOffset;
		return Math.max(0.0, radius);
	}

	override private function getDefaultGradientMatrixWidth():Float {
		return this.getRadius();
	}

	override private function getDefaultGradientMatrixHeight():Float {
		return this.getRadius();
	}

	override private function getDefaultGradientMatrixTx():Float {
		var drawWidth = Math.max(0.0, this.actualWidth - this.getRadius());
		return drawWidth / 2.0;
	}

	override private function getDefaultGradientMatrixTy():Float {
		var drawHeight = Math.max(0.0, this.actualHeight - this.getRadius());
		return drawHeight / 2.0;
	}
}
