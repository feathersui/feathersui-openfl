/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

/**
	A skin for Feathers components that draws an ellipse. The ellipse's fill
	and border may be styled.

	@since 1.0.0
**/
class EllipseSkin extends BaseGraphicsPathSkin {
	public function new() {
		super();
	}

	override private function drawPath():Void {
		this.graphics.drawEllipse(0, 0, this.actualWidth, this.actualHeight);
	}
}
