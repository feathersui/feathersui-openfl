/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import openfl.geom.Matrix;

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
	public function new() {
		super();
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
		return (shorterSide / 2.0) - thicknessOffset;
	}

	override private function getGradientMatrix(radians:Float):Matrix {
		var radius = this.getRadius();
		var matrix = new Matrix();
		matrix.createGradientBox(radius, radius, radians, (this.actualWidth - radius) / 2.0, (this.actualHeight - radius) / 2.0);
		return matrix;
	}
}
