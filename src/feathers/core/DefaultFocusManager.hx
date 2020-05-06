/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.core.IFocusContainer;
import feathers.core.IFocusManager;
import feathers.core.IFocusObject;
import feathers.core.IUIControl;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.InteractiveObject;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.MouseEvent;
import openfl.text.TextField;

/**
	The default implementation of `IFocusManager`.

	@since 1.0.0
**/
class DefaultFocusManager implements IFocusManager {
	/**
		Creates a new `DefaultFocusManager` object with the given arguments.

		@since 1.0.0
	**/
	public function new(root:DisplayObjectContainer) {
		this.root = root;
	}

	public var root(default, set):DisplayObjectContainer;

	private function set_root(value:DisplayObjectContainer):DisplayObjectContainer {
		if (this.root == value) {
			return this.root;
		}
		if (this.root != null) {
			this.clearFocusManager(this.root);
			this.root.removeEventListener(Event.ADDED, defaultFocusManager_root_addedHandler);
			this.root.removeEventListener(Event.REMOVED, defaultFocusManager_root_removedHandler);
			this.root.removeEventListener(MouseEvent.MOUSE_DOWN, defaultFocusManager_root_mouseDownHandler);
			this.root.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, defaultFocusManager_root_mouseFocusChangeHandler);
		}
		this.root = value;
		if (this.root != null) {
			this.setFocusManager(this.root);
			this.root.addEventListener(Event.ADDED, defaultFocusManager_root_addedHandler, false, 0, true);
			this.root.addEventListener(Event.REMOVED, defaultFocusManager_root_removedHandler, false, 0, true);
			this.root.addEventListener(MouseEvent.MOUSE_DOWN, defaultFocusManager_root_mouseDownHandler, false, 0, true);
			this.root.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, defaultFocusManager_root_mouseFocusChangeHandler, false, 0, true);
		}
		return this.root;
	}

	/**
		@see `feathers.core.IFocusManager.focus`
	**/
	@:isVar
	public var focus(get, set):IFocusObject = null;

	private function get_focus():IFocusObject {
		return this.focus;
	}

	private function set_focus(value:IFocusObject):IFocusObject {
		if (this.focus == value) {
			return this.focus;
		}
		this.focus = value;
		this.root.stage.focus = cast(value, InteractiveObject);
		return this.focus;
	}

	private function isValidFocus(target:IFocusObject):Bool {
		if (target == null) // || target.focusManager !== this)
		{
			return false;
		}
		if (!target.focusEnabled) {
			return false;
			/*if (child.focusOwner == null || !this.isValidFocus(child.focusOwner)) {
				return false;
			}*/
		}
		if (Std.is(target, IUIControl)) {
			var uiTarget = cast(target, IUIControl);
			if (!uiTarget.enabled) {
				return false;
			}
		}
		return true;
	}

	private function setFocusManager(target:DisplayObject):Void {
		if (Std.is(target, IFocusObject)) {
			var targetWithFocus = cast(target, IFocusObject);
			targetWithFocus.focusManager = this;
		}
		var container = Std.downcast(target, DisplayObjectContainer);
		if (container != null) {
			var setChildrenFocusManager = !Std.is(target, IFocusObject);
			if (!setChildrenFocusManager && Std.is(target, IFocusContainer)) {
				var focusContainer = cast(target, IFocusContainer);
				setChildrenFocusManager = focusContainer.childFocusEnabled;
			}
			if (setChildrenFocusManager) {
				for (i in 0...container.numChildren) {
					var child = container.getChildAt(i);
					this.setFocusManager(child);
				}
			}
		}
	}

	private function clearFocusManager(target:DisplayObject):Void {
		if (Std.is(target, IFocusObject)) {
			var targetWithFocus = cast(target, IFocusObject);
			if (targetWithFocus.focusManager == this) {
				targetWithFocus.focusManager = null;
			}
		}
		var container = Std.downcast(target, DisplayObjectContainer);
		if (container != null) {
			for (i in 0...container.numChildren) {
				var child = container.getChildAt(i);
				this.clearFocusManager(child);
			}
		}
	}

	private function defaultFocusManager_root_addedHandler(event:Event):Void {
		var target = cast(event.target, DisplayObject);
		this.setFocusManager(target);
	}

	private function defaultFocusManager_root_removedHandler(event:Event):Void {
		var target = cast(event.target, DisplayObject);
		this.clearFocusManager(target);
	}

	private function defaultFocusManager_root_mouseFocusChangeHandler(event:FocusEvent):Void {
		var textField = Std.downcast(event.relatedObject, TextField);
		if (textField != null && textField.type == INPUT) {
			// let OpenFL handle setting mouse focus on an input TextField
			// because it also sets the caret position and stuff
			return;
		}

		// for everything else, we'll handle focus changes in a pointer event
		event.preventDefault();
	}

	private function defaultFocusManager_root_mouseDownHandler(event:MouseEvent):Void {
		var focusTarget:IFocusObject = null;
		var target = cast(event.target, DisplayObject);
		do {
			if (Std.is(target, IFocusObject)) {
				var tempFocusTarget = cast(target, IFocusObject);
				if (this.isValidFocus(tempFocusTarget)) {
					if (focusTarget == null
						|| !Std.is(tempFocusTarget, IFocusContainer)
						|| !cast(tempFocusTarget, IFocusContainer).childFocusEnabled) {
						focusTarget = tempFocusTarget;
					}
				}
			}
			target = target.parent;
		} while (target != null);
		this.focus = focusTarget;
	}
}
