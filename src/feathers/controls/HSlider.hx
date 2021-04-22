/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.supportClasses.BaseSlider;
import feathers.core.IValidating;
import feathers.themes.steel.components.SteelHSliderStyles;
import openfl.events.KeyboardEvent;
import openfl.geom.Point;
import openfl.ui.Keyboard;

/**

	A horizontal slider where you may select a value within a range by dragging
	a thumb along the x-axis of a track.

	The following example sets the slider's range and listens for when the value
	changes:

	```hx
	var slider = new HSlider();
	slider.minimum = 0.0;
	slider.maximum = 100.0;
	slider.step = 1.0;
	slider.value = 12.0;
	slider.addEventListener(Event.CHANGE, slider_changeHandler);
	this.addChild(slider);
	```

	@see [Tutorial: How to use the HSlider and VSlider components](https://feathersui.com/learn/haxe-openfl/slider/)
	@see `feathers.controls.VSlider`

	@since 1.0.0
**/
@:styleContext
class HSlider extends BaseSlider {
	/**
		Creates a new `HSlider` object.

		@since 1.0.0
	**/
	public function new() {
		initializeHSliderTheme();

		super();

		this.addEventListener(KeyboardEvent.KEY_DOWN, hSlider_keyDownHandler);
	}

	private function initializeHSliderTheme():Void {
		SteelHSliderStyles.initialize();
	}

	override private function valueToLocation(value:Float):Float {
		// this will auto-size the thumb, if needed
		if ((this._currentThumbSkin is IValidating)) {
			cast(this._currentThumbSkin, IValidating).validateNow();
		}

		var normalized = this.normalizeValue(value);

		var trackScrollableWidth = this.actualWidth - this.minimumPadding - this.maximumPadding;
		if (this._currentThumbSkin != null) {
			trackScrollableWidth -= this._currentThumbSkin.width;
		}
		// minimum is at the left, so we need to start the x position of
		// the thumb from the minimum padding
		return Math.round(this.minimumPadding + (trackScrollableWidth * normalized));
	}

	override private function locationToValue(x:Float, y:Float):Float {
		var percentage = 0.0;
		var trackScrollableWidth = this.actualWidth - this.minimumPadding - this.maximumPadding;
		if (this._currentThumbSkin != null) {
			trackScrollableWidth -= this._currentThumbSkin.width;
		}
		var xOffset = x - this._pointerStartX - this.minimumPadding;
		var xPosition = Math.min(Math.max(0.0, this._thumbStartX + xOffset), trackScrollableWidth);
		percentage = xPosition / trackScrollableWidth;
		return this._minimum + percentage * (this._maximum - this._minimum);
	}

	override private function measure():Bool {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight && !needsMaxWidth && !needsMaxHeight) {
			return false;
		}

		if (this._currentThumbSkin != null) {
			this._thumbSkinMeasurements.restore(this._currentThumbSkin);
			if ((this._currentThumbSkin is IValidating)) {
				cast(this._currentThumbSkin, IValidating).validateNow();
			}
		}
		if (this._currentTrackSkin != null) {
			this._trackSkinMeasurements.restore(this._currentTrackSkin);
			if ((this._currentTrackSkin is IValidating)) {
				cast(this._currentTrackSkin, IValidating).validateNow();
			}
		}
		if (this._currentSecondaryTrackSkin != null) {
			this._secondaryTrackSkinMeasurements.restore(this._currentSecondaryTrackSkin);
			if ((this._currentSecondaryTrackSkin is IValidating)) {
				cast(this._currentSecondaryTrackSkin, IValidating).validateNow();
			}
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			newWidth = this._currentTrackSkin.width;
			if (this._currentSecondaryTrackSkin != null) {
				newWidth += this._currentSecondaryTrackSkin.width;
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = this._currentThumbSkin.height;
			if (newHeight < this._currentTrackSkin.height) {
				newHeight = this._currentTrackSkin.height;
			}
			if (this._currentSecondaryTrackSkin != null && newHeight < this._currentSecondaryTrackSkin.height) {
				newHeight = this._currentSecondaryTrackSkin.height;
			}
		}

		// TODO: calculate min and max
		var newMinWidth = newWidth;
		var newMinHeight = newHeight;
		var newMaxWidth = newWidth;
		var newMaxHeight = newHeight;

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	override private function saveThumbStart(x:Float, y:Float):Void {
		var trackWidthMinusThumbWidth = this.actualWidth;
		var locationMinusHalfThumbWidth = x;
		if (this._currentThumbSkin != null) {
			trackWidthMinusThumbWidth -= this._currentThumbSkin.width;
			locationMinusHalfThumbWidth -= this._currentThumbSkin.width / 2.0;
		}
		this._thumbStartX = Math.min(trackWidthMinusThumbWidth - this.maximumPadding, Math.max(this.minimumPadding, locationMinusHalfThumbWidth));
		this._thumbStartY = y;
	}

	override private function layoutSplitTrack():Void {
		var location = this.valueToLocation(value);
		if (this._currentThumbSkin != null) {
			if ((this._currentThumbSkin is IValidating)) {
				cast(this._currentThumbSkin, IValidating).validateNow();
			}
			location += Math.round(this._currentThumbSkin.width / 2.0);
		}

		this._currentTrackSkin.x = 0.0;
		this._currentTrackSkin.width = location;

		this._currentSecondaryTrackSkin.x = location;
		this._currentSecondaryTrackSkin.width = this.actualWidth - location;

		if ((this._currentTrackSkin is IValidating)) {
			cast(this._currentTrackSkin, IValidating).validateNow();
		}
		if ((this._currentSecondaryTrackSkin is IValidating)) {
			cast(this._currentSecondaryTrackSkin, IValidating).validateNow();
		}

		this._currentTrackSkin.y = (this.actualHeight - this._currentTrackSkin.height) / 2.0;
		this._currentSecondaryTrackSkin.y = (this.actualHeight - this._currentSecondaryTrackSkin.height) / 2.0;
	}

	override private function layoutSingleTrack():Void {
		if (this._currentTrackSkin == null) {
			return;
		}
		this._currentTrackSkin.x = 0.0;
		this._currentTrackSkin.width = this.actualWidth;

		if ((this._currentTrackSkin is IValidating)) {
			cast(this._currentTrackSkin, IValidating).validateNow();
		}

		this._currentTrackSkin.y = (this.actualHeight - this._currentTrackSkin.height) / 2.0;
	}

	override private function layoutThumb():Void {
		if (this._currentThumbSkin == null) {
			return;
		}
		var thumbLocation = this.valueToLocation(this._value);
		this._currentThumbSkin.x = thumbLocation;
		this._currentThumbSkin.y = (this.actualHeight - this.thumbSkin.height) / 2.0;
	}

	private function hSlider_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (event.isDefaultPrevented()) {
			return;
		}
		var newValue = this._value;
		switch (event.keyCode) {
			case Keyboard.LEFT:
				newValue -= this._step;
			case Keyboard.RIGHT:
				newValue += this._step;
			case Keyboard.HOME:
				newValue = this._minimum;
			case Keyboard.END:
				newValue = this._maximum;
			default:
				return;
		}
		if (newValue < this._minimum) {
			newValue = this._minimum;
		} else if (newValue > this._maximum) {
			newValue = this._maximum;
		}
		event.preventDefault();
		// use the setter
		this.value = newValue;
	}
}
