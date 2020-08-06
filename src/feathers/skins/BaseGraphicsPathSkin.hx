/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.core.IUIControl;
import openfl.events.Event;
import openfl.display.LineScaleMode;
import openfl.display.InterpolationMethod;
import openfl.display.SpreadMethod;
import feathers.controls.IToggle;
import feathers.core.InvalidationFlag;
import feathers.core.IStateContext;
import feathers.core.IStateObserver;
import feathers.core.MeasureSprite;
import feathers.events.FeathersEvent;
import openfl.geom.Matrix;
import feathers.graphics.FillStyle;
import feathers.graphics.LineStyle;

/**
	A base class for Feathers UI skins that draw a path with a fill and border
	using [`openfl.display.Graphics`](https://api.openfl.org/openfl/display/Graphics.html).

	@since 1.0.0
**/
class BaseGraphicsPathSkin extends ProgrammaticSkin {
	private function new(?fill:FillStyle, ?border:LineStyle) {
		super();
		this.fill = fill;
		this.border = border;
	}

	private var _previousBorder:LineStyle = null;
	private var _previousFill:FillStyle = null;

	private var _stateToFill:Map<EnumValue, FillStyle>;

	private var _fill:FillStyle;

	/**
		How the path's fill is styled. For example, it could be a solid color,
		a gradient, or a tiled bitmap.

		@since 1.0.0
	**/
	@:flash.property
	public var fill(get, set):FillStyle;

	private function get_fill():FillStyle {
		return this._fill;
	}

	private function set_fill(value:FillStyle):FillStyle {
		if (this._fill == value) {
			return this._fill;
		}
		this._fill = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this._fill;
	}

	private var _disabledFill:FillStyle;

	/**
		How the path's fill is styled when the state context is disabled. To
		use this skin, the state context must implement the `IUIControl`
		interface.

		@see `feathers.core.IUIControl.enabled`

		@since 1.0.0
	**/
	@:flash.property
	public var disabledFill(get, set):FillStyle;

	private function get_disabledFill():FillStyle {
		return this._disabledFill;
	}

	private function set_disabledFill(value:FillStyle):FillStyle {
		if (this._disabledFill == value) {
			return this._disabledFill;
		}
		this._disabledFill = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this._disabledFill;
	}

	private var _selectedFill:FillStyle;

	/**
		How the path's fill is styled when the state context is selected. To
		use this skin, the state context must implement the `IToggle` interface.

		@see `feathers.controls.IToggle.selected`

		@since 1.0.0
	**/
	@:flash.property
	public var selectedFill(get, set):FillStyle;

	private function get_selectedFill():FillStyle {
		return this._selectedFill;
	}

	private function set_selectedFill(value:FillStyle):FillStyle {
		if (this._selectedFill == value) {
			return this._selectedFill;
		}
		this._selectedFill = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this._selectedFill;
	}

	private var _stateToBorder:Map<EnumValue, LineStyle>;

	private var _border:LineStyle;

	/**
		How the path's border is styled.

		@since 1.0.0
	**/
	@:flash.property
	public var border(get, set):LineStyle;

	private function get_border():LineStyle {
		return this._border;
	}

	private function set_border(value:LineStyle):LineStyle {
		if (this._border == value) {
			return this._border;
		}
		this._border = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this._border;
	}

	private var _disabledBorder:LineStyle;

	/**
		How the path's border is styled when the state context is disabled. To
		use this skin, the state context must implement the `IUIControl`
		interface.

		@see `feathers.core.IUIControl.enabled`

		@since 1.0.0
	**/
	@:flash.property
	public var disabledBorder(get, set):LineStyle;

	private function get_disabledBorder():LineStyle {
		return this._disabledBorder;
	}

	private function set_disabledBorder(value:LineStyle):LineStyle {
		if (this._disabledBorder == value) {
			return this._disabledBorder;
		}
		this._disabledBorder = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this._disabledBorder;
	}

	private var _selectedBorder:LineStyle;

	/**
		How the path's border is styled when the state context is selected. To
		use this skin, the state context must implement the `IToggle` interface.

		@see `feathers.controls.IToggle.selected`

		@since 1.0.0
	**/
	@:flash.property
	public var selectedBorder(get, set):LineStyle;

	private function get_selectedBorder():LineStyle {
		return this._selectedBorder;
	}

	private function set_selectedBorder(value:LineStyle):LineStyle {
		if (this._selectedBorder == value) {
			return this._selectedBorder;
		}
		this._selectedBorder = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this._selectedBorder;
	}

	/**
		Gets the fill style to be used by the skin when the context's
		`currentState` property matches the specified state value.

		If a fill is not defined for a specific state, returns `null`.

		@see `BaseGraphicsPathSkin.stateContext`
		@see `BaseGraphicsPathSkin.fill`
		@see `BaseGraphicsPathSkin.setFillForState`

		@since 1.0.0
	**/
	public function getFillForState(state:EnumValue):FillStyle {
		if (this._stateToFill == null) {
			return null;
		}
		return this._stateToFill.get(state);
	}

	/**
		Sets the fill style to be used by the skin when the context's
		`currentState` property matches the specified state value.

		If a color is not defined for a specific state, the value of the `fill`
		property will be used instead.

		To clear a state's fill, pass in `null`.

		@see `BaseGraphicsPathSkin.stateContext`
		@see `BaseGraphicsPathSkin.fill`
		@see `BaseGraphicsPathSkin.getFillForState`

		@since 1.0.0
	**/
	public function setFillForState(state:EnumValue, fill:FillStyle):Void {
		if (this._stateToFill == null) {
			this._stateToFill = [];
		}
		if (this._stateToFill.get(state) == fill) {
			return;
		}
		this._stateToFill.set(state, fill);
		this.setInvalid(InvalidationFlag.STYLES);
	}

	/**
		Gets the border style to be used by the skin when the context's
		`currentState` property matches the specified state value.

		If a border is not defined for a specific state, returns `null`.

		@see `BaseGraphicsPathSkin.stateContext`
		@see `BaseGraphicsPathSkin.border`
		@see `BaseGraphicsPathSkin.setBorderForState`

		@since 1.0.0
	**/
	public function getBorderForState(state:EnumValue):LineStyle {
		if (this._stateToBorder == null) {
			return null;
		}
		return this._stateToBorder.get(state);
	}

	/**
		Sets the border style to be used by the skin when the context's
		`currentState` property matches the specified state value.

		If a color is not defined for a specific state, the value of the
		`border` property will be used instead.

		To clear a state's border, pass in `null`.

		@see `BaseGraphicsPathSkin.stateContext`
		@see `BaseGraphicsPathSkin.border`
		@see `BaseGraphicsPathSkin.getBorderForState`

		@since 1.0.0
	**/
	public function setBorderForState(state:EnumValue, border:LineStyle):Void {
		if (this._stateToBorder == null) {
			this._stateToBorder = [];
		}
		if (this._stateToBorder.get(state) == border) {
			return;
		}
		this._stateToBorder.set(state, border);
		this.setInvalid(InvalidationFlag.STYLES);
	}

	override private function update():Void {
		this._previousBorder = this.getCurrentBorder();
		this._previousFill = this.getCurrentFill();
		this.graphics.clear();
		this.draw();
	}

	private function draw():Void {
		this.applyLineStyle(this.getCurrentBorder());
		var currentFill = this.getCurrentFill();
		this.applyFillStyle(currentFill);
		this.drawPath();
		if (currentFill != null) {
			this.graphics.endFill();
		}
	}

	/**
		Subclasses should override `drawPath()` to draw the skin's graphics.

		@since 1.0.0
	**/
	@:dox(show)
	private function drawPath():Void {}

	private function applyLineStyle(lineStyle:LineStyle):Void {
		if (lineStyle == null) {
			return;
		}
		switch (lineStyle) {
			case SolidColor(thickness, color, alpha, pixelHinting, scaleMode, caps, joints, miterLimit):
				{
					if (color == null) {
						color = 0;
					}
					if (alpha == null) {
						alpha = 1.0;
					}
					if (pixelHinting == null) {
						pixelHinting = false;
					}
					if (scaleMode == null) {
						scaleMode = LineScaleMode.NORMAL;
					}
					if (miterLimit == null) {
						miterLimit = 3.0;
					}
					this.graphics.lineStyle(thickness, color, alpha, pixelHinting, scaleMode, caps, joints, miterLimit);
				}
			case Gradient(thickness, type, colors, alphas, ratios, radians, spreadMethod, interpolationMethod, focalPointRatio):
				{
					if (radians == null) {
						radians = 0.0;
					}
					if (spreadMethod == null) {
						spreadMethod = SpreadMethod.PAD;
					}
					if (interpolationMethod == null) {
						interpolationMethod = InterpolationMethod.RGB;
					}
					if (focalPointRatio == null) {
						focalPointRatio = 0.0;
					}
					var matrix = getGradientMatrix(radians);
					this.graphics.lineStyle(thickness);
					this.graphics.lineGradientStyle(type, #if flash cast #end colors, alphas, ratios, matrix, spreadMethod, interpolationMethod,
						focalPointRatio);
				}
		}
	}

	private function applyFillStyle(fillStyle:FillStyle):Void {
		if (fillStyle == null) {
			return;
		}
		switch (fillStyle) {
			case SolidColor(color, alpha):
				{
					if (alpha == null) {
						alpha = 1.0;
					}
					this.graphics.beginFill(color, alpha);
				}
			case Gradient(type, colors, alphas, ratios, radians, spreadMethod, interpolationMethod, focalPointRatio):
				{
					if (radians == null) {
						radians = 0.0;
					}
					if (spreadMethod == null) {
						spreadMethod = SpreadMethod.PAD;
					}
					if (interpolationMethod == null) {
						interpolationMethod = InterpolationMethod.RGB;
					}
					if (focalPointRatio == null) {
						focalPointRatio = 0.0;
					}
					var matrix = getGradientMatrix(radians);
					this.graphics.beginGradientFill(type, #if flash cast #end colors, alphas, ratios, matrix, spreadMethod, interpolationMethod,
						focalPointRatio);
				}
			case Bitmap(bitmapData, matrix, repeat, smooth):
				{
					if (repeat == null) {
						repeat = true;
					}
					if (smooth == null) {
						smooth = false;
					}
					this.graphics.beginBitmapFill(bitmapData, matrix, repeat, smooth);
				}
		}
	}

	private function getLineThickness(lineStyle:LineStyle):Float {
		if (lineStyle == null) {
			return 0;
		}
		switch (lineStyle) {
			case SolidColor(thickness):
				{
					return thickness;
				}
			case Gradient(thickness, colors, alphas, ratios, radians):
				{
					return thickness;
				}
			default:
				{
					return 0;
				}
		}
	}

	private function getGradientMatrix(radians:Float):Matrix {
		var matrix = new Matrix();
		matrix.createGradientBox(this.actualWidth, this.actualHeight, radians);
		return matrix;
	}

	/**
		Returns the current border based on the state context.

		@see `BaseGraphicsPathSkin.border`
		@see `BaseGraphicsPathSkin.getBorderForState`
		@see `BaseGraphicsPathSkin.setBorderForState`
		@see `BaseGraphicsPathSkin.stateContext`

		@since 1.0.0
	**/
	@:dox(show)
	private function getCurrentBorder():LineStyle {
		if (this._previousBorder != null) {
			return this._previousBorder;
		}
		return getCurrentBorderWithoutCache();
	}

	private function getCurrentBorderWithoutCache():LineStyle {
		if (this._stateContext == null) {
			return this._border;
		}
		if (this._stateToBorder != null) {
			var result = this._stateToBorder.get(this._stateContext.currentState);
			if (result != null) {
				return result;
			}
		}
		if (this._disabledBorder != null && Std.is(this._stateContext, IUIControl)) {
			var control = cast(this._stateContext, IUIControl);
			if (!control.enabled) {
				return this._disabledBorder;
			}
		}
		if (this._selectedBorder != null && Std.is(this._stateContext, IToggle)) {
			var toggle = cast(this._stateContext, IToggle);
			if (toggle.selected) {
				return this._selectedBorder;
			}
		}
		return this._border;
	}

	/**
		Returns the current fill based on the state context.

		@see `BaseGraphicsPathSkin.fill`
		@see `BaseGraphicsPathSkin.getFillForState`
		@see `BaseGraphicsPathSkin.setFillForState`
		@see `BaseGraphicsPathSkin.stateContext`

		@since 1.0.0
	**/
	@:dox(show)
	private function getCurrentFill():FillStyle {
		if (this._previousFill != null) {
			return this._previousFill;
		}
		return getCurrentFillWithoutCache();
	}

	private function getCurrentFillWithoutCache() {
		if (this._stateContext == null) {
			return this._fill;
		}
		if (this._stateToFill != null) {
			var result = this._stateToFill.get(this._stateContext.currentState);
			if (result != null) {
				return result;
			}
		}
		if (this._disabledFill != null && Std.is(this._stateContext, IUIControl)) {
			var control = cast(this._stateContext, IUIControl);
			if (!control.enabled) {
				return this._disabledFill;
			}
		}
		if (this._selectedFill != null && Std.is(this._stateContext, IToggle)) {
			var toggle = cast(this._stateContext, IToggle);
			if (toggle.selected) {
				return this._selectedFill;
			}
		}
		return this._fill;
	}

	override private function needsStateUpdate():Bool {
		var updated = false;
		if (this._previousBorder != getCurrentBorderWithoutCache()) {
			this._previousBorder = null;
			updated = true;
		}
		if (this._previousFill != getCurrentFillWithoutCache()) {
			this._previousFill = null;
			updated = true;
		}
		return updated;
	}
}
