/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.utils.KeyToState;
import feathers.utils.MeasurementsUtil;
import feathers.events.TriggerEvent;
import feathers.utils.PointerTrigger;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.MouseEvent;
import feathers.core.FeathersControl;
import feathers.core.IMeasureObject;
import feathers.core.IUIControl;
import feathers.core.InvalidationFlag;
import feathers.core.IStateContext;
import feathers.core.IStateObserver;
import feathers.core.IValidating;
import feathers.events.FeathersEvent;
import feathers.layout.Measurements;
import feathers.utils.PointerToState;

/**
	A simple toggle button control with selection, pointer states, but no
	content, that is useful for purposes like skinning. For a more full-featured
	toggle button, with a label and icon, see `feathers.controls.ToggleButton`
	instead.

	@since 1.0.0

	@see `feathers.controls.ToggleButton`
**/
class BasicToggleButton extends FeathersControl implements IToggle implements IStateContext<ToggleButtonState> {
	/**
		Creates a new `BasicToggleButton` object.

		@since 1.0.0
	**/
	public function new() {
		super();
		// MouseEvent.CLICK is dispatched only if the same object is under the
		// pointer for both MouseEvent.MOUSE_DOWN and MouseEvent.MOUSE_UP. The
		// button might change skins between ToggleButtonState.UP and
		// ToggleButtonState.DOWN, and this would prevent MouseEvent.CLICK.
		// setting mouseChildren to false keeps the toggle button as the target.
		this.mouseChildren = false;
		// when focused, keyboard space/enter trigger MouseEvent.CLICK
		this.buttonMode = true;
		// a hand cursor only makes sense for hyperlinks
		this.useHandCursor = false;

		this.addEventListener(TriggerEvent.TRIGGER, basicToggleButton_triggerHandler);
	}

	/**
		The current state of the toggle button.

		When the value of the `currentState` property changes, the button will
		dispatch an event of type `FeathersEvent.STATE_CHANGE`.

		@see `feathers.controls.ToggleButtonState`
		@see `feathers.events.FeathersEvent.STATE_CHANGE`

		@since 1.0.0
	**/
	public var currentState(get, null):ToggleButtonState = UP(false);

	private function get_currentState():ToggleButtonState {
		return this.currentState;
	}

	override private function set_enabled(value:Bool):Bool {
		super.enabled = value;
		if (this.enabled) {
			var toggleState = cast(@:bypassAccessor this.currentState, ToggleButtonState);
			switch (toggleState) {
				case DISABLED(selected):
					this.changeState(UP(selected));
				default: // do nothing
			}
		} else {
			this.changeState(DISABLED(this.selected));
		}
		return this.enabled;
	}

	/**
		Indicates if the button is selected or not. The button may be selected
		programmatically, even if `toggleable` is `false`, but generally,
		`toggleable` should be set to `true` to allow the user to select and
		deselect it by triggering the button with a click or tap. If focus
		management is enabled, and the button has focus, a button may also be
		triggered with the spacebar.

		When the value of the `selected` property changes, the button will
		dispatch an event of type `Event.CHANGE`.

		The following example selects the button:

		```hx
		button.selected = true;
		```

		The following example listens for changes to the `selected` property:

		```hx
		button.addEventListener(Event.CHANGE, (event:Event) -> {
			trace("selected changed: " + button.selected)
		});
		```

		**Warning:** Do not listen for `TriggerEvent.TRIGGER` to be notified
		when the `selected` property changes. You must listen for
		`Event.CHANGE`, which is dispatched after `TriggerEvent.TRIGGER`.

		@default false

		@see `BasicToggleButton.toggleable`

		@since 1.0.0
	**/
	@:isVar
	public var selected(get, set):Bool = false;

	private function get_selected():Bool {
		return this.selected;
	}

	private function set_selected(value:Bool):Bool {
		if (this.selected == value) {
			return this.selected;
		}
		this.selected = value;
		this.setInvalid(InvalidationFlag.SELECTION);
		this.setInvalid(InvalidationFlag.STATE);
		FeathersEvent.dispatch(this, Event.CHANGE);
		FeathersEvent.dispatch(this, FeathersEvent.STATE_CHANGE);
		return this.selected;
	}

	/**
		Determines if the button may be selected or deselected as a result of
		user interaction. If `true`, the value of the `selected` property will
		be toggled when the button is triggered.

		The following example disables the ability to toggle on click or tap:

		```hx
		button.toggleable = false;
		```

		@default true

		@see `BasicToggleButton.selected`
		@see `feathers.events.TriggerEvent.TRIGGER`

		@since 1.0.0
	**/
	public var toggleable(default, set):Bool = true;

	private function set_toggleable(value:Bool):Bool {
		if (this.toggleable == value) {
			return this.toggleable;
		}
		this.toggleable = value;
		return this.toggleable;
	}

	private var _pointerToState:PointerToState<ToggleButtonState> = null;
	private var _keyToState:KeyToState<ToggleButtonState> = null;
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
		The default background skin for the toggle button, which is used when no
		other skin is defined for the current state with `setSkinForState()`.

		The following example passes a bitmap for the button to use as a
		background skin:

		```hx
		button.backgroundSkin = new Bitmap(bitmapData);
		```

		@default null

		@see `BasicToggleButton.getSkinForState()`
		@see `BasicToggleButton.setSkinForState()`

		@since 1.0.0
	**/
	@:style
	public var backgroundSkin:DisplayObject = null;

	/**
		The default background skin for the toggle button when the `selected`
		property is `true`. Takes precendence over `backgroundSkin`, but will
		defer to another skin that is defined for the current state with
		`setSkinForState()`.

		The following example gives the toggle button a default selected skin:

		```hx
		button.selectedBackgroundSkin = new Bitmap(bitmapData);
		```

		@default null

		@see `BasicToggleButton.backgroundSkin`
		@see `BasicToggleButton.getSkinForState()`
		@see `BasicToggleButton.setSkinForState()`
		@see `BasicToggleButton.selected`

		@since 1.0.0
	**/
	@:style
	public var selectedBackgroundSkin:DisplayObject = null;

	private var _stateToSkin:Map<ToggleButtonState, DisplayObject> = new Map();

	/**
		Gets the skin to be used by the toggle button when its `currentState`
		property matches the specified state value.

		If a skin is not defined for a specific state, returns `null`.

		@see `BasicToggleButton.setSkinForState()`
		@see `BasicToggleButton.backgroundSkin`
		@see `BasicToggleButton.currentState`
		@see `feathers.controls.ToggleButtonState`

		@since 1.0.0
	**/
	public function getSkinForState(state:ToggleButtonState):DisplayObject {
		return this._stateToSkin.get(state);
	}

	/**
		Set the skin to be used by the toggle button when its `currentState`
		property matches the specified state value.

		If a skin is not defined for a specific state, the value of the
		`backgroundSkin` property will be used instead.

		@see `BasicToggleButton.getSkinForState()`
		@see `BasicToggleButton.backgroundSkin`
		@see `BasicToggleButton.currentState`
		@see `feathers.controls.ToggleButtonState`

		@since 1.0.0
	**/
	@style
	public function setSkinForState(state:ToggleButtonState, skin:DisplayObject):Void {
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
			this._pointerToState = new PointerToState(this, this.changeState, UP(false), DOWN(false), HOVER(false));
		}

		if (this._keyToState == null) {
			this._keyToState = new KeyToState(this, this.changeState, UP(false), DOWN(false));
		}

		if (this._pointerTrigger == null) {
			this._pointerTrigger = new PointerTrigger(this);
		}
	}

	override private function update():Void {
		var selectionInvalid = this.isInvalid(InvalidationFlag.SELECTION);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);

		if (selectionInvalid || stateInvalid || stylesInvalid) {
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
		if (this.selected && this.selectedBackgroundSkin != null) {
			return this.selectedBackgroundSkin;
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

	private function changeState(state:ToggleButtonState):Void {
		var toggleState = cast(state, ToggleButtonState);
		if (!this.enabled) {
			toggleState = DISABLED(this.selected);
		}
		switch (toggleState) {
			case UP(selected):
				if (this.selected != selected) {
					toggleState = UP(this.selected);
				}
			case DOWN(_):
				if (this.selected != selected) {
					toggleState = DOWN(this.selected);
				}
			case HOVER(_):
				if (this.selected != selected) {
					toggleState = HOVER(this.selected);
				}
			case DISABLED(_):
				if (this.selected != selected) {
					toggleState = DISABLED(this.selected);
				}
			default: // do nothing
		}
		if (this.currentState == toggleState) {
			return;
		}
		this.currentState = toggleState;
		this.setInvalid(InvalidationFlag.STATE);
		FeathersEvent.dispatch(this, FeathersEvent.STATE_CHANGE);
	}

	private function basicToggleButton_triggerHandler(event:TriggerEvent):Void {
		if (!this.enabled) {
			event.stopImmediatePropagation();
			return;
		}
		if (!this.toggleable) {
			return;
		}
		this.selected = !this.selected;
	}
}
