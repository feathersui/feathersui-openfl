/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.graphics.FillStyle;
import feathers.graphics.LineStyle;

/**
	A skin for Feathers UI components that draws a "donut" shape, a circle
	with an inner circle cut out. The donut's fill and border may be styled.

	@since 1.0.0
**/
class DonutSkin extends BaseGraphicsPathSkin {
	/**
		Creates a new `DonutSkin` object.

		@since 1.0.0
	**/
	public function new(?fill:FillStyle, ?border:LineStyle) {
		super(fill, border);
	}

	private var _thickness:Float = 1.0;

	/**
		The space, measured in pixels, between the outer radius and the inner
		radius.

		@since 1.0.0
	**/
	public var thickness(get, set):Float;

	private function get_thickness():Float {
		return this._thickness;
	}

	private function set_thickness(value:Float):Float {
		if (this._thickness == value) {
			return this._thickness;
		}
		this._thickness = value;
		this.setInvalid(STYLES);
		return this._thickness;
	}

	override private function drawPath():Void {
		var radius = this.getRadius();
		var innerRadius = this.getInnerRadius();
		if (radius == innerRadius) {
			// nothing to draw
			return;
		}
		this.graphics.drawCircle(this.actualWidth / 2.0, this.actualHeight / 2.0, radius);
		if (innerRadius == 0.0) {
			// just a circle
			return;
		}
		this.graphics.drawCircle(this.actualWidth / 2.0, this.actualHeight / 2.0, innerRadius);
	}

	private inline function getRadius():Float {
		var currentBorder = this.getCurrentBorder();
		var thicknessOffset = getLineThickness(currentBorder) / 2.0;

		var shorterSide = this.actualWidth;
		if (shorterSide > this.actualHeight) {
			shorterSide = this.actualHeight;
		}
		var radius = (shorterSide / 2.0) - thicknessOffset;
		return Math.max(0.0, radius);
	}

	private inline function getInnerRadius():Float {
		var currentBorder = this.getCurrentBorder();
		var thicknessOffset = getLineThickness(currentBorder) / 2.0;

		var shorterSide = this.actualWidth;
		if (shorterSide > this.actualHeight) {
			shorterSide = this.actualHeight;
		}
		var radius = (shorterSide / 2.0) - thicknessOffset;
		return Math.max(0.0, radius - Math.max(0.0, this.thickness));
	}

	override private function getDefaultGradientMatrixWidth():Float {
		return this.getRadius();
	}

	override private function getDefaultGradientMatrixHeight():Float {
		return this.getRadius();
	}

	override private function getDefaultGradientMatrixTx():Float {
		var drawWidth = Math.max(0.0, this.actualWidth - this.getRadius());
		return drawWidth / 2.0;
	}

	override private function getDefaultGradientMatrixTy():Float {
		var drawHeight = Math.max(0.0, this.actualHeight - this.getRadius());
		return drawHeight / 2.0;
	}
}
