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
import feathers.themes.steel.components.SteelVScrollBarStyles;

/**
	A vertical scroll bar, for use with scrolling containers like
	`ScrollContainer` and `ListView`.

	@see [Tutorial: How to use the HScrollBar and VScrollBar components](https://feathersui.com/learn/haxe-openfl/scroll-bar/)
	@see `feathers.controls.HScrollBar`

	@since 1.0.0
**/
@:styleContext
class VScrollBar extends BaseScrollBar {
	/**
		Creates a new `VScrollBar` object.

		@since 1.0.0
	**/
	public function new() {
		this.initializeVScrollBarTheme();

		super();
	}

	private function initializeVScrollBarTheme():Void {
		SteelVScrollBarStyles.initialize();
	}

	override private function valueToLocation(value:Float):Float {
		// this will auto-size the thumb, if needed
		if (Std.is(this.thumbSkin, IValidating)) {
			cast(this.thumbSkin, IValidating).validateNow();
		}
		var normalized = this.normalizeValue();
		var trackScrollableHeight = this.actualHeight - this.paddingTop - this.paddingBottom - this.thumbSkin.height;
		return this.paddingTop + (trackScrollableHeight * normalized);
	}

	override private function locationToValue(x:Float, y:Float):Float {
		var percentage = 0.0;
		var trackScrollableHeight = this.actualHeight - this.paddingTop - this.paddingBottom - this.thumbSkin.height;
		var yOffset = y - this._pointerStartY;
		var yPosition = Math.min(Math.max(0.0, this._thumbStartY + yOffset), trackScrollableHeight);
		percentage = yPosition / trackScrollableHeight;
		return this.minimum + percentage * (this.maximum - this.minimum);
	}

	override private function saveThumbStart(location:Point):Void {
		var trackHeightMinusThumbHeight = this.actualHeight;
		var locationMinusHalfThumbHeight = location.y;
		if (this.thumbSkin != null) {
			trackHeightMinusThumbHeight -= this.thumbSkin.height;
			locationMinusHalfThumbHeight -= this.thumbSkin.height / 2.0;
		}
		this._thumbStartX = location.x;
		this._thumbStartY = Math.min(trackHeightMinusThumbHeight, locationMinusHalfThumbHeight);
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
			newWidth = this.thumbSkin.width + this.paddingLeft + this.paddingRight;
			if (this.trackSkin != null) {
				if (newWidth < this.trackSkin.width) {
					newWidth = this.trackSkin.width;
				}
				if (this.secondaryTrackSkin != null && newWidth < this.secondaryTrackSkin.width) {
					newWidth = this.secondaryTrackSkin.width;
				}
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = 0.0;
			if (this.trackSkin != null) {
				newHeight += this.trackSkin.height;
				if (this.secondaryTrackSkin != null) {
					newHeight += this.secondaryTrackSkin.height;
				}
			}
			var thumbHeight = this.thumbSkin.height + this.paddingTop + this.paddingBottom;
			if (newHeight < thumbHeight) {
				newHeight = thumbHeight;
			}
		}

		// TODO: calculate min and max
		var newMinWidth = newWidth;
		var newMinHeight = newHeight;
		var newMaxWidth = newWidth;

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, Math.POSITIVE_INFINITY);
	}

	override private function layoutSplitTrack():Void {
		var location = this.valueToLocation(value);
		if (this.thumbSkin != null) {
			if (Std.is(this.thumbSkin, IValidating)) {
				cast(this.thumbSkin, IValidating).validateNow();
			}
			location += Math.round(this.thumbSkin.height / 2.0);
		}

		this.secondaryTrackSkin.y = 0.0;
		this.secondaryTrackSkin.height = location;

		this.trackSkin.y = location;
		this.trackSkin.height = this.actualHeight - location;

		if (Std.is(this.secondaryTrackSkin, IValidating)) {
			cast(this.secondaryTrackSkin, IValidating).validateNow();
		}
		if (Std.is(this.trackSkin, IValidating)) {
			cast(this.trackSkin, IValidating).validateNow();
		}

		this.secondaryTrackSkin.x = (this.actualWidth - this.secondaryTrackSkin.width) / 2.0;
		this.trackSkin.x = (this.actualWidth - this.trackSkin.width) / 2.0;
	}

	override private function layoutSingleTrack():Void {
		if (this.trackSkin == null) {
			return;
		}

		this.trackSkin.y = 0.0;
		this.trackSkin.height = this.actualHeight;

		if (Std.is(this.trackSkin, IValidating)) {
			cast(this.trackSkin, IValidating).validateNow();
		}

		this.trackSkin.x = (this.actualWidth - this.trackSkin.width) / 2.0;
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
			this.thumbSkin.height = this._thumbSkinMeasurements.height;
		} else {
			var thumbHeight = contentHeight * this.getAdjustedPage() / range;
			if (thumbHeight > 0.0) {
				var heightOffset = contentHeight - thumbHeight;
				if (heightOffset > thumbHeight) {
					heightOffset = thumbHeight;
				}
				heightOffset *= valueOffset / (range * thumbHeight / contentHeight);
				thumbHeight -= heightOffset;
			}
			if (this._thumbSkinMeasurements.minHeight != null && thumbHeight < this._thumbSkinMeasurements.minHeight) {
				thumbHeight = this._thumbSkinMeasurements.minHeight;
			}
			if (thumbHeight < 0.0) {
				thumbHeight = 0.0;
			}
			this.thumbSkin.height = thumbHeight;
		}
		this.thumbSkin.x = this.paddingLeft + (contentWidth - this.thumbSkin.width) / 2.0;
		this.thumbSkin.y = this.valueToLocation(this.value);
	}
}
