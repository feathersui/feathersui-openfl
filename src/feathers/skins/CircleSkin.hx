/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.core.IStateObserver;
import openfl.geom.Matrix;

/**
	A skin for Feathers components that draws a rectangle. The rectangle's fill
	and border may be styled, and the recatangle may be rounded.

	@since 1.0.0
**/
class CircleSkin extends BaseGraphicsPathSkin implements IStateObserver {
	public function new() {
		super();
	}

	override private function drawPath():Void {
		var radius = this.getRadius();
		this.graphics.drawCircle(this.actualWidth / 2, this.actualHeight / 2, radius);
	}

	private inline function getRadius():Float {
		var radius = this.actualWidth;
		if (radius > this.actualHeight) {
			radius = this.actualHeight;
		}
		return radius;
	}

	override private function getGradientMatrix(radians:Float):Matrix {
		var radius = this.getRadius();
		var matrix = new Matrix();
		matrix.createGradientBox(radius, radius, radians, (this.actualWidth - radius) / 2, (this.actualHeight - radius) / 2);
		return matrix;
	}
}
