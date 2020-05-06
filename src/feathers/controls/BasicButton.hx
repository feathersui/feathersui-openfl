/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.utils.KeyToState;
import feathers.core.FeathersControl;
import feathers.core.IMeasureObject;
import feathers.core.IStateContext;
import feathers.core.IStateObserver;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.core.InvalidationFlag;
import feathers.events.FeathersEvent;
import feathers.layout.Measurements;
import feathers.utils.MeasurementsUtil;
import feathers.utils.PointerToState;
import feathers.utils.PointerTrigger;
import openfl.display.DisplayObject;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.ui.Keyboard;

/**
	A simple button control with states, but no content, that is useful for
	purposes like skinning. For a more full-featured button, with a label and
	icon, see `feathers.controls.Button` instead.

	@since 1.0.0

	@see `feathers.controls.Button`
**/
class BasicButton extends FeathersControl implements IStateContext<ButtonState> {
	/**
		Creates a new `BasicButton` object.

		@since 1.0.0
	**/
	public function new() {
		super();
		// MouseEvent.CLICK is dispatched only if the same object is under the
		// pointer for both MouseEvent.MOUSE_DOWN and MouseEvent.MOUSE_UP. The
		// button might change skins between ButtonState.UP and
		// ButtonState.DOWN, and this would prevent MouseEvent.CLICK.
		// setting mouseChildren to false keeps the button as the target.
		this.mouseChildren = false;
		// when focused, keyboard space/enter trigger MouseEvent.CLICK
		this.buttonMode = true;
		// a hand cursor only makes sense for hyperlinks
		this.useHandCursor = false;

		this.addEventListener(MouseEvent.CLICK, basicButton_clickHandler);
	}

	/**
		The current state of the button.

		When the value of the `currentState` property changes, the button will
		dispatch an event of type `FeathersEvent.STATE_CHANGE`.

		@see `feathers.controls.ButtonState`
		@see `feathers.events.FeathersEvent.STATE_CHANGE`

		@since 1.0.0
	**/
	public var currentState(get, null):ButtonState = UP;

	private function get_currentState():ButtonState {
		return this.currentState;
	}

	override private function set_enabled(value:Bool):Bool {
		super.enabled = value;
		if (this.enabled) {
			if (this.currentState == DISABLED) {
				this.changeState(UP);
			}
		} else {
			this.changeState(DISABLED);
		}
		return this.enabled;
	}

	private var _pointerToState:PointerToState<ButtonState> = null;
	private var _keyToState:KeyToState<ButtonState> = null;
	private var _pointerTrigger:PointerTrigger = null;
	private var _backgroundSkinMeasurements:Measurements = null;
	private var _currentBackgroundSkin:DisplayObject = null;

	/**
		Determines if a pressed button should remain in the down state if the
		pointer moves outside of the button's bounds. Useful for controls like
		`HSlider`, `VSlider`, or `ToggleSwitch` to keep a thumb in the down
		state while it is being dragged around by the pointer.

		The following example ensures that the button's down state remains
		active on roll out.

		```hx
		button.keepDownStateOnRollOut = true;
		```

		@since 1.0.0
	**/
	@:style
	public var keepDownStateOnRollOut:Bool = false;

	/**
		The display object to use as the background skin for the button.

		To render a different background skin, depending on the button's current
		state, pass additional skins to `setSkinForState()`.

		The following example passes a bitmap for the button to use as a
		background skin:

		```hx
		button.backgroundSkin = new Bitmap(bitmapData);
		```

		@default null

		@see `BasicButton.getSkinForState()`
		@see `BasicButton.setSkinForState()`

		@since 1.0.0
	**/
	@:style
	public var backgroundSkin:DisplayObject = null;

	private var _stateToSkin:Map<ButtonState, DisplayObject> = new Map();

	/**
		Gets the skin to be used by the button when its `currentState` property
		matches the specified state value.

		If a skin is not defined for a specific state, returns `null`.

		@see `BasicButton.setSkinForState()`
		@see `BasicButton.backgroundSkin`
		@see `BasicButton.currentState`
		@see `feathers.controls.ButtonState`

		@since 1.0.0
	**/
	public function getSkinForState(state:ButtonState):DisplayObject {
		return this._stateToSkin.get(state);
	}

	/**
		Set the skin to be used by the button when its `currentState` property
		matches the specified state value.

		If a skin is not defined for a specific state, the value of the
		`backgroundSkin` property will be used instead.

		@see `BasicButton.getSkinForState()`
		@see `BasicButton.backgroundSkin`
		@see `BasicButton.currentState`
		@see `feathers.controls.ButtonState`

		@since 1.0.0
	**/
	@style
	public function setSkinForState(state:ButtonState, skin:DisplayObject):Void {
		if (!this.setStyle("setSkinForState", state)) {
			return;
		}
		var oldSkin = this._stateToSkin.get(state);
		if (oldSkin != null && oldSkin == this._currentBackgroundSkin) {
			this.removeCurrentBackgroundSkin(oldSkin);
			this._currentBackgroundSkin = null;
		}
		if (skin == null) {
			this._stateToSkin.remove(state);
		} else {
			this._stateToSkin.set(state, skin);
		}
		this.setInvalid(InvalidationFlag.STYLES);
	}

	override private function initialize():Void {
		super.initialize();

		if (this._pointerToState == null) {
			this._pointerToState = new PointerToState(this, this.changeState, UP, DOWN, HOVER);
		}

		if (this._keyToState == null) {
			this._keyToState = new KeyToState(this, this.changeState, UP, DOWN);
		}

		if (this._pointerTrigger == null) {
			this._pointerTrigger = new PointerTrigger(this);
		}
	}

	override private function update():Void {
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);

		if (stylesInvalid || stateInvalid) {
			this.refreshBackgroundSkin();
		}

		if (stylesInvalid) {
			this.refreshInteractivity();
		}

		this.measure();
		this.layoutBackgroundSkin();
	}

	private function refreshInteractivity():Void {
		this._pointerToState.keepDownStateOnRollOut = this.keepDownStateOnRollOut;
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
		if (Std.is(this._currentBackgroundSkin, IStateObserver)) {
			cast(this._currentBackgroundSkin, IStateObserver).stateContext = this;
		}
		this.addChildAt(this._currentBackgroundSkin, 0);
	}

	private function getCurrentBackgroundSkin():DisplayObject {
		var result = this._stateToSkin.get(this.currentState);
		if (result != null) {
			return result;
		}
		return this.backgroundSkin;
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if (Std.is(skin, IStateObserver)) {
			cast(skin, IStateObserver).stateContext = null;
		}
		this._backgroundSkinMeasurements.restore(skin);
		if (skin.parent == this) {
			// we need to restore these values so that they won't be lost the
			// next time that this skin is used for measurement
			this.removeChild(skin);
		}
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

		if (this._currentBackgroundSkin != null) {
			MeasurementsUtil.resetFluidlyWithParent(this._backgroundSkinMeasurements, this._currentBackgroundSkin, this);
		}

		var measureSkin:IMeasureObject = null;
		if (Std.is(this._currentBackgroundSkin, IMeasureObject)) {
			measureSkin = cast(this._currentBackgroundSkin, IMeasureObject);
		}

		if (Std.is(this._currentBackgroundSkin, IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			if (this._currentBackgroundSkin != null) {
				newWidth = this._currentBackgroundSkin.width;
			} else {
				newWidth = 0.0;
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			if (this._currentBackgroundSkin != null) {
				newHeight = this._currentBackgroundSkin.height;
			} else {
				newHeight = 0.0;
			}
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			if (measureSkin != null) {
				newMinWidth = measureSkin.minWidth;
			} else if (this._backgroundSkinMeasurements != null) {
				newMinWidth = this._backgroundSkinMeasurements.minWidth;
			} else {
				newMinWidth = 0.0;
			}
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			if (measureSkin != null) {
				newMinHeight = measureSkin.minHeight;
			} else if (this._backgroundSkinMeasurements != null) {
				newMinHeight = this._backgroundSkinMeasurements.minHeight;
			} else {
				newMinHeight = 0.0;
			}
		}
		var newMaxWidth = this.explicitMaxWidth;
		if (needsMaxWidth) {
			if (measureSkin != null) {
				newMaxWidth = measureSkin.maxWidth;
			} else if (this._backgroundSkinMeasurements != null) {
				newMaxWidth = this._backgroundSkinMeasurements.maxWidth;
			} else {
				newMaxWidth = Math.POSITIVE_INFINITY;
			}
		}

		var newMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {
			if (measureSkin != null) {
				newMaxHeight = measureSkin.maxHeight;
			} else if (this._backgroundSkinMeasurements != null) {
				newMaxHeight = this._backgroundSkinMeasurements.maxHeight;
			} else {
				newMaxHeight = Math.POSITIVE_INFINITY;
			}
		}

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	private function layoutBackgroundSkin():Void {
		if (this._currentBackgroundSkin == null) {
			return;
		}
		this._currentBackgroundSkin.x = 0.0;
		this._currentBackgroundSkin.y = 0.0;

		// don't set the width or height explicitly unless necessary because if
		// our explicit dimensions are cleared later, the measurement may not be
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

	private function changeState(state:ButtonState):Void {
		if (!this.enabled) {
			state = DISABLED;
		}
		if (this.currentState == state) {
			return;
		}
		this.currentState = state;
		this.setInvalid(InvalidationFlag.STATE);
		FeathersEvent.dispatch(this, FeathersEvent.STATE_CHANGE);
	}

	private function basicButton_clickHandler(event:MouseEvent):Void {
		if (!this.enabled) {
			event.stopImmediatePropagation();
			return;
		}
	}
}
