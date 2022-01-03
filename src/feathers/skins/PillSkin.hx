/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.graphics.FillStyle;
import feathers.graphics.LineStyle;
import feathers.layout.Direction;

/**
	A skin for Feathers UI components that draws a "pill" shape, which is a
	similar to a rectangle, but semi-circle "caps" are drawn on either the
	left/right or top/bottom sides.

	@since 1.0.0
**/
class PillSkin extends BaseGraphicsPathSkin {
	/**
		Creates a new `PillSkin` object.

		@since 1.0.0
	**/
	public function new(?fill:FillStyle, ?border:LineStyle, capDirection:Direction = HORIZONTAL) {
		super(fill, border);
		this._capDirection = capDirection;
	}

	private var _capDirection:Direction;

	/**
		If `HORIZONTAL`, the caps are drawn on the left and right sides. If
		`VERTICAL`, the caps are drawn on the top and bottom sides.

		@since 1.0.0
	**/
	@:flash.property
	public var capDirection(get, set):Direction;

	private function get_capDirection():Direction {
		return this._capDirection;
	}

	private function set_capDirection(value:Direction):Direction {
		if (this._capDirection == value) {
			return this._capDirection;
		}
		this._capDirection = value;
		this.setInvalid(STYLES);
		return this._capDirection;
	}

	override private function drawPath():Void {
		var currentBorder = this.getCurrentBorder();
		var thickness = getLineThickness(currentBorder);
		var thicknessOffset = thickness / 2.0;

		var drawWidth = Math.max(0.0, this.actualWidth - thickness);
		var drawHeight = Math.max(0.0, this.actualHeight - thickness);

		var ellipseSize = this.capDirection == VERTICAL ? this.actualWidth : this.actualHeight;
		this.graphics.drawRoundRect(thicknessOffset, thicknessOffset, drawWidth, drawHeight, ellipseSize);
	}
}
