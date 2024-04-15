/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.supportClasses;

import feathers.core.FeathersControl;
import feathers.core.IUIControl;
import feathers.events.FeathersEvent;
import feathers.layout.Measurements;
import feathers.skins.IIndeterminateSkin;
import feathers.skins.IProgrammaticSkin;
import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.errors.TypeError;
import openfl.events.Event;

/**
	Base class for progress bar components.

	@event openfl.events.Event.CHANGE Dispatched when `BaseProgressBar.value`
	changes.

	@see `feathers.controls.HProgressBar`
	@see `feathers.controls.VProgressBar`

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
class BaseProgressBar extends FeathersControl implements IRange {
	private function new(value:Float = 0.0, minimum:Float = 0.0, maximum:Float = 1.0, ?changeListener:(Event) -> Void) {
		super();

		this.minimum = minimum;
		this.maximum = maximum;
		this.value = value;

		if (changeListener != null) {
			this.addEventListener(Event.CHANGE, changeListener);
		}
	}

	private var _value:Float = 0.0;

	/**
		The value of the progress bar, which must be between the `minimum` and
		the `maximum`.

		When the `value` property changes, the progress bar will dispatch an event
		of type `Event.CHANGE`.

		In the following example, the value is changed to `12.0`:

		```haxe
		progress.minimum = 0.0;
		progress.maximum = 100.0;
		progress.value = 12.0;
		```

		@default 0.0

		@see `BaseProgressBar.minimum`
		@see `BaseProgressBar.maximum`
		@see [`openfl.events.Event.CHANGE`](https://api.openfl.org/openfl/events/Event.html#CHANGE)

		@since 1.0.0
	**/
	@:bindable("change")
	@:inspectable(defaultValue = "0.0")
	public var value(get, set):Float;

	private function get_value():Float {
		return this._value;
	}

	private function set_value(value:Float):Float {
		if (this._value == value) {
			return this._value;
		}
		this._value = value;
		this.setInvalid(DATA);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._value;
	}

	private var _minimum:Float = 0.0;

	/**
		The progress bar's value cannot be smaller than the minimum.

		In the following example, the minimum is set to `-100`:

		```haxe
		progress.minimum = -100;
		progress.maximum = 100;
		progress.value = 50;
		```

		@default 0.0

		@see `BaseProgressBar.value`
		@see `BaseProgressBar.maximum`

		@since 1.0.0
	**/
	@:inspectable(defaultValue = "0.0")
	public var minimum(get, set):Float;

	private function get_minimum():Float {
		return this._minimum;
	}

	private function set_minimum(value:Float):Float {
		if (this._minimum == value) {
			return this._minimum;
		}
		this._minimum = value;
		if (this.initialized && this._value < this._minimum) {
			// use the setter
			this.value = this._minimum;
		}
		this.setInvalid(DATA);
		return this._minimum;
	}

	private var _maximum:Float = 1.0;

	/**
		The progress bar's value cannot be larger than the maximum.

		In the following example, the maximum is set to `100.0`:

		```haxe
		progress.minimum = 0.0;
		progress.maximum = 100.0;
		progress.value = 12.0;
		```

		@default 1.0

		@see `BaseProgressBar.value`
		@see `BaseProgressBar.minimum`

		@since 1.0.0
	**/
	@:inspectable(defaultValue = "1.0")
	public var maximum(get, set):Float;

	private function get_maximum():Float {
		return this._maximum;
	}

	private function set_maximum(value:Float):Float {
		if (this._maximum == value) {
			return this._maximum;
		}
		this._maximum = value;
		if (this.initialized && this._value > this._maximum) {
			// use the setter
			this.value = this._maximum;
		}
		this.setInvalid(DATA);
		return this._maximum;
	}

	private var _indeterminateActive:Bool = false;
	private var _lastIndeterminateUpdateTime:Int;
	private var _reversedIndeterminate:Bool = false;
	private var _savedIndeterminateFillSkinAlpha:Float;

	private var _indeterminate:Bool = false;

	/**
		Indicates if a progress bar has a determinate or indeterminate
		appearance. Typically, an indeterminate progress bar will be animated,
		and will appear as if it has no specific value.

		In the following example, the progress bar is made indeterminate:

		```haxe
		progress.indeterminate = true;
		```

		@default false

		@since 1.3.0
	**/
	public var indeterminate(get, set):Bool;

	private function get_indeterminate():Bool {
		return this._indeterminate;
	}

	private function set_indeterminate(value:Bool):Bool {
		if (this._indeterminate == value) {
			return this._indeterminate;
		}
		this._indeterminate = value;
		this.setInvalid(STATE);
		return this._indeterminate;
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

		```haxe
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

		```haxe
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

		```haxe
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

		```haxe
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
		Controls how the fill of the progress bar is rendered.

		In the following example, the fill's mask is resized:

		```haxe
		progress.fillMode = MASK;
		```

		@since 1.1.0
	**/
	@:style
	public var fillMode:ProgressBarFillMode = RESIZE;

	/**
		The indeterminate skin to display. This skin will be animated when the
		progress bar is added to the display list, unless the activity
		indicator isn't in indeterminate mode.

		If the skin implements the `IIndeterminateSkin` interface, its
		`indeterminatePosition` property will be updated every frame with a
		value between `0.0` and `1.0`, based on the `indeterminateDuration`
		property. If the skin does not implement `IIndeterminateSkin`, its
		`alpha` property will be animated to fade in and out repeatedly.

		The following example passes a bitmap for the activity indicator to use
		as a skin:

		```haxe
		progressBar.indeterminateFillSkin = new Bitmap(bitmapData);
		```

		@since 1.3.0
	**/
	@:style
	public var indeterminateFillSkin:DisplayObject = null;

	/**
		The duration of the indeterminate effect, measured in seconds.

		@since 1.3.0
	**/
	@:style
	public var indeterminateDuration:Float = 0.75;

	/**
		The minimum space, in pixels, between the progress bar's top edge and the
		progress bar's fill skin.

		In the following example, the progress bar's top padding is set to 20
		pixels:

		```haxe
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

		```haxe
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

		```haxe
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

		```haxe
		progress.paddingLeft = 20.0;
		```

		@see `BaseProgressBar.paddingTop`
		@see `BaseProgressBar.paddingBottom`
		@see `BaseProgressBar.paddingRight`

		@since 1.0.0
	**/
	@:style
	public var paddingLeft:Float = 0.0;

	/**
		Sets all four padding properties to the same value.

		@see `BaseProgressBar.paddingTop`
		@see `BaseProgressBar.paddingRight`
		@see `BaseProgressBar.paddingBottom`
		@see `BaseProgressBar.paddingLeft`

		@since 1.0.0
	**/
	public function setPadding(value:Float):Void {
		this.paddingTop = value;
		this.paddingRight = value;
		this.paddingBottom = value;
		this.paddingLeft = value;
	}

	override private function update():Void {
		var stylesInvalid = this.isInvalid(STYLES);
		var stateInvalid = this.isInvalid(STATE);

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
		this.addCurrentBackgroundSkin(this._currentBackgroundSkin);
	}

	private function getCurrentBackgroundSkin():DisplayObject {
		if (!this._enabled && this.disabledBackgroundSkin != null) {
			return this.disabledBackgroundSkin;
		}
		return this.backgroundSkin;
	}

	private function addCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			this._backgroundSkinMeasurements = null;
			return;
		}
		if ((skin is IUIControl)) {
			(cast skin : IUIControl).initializeNow();
		}
		if (this._backgroundSkinMeasurements == null) {
			this._backgroundSkinMeasurements = new Measurements(skin);
		} else {
			this._backgroundSkinMeasurements.save(skin);
		}
		if ((skin is IProgrammaticSkin)) {
			(cast skin : IProgrammaticSkin).uiContext = this;
		}
		this.addChildAt(skin, 0);
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if ((skin is IProgrammaticSkin)) {
			(cast skin : IProgrammaticSkin).uiContext = null;
		}
		// we need to restore these values so that they won't be lost the
		// next time that this skin is used for measurement
		this._backgroundSkinMeasurements.restore(skin);
		if (skin.parent == this) {
			this.removeChild(skin);
		}
	}

	private function refreshFillSkin():Void {
		var oldSkin = this._currentFillSkin;
		this._currentFillSkin = this.getCurrentFillSkin();
		if (this._currentFillSkin != oldSkin) {
			this.removeCurrentFillSkin(oldSkin);
			this.addCurrentFillSkin(this._currentFillSkin);
		}
		if (!this._indeterminate && this._indeterminateActive && oldSkin != null) {
			oldSkin.alpha = this._savedIndeterminateFillSkinAlpha;
			this._indeterminateActive = false;
			this.removeEventListener(Event.ENTER_FRAME, baseProgressBar_enterFrameHandler);
		} else if (this._indeterminate && !this._indeterminateActive && this._currentFillSkin != null) {
			this._savedIndeterminateFillSkinAlpha = this._currentFillSkin.alpha;
			this._indeterminateActive = true;
			this._lastIndeterminateUpdateTime = Lib.getTimer();
			this.addEventListener(Event.ENTER_FRAME, baseProgressBar_enterFrameHandler);
		}
	}

	private function getCurrentFillSkin():DisplayObject {
		if (!this._enabled && this.disabledFillSkin != null) {
			return this.disabledFillSkin;
		}
		if (this._indeterminate && this.indeterminateFillSkin != null) {
			return this.indeterminateFillSkin;
		}
		return this.fillSkin;
	}

	private function addCurrentFillSkin(skin:DisplayObject):Void {
		if (skin == null) {
			this._fillSkinMeasurements = null;
			return;
		}
		if ((skin is IUIControl)) {
			(cast skin : IUIControl).initializeNow();
		}
		if (this._fillSkinMeasurements == null) {
			this._fillSkinMeasurements = new Measurements(skin);
		} else {
			this._fillSkinMeasurements.save(skin);
		}
		if ((skin is IProgrammaticSkin)) {
			(cast skin : IProgrammaticSkin).uiContext = this;
		}
		this.addChild(skin);
	}

	private function removeCurrentFillSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if ((skin is IProgrammaticSkin)) {
			(cast skin : IProgrammaticSkin).uiContext = null;
		}
		// we need to restore these values so that they won't be lost the
		// next time that this skin is used for measurement
		if (skin.parent == this) {
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

	private function baseProgressBar_enterFrameHandler(event:Event):Void {
		if (!this._enabled || !this.visible || !this._indeterminate) {
			return;
		}
		var currentTime = Lib.getTimer();
		var ratio = (currentTime - this._lastIndeterminateUpdateTime) / (this.indeterminateDuration * 1000.0);
		if (ratio >= 1.0) {
			ratio -= Math.ffloor(ratio);
			this._lastIndeterminateUpdateTime = currentTime;
			this._reversedIndeterminate = !this._reversedIndeterminate;
		}
		if ((this._currentFillSkin is IIndeterminateSkin)) {
			var activitySkin:IIndeterminateSkin = cast this._currentFillSkin;
			activitySkin.indeterminatePosition = ratio;
		} else {
			this._currentFillSkin.alpha = this._savedIndeterminateFillSkinAlpha * (this._reversedIndeterminate ? 1.0 - ratio : ratio);
		}
	}
}
