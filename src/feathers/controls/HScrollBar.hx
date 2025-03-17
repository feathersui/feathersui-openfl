/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.supportClasses.BaseScrollBar;
import feathers.core.IMeasureObject;
import feathers.core.IValidating;
import openfl.events.Event;

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
		The variant used to style the decrement `Button` child component in a theme.

		To override this default variant, set the
		`BaseScrollBar.customDecrementButtonVariant` property.

		@see `BaseScrollBar.customDecrementButtonVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.3.0
	**/
	public static final CHILD_VARIANT_DECREMENT_BUTTON = "hScrollBar_decrementButton";

	/**
		The variant used to style the increment `Button` child component in a theme.

		To override this default variant, set the
		`BaseScrollBar.customIncrementButtonVariant` property.

		@see `BaseScrollBar.customIncrementButtonVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.3.0
	**/
	public static final CHILD_VARIANT_INCREMENT_BUTTON = "hScrollBar_incrementButton";

	/**
		Creates a new `HScrollBar` object.

		@since 1.0.0
	**/
	public function new(value:Float = 0.0, minimum:Float = 0.0, maximum:Float = 1.0, ?changeListener:(Event) -> Void) {
		this.initializeHScrollBarTheme();

		super(value, minimum, maximum, changeListener);
	}

	private function initializeHScrollBarTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelHScrollBarStyles.initialize();
		#end
	}

	override private function valueToLocation(value:Float):Float {
		// this will auto-size the thumb, if needed
		if ((this._currentThumbSkin is IValidating)) {
			(cast this._currentThumbSkin : IValidating).validateNow();
		}
		if (this.showDecrementAndIncrementButtons) {
			this.decrementButton.validateNow();
			this.incrementButton.validateNow();
		}
		var normalized = this.normalizeValue(value);
		var trackScrollableWidth = this.actualWidth - this.paddingLeft - this.paddingRight - this._currentThumbSkin.width;
		if (this.showDecrementAndIncrementButtons) {
			trackScrollableWidth -= (this.decrementButton.width + this.incrementButton.width);
		}
		if (trackScrollableWidth < 0.0) {
			trackScrollableWidth = 0.0;
		}
		var result = this.paddingLeft + (trackScrollableWidth * normalized);
		if (this.showDecrementAndIncrementButtons) {
			result += this.decrementButton.width;
		}
		return result;
	}

	override private function locationToValue(x:Float, y:Float):Float {
		var percentage = 0.0;
		var minXPosition = this.paddingLeft;
		var trackScrollableWidth = this.actualWidth - this.paddingLeft - this.paddingRight - this._currentThumbSkin.width;
		if (this.showDecrementAndIncrementButtons) {
			minXPosition += this.decrementButton.width;
			trackScrollableWidth -= (this.decrementButton.width + this.incrementButton.width);
		}
		if (trackScrollableWidth < 0.0) {
			trackScrollableWidth = 0.0;
		}
		var xOffset = x - this._pointerStartX;
		var xPosition = Math.min(Math.max(0.0, this._thumbStartX + xOffset - minXPosition), trackScrollableWidth);
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

		if (this.decrementButton != null) {
			this.decrementButtonMeasurements.restore(this.decrementButton);
			this.decrementButton.validateNow();
		}

		if (this.incrementButton != null) {
			this.incrementButtonMeasurements.restore(this.incrementButton);
			this.incrementButton.validateNow();
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
			if (this._currentTrackSkin != null) {
				newWidth += this._currentTrackSkin.width;
				if (this._currentSecondaryTrackSkin != null) {
					newWidth += this._currentSecondaryTrackSkin.width;
				}
			}
			var thumbWidth = this.paddingLeft + this.paddingRight;
			if (this._currentThumbSkin != null) {
				thumbWidth += this._currentThumbSkin.width;
			}
			if (newWidth < thumbWidth) {
				newWidth = thumbWidth;
			}
			if (this.showDecrementAndIncrementButtons) {
				newWidth += this.decrementButton.width + this.incrementButton.width;
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = this.paddingTop + this.paddingBottom;
			if (this._currentThumbSkin != null) {
				newHeight += this._currentThumbSkin.height;
			}
			if (this._currentTrackSkin != null) {
				if (newHeight < this._currentTrackSkin.height) {
					newHeight = this._currentTrackSkin.height;
				}
				if (this._currentSecondaryTrackSkin != null && newHeight < this._currentSecondaryTrackSkin.height) {
					newHeight = this._currentSecondaryTrackSkin.height;
				}
			}
			if (this.showDecrementAndIncrementButtons) {
				var buttonHeight = Math.max(this.decrementButton.height, this.incrementButton.height);
				if (newHeight < buttonHeight) {
					newHeight = buttonHeight;
				}
			}
		}

		// TODO: calculate min and max
		var newMinWidth = newWidth;
		var newMinHeight = newHeight;
		var newMaxHeight = newHeight;

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, null, newMaxHeight);
	}

	override private function layoutButtons():Void {
		if (!this.showDecrementAndIncrementButtons) {
			return;
		}
		if (this.decrementButton != null) {
			this.decrementButton.validateNow();
		}
		this.decrementButton.x = 0.0;
		this.decrementButton.y = (this.actualHeight - this.decrementButton.height) / 2.0;

		if (this.incrementButton != null) {
			this.incrementButton.validateNow();
		}
		this.incrementButton.x = this.actualWidth - this.incrementButton.width;
		this.incrementButton.y = (this.actualHeight - this.incrementButton.height) / 2.0;
	}

	override private function layoutSplitTrack():Void {
		var location = this.valueToLocation(value);
		if (this._currentThumbSkin != null) {
			if ((this._currentThumbSkin is IValidating)) {
				(cast this._currentThumbSkin : IValidating).validateNow();
			}
			location += Math.round(this._currentThumbSkin.width / 2.0);
		}

		var minTrackX = 0.0;
		var maxTrackX = this.actualWidth;
		if (this.showDecrementAndIncrementButtons) {
			minTrackX = this.decrementButton.width;
			maxTrackX -= this.incrementButton.width;
		}

		this._currentTrackSkin.x = minTrackX;
		this._currentTrackSkin.width = location;

		this._currentSecondaryTrackSkin.x = location;
		this._currentSecondaryTrackSkin.width = maxTrackX - location;

		if ((this._currentTrackSkin is IValidating)) {
			(cast this._currentTrackSkin : IValidating).validateNow();
		}
		if ((this._currentSecondaryTrackSkin is IValidating)) {
			(cast this._currentSecondaryTrackSkin : IValidating).validateNow();
		}

		this._currentTrackSkin.y = (this.actualHeight - this._currentTrackSkin.height) / 2.0;
		this._currentSecondaryTrackSkin.y = (this.actualHeight - this._currentSecondaryTrackSkin.height) / 2.0;
	}

	override private function layoutSingleTrack():Void {
		if (this._currentTrackSkin == null) {
			return;
		}

		var minTrackX = 0.0;
		var maxTrackX = this.actualWidth;
		if (this.showDecrementAndIncrementButtons) {
			minTrackX = this.decrementButton.width;
			maxTrackX -= this.incrementButton.width;
		}

		this._currentTrackSkin.x = minTrackX;
		this._currentTrackSkin.width = maxTrackX - minTrackX;

		if ((this._currentTrackSkin is IValidating)) {
			(cast this._currentTrackSkin : IValidating).validateNow();
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
			(cast this._currentThumbSkin : IValidating).validateNow();
		}

		var valueOffset = 0.0;
		if (this._value < this._minimum) {
			valueOffset = this._minimum - this._value;
		} else if (this._value > this._maximum) {
			valueOffset = this._value - this._maximum;
		}

		var contentWidth = this.actualWidth - this.paddingLeft - this.paddingRight;
		if (contentWidth < 0.0) {
			contentWidth = 0.0;
		}
		var contentHeight = this.actualHeight - this.paddingTop - this.paddingBottom;
		if (contentHeight < 0.0) {
			contentHeight = 0.0;
		}

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
				var measureSkin:IMeasureObject = cast this._currentThumbSkin;
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
