/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

/**
	A skin for Feathers components that draws a line at the bottom.

	@since 1.0.0
**/
class UnderlineSkin extends BaseGraphicsPathSkin {
	public function new() {
		super();
	}

	override private function drawPath():Void {
		this.graphics.moveTo(0.0, this.actualHeight);
		this.graphics.lineTo(this.actualWidth, this.actualHeight);
	}
}
