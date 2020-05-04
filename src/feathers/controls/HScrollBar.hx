/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.geom.Point;
import feathers.core.IValidating;
import feathers.controls.supportClasses.BaseScrollBar;
import feathers.themes.steel.components.SteelHScrollBarStyles;

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
		if (Std.is(this.thumbSkin, IValidating)) {
			cast(this.thumbSkin, IValidating).validateNow();
		}
		var normalized = this.normalizeValue();
		var trackScrollableWidth = this.actualWidth - this.paddingLeft - this.paddingRight - this.thumbSkin.width;
		return this.paddingLeft + (trackScrollableWidth * normalized);
	}

	override private function locationToValue(x:Float, y:Float):Float {
		var percentage = 0.0;
		var trackScrollableWidth = this.actualWidth - this.paddingLeft - this.paddingRight - this.thumbSkin.width;
		var xOffset = x - this._pointerStartX;
		var xPosition = Math.min(Math.max(0.0, this._thumbStartX + xOffset), trackScrollableWidth);
		percentage = xPosition / trackScrollableWidth;
		return this.minimum + percentage * (this.maximum - this.minimum);
	}

	override private function saveThumbStart(location:Point):Void {
		var trackWidthMinusThumbWidth = this.actualWidth;
		var locationMinusHalfThumbWidth = location.x;
		if (this.thumbSkin != null) {
			trackWidthMinusThumbWidth -= this.thumbSkin.width;
			locationMinusHalfThumbWidth -= this.thumbSkin.width / 2.0;
		}
		this._thumbStartX = Math.min(trackWidthMinusThumbWidth, locationMinusHalfThumbWidth);
		this._thumbStartY = location.y;
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

		this._thumbSkinMeasurements.restore(this.thumbSkin);
		if (Std.is(this.thumbSkin, IValidating)) {
			cast(this.thumbSkin, IValidating).validateNow();
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
			newWidth = 0.0;
			if (this.trackSkin != null) {
				newWidth += this.trackSkin.width;
				if (this.secondaryTrackSkin != null) {
					newWidth += this.secondaryTrackSkin.width;
				}
			}
			var thumbWidth = this.thumbSkin.width + this.paddingLeft + this.paddingRight;
			if (newWidth < thumbWidth) {
				newWidth = thumbWidth;
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = this.thumbSkin.height + this.paddingTop + this.paddingBottom;
			if (this.trackSkin != null) {
				if (newHeight < this.trackSkin.height) {
					newHeight = this.trackSkin.height;
				}
				if (this.secondaryTrackSkin != null && newHeight < this.secondaryTrackSkin.height) {
					newHeight = this.secondaryTrackSkin.height;
				}
			}
		}

		// TODO: calculate min and max
		var newMinWidth = newWidth;
		var newMinHeight = newHeight;
		var newMaxHeight = newHeight;

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, Math.POSITIVE_INFINITY, newMaxHeight);
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

		var range = this.maximum - this.minimum;
		this.thumbSkin.visible = range > 0.0;
		if (!this.thumbSkin.visible) {
			return;
		}

		if (Std.is(this.thumbSkin, IValidating)) {
			cast(this.thumbSkin, IValidating).validateNow();
		}

		var valueOffset = 0.0;
		if (this.value < this.minimum) {
			valueOffset = this.minimum - this.value;
		} else if (this.value > this.maximum) {
			valueOffset = this.value - this.maximum;
		}

		var contentWidth = this.actualWidth - this.paddingLeft - this.paddingRight;
		var contentHeight = this.actualHeight - this.paddingTop - this.paddingBottom;

		if (this.fixedThumbSize) {
			this.thumbSkin.width = this._thumbSkinMeasurements.width;
		} else {
			var thumbWidth = contentWidth * this.getAdjustedPage() / range;
			if (thumbWidth > 0.0) {
				var widthOffset = contentWidth - thumbWidth;
				if (widthOffset > thumbWidth) {
					widthOffset = thumbWidth;
				}
				widthOffset *= valueOffset / (range * thumbWidth / contentWidth);
				thumbWidth -= widthOffset;
			}
			if (this._thumbSkinMeasurements.minWidth != null && thumbWidth < this._thumbSkinMeasurements.minWidth) {
				thumbWidth = this._thumbSkinMeasurements.minWidth;
			}
			if (thumbWidth < 0.0) {
				thumbWidth = 0.0;
			}
			this.thumbSkin.width = thumbWidth;
		}
		this.thumbSkin.x = this.valueToLocation(this.value);
		this.thumbSkin.y = this.paddingTop + (contentHeight - this.thumbSkin.height) / 2.0;
	}
}
