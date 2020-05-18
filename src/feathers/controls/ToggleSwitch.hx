/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IFocusObject;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.core.InvalidationFlag;
import feathers.events.FeathersEvent;
import feathers.layout.Measurements;
import feathers.themes.steel.components.SteelToggleSwitchStyles;
import motion.Actuate;
import motion.actuators.SimpleActuator;
import motion.easing.IEasing;
import motion.easing.Quart;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.ui.Keyboard;

/**
	Similar to a light switch, with on and off states that may be toggled.
	An alternative to a `Check`, especially on mobile.

	The following example creates a toggle switch, programmatically selects it,
	and listens for when the selection changes:

	```hx
	var toggleSwitch = new ToggleSwitch();
	toggleSwitch.selected = true;
	toggleSwitch.addEventListener(Event.CHANGE, (event) -> {
		var toggleSwitch = cast(event.currentTarget, ToggleSwitch);
		trace("toggle switch changed: " + toggleSwitch.selected);
	});
	this.addChild(toggleSwitch);
	```

	@see [Tutorial: How to use the ToggleSwitch component](https://feathersui.com/learn/haxe-openfl/toggle-switch/)
	@see `feathers.controls.Check`

	@since 1.0.0
**/
@:styleContext
class ToggleSwitch extends FeathersControl implements IToggle implements IFocusObject {
	/**
		Creates a new `ToggleSwitch` object.

		@since 1.0.0
	**/
	public function new() {
		initializeToggleSwitchTheme();

		super();

		// MouseEvent.CLICK is dispatched only if the same object is under the
		// pointer for both MouseEvent.MOUSE_DOWN and MouseEvent.MOUSE_UP. The
		// thumb/track might change skins between MouseEvent.MOUSE_DOWN and
		// MouseEvent.MOUSE_UP, and this would prevent MouseEvent.CLICK.
		// setting mouseChildren to false keeps the button as the target.
		this.mouseChildren = false;
		// when focused, keyboard space/enter trigger MouseEvent.CLICK
		this.buttonMode = true;
		// a hand cursor only makes sense for hyperlinks
		this.useHandCursor = false;

		this.tabEnabled = true;
		this.tabChildren = false;
		this.focusRect = null;

		this.addEventListener(KeyboardEvent.KEY_DOWN, toggleSwitch_keyDownHandler);
		this.addEventListener(MouseEvent.MOUSE_DOWN, toggleSwitch_mouseDownHandler);
		this.addEventListener(MouseEvent.CLICK, toggleSwitch_clickHandler);
	}

	/**
		Indicates if the toggle switch is selected or not.

		The following example selects the toggle switch:

		```hx
		toggleSwitch.selected = true;
		```

		Note: When changing the `selected` property programatically, the
		position of the thumb is not animated. To change the selection with
		animation, call the `setSelectionWithAnimation()` method.

		@default false

		@see `ToggleSwitch.setSelectionWithAnimation()`

		@since 1.0.0
	**/
	@:isVar
	public var selected(get, set):Bool = false;

	private function get_selected():Bool {
		return this.selected;
	}

	private function set_selected(value:Bool):Bool {
		this._animateSelectionChange = false;
		if (this.selected == value) {
			return this.selected;
		}
		this.selected = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		this.setInvalid(InvalidationFlag.SELECTION);
		return this.selected;
	}

	private var _currentThumbSkin:DisplayObject = null;
	private var _thumbSkinMeasurements:Measurements = null;

	/**
		The skin to use for the toggle switch's thumb.

		In the following example, a thumb skin is passed to the toggle switch:

		```hx
		var skin = new RectangleSkin();
		skin.fill = SolidColor(0xcccccc);
		toggleSwitch.thumbSkin = skin;
		```

		@see `ToggleSwitch.trackSkin`

		@since 1.0.0
	**/
	@:style
	public var thumbSkin:DisplayObject = null;

	private var _currentTrackSkin:DisplayObject = null;
	private var _trackSkinMeasurements:Measurements = null;

	/**
		The skin to use for the toggle switch's track.

		In the following example, a track skin is passed to the toggle switch:

		```hx
		var skin = new RectangleSkin();
		skin.fill = SolidColor(0xcccccc);
		toggleSwitch.trackSkin = skin;
		```

		@see `ToggleSwitch.secondaryTrackSkin`
		@see `ToggleSwitch.thumbSkin`

		@since 1.0.0
	**/
	@:style
	public var trackSkin:DisplayObject = null;

	private var _currentSecondaryTrackSkin:DisplayObject = null;
	private var _secondaryTrackSkinMeasurements:Measurements = null;

	/**
		The skin to use for the toggle switch's optional secondary track. If a
		toggle switch has one track, it will fill the entire length of the
		toggle switch. If a toggle switch has a track and a secondary track, the
		primary track will stretch between the left edge of the toggle switch
		and the location of the slider's thumb, while the secondary track will
		stretch from the location of the toggle switch's thumb to the right edge
		of the toggle switch.

		In the following example, a track skin and a secondary track skin are
		passed to the toggle switch:

		```hx
		var skin = new RectangleSkin();
		skin.fill = SolidColor(0xaaaaaa);
		toggleSwitch.trackSkin = skin;

		var skin = new RectangleSkin();
		skin.fill = SolidColor(0xcccccc);
		toggleSwitch.secondaryTrackSkin = skin;
		```

		@see `ToggleSwitch.trackSkin`

		@since 1.0.0
	**/
	@:style
	public var secondaryTrackSkin:DisplayObject = null;

	/**
		The minimum space, measured in pixels, between the toggle switch's right
		edge and the right edge of the thumb.

		In the following example, the toggle switch's right padding is set to 20
		pixels:

		```hx
		toggleSwitch.paddingRight = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingRight:Float = 0.0;

	/**
		The minimum space, measured in pixels, between the toggle switch's left
		edge and the left edge of the thumb.

		In the following example, the toggle switch's left padding is set to 20
		pixels:

		```hx
		toggleSwitch.paddingLeft = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingLeft:Float = 0.0;

	private var _toggleTween:SimpleActuator<Dynamic, Dynamic> = null;

	/**
		The duration, measured in seconds, of the animation when the toggle
		switch is clicked or tap and the thumb slides to the other side.

		In the following example, the duration of the animation that toggles the
		thumb is set to 500 milliseconds:

		```hx
		toggleSwitch.toggleDuration = 0.5;
		```

		@since 1.0.0
	**/
	@:style
	public var toggleDuration:Float = 0.15;

	/**
		The easing function used for the animation when the toggle switch is
		clicked or tap and the thumb slides to the other side.

		In the following example, the ease of the animation that toggles the
		thumb is customized:

		```hx
		toggleSwitch.toggleEase = Elastic.easeOut;
		```

		@since 1.0.0
	**/
	@:style
	public var toggleEase:IEasing = Quart.easeOut;

	private var _dragStartX:Float;
	private var _ignoreClick:Bool = false;

	private var _animateSelectionChange:Bool = false;

	/**
		Changes the `selected` property and animates the position of the thumb.

		@see `ToggleSwitch.selected`
	**/
	public function setSelectionWithAnimation(selected:Bool):Bool {
		if (this.selected == selected) {
			return this.selected;
		}
		this.selected = selected;
		this._animateSelectionChange = true;
		return this.selected;
	}

	private function initializeToggleSwitchTheme():Void {
		SteelToggleSwitchStyles.initialize();
	}

	override private function update():Void {
		var selectionInvalid = this.isInvalid(InvalidationFlag.SELECTION);
		var sizeInvalid = this.isInvalid(InvalidationFlag.SIZE);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);

		if (stylesInvalid) {
			this.refreshThumb();
			this.refreshTrack();
			this.refreshSecondaryTrack();
		}

		if (selectionInvalid) {
			this.refreshSelection();
		}

		if (stateInvalid) {
			this.refreshEnabled();
		}

		sizeInvalid = this.measure() || sizeInvalid;

		this.layoutContent();
	}

	private function measure():Bool {
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

	private function refreshThumb():Void {
		var oldSkin = this._currentThumbSkin;
		this._currentThumbSkin = this.thumbSkin;
		if (this._currentThumbSkin == oldSkin) {
			return;
		}
		if (oldSkin != null && oldSkin.parent == this) {
			this.removeChild(oldSkin);
		}
		if (this._currentThumbSkin != null) {
			if (Std.is(this._currentThumbSkin, IUIControl)) {
				cast(this._currentThumbSkin, IUIControl).initializeNow();
			}
			if (this._thumbSkinMeasurements == null) {
				this._thumbSkinMeasurements = new Measurements(this._currentThumbSkin);
			} else {
				this._thumbSkinMeasurements.save(this._currentThumbSkin);
			}
			// add it above the trackSkin and secondaryTrackSkin
			this.addChild(this._currentThumbSkin);
		} else {
			this._thumbSkinMeasurements = null;
		}
	}

	private function refreshTrack():Void {
		var oldSkin = this._currentTrackSkin;
		this._currentTrackSkin = this.trackSkin;
		if (this._currentTrackSkin == oldSkin) {
			return;
		}
		if (oldSkin != null && oldSkin.parent == this) {
			this.removeChild(oldSkin);
		}
		if (this._currentTrackSkin != null) {
			if (Std.is(this._currentTrackSkin, IUIControl)) {
				cast(this._currentTrackSkin, IUIControl).initializeNow();
			}
			if (this._trackSkinMeasurements == null) {
				this._trackSkinMeasurements = new Measurements(this._currentTrackSkin);
			} else {
				this._trackSkinMeasurements.save(this._currentTrackSkin);
			}
			// always on the bottom
			this.addChildAt(this._currentTrackSkin, 0);
		} else {
			this._trackSkinMeasurements = null;
		}
	}

	private function refreshSecondaryTrack():Void {
		var oldSkin = this._currentSecondaryTrackSkin;
		this._currentSecondaryTrackSkin = this.secondaryTrackSkin;
		if (this._currentSecondaryTrackSkin == oldSkin) {
			return;
		}
		if (oldSkin != null && oldSkin.parent == this) {
			this.removeChild(oldSkin);
		}
		if (this._currentSecondaryTrackSkin != null) {
			if (Std.is(this._currentSecondaryTrackSkin, IUIControl)) {
				cast(this._currentSecondaryTrackSkin, IUIControl).initializeNow();
			}
			if (this._secondaryTrackSkinMeasurements == null) {
				this._secondaryTrackSkinMeasurements = new Measurements(this._currentSecondaryTrackSkin);
			} else {
				this._secondaryTrackSkinMeasurements.save(this._currentSecondaryTrackSkin);
			}

			// on the bottom or above the trackSkin
			var index = this._currentTrackSkin != null ? 1 : 0;
			this.addChildAt(this._currentSecondaryTrackSkin, index);
		} else {
			this._secondaryTrackSkinMeasurements = null;
		}
	}

	private function refreshSelection():Void {
		if (Std.is(this.thumbSkin, IToggle)) {
			cast(this.thumbSkin, IToggle).selected = this.selected;
		}
		if (Std.is(this.trackSkin, IToggle)) {
			cast(this.trackSkin, IToggle).selected = this.selected;
		}
		if (Std.is(this.secondaryTrackSkin, IToggle)) {
			cast(this.secondaryTrackSkin, IToggle).selected = this.selected;
		}

		// stop the tween, no matter what
		if (this._toggleTween != null) {
			Actuate.stop(this._toggleTween, null, false, false);
			this._toggleTween = null;
		}
	}

	private function refreshEnabled():Void {
		if (Std.is(this.thumbSkin, IUIControl)) {
			cast(this.thumbSkin, IUIControl).enabled = this.enabled;
		}
		if (Std.is(this.trackSkin, IUIControl)) {
			cast(this.trackSkin, IUIControl).enabled = this.enabled;
		}
		if (Std.is(this.secondaryTrackSkin, IUIControl)) {
			cast(this.secondaryTrackSkin, IUIControl).enabled = this.enabled;
		}
	}

	private function layoutContent():Void {
		this.layoutThumb();
		if (this.trackSkin != null && this.secondaryTrackSkin != null) {
			this.layoutSplitTrack();
		} else {
			this.layoutSingleTrack();
		}
	}

	private function layoutThumb():Void {
		if (Std.is(this.thumbSkin, IValidating)) {
			cast(this.thumbSkin, IValidating).validateNow();
		}

		var xPosition = this.paddingLeft;
		if (this.selected) {
			xPosition = this.actualWidth - this.thumbSkin.width - this.paddingRight;
		}

		if (this._animateSelectionChange) {
			var tween = Actuate.update((x : Float) -> {
				this.thumbSkin.x = x;
			}, this.toggleDuration, [this.thumbSkin.x], [xPosition], true);
			this._toggleTween = cast(tween, SimpleActuator<Dynamic, Dynamic>);
			this._toggleTween.ease(this.toggleEase);
			this._toggleTween.onUpdate(this.toggleTween_onUpdate);
			this._toggleTween.onComplete(this.toggleTween_onComplete);
		} else if (this._toggleTween == null) {
			this.thumbSkin.x = xPosition;
		}
		this.thumbSkin.y = Math.round((this.actualHeight - this.thumbSkin.height) / 2.0);

		this._animateSelectionChange = false;
	}

	private function layoutSplitTrack():Void {
		var location = this.thumbSkin.x + this.thumbSkin.width / 2.0;

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

	private function layoutSingleTrack():Void {
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

	private function toggleSwitch_keyDownHandler(event:KeyboardEvent):Void {
		if (!this.enabled || (this.buttonMode && this.focusRect == true)) {
			return;
		}
		if (event.keyCode != Keyboard.SPACE && event.keyCode != Keyboard.ENTER) {
			return;
		}
		this.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
	}

	private function toggleSwitch_mouseDownHandler(event:MouseEvent):Void {
		if (!this.enabled) {
			return;
		}
		this._dragStartX = this.mouseX;
		this._ignoreClick = false;
		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, toggleSwitch_stage_mouseMoveHandler, false, 0, true);
		this.stage.addEventListener(MouseEvent.MOUSE_UP, toggleSwitch_stage_mouseUpHandler, false, 0, true);
	}

	private function toggleSwitch_clickHandler(event:MouseEvent):Void {
		if (!this.enabled || this._ignoreClick) {
			return;
		}
		this.setSelectionWithAnimation(!this.selected);
	}

	private function toggleSwitch_stage_mouseMoveHandler(event:MouseEvent):Void {
		if (!this.enabled) {
			return;
		}

		var halfDistance = (this.actualWidth - this.paddingLeft - this.paddingRight) / 2.0;
		var dragOffset = this.mouseX - this._dragStartX;
		var selected = this.selected;
		if (dragOffset >= halfDistance) {
			selected = true;
		} else if (dragOffset <= -halfDistance) {
			selected = false;
		}
		if (this.selected != selected) {
			this._ignoreClick = true;
			this._dragStartX = this.mouseX;
			this.setSelectionWithAnimation(selected);
		}
	}

	private function toggleSwitch_stage_mouseUpHandler(event:MouseEvent):Void {
		this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, toggleSwitch_stage_mouseMoveHandler);
		this.stage.removeEventListener(MouseEvent.MOUSE_UP, toggleSwitch_stage_mouseUpHandler);
	}

	private function toggleTween_onUpdate():Void {
		this.layoutContent();
	}

	private function toggleTween_onComplete():Void {
		this._toggleTween = null;
	}
}
