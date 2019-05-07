/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.events.Event;
import feathers.events.FeathersEvent;

/**
	A `openfl.display.Sprite` with extra minimum and maximum dimensions that may
	be used in Feathers layouts.

	@since 1.0.0
**/
class MeasureSprite extends ValidatingSprite implements IMeasureObject {
	private var actualWidth:Float = 0;
	private var actualHeight:Float = 0;
	private var actualMinWidth:Float = 0;
	private var actualMinHeight:Float = 0;
	private var actualMaxWidth:Float = Math.POSITIVE_INFINITY;
	private var actualMaxHeight:Float = Math.POSITIVE_INFINITY;
	private var scaledActualWidth:Float = 0;
	private var scaledActualHeight:Float = 0;
	private var scaledActualMinWidth:Float = 0;
	private var scaledActualMinHeight:Float = 0;
	private var scaledActualMaxWidth:Float = Math.POSITIVE_INFINITY;
	private var scaledActualMaxHeight:Float = Math.POSITIVE_INFINITY;

	override private function get_width():Float {
		return this.scaledActualWidth;
	}

	override private function set_width(value:Float):Float {
		if (this.scaleX != 1) {
			value /= this.scaleX;
		}
		this.explicitWidth = value;
		return this.scaledActualWidth;
	}

	override private function get_height():Float {
		return this.scaledActualHeight;
	}

	override private function set_height(value:Float):Float {
		if (this.scaleY != 1) {
			value /= this.scaleY;
		}
		this.explicitHeight = value;
		return this.scaledActualHeight;
	}

	override private function set_scaleX(value:Float):Float {
		super.scaleX = value;
		this.saveMeasurements(this.actualWidth, this.actualHeight, this.actualMinWidth, this.actualMinHeight, this.actualMaxWidth, this.actualMaxHeight);
		// no need to set invalid because the layout will be the same
		return this.scaleX;
	}

	override private function set_scaleY(value:Float):Float {
		super.scaleY = value;
		this.saveMeasurements(this.actualWidth, this.actualHeight, this.actualMinWidth, this.actualMinHeight, this.actualMaxWidth, this.actualMaxHeight);
		// no need to set invalid because the layout will be the same
		return this.scaleY;
	}

	public var explicitWidth(default, set):Null<Float> = null;

	private function set_explicitWidth(value:Null<Float>):Null<Float> {
		if (this.explicitWidth == value) {
			return this.explicitWidth;
		}
		this.explicitWidth = value;
		var result = this.saveMeasurements(value, this.actualHeight, this.actualMinWidth, this.actualMinHeight, this.actualMaxWidth, this.actualMaxHeight);
		if (result) {
			this.setInvalid(InvalidationFlag.SIZE);
		}
		return this.explicitWidth;
	}

	public var explicitHeight(default, set):Null<Float> = null;

	private function set_explicitHeight(value:Null<Float>):Null<Float> {
		if (this.explicitHeight == value) {
			return this.explicitHeight;
		}
		this.explicitHeight = value;
		var result = this.saveMeasurements(this.actualWidth, value, this.actualMinWidth, this.actualMinHeight, this.actualMaxWidth, this.actualMaxHeight);
		if (result) {
			this.setInvalid(InvalidationFlag.SIZE);
		}
		return this.explicitHeight;
	}

	public var explicitMinWidth(default, set):Null<Float> = null;

	private function set_explicitMinWidth(value:Null<Float>):Null<Float> {
		if (this.explicitMinWidth == value) {
			return this.explicitMinWidth;
		}
		var oldValue = this.explicitMinWidth;
		this.explicitMinWidth = value;
		if (value == null) {
			this.actualMinWidth = 0;
			this.scaledActualMinWidth = 0;
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

	public var explicitMinHeight(default, set):Null<Float> = null;

	private function set_explicitMinHeight(value:Null<Float>):Null<Float> {
		if (this.explicitMinHeight == value) {
			return this.explicitMinHeight;
		}
		var oldValue = this.explicitMinHeight;
		this.explicitMinHeight = value;
		if (value == null) {
			this.actualMinHeight = 0;
			this.scaledActualMinHeight = 0;
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

	public var minWidth(default, set):Float = 0;

	private function set_minWidth(value:Float):Float {
		if (this.scaleX != 1) {
			value /= this.scaleX;
		}
		this.explicitMinWidth = value;
		return this.scaledActualMinWidth;
	}

	public var minHeight(default, set):Float = 0;

	private function set_minHeight(value:Float):Float {
		if (this.scaleY != 1) {
			value /= this.scaleY;
		}
		this.explicitMinHeight = value;
		return this.scaledActualMinHeight;
	}

	public var explicitMaxWidth(default, null):Null<Float> = null;
	public var explicitMaxHeight(default, null):Null<Float> = null;
	public var maxWidth(default, set):Float = Math.POSITIVE_INFINITY;

	private function set_maxWidth(value:Float):Float {
		if (this.scaleX != 1) {
			value /= this.scaleX;
		}
		this.explicitMaxWidth = value;
		return this.scaledActualMaxWidth;
	}

	public var maxHeight(default, set):Float = Math.POSITIVE_INFINITY;

	private function set_maxHeight(value:Float):Float {
		if (this.scaleY != 1) {
			value /= this.scaleY;
		}
		this.explicitMaxHeight = value;
		return this.scaledActualMaxHeight;
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
		if (scaleX < 0) {
			scaleX = -scaleX;
		}
		var scaleY = this.scaleY;
		if (scaleY < 0) {
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
