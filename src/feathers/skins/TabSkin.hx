/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.graphics.FillStyle;
import feathers.graphics.LineStyle;
import feathers.layout.RelativePosition;
import openfl.errors.ArgumentError;

/**
	A skin for Feathers UI components that draws a tab (a rectangle with two
	rounded corners along the same edge). The tab's fill and border may be
	styled, and the position of the rounded corners may be customized.

	@since 1.0.0
**/
class TabSkin extends BaseGraphicsPathSkin {
	/**
		Creates a new `TabSkin` object.

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

	private var _drawBaseBorder:Bool = true;

	/**
		The tab's base border can be drawn or not

		@since 1.0.0
	**/
	public var drawBaseBorder(get, set):Bool;

	private function get_drawBaseBorder():Bool {
		return this._drawBaseBorder;
	}

	private function set_drawBaseBorder(value:Bool):Bool {
		if (this._drawBaseBorder == value) {
			return this._drawBaseBorder;
		}
		this._drawBaseBorder = value;
		this.setInvalid(STYLES);
		return this._drawBaseBorder;
	}

	private var _cornerRadius:Float = 0.0;

	/**
		The rectangle may optionally have rounded corners, and this sets their
		radius, measured in pixels.

		@since 1.0.0
	**/
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
		var thicknessOffset = getLineThickness(currentBorder) / 2.0;

		var drawWidth = Math.max(0.0, this.actualWidth - thicknessOffset);
		var drawHeight = Math.max(0.0, this.actualHeight - thicknessOffset);

		var adjustedCornerRadius = Math.min(this._cornerRadius, Math.min(this.actualWidth / 2.0, this.actualHeight / 2.0));

		if (adjustedCornerRadius == 0.0 && this._drawBaseBorder) {
			this.graphics.drawRect(thicknessOffset, thicknessOffset, drawWidth, drawHeight);
		} else {
			switch (this._cornerRadiusPosition) {
				case LEFT:
					this.graphics.moveTo(thicknessOffset + adjustedCornerRadius, thicknessOffset);
					if (this._drawBaseBorder) {
						this.graphics.lineTo(drawWidth, thicknessOffset);
						this.graphics.lineTo(drawWidth, drawHeight);
					} else {
						this.graphics.lineTo(this.actualWidth, thicknessOffset);
						this.graphics.lineStyle(0.0, 0.0, 0.0);
						this.graphics.lineTo(this.actualWidth, drawHeight);
						this.applyLineStyle(currentBorder);
					}
					this.graphics.lineTo(thicknessOffset + adjustedCornerRadius, drawHeight);
					this.graphics.curveTo(thicknessOffset, drawHeight, thicknessOffset, drawHeight - adjustedCornerRadius);
					this.graphics.lineTo(thicknessOffset, thicknessOffset + adjustedCornerRadius);
					this.graphics.curveTo(thicknessOffset, thicknessOffset, thicknessOffset + adjustedCornerRadius, thicknessOffset);
				case RIGHT:
					this.graphics.moveTo(thicknessOffset, thicknessOffset);
					this.graphics.lineTo(drawWidth - adjustedCornerRadius, thicknessOffset);
					this.graphics.curveTo(drawWidth, thicknessOffset, drawWidth, thicknessOffset + adjustedCornerRadius);
					this.graphics.lineTo(drawWidth, drawHeight - adjustedCornerRadius);
					this.graphics.curveTo(drawWidth, drawHeight, drawWidth - adjustedCornerRadius, drawHeight);
					if (this._drawBaseBorder) {
						this.graphics.lineTo(thicknessOffset, drawHeight);
						this.graphics.lineTo(thicknessOffset, thicknessOffset);
					} else {
						this.graphics.lineTo(0.0, drawHeight);
						this.graphics.lineStyle(0.0, 0.0, 0.0);
						this.graphics.lineTo(0.0, thicknessOffset);
						this.applyLineStyle(currentBorder);
					}
				case TOP:
					this.graphics.moveTo(thicknessOffset + adjustedCornerRadius, thicknessOffset);
					this.graphics.lineTo(drawWidth - adjustedCornerRadius, thicknessOffset);
					this.graphics.curveTo(drawWidth, thicknessOffset, drawWidth, thicknessOffset + adjustedCornerRadius);
					if (this._drawBaseBorder) {
						this.graphics.lineTo(drawWidth, drawHeight);
						this.graphics.lineTo(thicknessOffset, drawHeight);
					} else {
						this.graphics.lineTo(drawWidth, this.actualHeight);
						this.graphics.lineStyle(0.0, 0.0, 0.0);
						this.graphics.lineTo(thicknessOffset, this.actualHeight);
						this.applyLineStyle(currentBorder);
					}
					this.graphics.lineTo(thicknessOffset, thicknessOffset + adjustedCornerRadius);
					this.graphics.curveTo(thicknessOffset, thicknessOffset, thicknessOffset + adjustedCornerRadius, thicknessOffset);
				case BOTTOM:
					if (this._drawBaseBorder) {
						this.graphics.moveTo(thicknessOffset, thicknessOffset);
						this.graphics.lineTo(drawWidth, thicknessOffset);
					} else {
						this.graphics.lineStyle(0.0, 0.0, 0.0);
						this.graphics.moveTo(thicknessOffset, 0.0);
						this.graphics.lineTo(drawWidth, 0.0);
						this.applyLineStyle(currentBorder);
					}
					this.graphics.lineTo(drawWidth, drawHeight - adjustedCornerRadius);
					this.graphics.curveTo(drawWidth, drawHeight, drawWidth - adjustedCornerRadius, drawHeight);
					this.graphics.lineTo(thicknessOffset + adjustedCornerRadius, drawHeight);
					this.graphics.curveTo(thicknessOffset, drawHeight, thicknessOffset, drawHeight - adjustedCornerRadius);
					this.graphics.lineTo(thicknessOffset, thicknessOffset);
				default:
					throw new ArgumentError("Tab cornerRadiusPosition not supported: " + this._cornerRadiusPosition);
			}
		}
	}
}
