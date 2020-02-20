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

	/**
		@see `feathers.core.IMeasureObject.explicitWidth`
	**/
	@:isVar
	public var explicitWidth(get, set):Null<Float> = null;

	private function get_explicitWidth():Null<Float> {
		return this.explicitWidth;
	}

	private function set_explicitWidth(value:Null<Float>):Null<Float> {
		if (this.explicitWidth == value) {
			return this.explicitWidth;
		}
		this.explicitWidth = value;
		if (value == null) {
			if (this.actualWidth != 0.0) {
				this.actualWidth = 0.0;
				this.scaledActualWidth = 0.0;
				this.setInvalid(InvalidationFlag.SIZE);
			}
		} else {
			var result = this.saveMeasurements(value, this.actualHeight, this.actualMinWidth, this.actualMinHeight, this.actualMaxWidth, this.actualMaxHeight);
			if (result) {
				this.setInvalid(InvalidationFlag.SIZE);
			}
		}
		return this.explicitWidth;
	}

	/**
		@see `feathers.core.IMeasureObject.explicitHeight`
	**/
	@:isVar
	public var explicitHeight(get, set):Null<Float> = null;

	private function get_explicitHeight():Null<Float> {
		return this.explicitHeight;
	}

	private function set_explicitHeight(value:Null<Float>):Null<Float> {
		if (this.explicitHeight == value) {
			return this.explicitHeight;
		}
		this.explicitHeight = value;
		if (value == null) {
			if (this.actualHeight != 0.0) {
				this.actualHeight = 0.0;
				this.scaledActualHeight = 0.0;
				this.setInvalid(InvalidationFlag.SIZE);
			}
		} else {
			var result = this.saveMeasurements(this.actualWidth, value, this.actualMinWidth, this.actualMinHeight, this.actualMaxWidth, this.actualMaxHeight);
			if (result) {
				this.setInvalid(InvalidationFlag.SIZE);
			}
		}
		return this.explicitHeight;
	}

	/**
		@see `feathers.core.IMeasureObject.explicitMinWidth`
	**/
	@:isVar
	public var explicitMinWidth(get, set):Null<Float> = null;

	private function get_explicitMinWidth():Null<Float> {
		return this.explicitMinWidth;
	}

	private function set_explicitMinWidth(value:Null<Float>):Null<Float> {
		if (this.explicitMinWidth == value) {
			return this.explicitMinWidth;
		}
		var oldValue = this.explicitMinWidth;
		this.explicitMinWidth = value;
		if (value == null) {
			this.actualMinWidth = 0.0;
			this.scaledActualMinWidth = 0.0;
			this.setInvalid(InvalidationFlag.SIZE);
		} else {
			// saveMeasurements() might change actualWidth, so keep the old
			// value for the comparisons below
			var actualWidth = this.actualWidth;
			this.saveMeasurements(this.actualWidth, this.actualHeight, value, this.actualMinHeight, this.actualMaxWidth, this.actualMaxHeight);
			if (this.explicitWidth == null && (actualWidth < value || actualWidth == oldValue)) {
				// only invalidate if this change might affect the width
				// because everything else was handled in saveMeasurements()
				this.setInvalid(InvalidationFlag.SIZE);
			}
		}
		return this.explicitMinWidth;
	}

	/**
		@see `feathers.core.IMeasureObject.explicitMinHeight`
	**/
	@:isVar
	public var explicitMinHeight(get, set):Null<Float> = null;

	private function get_explicitMinHeight():Null<Float> {
		return this.explicitMinHeight;
	}

	private function set_explicitMinHeight(value:Null<Float>):Null<Float> {
		if (this.explicitMinHeight == value) {
			return this.explicitMinHeight;
		}
		var oldValue = this.explicitMinHeight;
		this.explicitMinHeight = value;
		if (value == null) {
			this.actualMinHeight = 0.0;
			this.scaledActualMinHeight = 0.0;
			this.setInvalid(InvalidationFlag.SIZE);
		} else {
			// saveMeasurements() might change actualHeight, so keep the old
			// value for the comparisons below
			var actualHeight = this.actualHeight;
			this.saveMeasurements(this.actualWidth, this.actualHeight, this.actualMinWidth, value, this.actualMaxWidth, this.actualMaxHeight);
			if (this.explicitHeight == null && (actualHeight < value || actualHeight == oldValue)) {
				// only invalidate if this change might affect the width
				// because everything else was handled in saveMeasurements()
				this.setInvalid(InvalidationFlag.SIZE);
			}
		}
		return this.explicitMinHeight;
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
		this.explicitMinHeight = value;
		return this.scaledActualMinHeight;
	}

	/**
		@see `feathers.core.IMeasureObject.explicitMaxWidth`
	**/
	@:isVar
	public var explicitMaxWidth(get, set):Null<Float> = null;

	private function get_explicitMaxWidth():Null<Float> {
		return this.explicitMaxWidth;
	}

	private function set_explicitMaxWidth(value:Null<Float>):Null<Float> {
		if (this.explicitMaxWidth == value) {
			return this.explicitMaxWidth;
		}
		var oldValue = this.explicitMaxWidth;
		this.explicitMaxWidth = value;
		if (value == null) {
			this.actualMaxWidth = Math.POSITIVE_INFINITY;
			this.scaledActualMaxWidth = Math.POSITIVE_INFINITY;
			this.setInvalid(InvalidationFlag.SIZE);
		} else {
			// saveMeasurements() might change actualWidth, so keep the old
			// value for the comparisons below
			var actualWidth = this.actualWidth;
			this.saveMeasurements(this.actualWidth, this.actualHeight, this.actualMinWidth, this.actualMinHeight, value, this.actualMaxHeight);
			if (this.explicitWidth == null && (actualWidth > value || actualWidth == oldValue)) {
				// only invalidate if this change might affect the width
				// because everything else was handled in saveMeasurements()
				this.setInvalid(InvalidationFlag.SIZE);
			}
		}
		return this.explicitMaxWidth;
	}

	/**
		@see `feathers.core.IMeasureObject.explicitMaxHeight`
	**/
	@:isVar
	public var explicitMaxHeight(get, set):Null<Float> = null;

	private function get_explicitMaxHeight():Null<Float> {
		return this.explicitMaxHeight;
	}

	private function set_explicitMaxHeight(value:Null<Float>):Null<Float> {
		if (this.explicitMaxHeight == value) {
			return this.explicitMaxHeight;
		}
		var oldValue = this.explicitMaxHeight;
		this.explicitMaxHeight = value;
		if (value == null) {
			this.actualMaxHeight = Math.POSITIVE_INFINITY;
			this.scaledActualMaxHeight = Math.POSITIVE_INFINITY;
			this.setInvalid(InvalidationFlag.SIZE);
		} else {
			// saveMeasurements() might change actualWidth, so keep the old
			// value for the comparisons below
			var actualHeight = this.actualHeight;
			this.saveMeasurements(this.actualWidth, this.actualHeight, this.actualMinWidth, this.actualMinHeight, this.actualMaxWidth, value);
			if (this.explicitHeight == null && (actualHeight > value || actualHeight == oldValue)) {
				// only invalidate if this change might affect the width
				// because everything else was handled in saveMeasurements()
				this.setInvalid(InvalidationFlag.SIZE);
			}
		}
		return this.explicitMaxHeight;
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
		this.explicitMaxHeight = value;
		return this.scaledActualMaxHeight;
	}

	/**
		@see `feathers.core.IMeasureObject.resetWidth`
	**/
	public function resetWidth():Void {
		this.explicitWidth = null;
	}

	/**
		@see `feathers.core.IMeasureObject.resetHeight`
	**/
	public function resetHeight():Void {
		this.explicitHeight = null;
	}

	/**
		@see `feathers.core.IMeasureObject.resetMinWidth`
	**/
	public function resetMinWidth():Void {
		this.explicitMinWidth = null;
	}

	/**
		@see `feathers.core.IMeasureObject.resetMinHeight`
	**/
	public function resetMinHeight():Void {
		this.explicitMinHeight = null;
	}

	/**
		@see `feathers.core.IMeasureObject.resetMaxWidth`
	**/
	public function resetMaxWidth():Void {
		this.explicitMaxWidth = null;
	}

	/**
		@see `feathers.core.IMeasureObject.resetMaxHeight`
	**/
	public function resetMaxHeight():Void {
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
		if (this.explicitMinWidth != null) {
			minWidth = this.explicitMinWidth;
		}
		if (this.explicitMinHeight != null) {
			minHeight = this.explicitMinHeight;
		}
		if (this.explicitMaxWidth != null) {
			maxWidth = this.explicitMaxWidth;
		} else if (maxWidth == null) {
			// since it's optional, this is our default
			maxWidth = Math.POSITIVE_INFINITY;
		}
		if (this.explicitMaxHeight != null) {
			maxHeight = this.explicitMaxHeight;
		} else if (maxHeight == null) {
			// since it's optional, this is our default
			maxHeight = Math.POSITIVE_INFINITY;
		}

		// next, we ensure that minimum and maximum measured dimensions are not
		// swapped because we'd prefer to avoid a situation where min > max
		// but don't change anything that's explicit, even if it doesn't meet
		// that preference.
		if (this.explicitMaxWidth == null && maxWidth < minWidth) {
			maxWidth = minWidth;
		}
		if (this.explicitMinWidth == null && minWidth > maxWidth) {
			minWidth = maxWidth;
		}
		if (this.explicitMaxHeight == null && maxHeight < minHeight) {
			maxHeight = minHeight;
		}
		if (this.explicitMinHeight == null && minHeight > maxHeight) {
			minHeight = maxHeight;
		}

		// now, proceed with the final width and height values, based on the
		// measurements passed in, and the adjustments to
		if (this.explicitWidth != null) {
			width = this.explicitWidth;
		} else {
			if (width < minWidth) {
				width = minWidth;
			} else if (width > maxWidth) {
				width = maxWidth;
			}
		}
		if (this.explicitHeight != null) {
			height = this.explicitHeight;
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
