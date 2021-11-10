/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.supportClasses.BaseScrollBar;
import feathers.core.IMeasureObject;
import feathers.core.IValidating;
import feathers.themes.steel.components.SteelHScrollBarStyles;
import openfl.geom.Point;

/**
	A horizontal scroll bar, for use with scrolling containers like
	`ScrollContainer` and `ListView`.

	@see [Tutorial: How to use the HScrollBar and VScrollBar components](https://feathersui.com/learn/haxe-openfl/scroll-bar/)
	@see `feathers.controls.VScrollBar`

	@since 1.0.0
**/
@:styleContext
class HScrollBar extends BaseScrollBar {
	/**
		Creates a new `HScrollBar` object.

		@since 1.0.0
	**/
	public function new() {
		this.initializeHScrollBarTheme();

		super();
	}

	private function initializeHScrollBarTheme():Void {
		SteelHScrollBarStyles.initialize();
	}

	override private function valueToLocation(value:Float):Float {
		// this will auto-size the thumb, if needed
		if ((this._currentThumbSkin is IValidating)) {
			cast(this._currentThumbSkin, IValidating).validateNow();
		}
		var normalized = this.normalizeValue(value);
		var trackScrollableWidth = this.actualWidth - this.paddingLeft - this.paddingRight - this._currentThumbSkin.width;
		return this.paddingLeft + (trackScrollableWidth * normalized);
	}

	override private function locationToValue(x:Float, y:Float):Float {
		var percentage = 0.0;
		var trackScrollableWidth = this.actualWidth - this.paddingLeft - this.paddingRight - this._currentThumbSkin.width;
		var xOffset = x - this._pointerStartX;
		var xPosition = Math.min(Math.max(0.0, this._thumbStartX + xOffset), trackScrollableWidth);
		percentage = xPosition / trackScrollableWidth;
		return this._minimum + percentage * (this._maximum - this._minimum);
	}

	override private function saveThumbStart(x:Float, y:Float):Void {
		var trackWidthMinusThumbWidth = this.actualWidth;
		var locationMinusHalfThumbWidth = x;
		if (this._currentThumbSkin != null) {
			trackWidthMinusThumbWidth -= this._currentThumbSkin.width;
			locationMinusHalfThumbWidth -= this._currentThumbSkin.width / 2.0;
		}
		this._thumbStartX = Math.min(trackWidthMinusThumbWidth, locationMinusHalfThumbWidth);
		this._thumbStartY = y;
	}

	override function measure():Bool {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight && !needsMaxWidth && !needsMaxHeight) {
			return false;
		}

		this._thumbSkinMeasurements.restore(this._currentThumbSkin);
		if ((this._currentThumbSkin is IValidating)) {
			cast(this._currentThumbSkin, IValidating).validateNow();
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
			newWidth = 0.0;
			if (this._currentTrackSkin != null) {
				newWidth += this._currentTrackSkin.width;
				if (this._currentSecondaryTrackSkin != null) {
					newWidth += this._currentSecondaryTrackSkin.width;
				}
			}
			var thumbWidth = this._currentThumbSkin.width + this.paddingLeft + this.paddingRight;
			if (newWidth < thumbWidth) {
				newWidth = thumbWidth;
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = this._currentThumbSkin.height + this.paddingTop + this.paddingBottom;
			if (this._currentTrackSkin != null) {
				if (newHeight < this._currentTrackSkin.height) {
					newHeight = this._currentTrackSkin.height;
				}
				if (this._currentSecondaryTrackSkin != null && newHeight < this._currentSecondaryTrackSkin.height) {
					newHeight = this._currentSecondaryTrackSkin.height;
				}
			}
		}

		// TODO: calculate min and max
		var newMinWidth = newWidth;
		var newMinHeight = newHeight;
		var newMaxHeight = newHeight;

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, null, newMaxHeight);
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

		var range = this._maximum - this._minimum;
		this._currentThumbSkin.visible = (!this.hideThumbWhenDisabled || this._enabled) && range > 0.0;
		if (!this._currentThumbSkin.visible) {
			return;
		}

		if ((this._currentThumbSkin is IValidating)) {
			cast(this._currentThumbSkin, IValidating).validateNow();
		}

		var valueOffset = 0.0;
		if (this._value < this._minimum) {
			valueOffset = this._minimum - this._value;
		} else if (this._value > this._maximum) {
			valueOffset = this._value - this._maximum;
		}

		var contentWidth = this.actualWidth - this.paddingLeft - this.paddingRight;
		var contentHeight = this.actualHeight - this.paddingTop - this.paddingBottom;

		if (this.fixedThumbSize) {
			if (this._thumbSkinMeasurements.width != null) {
				this._currentThumbSkin.width = this._thumbSkinMeasurements.width;
			}
		} else {
			var adjustedPage = this.getAdjustedPage();
			var thumbWidth = contentWidth * adjustedPage / (range + adjustedPage);
			if (thumbWidth > 0.0) {
				var widthOffset = contentWidth - thumbWidth;
				if (widthOffset > thumbWidth) {
					widthOffset = thumbWidth;
				}
				widthOffset *= valueOffset / (range * thumbWidth / contentWidth);
				thumbWidth -= widthOffset;
			}
			if (this._thumbSkinMeasurements.minWidth != null) {
				if (thumbWidth < this._thumbSkinMeasurements.minWidth) {
					thumbWidth = this._thumbSkinMeasurements.minWidth;
				}
			} else if ((this._currentThumbSkin is IMeasureObject)) {
				var measureSkin = cast(this._currentThumbSkin, IMeasureObject);
				if (thumbWidth < measureSkin.minWidth) {
					thumbWidth = measureSkin.minWidth;
				}
			}
			if (thumbWidth < 0.0) {
				thumbWidth = 0.0;
			}
			this._currentThumbSkin.width = thumbWidth;
		}
		this._currentThumbSkin.x = this.valueToLocation(this._value);
		this._currentThumbSkin.y = this.paddingTop + (contentHeight - this._currentThumbSkin.height) / 2.0;
	}
}
