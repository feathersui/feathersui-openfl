/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.graphics.LineStyle;
import feathers.graphics.FillStyle;
import feathers.core.InvalidationFlag;

/**
	A skin for Feathers UI components that draws a rectangle. The rectangle's
	fill and border may be styled, and the corners may be rounded.

	@since 1.0.0
**/
class RectangleSkin extends BaseGraphicsPathSkin {
	/**
		Creates a new `RectangleSkin` object.

		@since 1.0.0
	**/
	public function new(?fill:FillStyle, ?border:LineStyle) {
		super(fill, border);
	}

	private var _cornerRadius:Float = 0.0;

	/**
		The rectangle may optionally have rounded corners, and this sets their
		radius, measured in pixels.

		@since 1.0.0
	**/
	@:flash.property
	public var cornerRadius(get, set):Float;

	private function get_cornerRadius():Float {
		return this._cornerRadius;
	}

	private function set_cornerRadius(value:Float):Float {
		if (this._cornerRadius == value) {
			return this._cornerRadius;
		}
		this._cornerRadius = value;
		this.setInvalid(STYLES);
		return this._cornerRadius;
	}

	override private function drawPath():Void {
		var currentBorder = this.getCurrentBorder();
		var thickness = getLineThickness(currentBorder);
		var thicknessOffset = thickness / 2.0;

		var drawWidth = Math.max(0.0, this.actualWidth - thickness);
		var drawHeight = Math.max(0.0, this.actualHeight - thickness);

		if (this._cornerRadius == 0.0) {
			this.graphics.drawRect(thicknessOffset, thicknessOffset, drawWidth, drawHeight);
		} else {
			var ellipseSize = this._cornerRadius * 2.0;
			ellipseSize = Math.min(ellipseSize, Math.min(this.actualWidth, this.actualHeight));
			this.graphics.drawRoundRect(thicknessOffset, thicknessOffset, drawWidth, drawHeight, ellipseSize);
		}
	}
}
