/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins.activity;

import feathers.utils.MathUtil;
import motion.easing.IEasing;
import motion.easing.Sine;
import openfl.geom.Point;

/**
	A skin for `ActivityIndicator` component that displays a set of dots or
	circles evenly spaced around the radius.

	@since 1.1.0

	@see `feathers.ccontrols.ActivityIndicator`
**/
class DotsActivitySkin extends ProgrammaticSkin implements IIndeterminateSkin {
	/**
		Creates a new `DotsActivitySkin` object.

		@since 1.1.0
	**/
	public function new() {
		super();
	}

	private var _indeterminatePosition:Float = 0.0;

	/**
		@see `feathers.skins.IIndeterminateSkin.indeterminatePosition`
	**/
	public var indeterminatePosition(get, set):Float;

	public function get_indeterminatePosition():Float {
		return this._indeterminatePosition;
	}

	public function set_indeterminatePosition(value:Float):Float {
		if (this._indeterminatePosition == value) {
			return this._indeterminatePosition;
		}
		this._indeterminatePosition = value;
		setInvalid(DATA);
		return this._indeterminatePosition;
	}

	private var _numDots:Int = 8;

	/**
		The total number of dots, some of which may be filled, and some of which
		may be empty.

		@since 1.1.0
	**/
	public var numDots(get, set):Int;

	private function get_numDots():Int {
		return this._numDots;
	}

	private function set_numDots(value:Int):Int {
		if (this._numDots == value) {
			return this._numDots;
		}
		this._numDots = value;
		setInvalid(STYLES);
		return this._numDots;
	}

	private var _numEmptyDots:Int = 0;

	/**
		The number of empty dots.

		@since 1.1.0
	**/
	public var numEmptyDots(get, set):Int;

	private function get_numEmptyDots():Int {
		return this._numEmptyDots;
	}

	private function set_numEmptyDots(value:Int):Int {
		if (this._numEmptyDots == value) {
			return this._numEmptyDots;
		}
		this._numEmptyDots = value;
		setInvalid(STYLES);
		return this._numEmptyDots;
	}

	private var _dotRadius:Float = 3.0;

	/**
		The radius of the dots, measured in pixels. If `endDotRadius` is also
		defined, the dot diameters will be interpolated between `dotRadius` and
		`endDotRadius`.

		@since 1.1.0
	**/
	public var dotRadius(get, set):Float;

	private function get_dotRadius():Float {
		return this._dotRadius;
	}

	private function set_dotRadius(value:Float):Float {
		if (this._dotRadius == value) {
			return this._dotRadius;
		}
		this._dotRadius = value;
		setInvalid(STYLES);
		return this._dotRadius;
	}

	private var _endDotRadius:Null<Float> = null;

	/**
		If `endDotRadius` is not `null`, the dot radius values will be
		interpolated between `dotRadius` and `endDotRadius`.

		@since 1.1.0

		@see `DotsActivitySkin.dotRadius`
	**/
	public var endDotRadius(get, set):Null<Float>;

	private function get_endDotRadius():Null<Float> {
		return this._endDotRadius;
	}

	private function set_endDotRadius(value:Null<Float>):Null<Float> {
		if (this._endDotRadius == value) {
			return this._endDotRadius;
		}
		this._endDotRadius = value;
		setInvalid(STYLES);
		return this._endDotRadius;
	}

	private var _dotColor:UInt = 0x000000;

	/**
		The color of the dots.

		@since 1.1.0
	**/
	public var dotColor(get, set):UInt;

	private function get_dotColor():UInt {
		return this._dotColor;
	}

	private function set_dotColor(value:UInt):UInt {
		if (this._dotColor == value) {
			return this._dotColor;
		}
		this._dotColor = value;
		setInvalid(STYLES);
		return this._dotColor;
	}

	private var _endDotColor:Null<UInt> = null;

	/**
		If `endDotColor` is not `null`, the dot color values will be
		interpolated between `dotColor` and `endDotColor`.

		@since 1.1.0

		@see `DotsActivitySkin.dotColor`
	**/
	public var endDotColor(get, set):Null<UInt>;

	private function get_endDotColor():Null<UInt> {
		return this._endDotColor;
	}

	private function set_endDotColor(value:Null<UInt>):Null<UInt> {
		if (this._endDotColor == value) {
			return this._endDotColor;
		}
		this._endDotColor = value;
		setInvalid(STYLES);
		return this._endDotColor;
	}

	private var _dotAlpha:Float = 1.0;

	/**
		The alpha or opacity of the dots, a value between `0.0` and `1.0`.

		@since 1.1.0
	**/
	public var dotAlpha(get, set):Float;

	private function get_dotAlpha():Float {
		return this._dotAlpha;
	}

	private function set_dotAlpha(value:Float):Float {
		if (this._dotAlpha == value) {
			return this._dotAlpha;
		}
		this._dotAlpha = value;
		setInvalid(STYLES);
		return this._dotAlpha;
	}

	private var _endDotAlpha:Null<Float> = 0.0;

	/**
		If `endDotAlpha` is not `null`, the dot alpha values will be
		interpolated between `dotAlpha` and `endDotAlpha`.

		@since 1.1.0

		@see `DotsActivitySkin.dotAlpha`
	**/
	public var endDotAlpha(get, set):Null<Float>;

	private function get_endDotAlpha():Null<Float> {
		return this._endDotAlpha;
	}

	private function set_endDotAlpha(value:Null<Float>):Null<Float> {
		if (this._endDotAlpha == value) {
			return this._endDotAlpha;
		}
		this._endDotAlpha = value;
		setInvalid(STYLES);
		return this._endDotAlpha;
	}

	override private function update():Void {
		var dataInvalid = isInvalid(DATA);
		var sizeInvalid = isInvalid(SIZE);

		sizeInvalid = measure() || sizeInvalid;

		if (dataInvalid || sizeInvalid) {
			drawSkin();
		}
	}

	private function measure():Bool {
		var needsWidth = explicitWidth == null;
		var needsHeight = explicitHeight == null;
		if (!needsWidth && !needsHeight) {
			return false;
		}

		var endDotRadius = this._dotRadius;
		if (this._endDotRadius != null) {
			endDotRadius = this._endDotRadius;
		}
		var maxDotRadius = Math.max(dotRadius, endDotRadius);

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			if (needsHeight) {
				newWidth = maxDotRadius * this._numDots;
			} else {
				newWidth = this.explicitHeight;
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			if (needsHeight) {
				newHeight = maxDotRadius * this._numDots;
			} else {
				newHeight = this.explicitWidth;
			}
		}
		return saveMeasurements(newWidth, newHeight);
	}

	private function drawSkin():Void {
		graphics.clear();
		if (this._numDots == 0) {
			return;
		}

		var radius = Math.min(this.actualWidth, this.actualHeight) / 2.0;
		var centerX = this.actualWidth / 2.0;
		var centerY = this.actualHeight / 2.0;

		var degreesPerSegment = 360.0 / this._numDots;
		var nearestAngle = MathUtil.roundToNearest(this._indeterminatePosition * 360.0, degreesPerSegment);

		var endDotRadius = this._dotRadius;
		if (this._endDotRadius != null) {
			endDotRadius = this._endDotRadius;
		}
		var maxDotRadius = Math.max(dotRadius, endDotRadius);

		var adjustScale = true;
		var adjustAlpha = true;
		graphics.beginFill(0xff00ff, 0.0);
		graphics.drawCircle(centerX, centerY, radius);
		graphics.endFill();
		var numEmptyDots = 0;
		if (this._numDots > this._numEmptyDots) {
			numEmptyDots = this._numEmptyDots;
		};
		for (i in 0...this._numDots) {
			var point = Point.polar(radius - maxDotRadius, (-i * 2.0 * Math.PI / this._numDots) + nearestAngle * Math.PI / 180.0);

			var ratio = i / (this._numDots - numEmptyDots);
			var currentColor = this._dotColor;
			if (this._endDotColor != null && this._endDotColor != this._dotColor) {
				currentColor = blendColors(this._dotColor, this._endDotColor, ratio);
			}
			var currentAlpha = this._dotAlpha;
			if (adjustAlpha) {
				currentAlpha = this._dotAlpha - ((this._dotAlpha - this._endDotAlpha) * ratio);
			}
			var currentRadius = dotRadius;
			if (adjustScale) {
				currentRadius = dotRadius - ((dotRadius - endDotRadius) * ratio);
			}

			graphics.beginFill(currentColor, currentAlpha);
			graphics.drawCircle(centerX + point.x, centerY + point.y, currentRadius);
			graphics.endFill();
		}
	}

	private function blendColors(color1:UInt, color2:UInt, ratio:Float):UInt {
		var r1:Int = (color1 >> 16) & 0xff;
		var g1:Int = (color1 >> 8) & 0xff;
		var b1:Int = color1 & 0xff;

		var r2:Int = (color2 >> 16) & 0xff;
		var g2:Int = (color2 >> 8) & 0xff;
		var b2:Int = color2 & 0xff;

		var r3:Int = r1 + Std.int((r2 - r1) * ratio);
		var g3:Int = g1 + Std.int((g2 - g1) * ratio);
		var b3:Int = b1 + Std.int((b2 - b1) * ratio);

		return (r3 << 16) | (g3 << 8) | b3;
	}
}
