/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

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
		if (Std.is(this.thumbSkin, IValidating)) {
			cast(this.thumbSkin, IValidating).validateNow();
		}

		var normalized = this.normalizeValue();

		var trackScrollableWidth = this.actualWidth - this.minimumPadding - this.maximumPadding;
		if (this.thumbSkin != null) {
			trackScrollableWidth -= this.thumbSkin.width;
		}
		// minimum is at the left, so we need to start the x position of
		// the thumb from the minimum padding
		return Math.round(this.minimumPadding + (trackScrollableWidth * normalized));
	}

	override private function locationToValue(x:Float, y:Float):Float {
		var percentage = 0.0;
		var trackScrollableWidth = this.actualWidth - this.minimumPadding - this.maximumPadding;
		if (this.thumbSkin != null) {
			trackScrollableWidth -= this.thumbSkin.width;
		}
		var xOffset = x - this._pointerStartX - this.minimumPadding;
		var xPosition = Math.min(Math.max(0.0, this._thumbStartX + xOffset), trackScrollableWidth);
		percentage = xPosition / trackScrollableWidth;
		return this.minimum + percentage * (this.maximum - this.minimum);
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

		if (this.thumbSkin != null) {
			this._thumbSkinMeasurements.restore(this.thumbSkin);
			if (Std.is(this.thumbSkin, IValidating)) {
				cast(this.thumbSkin, IValidating).validateNow();
			}
		}
		if (this.trackSkin != null) {
			this._trackSkinMeasurements.restore(this.trackSkin);
			if (Std.is(this.trackSkin, IValidating)) {
				cast(this.trackSkin, IValidating).validateNow();
			}
		}
		if (this.secondaryTrackSkin != null) {
			this._secondaryTrackSkinMeasurements.restore(this.secondaryTrackSkin);
			if (Std.is(this.secondaryTrackSkin, IValidating)) {
				cast(this.secondaryTrackSkin, IValidating).validateNow();
			}
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			newWidth = this.trackSkin.width;
			if (this.secondaryTrackSkin != null) {
				newWidth += this.secondaryTrackSkin.width;
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = this.thumbSkin.height;
			if (newHeight < this.trackSkin.height) {
				newHeight = this.trackSkin.height;
			}
			if (this.secondaryTrackSkin != null && newHeight < this.secondaryTrackSkin.height) {
				newHeight = this.secondaryTrackSkin.height;
			}
		}

		// TODO: calculate min and max
		var newMinWidth = newWidth;
		var newMinHeight = newHeight;
		var newMaxWidth = newWidth;
		var newMaxHeight = newHeight;

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	override private function saveThumbStart(location:Point):Void {
		var trackWidthMinusThumbWidth = this.actualWidth;
		var locationMinusHalfThumbWidth = location.x;
		if (this.thumbSkin != null) {
			trackWidthMinusThumbWidth -= this.thumbSkin.width;
			locationMinusHalfThumbWidth -= this.thumbSkin.width / 2.0;
		}
		this._thumbStartX = Math.min(trackWidthMinusThumbWidth - this.maximumPadding, Math.max(this.minimumPadding, locationMinusHalfThumbWidth));
		this._thumbStartY = location.y;
	}

	override private function layoutSplitTrack():Void {
		var location = this.valueToLocation(value);
		if (this.thumbSkin != null) {
			if (Std.is(this.thumbSkin, IValidating)) {
				cast(this.thumbSkin, IValidating).validateNow();
			}
			location += Math.round(this.thumbSkin.width / 2.0);
		}

		this.trackSkin.x = 0.0;
		this.trackSkin.width = location;

		this.secondaryTrackSkin.x = location;
		this.secondaryTrackSkin.width = this.actualWidth - location;

		if (Std.is(this.trackSkin, IValidating)) {
			cast(this.trackSkin, IValidating).validateNow();
		}
		if (Std.is(this.secondaryTrackSkin, IValidating)) {
			cast(this.secondaryTrackSkin, IValidating).validateNow();
		}

		this.trackSkin.y = (this.actualHeight - this.trackSkin.height) / 2.0;
		this.secondaryTrackSkin.y = (this.actualHeight - this.secondaryTrackSkin.height) / 2.0;
	}

	override private function layoutSingleTrack():Void {
		if (this.trackSkin == null) {
			return;
		}
		this.trackSkin.x = 0.0;
		this.trackSkin.width = this.actualWidth;

		if (Std.is(this.trackSkin, IValidating)) {
			cast(this.trackSkin, IValidating).validateNow();
		}

		this.trackSkin.y = (this.actualHeight - this.trackSkin.height) / 2.0;
	}

	override private function layoutThumb():Void {
		if (this.thumbSkin == null) {
			return;
		}
		var thumbLocation = this.valueToLocation(this.value);
		this.thumbSkin.x = thumbLocation;
		this.thumbSkin.y = Math.round((this.actualHeight - this.thumbSkin.height) / 2.0);
	}

	private function hSlider_keyDownHandler(event:KeyboardEvent):Void {
		var newValue = this.value;
		switch (event.keyCode) {
			case Keyboard.LEFT:
				newValue -= this.step;
			case Keyboard.RIGHT:
				newValue += this.step;
			case Keyboard.HOME:
				newValue = this.minimum;
			case Keyboard.END:
				newValue = this.maximum;
			default:
				return;
		}
		event.stopPropagation();
		this.value = newValue;
	}
}
