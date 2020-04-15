/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.supportClasses;

import openfl.events.Event;
import feathers.events.FeathersEvent;
import openfl.errors.TypeError;
import feathers.core.IUIControl;
import feathers.core.InvalidationFlag;
import feathers.layout.Measurements;
import openfl.display.DisplayObject;
import feathers.core.FeathersControl;

/**
	Base class for progress bar components.

	@see `feathers.controls.HProgressBar`
	@see `feathers.controls.VProgressBar`

	@since 1.0.0
**/
class BaseProgressBar extends FeathersControl {
	private function new() {
		super();
	}

	/**
		The value of the progress bar, which must be between the `minimum` and
		the `maximum`.

		When the `value` property changes, the progress bar will dispatch an event
		of type `Event.CHANGE`.

		In the following example, the value is changed to `12.0`:

		```hx
		progress.minimum = 0.0;
		progress.maximum = 100.0;
		progress.value = 12.0;
		```

		@default 0.0

		@see `BaseProgressBar.minimum`
		@see `BaseProgressBar.maximum`
		@see `openfl.events.Event.CHANGE`

		@since 1.0.0
	**/
	public var value(default, set):Float = 0.0;

	private function set_value(value:Float):Float {
		if (this.value == value) {
			return this.value;
		}
		this.value = value;
		this.setInvalid(InvalidationFlag.DATA);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.value;
	}

	/**
		The progress bar's value cannot be smaller than the minimum.

		In the following example, the minimum is set to `-100`:

		```hx
		progress.minimum = -100;
		progress.maximum = 100;
		progress.value = 50;
		```

		@default 0.0

		@see `BaseProgressBar.value`
		@see `BaseProgressBar.maximum`

		@since 1.0.0
	**/
	public var minimum(default, set):Float = 0.0;

	private function set_minimum(value:Float):Float {
		if (this.minimum == value) {
			return this.minimum;
		}
		this.minimum = value;
		if (this.initialized && this.value < this.minimum) {
			this.value = this.minimum;
		}
		this.setInvalid(InvalidationFlag.DATA);
		return this.minimum;
	}

	/**
		The progress bar's value cannot be larger than the maximum.

		In the following example, the maximum is set to `100.0`:

		```hx
		progress.minimum = 0.0;
		progress.maximum = 100.0;
		progress.value = 12.0;
		```

		@default 1.0

		@see `BaseProgressBar.value`
		@see `BaseProgressBar.minimum`

		@since 1.0.0
	**/
	public var maximum(default, set):Float = 1.0;

	private function set_maximum(value:Float):Float {
		if (this.maximum == value) {
			return this.maximum;
		}
		this.maximum = value;
		if (this.initialized && this.value > this.maximum) {
			this.value = this.maximum;
		}
		this.setInvalid(InvalidationFlag.DATA);
		return this.maximum;
	}

	private var _backgroundSkinMeasurements:Measurements = null;
	private var _currentBackgroundSkin:DisplayObject = null;

	/**
		The primary background to display in the progress bar. The background
		skin is displayed below the fill skin, and the fill skin is affected by
		the padding, and the background skin may be seen around the edges.

		The original width or height of the background skin will be one of the
		values used to calculate the width or height of the progress bar, if the
		`width` and `height` properties are not set explicitly. The fill skin
		and padding values will also be used.

		If the background skin is a measurable component, the `minWidth` or
		`minHeight` properties will be one of the values used to calculate the
		width or height of the progress bar. If the background skin is a regular
		OpenFL display object, the original width and height of the display
		object will be used to calculate the minimum dimensions instead.

		In the following example, the progress bar is given a background skin:

		```hx
		var skin = new RectangleSkin();
		skin.fill = SolidColor(0xcccccc);
		progress.backgroundSkin = skin;
		```

		@see `BaseProgressBar.disabledBackgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var backgroundSkin:DisplayObject = null;

	/**
		The background skin to display when the progress bar is disabled.

		In the following example, the progress bar is given a disabled
		background skin:

		```hx
		var skin = new RectangleSkin();
		skin.fill = SolidColor(0xdddddd);
		progress.disabledBackgroundSkin = skin;

		progress.enabled = false;
		```

		@see `BaseProgressBar.backgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var disabledBackgroundSkin:DisplayObject = null;

	private var _fillSkinMeasurements:Measurements = null;
	private var _currentFillSkin:DisplayObject = null;

	/**
		The primary fill to display in the progress bar. The fill skin is
		rendered above the background skin, with padding around the edges of the
		the fill skin to reveal the background skin behind.

		In the following example, the progress bar is given a fill skin:

		```hx
		var skin = new RectangleSkin();
		skin.fill = SolidColor(0xaaaaaa);
		progress.fillSkin = skin;
		```

		@since 1.0.0
	**/
	@:style
	public var fillSkin:DisplayObject = null;

	/**
		The fill skin to display when the progress bar is disabled.

		In the following example, the progress bar is given a disabled
		fill skin:

		```hx
		var skin = new RectangleSkin();
		skin.fill = SolidColor(0xcccccc);
		progress.disabledFillSkin = skin;

		progress.enabled = false;
		```

		@since 1.0.0
	**/
	@:style
	public var disabledFillSkin:DisplayObject = null;

	/**
		The minimum space, in pixels, between the progress bar's top edge and the
		progress bar's fill skin.

		In the following example, the progress bar's top padding is set to 20
		pixels:

		```hx
		progress.paddingTop = 20.0;
		```

		@see `BaseProgressBar.paddingBottom`
		@see `BaseProgressBar.paddingRight`
		@see `BaseProgressBar.paddingLeft`

		@since 1.0.0
	**/
	@:style
	public var paddingTop:Float = 0.0;

	/**
		The minimum space, in pixels, between the progress bar's right edge and
		the progress bar's fill skin.

		In the following example, the progress bar's right padding is set to 20
		pixels:

		```hx
		progress.paddingRight = 20.0;
		```

		@see `BaseProgressBar.paddingTop`
		@see `BaseProgressBar.paddingBottom`
		@see `BaseProgressBar.paddingLeft`

		@since 1.0.0
	**/
	@:style
	public var paddingRight:Float = 0.0;

	/**
		The minimum space, in pixels, between the progress bar's bottom edge and
		the progress bar's fill skin.

		In the following example, the progress bar's bottom padding is set to 20
		pixels:

		```hx
		progress.paddingBottom = 20.0;
		```

		@see `BaseProgressBar.paddingTop`
		@see `BaseProgressBar.paddingRight`
		@see `BaseProgressBar.paddingLeft`

		@since 1.0.0
	**/
	@:style
	public var paddingBottom:Float = 0.0;

	/**
		The minimum space, in pixels, between the progress bar's left edge and the
		text input's content.

		In the following example, the progress bar's left padding is set to 20
		pixels:

		```hx
		progress.paddingLeft = 20.0;
		```

		@see `BaseProgressBar.paddingTop`
		@see `BaseProgressBar.paddingBottom`
		@see `BaseProgressBar.paddingRight`

		@since 1.0.0
	**/
	@:style
	public var paddingLeft:Float = 0.0;

	override private function update():Void {
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);

		if (stylesInvalid || stateInvalid) {
			this.refreshBackgroundSkin();
			this.refreshFillSkin();
		}

		this.measure();
		this.layoutContent();
	}

	private function measure():Bool {
		throw new TypeError("Missing override for 'measure' in type " + Type.getClassName(Type.getClass(this)));
	}

	private function refreshBackgroundSkin():Void {
		var oldSkin = this._currentBackgroundSkin;
		this._currentBackgroundSkin = this.getCurrentBackgroundSkin();
		if (this._currentBackgroundSkin == oldSkin) {
			return;
		}
		this.removeCurrentBackgroundSkin(oldSkin);
		if (this._currentBackgroundSkin == null) {
			this._backgroundSkinMeasurements = null;
			return;
		}
		if (Std.is(this._currentBackgroundSkin, IUIControl)) {
			cast(this._currentBackgroundSkin, IUIControl).initializeNow();
		}
		if (this._backgroundSkinMeasurements == null) {
			this._backgroundSkinMeasurements = new Measurements(this._currentBackgroundSkin);
		} else {
			this._backgroundSkinMeasurements.save(this._currentBackgroundSkin);
		}
		this.addChildAt(this._currentBackgroundSkin, 0);
	}

	private function getCurrentBackgroundSkin():DisplayObject {
		if (!this.enabled && this.disabledBackgroundSkin != null) {
			return this.disabledBackgroundSkin;
		}
		return this.backgroundSkin;
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		this._backgroundSkinMeasurements.restore(skin);
		if (skin.parent == this) {
			// we need to restore these values so that they won't be lost the
			// next time that this skin is used for measurement
			this.removeChild(skin);
		}
	}

	private function refreshFillSkin():Void {
		var oldSkin = this._currentFillSkin;
		this._currentFillSkin = this.getCurrentFillSkin();
		if (this._currentFillSkin == oldSkin) {
			return;
		}
		this.removeCurrentFillSkin(oldSkin);
		if (this._currentFillSkin == null) {
			this._fillSkinMeasurements = null;
			return;
		}
		if (Std.is(this._currentFillSkin, IUIControl)) {
			cast(this._currentFillSkin, IUIControl).initializeNow();
		}
		if (this._fillSkinMeasurements == null) {
			this._fillSkinMeasurements = new Measurements(this._currentFillSkin);
		} else {
			this._fillSkinMeasurements.save(this._currentFillSkin);
		}
		this.addChild(this._currentFillSkin);
	}

	private function getCurrentFillSkin():DisplayObject {
		if (!this.enabled && this.disabledFillSkin != null) {
			return this.disabledFillSkin;
		}
		return this.fillSkin;
	}

	private function removeCurrentFillSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if (skin.parent == this) {
			// we need to restore these values so that they won't be lost the
			// next time that this skin is used for measurement
			this.removeChild(skin);
		}
	}

	private function layoutContent():Void {
		this.layoutBackground();
		this.layoutFill();
	}

	private function layoutBackground():Void {
		throw new TypeError("Missing override for 'layoutBackground' in type " + Type.getClassName(Type.getClass(this)));
	}

	private function layoutFill():Void {
		throw new TypeError("Missing override for 'layoutFill' in type " + Type.getClassName(Type.getClass(this)));
	}
}
