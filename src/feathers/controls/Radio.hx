/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.IFocusObject;
import feathers.core.ToggleGroup;
import openfl.display.InteractiveObject;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

/**
	A selectable control that may be toggled on and off and exists in a group
	that requires a single, exclusive toggled item.

	In the following example, a set of radios are created, along with a
	`ToggleGroup` to group them together:

	```haxe
	var group = new ToggleGroup();
	group.addEventListener(Event.CHANGE, group_changeHandler);

	var radio1 = new Radio();
	radio1.text = "One";
	radio1.toggleGroup = group;
	this.addChild(radio1);

	var radio2 = new Radio();
	radio2.text = "Two";
	radio2.toggleGroup = group;
	this.addChild(radio2);

	var radio3 = new Radio();
	radio3.text = "Three";
	radio3.toggleGroup = group;
	this.addChild(radio3);
	```

	@see [Tutorial: How to use the Radio component](https://feathersui.com/learn/haxe-openfl/radio/)
	@see `feathers.core.ToggleGroup`

	@since 1.0.0
**/
@:styleContext
class Radio extends ToggleButton implements IGroupedToggle {
	/**
		The default `ToggleGroup` that radios are added to when they are not
		added to any other group.

		@see `Radio.toggleGroup`

		@since 1.0.0
	**/
	public static final defaultRadioGroup:ToggleGroup = new ToggleGroup();

	/**
		Creates a new `Radio` object.

		@since 1.0.0
	**/
	public function new(?text:String, selected:Bool = false, ?changeListener:(Event) -> Void) {
		initializeRadioTheme();

		super(text, selected);

		super.toggleable = true;

		this.addEventListener(Event.ADDED_TO_STAGE, radio_addedToStageHandler);
		this.addEventListener(KeyboardEvent.KEY_DOWN, radio_keyDownHandler);

		if (changeListener != null) {
			this.addEventListener(Event.CHANGE, changeListener);
		}
	}

	override private function set_toggleable(value:Bool):Bool {
		throw new IllegalOperationError("Radio toggleable must always be true");
	}

	private var _toggleGroup:ToggleGroup = null;

	/**
		The `ToggleGroup` that this radio has been added to, or `null` if the
		radio has not been added to a group.

		@see `Radio.defaultRadioGroup`

		@since 1.0.0
	**/
	public var toggleGroup(get, set):ToggleGroup;

	private function get_toggleGroup():ToggleGroup {
		return this._toggleGroup;
	}

	private function set_toggleGroup(value:ToggleGroup):ToggleGroup {
		if (this._toggleGroup == value) {
			return this._toggleGroup;
		}
		// a null toggle group will automatically add it to
		// defaultRadioGroup. however, if toggleGroup is already
		// defaultRadioGroup, then we really want to use null because
		// otherwise we'd remove the radio from defaultRadioGroup and then
		// immediately add it back because ToggleGroup sets the toggleGroup
		// property to null when removing an item.
		if (value == null && this._toggleGroup != defaultRadioGroup && this.stage != null) {
			value = defaultRadioGroup;
		}
		if (this._toggleGroup != null && this._toggleGroup.hasItem(this)) {
			this._toggleGroup.removeItem(this);
		}
		this._toggleGroup = value;
		if (this._toggleGroup != null && !this._toggleGroup.hasItem(this)) {
			this._toggleGroup.addItem(this);
		}
		return this._toggleGroup;
	}

	override public function dispose():Void {
		this.toggleGroup = null;
		super.dispose();
	}

	private function initializeRadioTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelRadioStyles.initialize();
		#end
	}

	private function navigateWithKeyboard(event:KeyboardEvent):Void {
		if (event.isDefaultPrevented()) {
			return;
		}
		if (this._toggleGroup == null) {
			return;
		}
		if (event.keyLocation == 4 /* KeyLocation.D_PAD */) {
			// if the the key press originated on the d-pad, ignore it
			// the focus manager will handle it instead
			return;
		}
		var startIndex = this._toggleGroup.getItemIndex(this);
		if (startIndex == -1) {
			return;
		}
		var result = startIndex;
		var needsAnotherPass = true;
		var lastResult = -1;
		while (needsAnotherPass) {
			needsAnotherPass = false;
			switch (event.keyCode) {
				case Keyboard.UP:
					result = result - 1;
				case Keyboard.DOWN:
					result = result + 1;
				case Keyboard.LEFT:
					result = result - 1;
				case Keyboard.RIGHT:
					result = result + 1;
				default:
					// not keyboard navigation
					return;
			}
			if (result < 0) {
				result = 0;
			} else if (result >= this._toggleGroup.numItems) {
				result = this._toggleGroup.numItems - 1;
			}
			var nextItem = this._toggleGroup.getItemAt(result);
			if (!nextItem.enabled) {
				// keep going until we reach a non-branch
				if (result == lastResult) {
					// but don't keep trying if we got the same result more than
					// once because it means that we got stuck
					return;
				}
				needsAnotherPass = true;
			}
			lastResult = result;
		}
		event.preventDefault();
		this._toggleGroup.selectedIndex = result;
		var nextFocus = cast(this._toggleGroup.selectedItem, IFocusObject);
		if (this._focusManager != null) {
			this._focusManager.focus = nextFocus;
			nextFocus.showFocus(true);
		} else {
			this.stage.focus = cast(nextFocus, InteractiveObject);
		}
	}

	private function radio_addedToStageHandler(event:Event):Void {
		if (this._toggleGroup == null) {
			// use the setter
			this.toggleGroup = defaultRadioGroup;
		}
		this.addEventListener(Event.REMOVED_FROM_STAGE, radio_removedFromStageHandler);
	}

	private function radio_removedFromStageHandler(event:Event):Void {
		this.removeEventListener(Event.REMOVED_FROM_STAGE, radio_removedFromStageHandler);
		if (this._toggleGroup == defaultRadioGroup) {
			this._toggleGroup.removeItem(this);
		}
	}

	private function radio_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._enabled) {
			return;
		}
		this.navigateWithKeyboard(event);
	}
}
