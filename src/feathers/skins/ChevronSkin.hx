/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.graphics.FillStyle;
import feathers.graphics.LineStyle;
import feathers.layout.RelativePosition;
import openfl.errors.ArgumentError;

/**
	A skin for Feathers UI components that draws a chevron pointing in one of
	the four cardinal directions. The chevron's fill and border may be styled,
	and the position of the primary point may be customized.

	@since 1.0.0
**/
class ChevronSkin extends BaseGraphicsPathSkin {
	/**
		Creates a new `ChevronSkin` object.

		@since 1.0.0
	**/
	public function new(?border:LineStyle) {
		super(null, border);
	}

	private var _pointPosition:RelativePosition = TOP;

	/**
		The chevron may point in any of the four cardinal directions.

		@since 1.0.0
	**/
	@:flash.property
	public var pointPosition(get, set):RelativePosition;

	private function get_pointPosition():RelativePosition {
		return this._pointPosition;
	}

	private function set_pointPosition(value:RelativePosition):RelativePosition {
		if (this._pointPosition == value) {
			return this._pointPosition;
		}
		this._pointPosition = value;
		this.setInvalid(STYLES);
		return this._pointPosition;
	}

	override private function drawPath():Void {
		var currentBorder = this.getCurrentBorder();
		var thicknessOffset = getLineThickness(currentBorder) / 2.0;

		switch (this._pointPosition) {
			case LEFT:
				this.graphics.moveTo(this.actualWidth - thicknessOffset, thicknessOffset);
				this.graphics.lineTo(thicknessOffset, this.actualHeight / 2.0);
				this.graphics.lineTo(this.actualWidth - thicknessOffset, this.actualHeight - thicknessOffset);
			case RIGHT:
				this.graphics.moveTo(thicknessOffset, thicknessOffset);
				this.graphics.lineTo(this.actualWidth - thicknessOffset, this.actualHeight / 2.0);
				this.graphics.lineTo(thicknessOffset, this.actualHeight - thicknessOffset);
			case TOP:
				this.graphics.lineTo(thicknessOffset, this.actualHeight - thicknessOffset);
				this.graphics.moveTo(this.actualWidth / 2.0, thicknessOffset);
				this.graphics.lineTo(this.actualWidth - thicknessOffset, this.actualHeight - thicknessOffset);
			case BOTTOM:
				this.graphics.moveTo(thicknessOffset, thicknessOffset);
				this.graphics.lineTo(this.actualWidth / 2.0, this.actualHeight - thicknessOffset);
				this.graphics.lineTo(this.actualWidth - thicknessOffset, thicknessOffset);
			default:
				throw new ArgumentError("Chevron pointPosition not supported: " + this._pointPosition);
		}
	}
}
