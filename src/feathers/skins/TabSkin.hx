/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import openfl.errors.ArgumentError;
import feathers.layout.RelativePosition;
import feathers.layout.Direction;
import feathers.graphics.LineStyle;
import feathers.graphics.FillStyle;
import feathers.core.InvalidationFlag;

/**
	A skin for Feathers UI components that draws a tab (a rectangle with two
	rounded corners along the same edge). The tab's fill and border may be
	styled, and the position of the rounded corners may be customized.

	@since 1.0.0
**/
class TabSkin extends BaseGraphicsPathSkin {
	/**
		Creates a new `RectangleSkin` object.

		@since 1.0.0
	**/
	public function new(?fill:FillStyle, ?border:LineStyle, cornerRadius:Float = 0.0) {
		super(fill, border);
		this._cornerRadius = cornerRadius;
	}

	private var _cornerRadiusPosition:RelativePosition = TOP;

	/**
		The tab may have rounded corners on any of its four sides.

		@since 1.0.0
	**/
	@:flash.property
	public var cornerRadiusPosition(get, set):RelativePosition;

	private function get_cornerRadiusPosition():RelativePosition {
		return this._cornerRadiusPosition;
	}

	private function set_cornerRadiusPosition(value:RelativePosition):RelativePosition {
		if (this._cornerRadiusPosition == value) {
			return this._cornerRadiusPosition;
		}
		this._cornerRadiusPosition = value;
		this.setInvalid(STYLES);
		return this._cornerRadiusPosition;
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

		if (this._cornerRadius == 0.0) {
			this.graphics.drawRect(thicknessOffset, thicknessOffset, this.actualWidth - thickness, this.actualHeight - thickness);
		} else {
			switch (this._cornerRadiusPosition) {
				case LEFT:
					this.graphics.moveTo(thicknessOffset + this._cornerRadius, thicknessOffset);
					this.graphics.lineTo(this.actualWidth - thickness, thicknessOffset);
					this.graphics.lineTo(this.actualWidth - thickness, this.actualHeight - thickness);
					this.graphics.lineTo(thicknessOffset + this._cornerRadius, this.actualHeight - thickness);
					this.graphics.curveTo(thicknessOffset, this.actualHeight - thickness, thicknessOffset, this.actualHeight - thickness - this._cornerRadius);
					this.graphics.lineTo(thicknessOffset, thicknessOffset + this._cornerRadius);
					this.graphics.curveTo(thicknessOffset, thicknessOffset, thicknessOffset + this._cornerRadius, thicknessOffset);
				case RIGHT:
					this.graphics.moveTo(thicknessOffset, thicknessOffset);
					this.graphics.lineTo(this.actualWidth - thickness - this._cornerRadius, thicknessOffset);
					this.graphics.curveTo(this.actualWidth - thickness, thicknessOffset, this.actualWidth - thickness, thicknessOffset + this._cornerRadius);
					this.graphics.lineTo(this.actualWidth - thickness, this.actualHeight - thickness - this._cornerRadius);
					this.graphics.curveTo(this.actualWidth
						- thickness, this.actualHeight
						- thickness, this.actualWidth
						- thickness
						- this._cornerRadius,
						this.actualHeight
						- thickness);
					this.graphics.lineTo(thicknessOffset, this.actualHeight - thickness);
					this.graphics.lineTo(thicknessOffset, thicknessOffset);
				case TOP:
					this.graphics.moveTo(thicknessOffset + this._cornerRadius, thicknessOffset);
					this.graphics.lineTo(this.actualWidth - thickness - this._cornerRadius, thicknessOffset);
					this.graphics.curveTo(this.actualWidth - thickness, thicknessOffset, this.actualWidth - thickness, thicknessOffset + this._cornerRadius);
					this.graphics.lineTo(this.actualWidth - thickness, this.actualHeight - thickness);
					this.graphics.lineTo(thicknessOffset, this.actualHeight - thickness);
					this.graphics.lineTo(thicknessOffset, thicknessOffset + this._cornerRadius);
					this.graphics.curveTo(thicknessOffset, thicknessOffset, thicknessOffset + this._cornerRadius, thicknessOffset);
				case BOTTOM:
					this.graphics.moveTo(thicknessOffset, thicknessOffset);
					this.graphics.lineTo(this.actualWidth - thickness, thicknessOffset);
					this.graphics.lineTo(this.actualWidth - thickness, this.actualHeight - thickness - this._cornerRadius);
					this.graphics.curveTo(this.actualWidth
						- thickness, this.actualHeight
						- thickness, this.actualWidth
						- thickness
						- this._cornerRadius,
						this.actualHeight
						- thickness);
					this.graphics.lineTo(thicknessOffset + this._cornerRadius, this.actualHeight - thickness);
					this.graphics.curveTo(thicknessOffset, this.actualHeight - thickness, thicknessOffset, this.actualHeight - thickness - this._cornerRadius);
					this.graphics.lineTo(thicknessOffset, thicknessOffset);
				default:
					throw new ArgumentError("Tab cornerRadiusPosition not supported: " + this._cornerRadiusPosition);
			}
		}
	}
}
