/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import openfl.display.LineScaleMode;
import feathers.core.InvalidationFlag;
import feathers.core.IStateContext;
import feathers.core.IStateObserver;
import feathers.core.FeathersControl;
import feathers.graphics.FillStyle;
import feathers.graphics.LineStyle;

/**
	A skin for Feathers components that draws a rectangle. The rectangle's fill
	and border may be styled, and the recatangle may be rounded.

	@since 1.0.0
**/
class RectangleSkin extends FeathersControl implements IStateObserver {
	public function new() {
		super();
		this.mouseChildren = false;
		this.tabEnabled = false;
		this.tabChildren = false;
	}

	public var stateContext(default, set):IStateContext;

	private function set_stateContext(value:IStateContext):IStateContext {
		if (this.stateContext == value) {
			return this.stateContext;
		}
		this.stateContext = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.stateContext;
	}

	private var _stateToFill:Map<String, FillStyle>;

	/**
		How the rectangle's fill is styled. For example, it could be a solid
		color, a gradient, or a tiled bitmap.

		@since 1.0.0
	**/
	public var fill(default, set):FillStyle = FillStyle.SolidColor(0xcccccc);

	private function set_fill(value:FillStyle):FillStyle {
		if (this.fill == value) {
			return this.fill;
		}
		this.fill = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.fill;
	}

	private var _stateToBorder:Map<String, LineStyle>;

	/**
		How the rectangle's border is styled.

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
		The rectangle may optionally have rounded corners, and this sets their
		radius.

		@since 1.0.0
	**/
	public var cornerRadius(default, set):Null<Float> = null;

	private function set_cornerRadius(value:Float):Float {
		if (this.cornerRadius == value) {
			return this.cornerRadius;
		}
		this.cornerRadius = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.cornerRadius;
	}

	/**
		Gets the fill style to be used by the skin when the context's
		`currentState` property matches the specified state value.

		If a fill is not defined for a specific state, returns `null`.

		@see `fill`
		@see `setFillForState()`

		@since 1.0.0
	**/
	public function getFillForState(state:String):FillStyle {
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

		@see `fill`
		@see `getFillForState()`

		@since 1.0.0
	**/
	public function setFillForState(state:String, fill:FillStyle):Void {
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

		@see `border`
		@see `setBorderForState()`

		@since 1.0.0
	**/
	public function getBorderForState(state:String):LineStyle {
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

		@see `border`
		@see `getBorderForState()`

		@since 1.0.0
	**/
	public function setBorderForState(state:String, border:LineStyle):Void {
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
		this.graphics.clear();
		this.applyBorderStyle();
		this.applyFillStyle();
		if (this.cornerRadius == 0.0) {
			this.graphics.drawRect(0.0, 0.0, this.actualWidth, this.actualHeight);
		} else {
			this.graphics.drawRoundRect(0.0, 0.0, this.actualWidth, this.actualHeight, this.cornerRadius, this.cornerRadius);
		}
		this.graphics.endFill();
	}

	private function applyBorderStyle():Void {
		var border = this.getCurrentBorder();
		if (border == null) {
			return;
		}
		switch (border) {
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
		}
	}

	private function getCurrentBorder():LineStyle {
		if (this.stateContext == null || this._stateToBorder == null) {
			return this.border;
		}
		var result = this._stateToBorder.get(this.stateContext.currentState);
		if (result == null) {
			return this.border;
		}
		return result;
	}

	private function applyFillStyle():Void {
		var fill = this.getCurrentFill();
		if (fill == null) {
			return;
		}
		switch (fill) {
			case SolidColor(color, alpha):
				{
					if (alpha == null) {
						alpha = 1.0;
					}
					this.graphics.beginFill(color, alpha);
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

	private function getCurrentFill():FillStyle {
		if (this.stateContext == null || this._stateToFill == null) {
			return this.fill;
		}
		var result = this._stateToFill.get(this.stateContext.currentState);
		if (result == null) {
			return this.fill;
		}
		return result;
	}
}
