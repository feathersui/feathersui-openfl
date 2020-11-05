/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.utils.PointerToState;
import feathers.core.IStateContext;
import openfl.events.Event;
import feathers.events.FeathersEvent;
import feathers.core.IPointerDelegate;
import feathers.layout.ILayoutIndexObject;
import feathers.themes.steel.components.SteelLayoutGroupItemRendererStyles;
import openfl.display.DisplayObject;
import openfl.display.InteractiveObject;

/**
	A generic renderer with support for layout that may support any number of
	children. Designed to be used by UI components that display data
	collections, such as `ListView`.

	@see [Tutorial: How to use the LayoutGroupItemRenderer component](https://feathersui.com/learn/haxe-openfl/layout-group-item-renderer/)

	@since 1.0.0
**/
@:styleContext
class LayoutGroupItemRenderer extends LayoutGroup implements IStateContext<ToggleButtonState> implements ILayoutIndexObject implements IDataRenderer
		implements IToggle implements IPointerDelegate {
	/**
		Creates a new `LayoutGroupItemRenderer` object.

		@since 1.0.0
	**/
	public function new() {
		initializeLayoutGroupItemRendererTheme();

		super();
	}

	private var _data:Dynamic;

	/**
		@see `feathers.controls.dataRenderers.IDataRenderer.data`
	**/
	@:flash.property
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return this._data;
	}

	private function set_data(value:Dynamic):Dynamic {
		if (this._data == value) {
			return this._data;
		}
		this._data = value;
		this.setInvalid(DATA);
		return this._data;
	}

	private var _currentState:ToggleButtonState = UP(false);

	/**
		The current state of the item renderer.

		When the value of the `currentState` property changes, the item renderer
		will dispatch an event of type `FeathersEvent.STATE_CHANGE`.

		@see `feathers.controls.ToggleButtonState`
		@see `feathers.events.FeathersEvent.STATE_CHANGE`

		@since 1.0.0
	**/
	@:flash.property
	public var currentState(get, never):#if flash Dynamic #else ToggleButtonState #end;

	private function get_currentState():#if flash Dynamic #else ToggleButtonState #end {
		return this._currentState;
	}

	private var _layoutIndex:Int = -1;

	/**
		@see `feathers.layout.ILayoutIndexObject.layoutIndex`
	**/
	@:flash.property
	public var layoutIndex(get, set):Int;

	private function get_layoutIndex():Int {
		return this._layoutIndex;
	}

	private function set_layoutIndex(value:Int):Int {
		if (this._layoutIndex == value) {
			return this._layoutIndex;
		}
		this._layoutIndex = value;
		this.setInvalid(DATA);
		this.setInvalid(STYLES);
		return this._layoutIndex;
	}

	private var _selected:Bool = false;

	/**
		@see `feathers.core.IToggle.selected`
	**/
	@:flash.property
	public var selected(get, set):Bool;

	private function get_selected():Bool {
		return this._selected;
	}

	private function set_selected(value:Bool):Bool {
		if (this._selected == value) {
			return this._selected;
		}
		this._selected = value;
		this.setInvalid(DATA);
		this.setInvalid(STYLES);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._selected;
	}

	private var _pointerTarget:InteractiveObject;

	/**
		@see `feathers.core.IPointerDelegate.pointerTarget`
	**/
	@:flash.property
	public var pointerTarget(get, set):InteractiveObject;

	private function get_pointerTarget():InteractiveObject {
		return this._pointerTarget;
	}

	private function set_pointerTarget(value:InteractiveObject):InteractiveObject {
		if (this._pointerTarget == value) {
			return this._pointerTarget;
		}
		this._pointerTarget = value;
		this.setInvalid(DATA);
		return this._pointerTarget;
	}

	private var _pointerToState:PointerToState<ToggleButtonState> = null;

	/**
		The default background skin to display behind all content added to the
		group. The background skin is resized to fill the complete width and
		height of the group.

		The following example gives the group a selected background skin:

		```hx
		group.selectedBackgroundSkin = new Bitmap(bitmapData);
		group.selected = true;
		```

		@default null

		@see `LayoutGroup.backgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var selectedBackgroundSkin:DisplayObject = null;

	private var _stateToSkin:Map<ToggleButtonState, DisplayObject> = new Map();

	/**
		Gets the skin to be used by the itenm renderer when its `currentState`
		property matches the specified state value.

		If a skin is not defined for a specific state, returns `null`.

		@see `LayoutGroupItemRenderer.setSkinForState()`
		@see `LayoutGroupItemRenderer.backgroundSkin`
		@see `LayoutGroupItemRenderer.currentState`
		@see `feathers.controls.ToggleButtonState`

		@since 1.0.0
	**/
	public function getSkinForState(state:ToggleButtonState):DisplayObject {
		return this._stateToSkin.get(state);
	}

	/**
		Set the skin to be used by the item renderer when its `currentState`
		property matches the specified state value.

		If a skin is not defined for a specific state, the value of the
		`backgroundSkin` property will be used instead.

		@see `LayoutGroupItemRenderer.getSkinForState()`
		@see `LayoutGroupItemRenderer.backgroundSkin`
		@see `LayoutGroupItemRenderer.currentState`
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
		this.setInvalid(STYLES);
	}

	private function initializeLayoutGroupItemRendererTheme():Void {
		SteelLayoutGroupItemRendererStyles.initialize();
	}

	override private function initialize():Void {
		super.initialize();

		if (this._pointerToState == null) {
			this._pointerToState = new PointerToState(this, this.changeState, UP(false), DOWN(false), HOVER(false));
		}
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);

		if (dataInvalid) {
			this._pointerToState.target = (this._pointerTarget != null) ? this._pointerTarget : this;
		}

		super.update();
	}

	private function changeState(state:ToggleButtonState):Void {
		var toggleState = cast(state, ToggleButtonState);
		if (!this._enabled) {
			toggleState = DISABLED(this._selected);
		}
		switch (toggleState) {
			case UP(selected):
				if (this._selected != selected) {
					toggleState = UP(this._selected);
				}
			case DOWN(selected):
				if (this._selected != selected) {
					toggleState = DOWN(this._selected);
				}
			case HOVER(selected):
				if (this._selected != selected) {
					toggleState = HOVER(this._selected);
				}
			case DISABLED(selected):
				if (this._selected != selected) {
					toggleState = DISABLED(this._selected);
				}
			default: // do nothing
		}
		if (this._currentState == toggleState) {
			return;
		}
		this._currentState = toggleState;
		this.setInvalid(STATE);
		FeathersEvent.dispatch(this, FeathersEvent.STATE_CHANGE);
	}

	override private function getCurrentBackgroundSkin():DisplayObject {
		var result = this._stateToSkin.get(this._currentState);
		if (result != null) {
			return result;
		}
		if (!this._enabled && this.disabledBackgroundSkin != null) {
			return this.disabledBackgroundSkin;
		}
		if (this._selected && this.selectedBackgroundSkin != null) {
			return this.selectedBackgroundSkin;
		}
		return this.backgroundSkin;
	}
}
