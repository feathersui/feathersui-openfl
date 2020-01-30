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
class BaseGraphicsPathSkin extends MeasureSprite implements IStateObserver {
	private function new() {
		super();
		this.mouseChildren = false;
		this.tabEnabled = false;
		this.tabChildren = false;
	}

	private var _previousBorder:LineStyle = null;
	private var _previousFill:FillStyle = null;

	/**
		An optional `IStateContext` that is used to change the styles of the
		skin when its state changes.

		@since 1.0.0
	**/
	public var stateContext(default, set):IStateContext<Dynamic>;

	private function set_stateContext(value:IStateContext<Dynamic>):IStateContext<Dynamic> {
		if (this.stateContext == value) {
			return this.stateContext;
		}
		if (this.stateContext != null) {
			this.stateContext.removeEventListener(FeathersEvent.STATE_CHANGE, stateContext_stateChangeHandler);
			if (Std.is(this.stateContext, IToggle)) {
				this.stateContext.removeEventListener(Event.CHANGE, stateContextToggle_changeHandler);
			}
		}
		this.stateContext = value;
		if (this.stateContext != null) {
			this.stateContext.addEventListener(FeathersEvent.STATE_CHANGE, stateContext_stateChangeHandler, false, 0, true);
			if (Std.is(this.stateContext, IToggle)) {
				this.stateContext.addEventListener(Event.CHANGE, stateContextToggle_changeHandler);
			}
		}
		this.setInvalid(InvalidationFlag.DATA);
		return this.stateContext;
	}

	private var _stateToFill:Map<EnumValue, FillStyle>;

	/**
		How the path's fill is styled. For example, it could be a solid color,
		a gradient, or a tiled bitmap.

		@since 1.0.0
	**/
	public var fill(default, set):FillStyle = SolidColor(0xcccccc);

	private function set_fill(value:FillStyle):FillStyle {
		if (this.fill == value) {
			return this.fill;
		}
		this.fill = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.fill;
	}

	/**
		How the path's fill is styled when the state context is disabled. To
		use this skin, the state context must implement the `IUIControl`
		interface.

		@see `feathers.core.IUIControl.enabled`

		@since 1.0.0
	**/
	public var disabledFill(default, set):FillStyle = null;

	private function set_disabledFill(value:FillStyle):FillStyle {
		if (this.disabledFill == value) {
			return this.disabledFill;
		}
		this.disabledFill = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.disabledFill;
	}

	/**
		How the path's fill is styled when the state context is selected. To
		use this skin, the state context must implement the `IToggle` interface.

		@see `feathers.controls.IToggle.selected`

		@since 1.0.0
	**/
	public var selectedFill(default, set):FillStyle = null;

	private function set_selectedFill(value:FillStyle):FillStyle {
		if (this.selectedFill == value) {
			return this.selectedFill;
		}
		this.selectedFill = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.selectedFill;
	}

	private var _stateToBorder:Map<EnumValue, LineStyle>;

	/**
		How the path's border is styled.

		@since 1.0.0
	**/
	public var border(default, set):LineStyle;

	private function set_border(value:LineStyle):LineStyle {
		if (this.border == value) {
			return this.border;
		}
		this.border = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.border;
	}

	/**
		How the path's border is styled when the state context is disabled. To
		use this skin, the state context must implement the `IUIControl`
		interface.

		@see `feathers.core.IUIControl.enabled`

		@since 1.0.0
	**/
	public var disabledBorder(default, set):LineStyle;

	private function set_disabledBorder(value:LineStyle):LineStyle {
		if (this.disabledBorder == value) {
			return this.disabledBorder;
		}
		this.disabledBorder = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.disabledBorder;
	}

	/**
		How the path's border is styled when the state context is selected. To
		use this skin, the state context must implement the `IToggle` interface.

		@see `feathers.controls.IToggle.selected`

		@since 1.0.0
	**/
	public var selectedBorder(default, set):LineStyle;

	private function set_selectedBorder(value:LineStyle):LineStyle {
		if (this.selectedBorder == value) {
			return this.selectedBorder;
		}
		this.selectedBorder = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.selectedBorder;
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
		if (this.stateContext == null) {
			return this.border;
		}
		if (this._stateToBorder != null) {
			var result = this._stateToBorder.get(this.stateContext.currentState);
			if (result != null) {
				return result;
			}
		}
		if (this.disabledBorder != null && Std.is(this.stateContext, IUIControl)) {
			var control = cast(this.stateContext, IUIControl);
			if (!control.enabled) {
				return this.disabledBorder;
			}
		}
		if (this.selectedBorder != null && Std.is(this.stateContext, IToggle)) {
			var toggle = cast(this.stateContext, IToggle);
			if (toggle.selected) {
				return this.selectedBorder;
			}
		}
		return this.border;
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
		if (this.stateContext == null) {
			return this.fill;
		}
		if (this._stateToFill != null) {
			var result = this._stateToFill.get(this.stateContext.currentState);
			if (result != null) {
				return result;
			}
		}
		if (this.disabledFill != null && Std.is(this.stateContext, IUIControl)) {
			var control = cast(this.stateContext, IUIControl);
			if (!control.enabled) {
				return this.disabledFill;
			}
		}
		if (this.selectedFill != null && Std.is(this.stateContext, IToggle)) {
			var toggle = cast(this.stateContext, IToggle);
			if (toggle.selected) {
				return this.selectedFill;
			}
		}
		return this.fill;
	}

	/**
		Checks if a the current state requires the skin to be redrawn.

		Subclasses may need to override this method if they add any additional
		state-dependent properties similar to `getCurrentBorder` and
		`getCurrentFill`.

		@since 1.0.0
	**/
	@:dox(show)
	private function needsStateUpdate():Bool {
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

	private function checkForStateChange():Void {
		if (!this.needsStateUpdate()) {
			return;
		}
		this.setInvalid(InvalidationFlag.STATE);
	}

	private function stateContext_stateChangeHandler(event:FeathersEvent):Void {
		this.checkForStateChange();
	}

	private function stateContextToggle_changeHandler(event:Event):Void {
		this.checkForStateChange();
	}
}
