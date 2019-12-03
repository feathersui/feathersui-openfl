/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.themes.steel.components.SteelVProgressBarStyles;
import feathers.core.IMeasureObject;
import feathers.core.IValidating;
import feathers.controls.supportClasses.BaseProgressBar;

@:styleContext
class VProgressBar extends BaseProgressBar {
	/**
		Creates a new `VProgressBar` object.

		@since 1.0.0
	**/
	public function new() {
		initializeVProgressBarTheme();

		super();
	}

	private function initializeVProgressBarTheme():Void {
		SteelVProgressBarStyles.initialize();
	}

	/**
		If the component's dimensions have not been set explicitly, it will
		measure its content and determine an ideal size for itself. For
		instance, if the `explicitWidth` property is set, that value will be
		used without additional measurement. If `explicitWidth` is set, but
		`explicitHeight` is not (or the other way around), the dimension with
		the explicit value will not be measured, but the other non-explicit
		dimension will still require measurement.

		Calls `saveMeasurements()` to set up the `actualWidth` and
		`actualHeight` member variables used for layout.

		Meant for internal use, and subclasses may override this function with a
		custom implementation.

		@see `FeathersControl.saveMeasurements()`
		@see `FeathersControl.explicitWidth`
		@see `FeathersControl.explicitHeight`
		@see `FeathersControl.actualWidth`
		@see `FeathersControl.actualHeight`

		@since 1.0.0
	**/
	@:dox(show)
	override private function autoSizeIfNeeded():Bool {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight && !needsMaxWidth && !needsMaxHeight) {
			return false;
		}

		if (this._backgroundSkinMeasurements != null) {
			this._backgroundSkinMeasurements.resetTargetFluidlyForParent(this._currentBackgroundSkin, this);
		}

		var measureBackgroundSkin:IMeasureObject = null;
		if (Std.is(this._currentBackgroundSkin, IMeasureObject)) {
			measureBackgroundSkin = cast(this._currentBackgroundSkin, IMeasureObject);
		}

		if (Std.is(this._currentBackgroundSkin, IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			if (this._currentBackgroundSkin != null) {
				newWidth = this._backgroundSkinMeasurements.width;
			} else {
				newWidth = 0.0;
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			if (this._currentBackgroundSkin != null) {
				newHeight = this._backgroundSkinMeasurements.height;
			} else {
				newHeight = 0.0;
			}
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {}
		var newMaxWidth = this.explicitMaxWidth;
		if (needsMaxWidth) {}

		var newMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {}

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	override private function layoutBackground():Void {
		if (this._currentBackgroundSkin == null) {
			return;
		}
		this._currentBackgroundSkin.x = 0.0;
		this._currentBackgroundSkin.y = 0.0;

		// don' t set the width or height explicitly unless necessary because if // our explicit dimensions are cleared later, the measurement may not be

		// accurate anymore
		if (this._currentBackgroundSkin.width != this.actualWidth) {
			this._currentBackgroundSkin.width = this.actualWidth;
		}
		if (this._currentBackgroundSkin.height != this.actualHeight) {
			this._currentBackgroundSkin.height = this.actualHeight;
		}
		if (Std.is(this._currentBackgroundSkin, IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}
	}

	override private function layoutFill():Void {
		if (this._currentFillSkin == null) {
			return;
		}
		var percentage = 1.0;
		if (this.minimum != this.maximum) {
			percentage = (this.value - this.minimum) / (this.maximum - this.minimum);
			if (percentage < 0.0) {
				percentage = 0.0;
			} else if (percentage > 1.0) {
				percentage = 1.0;
			}
		}
		var calculatedHeight:Float = Math.round(percentage * (this.actualHeight - this.paddingTop - this.paddingBottom));
		if (this._fillSkinMeasurements.height != null && calculatedHeight < this._fillSkinMeasurements.height) {
			calculatedHeight = this._fillSkinMeasurements.height;
			// if the size is too small, and the value is equal to the
			// minimum, people don't expect to see the fill
			this._currentFillSkin.visible = this.value > this.minimum;
		} else {
			// if it was hidden before, we want to show it again
			this._currentFillSkin.visible = true;
		}

		this._currentFillSkin.x = this.paddingLeft;
		this._currentFillSkin.y = this.actualHeight - this.paddingBottom - calculatedHeight;
		this._currentFillSkin.width = this.actualWidth - this.paddingLeft - this.paddingRight;
		this._currentFillSkin.height = calculatedHeight;

		if (Std.is(this._currentFillSkin, IValidating)) {
			cast(this._currentFillSkin, IValidating).validateNow();
		}
	}
}
