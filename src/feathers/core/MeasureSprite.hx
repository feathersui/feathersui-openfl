/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.errors.ArgumentError;
import openfl.events.Event;
import feathers.events.FeathersEvent;

/**
	An [`openfl.display.Sprite`](https://api.openfl.org/openfl/display/Sprite.html)
	with extra minimum and maximum dimensions that may be used in Feathers UI
	layouts.

	@since 1.0.0
**/
@:event(openfl.events.Event.RESIZE)
class MeasureSprite extends ValidatingSprite implements IMeasureObject {
	private var actualWidth:Float = 0.0;
	private var actualHeight:Float = 0.0;
	private var actualMinWidth:Float = 0.0;
	private var actualMinHeight:Float = 0.0;
	private var actualMaxWidth:Float = Math.POSITIVE_INFINITY;
	private var actualMaxHeight:Float = Math.POSITIVE_INFINITY;
	private var scaledActualWidth:Float = 0.0;
	private var scaledActualHeight:Float = 0.0;
	private var scaledActualMinWidth:Float = 0.0;
	private var scaledActualMinHeight:Float = 0.0;
	private var scaledActualMaxWidth:Float = Math.POSITIVE_INFINITY;
	private var scaledActualMaxHeight:Float = Math.POSITIVE_INFINITY;

	/**
		Creates a new `MeasureSprite` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

	@:getter(width)
	#if !flash override #end private function get_width():Float {
		return this.scaledActualWidth;
	}

	@:setter(width)
	#if !flash override #end private function set_width(value:Float):#if !flash Float #else Void #end {
		if (this.scaleX != 1.0) {
			value /= this.scaleX;
		}
		// use the setter here
		this.explicitWidth = value;
		#if !flash
		return this.scaledActualWidth;
		#end
	}

	@:getter(height)
	#if !flash override #end private function get_height():Float {
		return this.scaledActualHeight;
	}

	@:setter(height)
	#if !flash override #end private function set_height(value:Float):#if !flash Float #else Void #end {
		if (this.scaleY != 1.0) {
			value /= this.scaleY;
		}
		// use the setter here
		this.explicitHeight = value;
		#if !flash
		return this.scaledActualHeight;
		#end
	}

	@:setter(scaleX)
	#if !flash override #end private function set_scaleX(value:Float):#if !flash Float #else Void #end {
		super.scaleX = value;
		this.saveMeasurements(this.actualWidth, this.actualHeight, this.actualMinWidth, this.actualMinHeight, this.actualMaxWidth, this.actualMaxHeight);
		// no need to set invalid because the layout will be the same
		#if !flash
		return this.scaleX;
		#end
	}

	@:setter(scaleY)
	#if !flash override #end private function set_scaleY(value:Float):#if !flash Float #else Void #end {
		super.scaleY = value;
		this.saveMeasurements(this.actualWidth, this.actualHeight, this.actualMinWidth, this.actualMinHeight, this.actualMaxWidth, this.actualMaxHeight);
		// no need to set invalid because the layout will be the same
		#if !flash
		return this.scaleY;
		#end
	}

	private var _explicitWidth:Null<Float> = null;

	/**
		@see `feathers.core.IMeasureObject.explicitWidth`
	**/
	@:flash.property
	public var explicitWidth(get, set):Null<Float>;

	private function get_explicitWidth():Null<Float> {
		return this._explicitWidth;
	}

	private function set_explicitWidth(value:Null<Float>):Null<Float> {
		if (this._explicitWidth == value) {
			return this._explicitWidth;
		}
		this._explicitWidth = value;
		if (value == null) {
			if (this.actualWidth != 0.0) {
				this.actualWidth = 0.0;
				this.scaledActualWidth = 0.0;
				this.setInvalid(SIZE);
			}
		} else {
			var result = this.saveMeasurements(value, this.actualHeight, this.actualMinWidth, this.actualMinHeight, this.actualMaxWidth, this.actualMaxHeight);
			if (result) {
				this.setInvalid(SIZE);
			}
		}
		return this._explicitWidth;
	}

	private var _explicitHeight:Null<Float> = null;

	/**
		@see `feathers.core.IMeasureObject.explicitHeight`
	**/
	@:flash.property
	public var explicitHeight(get, set):Null<Float>;

	private function get_explicitHeight():Null<Float> {
		return this._explicitHeight;
	}

	private function set_explicitHeight(value:Null<Float>):Null<Float> {
		if (this._explicitHeight == value) {
			return this._explicitHeight;
		}
		this._explicitHeight = value;
		if (value == null) {
			if (this.actualHeight != 0.0) {
				this.actualHeight = 0.0;
				this.scaledActualHeight = 0.0;
				this.setInvalid(SIZE);
			}
		} else {
			var result = this.saveMeasurements(this.actualWidth, value, this.actualMinWidth, this.actualMinHeight, this.actualMaxWidth, this.actualMaxHeight);
			if (result) {
				this.setInvalid(SIZE);
			}
		}
		return this._explicitHeight;
	}

	private var _explicitMinWidth:Null<Float> = null;

	/**
		@see `feathers.core.IMeasureObject.explicitMinWidth`
	**/
	@:flash.property
	public var explicitMinWidth(get, set):Null<Float>;

	private function get_explicitMinWidth():Null<Float> {
		return this._explicitMinWidth;
	}

	private function set_explicitMinWidth(value:Null<Float>):Null<Float> {
		if (this._explicitMinWidth == value) {
			return this._explicitMinWidth;
		}
		var oldValue = this._explicitMinWidth;
		this._explicitMinWidth = value;
		if (value == null) {
			this.actualMinWidth = 0.0;
			this.scaledActualMinWidth = 0.0;
			this.setInvalid(SIZE);
		} else {
			// saveMeasurements() might change actualWidth, so keep the old
			// value for the comparisons below
			var actualWidth = this.actualWidth;
			this.saveMeasurements(this.actualWidth, this.actualHeight, value, this.actualMinHeight, this.actualMaxWidth, this.actualMaxHeight);
			if (this._explicitWidth == null && (actualWidth < value || actualWidth == oldValue)) {
				// only invalidate if this change might affect the width
				// because everything else was handled in saveMeasurements()
				this.setInvalid(SIZE);
			}
		}
		return this._explicitMinWidth;
	}

	private var _explicitMinHeight:Null<Float> = null;

	/**
		@see `feathers.core.IMeasureObject.explicitMinHeight`
	**/
	@:flash.property
	public var explicitMinHeight(get, set):Null<Float>;

	private function get_explicitMinHeight():Null<Float> {
		return this._explicitMinHeight;
	}

	private function set_explicitMinHeight(value:Null<Float>):Null<Float> {
		if (this._explicitMinHeight == value) {
			return this._explicitMinHeight;
		}
		var oldValue = this._explicitMinHeight;
		this._explicitMinHeight = value;
		if (value == null) {
			this.actualMinHeight = 0.0;
			this.scaledActualMinHeight = 0.0;
			this.setInvalid(SIZE);
		} else {
			// saveMeasurements() might change actualHeight, so keep the old
			// value for the comparisons below
			var actualHeight = this.actualHeight;
			this.saveMeasurements(this.actualWidth, this.actualHeight, this.actualMinWidth, value, this.actualMaxWidth, this.actualMaxHeight);
			if (this._explicitHeight == null && (actualHeight < value || actualHeight == oldValue)) {
				// only invalidate if this change might affect the width
				// because everything else was handled in saveMeasurements()
				this.setInvalid(SIZE);
			}
		}
		return this._explicitMinHeight;
	}

	/**
		@see `feathers.core.IMeasureObject.minWidth`
	**/
	@:flash.property
	public var minWidth(get, set):Float;

	private function get_minWidth():Float {
		return this.scaledActualMinWidth;
	}

	private function set_minWidth(value:Float):Float {
		if (this.scaleX != 1) {
			value /= this.scaleX;
		}
		// use the setter here
		this.explicitMinWidth = value;
		return this.scaledActualMinWidth;
	}

	/**
		@see `feathers.core.IMeasureObject.minHeight`
	**/
	@:flash.property
	public var minHeight(get, set):Float;

	private function get_minHeight():Float {
		return this.scaledActualMinHeight;
	}

	private function set_minHeight(value:Float):Float {
		if (this.scaleY != 1) {
			value /= this.scaleY;
		}
		// use the setter here
		this.explicitMinHeight = value;
		return this.scaledActualMinHeight;
	}

	private var _explicitMaxWidth:Null<Float> = null;

	/**
		@see `feathers.core.IMeasureObject.explicitMaxWidth`
	**/
	@:flash.property
	public var explicitMaxWidth(get, set):Null<Float>;

	private function get_explicitMaxWidth():Null<Float> {
		return this._explicitMaxWidth;
	}

	private function set_explicitMaxWidth(value:Null<Float>):Null<Float> {
		if (this._explicitMaxWidth == value) {
			return this._explicitMaxWidth;
		}
		var oldValue = this._explicitMaxWidth;
		this._explicitMaxWidth = value;
		if (value == null) {
			this.actualMaxWidth = Math.POSITIVE_INFINITY;
			this.scaledActualMaxWidth = Math.POSITIVE_INFINITY;
			this.setInvalid(SIZE);
		} else {
			// saveMeasurements() might change actualWidth, so keep the old
			// value for the comparisons below
			var actualWidth = this.actualWidth;
			this.saveMeasurements(this.actualWidth, this.actualHeight, this.actualMinWidth, this.actualMinHeight, value, this.actualMaxHeight);
			if (this._explicitWidth == null && (actualWidth > value || actualWidth == oldValue)) {
				// only invalidate if this change might affect the width
				// because everything else was handled in saveMeasurements()
				this.setInvalid(SIZE);
			}
		}
		return this._explicitMaxWidth;
	}

	private var _explicitMaxHeight:Null<Float> = null;

	/**
		@see `feathers.core.IMeasureObject.explicitMaxHeight`
	**/
	@:flash.property
	public var explicitMaxHeight(get, set):Null<Float>;

	private function get_explicitMaxHeight():Null<Float> {
		return this._explicitMaxHeight;
	}

	private function set_explicitMaxHeight(value:Null<Float>):Null<Float> {
		if (this._explicitMaxHeight == value) {
			return this._explicitMaxHeight;
		}
		var oldValue = this._explicitMaxHeight;
		this._explicitMaxHeight = value;
		if (value == null) {
			this.actualMaxHeight = Math.POSITIVE_INFINITY;
			this.scaledActualMaxHeight = Math.POSITIVE_INFINITY;
			this.setInvalid(SIZE);
		} else {
			// saveMeasurements() might change actualWidth, so keep the old
			// value for the comparisons below
			var actualHeight = this.actualHeight;
			this.saveMeasurements(this.actualWidth, this.actualHeight, this.actualMinWidth, this.actualMinHeight, this.actualMaxWidth, value);
			if (this._explicitHeight == null && (actualHeight > value || actualHeight == oldValue)) {
				// only invalidate if this change might affect the width
				// because everything else was handled in saveMeasurements()
				this.setInvalid(SIZE);
			}
		}
		return this._explicitMaxHeight;
	}

	/**
		@see `feathers.core.IMeasureObject.maxWidth`
	**/
	@:flash.property
	public var maxWidth(get, set):Float;

	private function get_maxWidth():Float {
		return this.scaledActualMaxWidth;
	}

	private function set_maxWidth(value:Float):Float {
		if (this.scaleX != 1) {
			value /= this.scaleX;
		}
		// use the setter here
		this.explicitMaxWidth = value;
		return this.scaledActualMaxWidth;
	}

	/**
		@see `feathers.core.IMeasureObject.maxHeight`
	**/
	@:flash.property
	public var maxHeight(get, set):Float;

	private function get_maxHeight():Float {
		return this.scaledActualMaxHeight;
	}

	private function set_maxHeight(value:Float):Float {
		if (this.scaleY != 1) {
			value /= this.scaleY;
		}
		// use the setter here
		this.explicitMaxHeight = value;
		return this.scaledActualMaxHeight;
	}

	/**
		@see `feathers.core.IMeasureObject.resetWidth`
	**/
	public function resetWidth():Void {
		// use the setter here
		this.explicitWidth = null;
	}

	/**
		@see `feathers.core.IMeasureObject.resetHeight`
	**/
	public function resetHeight():Void {
		// use the setter here
		this.explicitHeight = null;
	}

	/**
		@see `feathers.core.IMeasureObject.resetMinWidth`
	**/
	public function resetMinWidth():Void {
		// use the setter here
		this.explicitMinWidth = null;
	}

	/**
		@see `feathers.core.IMeasureObject.resetMinHeight`
	**/
	public function resetMinHeight():Void {
		// use the setter here
		this.explicitMinHeight = null;
	}

	/**
		@see `feathers.core.IMeasureObject.resetMaxWidth`
	**/
	public function resetMaxWidth():Void {
		// use the setter here
		this.explicitMaxWidth = null;
	}

	/**
		@see `feathers.core.IMeasureObject.resetMaxHeight`
	**/
	public function resetMaxHeight():Void {
		// use the setter here
		this.explicitMaxHeight = null;
	}

	/**
		Saves the calculated dimensions for the component, replacing any values
		that haven't been set explicitly. Returns `true` if the reported values
		have changed and `Event.RESIZE` was dispatched.

		@since 1.0.0
	**/
	@:dox(show)
	private function saveMeasurements(width:Float, height:Float, minWidth:Float = 0.0, minHeight:Float = 0.0, ?maxWidth:Float, ?maxHeight:Float):Bool {
		if (maxWidth == null) {
			maxWidth = Math.POSITIVE_INFINITY;
		}
		if (maxHeight == null) {
			maxHeight = Math.POSITIVE_INFINITY;
		}
		// if any of the dimensions were set explicitly, the explicit values must
		// take precedence over the measured values
		if (this._explicitMinWidth != null) {
			minWidth = this._explicitMinWidth;
		}
		if (this._explicitMinHeight != null) {
			minHeight = this._explicitMinHeight;
		}
		if (this._explicitMaxWidth != null) {
			maxWidth = this._explicitMaxWidth;
		} else if (maxWidth == null) {
			// since it's optional, this is our default
			maxWidth = Math.POSITIVE_INFINITY;
		}
		if (this._explicitMaxHeight != null) {
			maxHeight = this._explicitMaxHeight;
		} else if (maxHeight == null) {
			// since it's optional, this is our default
			maxHeight = Math.POSITIVE_INFINITY;
		}

		// next, we ensure that minimum and maximum measured dimensions are not
		// swapped because we'd prefer to avoid a situation where min > max
		// but don't change anything that's explicit, even if it doesn't meet
		// that preference.
		if (this._explicitMaxWidth == null && maxWidth < minWidth) {
			maxWidth = minWidth;
		}
		if (this._explicitMinWidth == null && minWidth > maxWidth) {
			minWidth = maxWidth;
		}
		if (this._explicitMaxHeight == null && maxHeight < minHeight) {
			maxHeight = minHeight;
		}
		if (this._explicitMinHeight == null && minHeight > maxHeight) {
			minHeight = maxHeight;
		}

		// now, proceed with the final width and height values, based on the
		// measurements passed in, and the adjustments to
		if (this._explicitWidth != null) {
			width = this._explicitWidth;
		} else {
			if (width < minWidth) {
				width = minWidth;
			} else if (width > maxWidth) {
				width = maxWidth;
			}
		}
		if (this._explicitHeight != null) {
			height = this._explicitHeight;
		} else {
			if (height < minHeight) {
				height = minHeight;
			} else if (height > maxHeight) {
				height = maxHeight;
			}
		}

		var scaleX = this.scaleX;
		if (scaleX < 0.0) {
			scaleX = -scaleX;
		}
		var scaleY = this.scaleY;
		if (scaleY < 0.0) {
			scaleY = -scaleY;
		}

		var resized = false;
		if (this.actualWidth != width) {
			this.actualWidth = width;
			resized = true;
		}
		if (this.actualHeight != height) {
			this.actualHeight = height;
			resized = true;
		}
		if (this.actualMinWidth != minWidth) {
			this.actualMinWidth = minWidth;
			resized = true;
		}
		if (this.actualMinHeight != minHeight) {
			this.actualMinHeight = minHeight;
			resized = true;
		}
		if (this.actualMaxWidth != maxWidth) {
			this.actualMaxWidth = maxWidth;
			resized = true;
		}
		if (this.actualMaxHeight != maxHeight) {
			this.actualMaxHeight = maxHeight;
			resized = true;
		}

		width = this.scaledActualWidth;
		height = this.scaledActualHeight;
		this.scaledActualWidth = this.actualWidth * scaleX;
		this.scaledActualHeight = this.actualHeight * scaleY;
		this.scaledActualMinWidth = this.actualMinWidth * scaleX;
		this.scaledActualMinHeight = this.actualMinHeight * scaleY;
		this.scaledActualMaxWidth = this.actualMaxWidth * scaleX;
		this.scaledActualMaxHeight = this.actualMaxHeight * scaleY;
		if (width != this.scaledActualWidth || height != this.scaledActualHeight) {
			resized = true;
			FeathersEvent.dispatch(this, Event.RESIZE);
		}
		return resized;
	}
}
