/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.core.IStateObserver;

/**
	A skin for Feathers components that draws a rectangle. The rectangle's fill
	and border may be styled, and the recatangle may be rounded.

	@since 1.0.0
**/
class EllipseSkin extends BaseGraphicsPathSkin implements IStateObserver {
	public function new() {
		super();
	}

	override private function drawPath():Void {
		this.graphics.drawEllipse(0, 0, this.actualWidth, this.actualHeight);
	}
}
