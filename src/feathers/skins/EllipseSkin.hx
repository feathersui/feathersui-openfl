/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

/**
	A skin for Feathers UI components that draws an ellipse. The ellipse's fill
	and border may be styled.

	@since 1.0.0
**/
class EllipseSkin extends BaseGraphicsPathSkin {
	/**
		Creates a new `CircleSkin` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

	override private function drawPath():Void {
		var currentBorder = this.getCurrentBorder();
		var thickness = getLineThickness(currentBorder);
		var thicknessOffset = thickness / 2.0;

		this.graphics.drawEllipse(thicknessOffset, thicknessOffset, this.actualWidth - thickness, this.actualHeight - thickness);
	}
}
