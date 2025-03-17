/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.controls.IToggle;
import feathers.core.IStateContext;
import feathers.core.IUIControl;
import feathers.graphics.FillStyle;
import feathers.graphics.LineStyle;
import openfl.display.InterpolationMethod;
import openfl.display.LineScaleMode;
import openfl.display.SpreadMethod;
import openfl.geom.Matrix;

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
	public var fill(get, set):FillStyle;

	private function get_fill():FillStyle {
		return this._fill;
	}

	private function set_fill(value:FillStyle):FillStyle {
		if (this._fill == value) {
			return this._fill;
		}
		if (this._previousFill == this._fill) {
			this._previousFill = null;
		}
		this._fill = value;
		this.setInvalid(STYLES);
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
	public var disabledFill(get, set):FillStyle;

	private function get_disabledFill():FillStyle {
		return this._disabledFill;
	}

	private function set_disabledFill(value:FillStyle):FillStyle {
		if (this._disabledFill == value) {
			return this._disabledFill;
		}
		if (this._previousFill == this._disabledFill) {
			this._previousFill = null;
		}
		this._disabledFill = value;
		this.setInvalid(STYLES);
		return this._disabledFill;
	}

	private var _selectedFill:FillStyle;

	/**
		How the path's fill is styled when the state context is selected. To
		use this skin, the state context must implement the `IToggle` interface.

		@see `feathers.controls.IToggle.selected`

		@since 1.0.0
	**/
	public var selectedFill(get, set):FillStyle;

	private function get_selectedFill():FillStyle {
		return this._selectedFill;
	}

	private function set_selectedFill(value:FillStyle):FillStyle {
		if (this._selectedFill == value) {
			return this._selectedFill;
		}
		if (this._previousFill == this._selectedFill) {
			this._previousFill = null;
		}
		this._selectedFill = value;
		this.setInvalid(STYLES);
		return this._selectedFill;
	}

	override private function set_uiContext(value:IUIControl):IUIControl {
		if (this._uiContext == value) {
			return this._uiContext;
		}
		this._previousBorder = null;
		this._previousFill = null;
		return super.uiContext = value;
	}

	override private function set_stateContext(value:IStateContext<Dynamic>):IStateContext<Dynamic> {
		if (this._stateContext == value) {
			return this._stateContext;
		}
		this._previousBorder = null;
		this._previousFill = null;
		return super.stateContext = value;
	}

	private var _stateToBorder:Map<EnumValue, LineStyle>;

	private var _border:LineStyle;

	/**
		How the path's border is styled.

		@since 1.0.0
	**/
	public var border(get, set):LineStyle;

	private function get_border():LineStyle {
		return this._border;
	}

	private function set_border(value:LineStyle):LineStyle {
		if (this._border == value) {
			return this._border;
		}
		if (this._previousBorder == this._border) {
			this._previousBorder = null;
		}
		this._border = value;
		this.setInvalid(STYLES);
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
	public var disabledBorder(get, set):LineStyle;

	private function get_disabledBorder():LineStyle {
		return this._disabledBorder;
	}

	private function set_disabledBorder(value:LineStyle):LineStyle {
		if (this._disabledBorder == value) {
			return this._disabledBorder;
		}
		if (this._previousBorder == this._disabledBorder) {
			this._previousBorder = null;
		}
		this._disabledBorder = value;
		this.setInvalid(STYLES);
		return this._disabledBorder;
	}

	private var _selectedBorder:LineStyle;

	/**
		How the path's border is styled when the state context is selected. To
		use this skin, the state context must implement the `IToggle` interface.

		@see `feathers.controls.IToggle.selected`

		@since 1.0.0
	**/
	public var selectedBorder(get, set):LineStyle;

	private function get_selectedBorder():LineStyle {
		return this._selectedBorder;
	}

	private function set_selectedBorder(value:LineStyle):LineStyle {
		if (this._selectedBorder == value) {
			return this._selectedBorder;
		}
		if (this._previousBorder == this._selectedBorder) {
			this._previousBorder = null;
		}
		this._selectedBorder = value;
		this.setInvalid(STYLES);
		return this._selectedBorder;
	}

	/**
		Gets the fill style to be used by the skin when the context's
		`currentState` property matches the specified state value.

		If a fill is not defined for a specific state, returns `null`.

		@see `ProgrammaticSkin.stateContext`
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

		@see `ProgrammaticSkin.stateContext`
		@see `BaseGraphicsPathSkin.fill`
		@see `BaseGraphicsPathSkin.getFillForState`

		@since 1.0.0
	**/
	public function setFillForState(state:EnumValue, fill:FillStyle):Void {
		if (this._stateToFill == null) {
			this._stateToFill = [];
		}
		var oldFill = this._stateToFill.get(state);
		if (oldFill == fill) {
			return;
		}
		if (this._previousFill == oldFill) {
			this._previousFill = null;
		}
		this._stateToFill.set(state, fill);
		this.setInvalid(STYLES);
	}

	/**
		Gets the border style to be used by the skin when the context's
		`currentState` property matches the specified state value.

		If a border is not defined for a specific state, returns `null`.

		@see `ProgrammaticSkin.stateContext`
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

		@see `ProgrammaticSkin.stateContext`
		@see `BaseGraphicsPathSkin.border`
		@see `BaseGraphicsPathSkin.getBorderForState`

		@since 1.0.0
	**/
	public function setBorderForState(state:EnumValue, border:LineStyle):Void {
		if (this._stateToBorder == null) {
			this._stateToBorder = [];
		}
		var oldBorder = this._stateToBorder.get(state);
		if (oldBorder == border) {
			return;
		}
		if (this._previousBorder == oldBorder) {
			this._previousBorder = null;
		}
		this._stateToBorder.set(state, border);
		this.setInvalid(STYLES);
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
		if (currentFill != null && currentFill != None) {
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
			case None:
				{
					this.graphics.lineStyle(Math.NaN, 0, 0.0);
				}
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
			case Gradient(thickness, type, colors, alphas, ratios, matrixCallback, spreadMethod, interpolationMethod, focalPointRatio):
				{
					var callback:(Float, Float, ?Float, ?Float, ?Float) -> Matrix = matrixCallback;
					if (callback == null) {
						callback = getDefaultGradientMatrix;
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
					var matrix = callback(this.getDefaultGradientMatrixWidth(), this.getDefaultGradientMatrixHeight(), this.getDefaultGradientMatrixRadians(),
						this.getDefaultGradientMatrixTx(), this.getDefaultGradientMatrixTy());
					this.graphics.lineStyle(thickness);
					this.graphics.lineGradientStyle(type, #if flash cast #end colors, alphas, ratios, matrix, spreadMethod, interpolationMethod,
						focalPointRatio);
				}
			case Bitmap(thickness, bitmapData, matrix, repeat, smooth):
				{
					if (repeat == null) {
						repeat = true;
					}
					if (smooth == null) {
						smooth = false;
					}
					this.graphics.lineStyle(thickness);
					this.graphics.lineBitmapStyle(bitmapData, matrix, repeat, smooth);
				}
		}
	}

	private function applyFillStyle(fillStyle:FillStyle):Void {
		if (fillStyle == null) {
			return;
		}
		switch (fillStyle) {
			case None:
				{
					// no fill style to apply
					return;
				}
			case SolidColor(color, alpha):
				{
					if (alpha == null) {
						alpha = 1.0;
					}
					this.graphics.beginFill(color, alpha);
				}
			case Gradient(type, colors, alphas, ratios, matrixCallback, spreadMethod, interpolationMethod, focalPointRatio):
				{
					var callback:(Float, Float, ?Float, ?Float, ?Float) -> Matrix = matrixCallback;
					if (callback == null) {
						callback = getDefaultGradientMatrix;
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
					var matrix = callback(this.getDefaultGradientMatrixWidth(), this.getDefaultGradientMatrixHeight(), this.getDefaultGradientMatrixRadians(),
						this.getDefaultGradientMatrixTx(), this.getDefaultGradientMatrixTy());
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
			case Gradient(thickness, colors, alphas, ratios, matrixCallback):
				{
					return thickness;
				}
			default:
				{
					return 0;
				}
		}
	}

	private function getDefaultGradientMatrix(width:Float, height:Float, ?radians:Float = 0.0, ?tx:Float = 0.0, ?ty:Float = 0.0):Matrix {
		var matrix = new Matrix();
		matrix.createGradientBox(width, height, radians, tx, ty);
		return matrix;
	}

	private function getDefaultGradientMatrixWidth():Float {
		return this.actualWidth;
	}

	private function getDefaultGradientMatrixHeight():Float {
		return this.actualHeight;
	}

	private function getDefaultGradientMatrixRadians():Float {
		return 0.0;
	}

	private function getDefaultGradientMatrixTx():Float {
		return 0.0;
	}

	private function getDefaultGradientMatrixTy():Float {
		return 0.0;
	}

	/**
		Returns the current border based on the state context.

		@see `BaseGraphicsPathSkin.border`
		@see `BaseGraphicsPathSkin.getBorderForState`
		@see `BaseGraphicsPathSkin.setBorderForState`
		@see `ProgrammaticSkin.stateContext`

		@since 1.0.0
	**/
	@:dox(show)
	private function getCurrentBorder():LineStyle {
		if (this._previousBorder != null) {
			return this._previousBorder;
		}
		return this.getCurrentBorderWithoutCache();
	}

	private function getCurrentBorderWithoutCache():LineStyle {
		var stateContext = this._stateContext;
		if (stateContext == null && (this._uiContext is IStateContext)) {
			stateContext = cast this._uiContext;
		}
		if (this._stateToBorder != null && stateContext != null) {
			var result = this._stateToBorder.get(stateContext.currentState);
			if (result != null) {
				return result;
			}
		}
		if (this._uiContext == null) {
			return this._border;
		}
		if (this._disabledBorder != null) {
			if (!this._uiContext.enabled) {
				return this._disabledBorder;
			}
		}
		if (this._selectedBorder != null && (this._uiContext is IToggle)) {
			var toggle:IToggle = cast this._uiContext;
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
		@see `ProgrammaticSkin.stateContext`

		@since 1.0.0
	**/
	@:dox(show)
	private function getCurrentFill():FillStyle {
		if (this._previousFill != null) {
			return this._previousFill;
		}
		return this.getCurrentFillWithoutCache();
	}

	private function getCurrentFillWithoutCache() {
		var stateContext = this._stateContext;
		if (stateContext == null && (this._uiContext is IStateContext)) {
			stateContext = cast this._uiContext;
		}
		if (this._stateToFill != null && stateContext != null) {
			var result = this._stateToFill.get(stateContext.currentState);
			if (result != null) {
				return result;
			}
		}
		if (this._uiContext == null) {
			return this._fill;
		}
		if (this._disabledFill != null) {
			if (!this._uiContext.enabled) {
				return this._disabledFill;
			}
		}
		if (this._selectedFill != null && (this._uiContext is IToggle)) {
			var toggle:IToggle = cast this._uiContext;
			if (toggle.selected) {
				return this._selectedFill;
			}
		}
		return this._fill;
	}

	override private function needsStateUpdate():Bool {
		var updated = false;
		if (this._previousBorder != this.getCurrentBorderWithoutCache()) {
			this._previousBorder = null;
			updated = true;
		}
		if (this._previousFill != this.getCurrentFillWithoutCache()) {
			this._previousFill = null;
			updated = true;
		}
		return updated;
	}
}
