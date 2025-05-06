/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.supportClasses.BaseSlider;
import feathers.core.IValidating;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

/**

	A vertical slider where you may select a value within a range by dragging
	a thumb along the y-axis of a track.

	The following example sets the slider's range and listens for when the value
	changes:

	```haxe
	var slider = new VSlider();
	slider.minimum = 0.0;
	slider.maximum = 100.0;
	slider.step = 1.0;
	slider.value = 12.0;
	slider.addEventListener(Event.CHANGE, slider_changeHandler);
	this.addChild(slider);
	```

	@see [Tutorial: How to use the HSlider and VSlider components](https://feathersui.com/learn/haxe-openfl/slider/)
	@see `feathers.controls.HSlider`

	@since 1.0.0
**/
@:styleContext
class VSlider extends BaseSlider {
	/**
		Creates a new `VSlider` object.

		@since 1.0.0
	**/
	public function new(value:Float = 0.0, minimum:Float = 0.0, maximum:Float = 1.0, ?changeListener:(Event) -> Void) {
		initializeVSliderTheme();

		super(value, minimum, maximum, changeListener);

		this.addEventListener(KeyboardEvent.KEY_DOWN, vSlider_keyDownHandler);
	}

	private function initializeVSliderTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelVSliderStyles.initialize();
		#end
	}

	override private function valueToLocation(value:Float):Float {
		// this will auto-size the thumb, if needed
		if ((this._currentThumbSkin is IValidating)) {
			(cast this._currentThumbSkin : IValidating).validateNow();
		}

		var normalized = this.normalizeValue(value);

		var trackScrollableHeight = this.actualHeight - this.minimumPadding - this.maximumPadding;
		if (this._currentThumbSkin != null) {
			trackScrollableHeight -= this._currentThumbSkin.height;
		}
		// maximum is at the top, so we need to start the y position of
		// the thumb from the maximum padding
		return Math.round(this.maximumPadding + trackScrollableHeight * (1.0 - normalized));
	}

	override private function locationToValue(x:Float, y:Float):Float {
		var percentage = 0.0;

		var trackScrollableHeight = this.actualHeight - this.minimumPadding - this.maximumPadding;
		if (this._currentThumbSkin != null) {
			trackScrollableHeight -= this._currentThumbSkin.height;
		}
		var yOffset = y - this._pointerStartY - this.maximumPadding;
		var yPosition = Math.min(Math.max(0.0, this._thumbStartY + yOffset), trackScrollableHeight);
		percentage = 1.0 - (yPosition / trackScrollableHeight);

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
				(cast this._currentThumbSkin : IValidating).validateNow();
			}
		}
		if (this._currentTrackSkin != null) {
			this._trackSkinMeasurements.restore(this._currentTrackSkin);
			if ((this._currentTrackSkin is IValidating)) {
				(cast this._currentTrackSkin : IValidating).validateNow();
			}
		}
		if (this._currentSecondaryTrackSkin != null) {
			this._secondaryTrackSkinMeasurements.restore(this._currentSecondaryTrackSkin);
			if ((this._currentSecondaryTrackSkin is IValidating)) {
				(cast this._currentSecondaryTrackSkin : IValidating).validateNow();
			}
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			newWidth = 0.0;
			if (this._currentThumbSkin != null) {
				newWidth += this._currentThumbSkin.width;
			}
			if (this._currentTrackSkin != null) {
				if (newWidth < this._currentTrackSkin.width) {
					newWidth = this._currentTrackSkin.width;
				}
				if (this._currentSecondaryTrackSkin != null && newWidth < this._currentSecondaryTrackSkin.width) {
					newWidth = this._currentSecondaryTrackSkin.width;
				}
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = 0.0;
			if (this._currentTrackSkin != null) {
				newHeight += this._currentTrackSkin.height;
				if (this._currentSecondaryTrackSkin != null) {
					newHeight += this._currentSecondaryTrackSkin.height;
				}
			}
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			newMinWidth = 0.0;
			if (this._currentThumbSkin != null) {
				newMinWidth += this._currentThumbSkin.width;
			}
			if (this._currentTrackSkin != null) {
				if (newMinWidth < this._currentTrackSkin.width) {
					newMinWidth = this._currentTrackSkin.width;
				}
				if (this._currentSecondaryTrackSkin != null && newMinWidth < this._currentSecondaryTrackSkin.width) {
					newMinWidth = this._currentSecondaryTrackSkin.width;
				}
			}
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			newMinHeight = 0.0;
			if (this._currentTrackSkin != null) {
				newMinHeight += this._currentTrackSkin.height;
				if (this._currentSecondaryTrackSkin != null) {
					newMinHeight += this._secondaryTrackSkinMeasurements.height;
				}
			}
		}

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}

	override private function saveThumbStart(x:Float, y:Float):Void {
		var trackHeightMinusThumbHeight = this.actualHeight;
		var locationMinusHalfThumbHeight = y;
		if (this._currentThumbSkin != null) {
			trackHeightMinusThumbHeight -= this._currentThumbSkin.height;
			locationMinusHalfThumbHeight -= this._currentThumbSkin.height / 2.0;
		}
		this._thumbStartX = x;
		this._thumbStartY = Math.min(trackHeightMinusThumbHeight - this.maximumPadding, Math.max(this.minimumPadding, locationMinusHalfThumbHeight));
	}

	override private function layoutSplitTrack():Void {
		var location = this.valueToLocation(value);
		if (this._currentThumbSkin != null) {
			if ((this._currentThumbSkin is IValidating)) {
				(cast this._currentThumbSkin : IValidating).validateNow();
			}
			location += Math.round(this._currentThumbSkin.height / 2.0);
		}

		this._currentSecondaryTrackSkin.y = 0.0;
		this._currentSecondaryTrackSkin.height = location;

		this._currentTrackSkin.y = location;
		this._currentTrackSkin.height = this.actualHeight - location;

		if ((this._currentSecondaryTrackSkin is IValidating)) {
			(cast this._currentSecondaryTrackSkin : IValidating).validateNow();
		}
		if ((this._currentTrackSkin is IValidating)) {
			(cast this._currentTrackSkin : IValidating).validateNow();
		}

		this._currentSecondaryTrackSkin.x = (this.actualWidth - this._currentSecondaryTrackSkin.width) / 2.0;
		this._currentTrackSkin.x = (this.actualWidth - this._currentTrackSkin.width) / 2.0;
	}

	override private function layoutSingleTrack():Void {
		if (this._currentTrackSkin == null) {
			return;
		}

		this._currentTrackSkin.y = 0.0;
		this._currentTrackSkin.height = this.actualHeight;

		if ((this._currentTrackSkin is IValidating)) {
			(cast this._currentTrackSkin : IValidating).validateNow();
		}

		this._currentTrackSkin.x = (this.actualWidth - this._currentTrackSkin.width) / 2.0;
	}

	override private function layoutThumb():Void {
		if (this._currentThumbSkin == null) {
			return;
		}
		var thumbLocation = this.valueToLocation(this._value);
		this._currentThumbSkin.x = this.thumbOffsetX + (this.actualWidth - this._currentThumbSkin.width) / 2.0;
		this._currentThumbSkin.y = this.thumbOffsetY + thumbLocation;
	}

	private function vSlider_keyDownHandler(event:KeyboardEvent):Void {
		if (event.isDefaultPrevented()) {
			return;
		}
		if (!this._enabled) {
			return;
		}
		var newValue = this._value;
		switch (event.keyCode) {
			case Keyboard.DOWN:
				newValue -= this._step;
			case Keyboard.UP:
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
