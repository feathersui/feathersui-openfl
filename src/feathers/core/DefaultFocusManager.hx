/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.controls.supportClasses.IViewPort;
import feathers.core.IFocusContainer;
import feathers.core.IFocusManager;
import feathers.core.IFocusObject;
import feathers.core.IUIControl;
import feathers.events.FeathersEvent;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.InteractiveObject;
import openfl.display.Sprite;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.ui.Keyboard;
#if (html5 && openfl < "9.0.0")
import openfl.events.KeyboardEvent;
#else
import openfl.system.Capabilities;
#end

/**
	The default implementation of `IFocusManager`.

	@since 1.0.0
**/
class DefaultFocusManager implements IFocusManager {
	/**
		Creates a new `DefaultFocusManager` object with the given arguments.

		@since 1.0.0
	**/
	public function new(root:DisplayObject) {
		this.root = root;
	}

	private var _enabled = true;

	@:flash.property
	public var enabled(get, set):Bool;

	private function get_enabled():Bool {
		return this._enabled;
	}

	private function set_enabled(value:Bool):Bool {
		if (this._enabled == value) {
			return this._enabled;
		}
		if (value && this._root == null) {
			throw new IllegalOperationError("Cannot enable focus manager without a root container.");
		}
		this._enabled = value;
		if (this._focus != null && this._root.stage != null) {
			if (this._enabled) {
				this._focus.showFocus(true);
				this.setStageFocus(cast(this._focus, InteractiveObject));
			} else {
				this._focus.showFocus(false);
				if (this._root.stage.focus == cast(this._focus, InteractiveObject)) {
					this._root.stage.focus = null;
				}
			}
		}
		return this._enabled;
	}

	private var _root:DisplayObject = null;

	@:flash.property
	public var root(get, set):DisplayObject;

	private function get_root():DisplayObject {
		return this._root;
	}

	private function set_root(value:DisplayObject):DisplayObject {
		if (this._root == value) {
			return this._root;
		}
		if (this._root != null) {
			this.clearFocusManager(this._root);
			this._root.removeEventListener(Event.ADDED_TO_STAGE, defaultFocusManager_root_addedToStageHandler);
			this._root.removeEventListener(Event.REMOVED_FROM_STAGE, defaultFocusManager_root_removedFromStageHandler);
			this._root.removeEventListener(Event.ADDED, defaultFocusManager_root_addedHandler);
			this._root.removeEventListener(Event.REMOVED, defaultFocusManager_root_removedHandler);
			this._root.removeEventListener(MouseEvent.MOUSE_DOWN, defaultFocusManager_root_mouseDownHandler);
			this._root.removeEventListener(Event.ACTIVATE, defaultFocusManager_root_activateHandler);
			this._root.removeEventListener(Event.DEACTIVATE, defaultFocusManager_root_deactivateHandler);
			this.handleRootRemovedFromStage(this._root.stage);
		}
		this._root = value;
		if (this._root != null) {
			this.handleRootAddedToStage(this._root);
			this.setFocusManager(this._root);
			this._root.addEventListener(Event.ADDED_TO_STAGE, defaultFocusManager_root_addedToStageHandler, false, 0, true);
			this._root.addEventListener(Event.REMOVED_FROM_STAGE, defaultFocusManager_root_removedFromStageHandler, false, 0, true);
			this._root.addEventListener(Event.ADDED, defaultFocusManager_root_addedHandler, false, 0, true);
			this._root.addEventListener(Event.REMOVED, defaultFocusManager_root_removedHandler, false, 0, true);
			this._root.addEventListener(MouseEvent.MOUSE_DOWN, defaultFocusManager_root_mouseDownHandler, false, 0, true);
			this._root.addEventListener(Event.ACTIVATE, defaultFocusManager_root_activateHandler, false, 0, true);
			this._root.addEventListener(Event.DEACTIVATE, defaultFocusManager_root_deactivateHandler, false, 0, true);
		}
		return this._root;
	}

	private var _focusPane:DisplayObjectContainer = null;

	/**
		@see `feathers.core.IFocusManager.focusPane`
	**/
	@:flash.property
	public var focusPane(get, never):DisplayObjectContainer;

	private function get_focusPane():DisplayObjectContainer {
		if (this._focusPane == null) {
			this._focusPane = new Sprite();
			this._focusPane.mouseEnabled = false;
			this._focusPane.mouseChildren = false;
			this._focusPane.tabEnabled = false;
			this._focusPane.tabChildren = false;
			PopUpManager.forStage(this._root.stage).addPopUp(this._focusPane, false, false);
		}
		return this._focusPane;
	}

	private var _focus:IFocusObject = null;

	/**
		@see `feathers.core.IFocusManager.focus`
	**/
	@:flash.property
	public var focus(get, set):IFocusObject;

	private function get_focus():IFocusObject {
		return this._focus;
	}

	private function set_focus(value:IFocusObject):IFocusObject {
		if (this._focus == value) {
			if (this._enabled && this._root.stage != null) {
				// in some cases, the stage focus seems to get cleared, so even
				// though our focus hasn't changed, we should still pass it to the
				// stage
				this.setStageFocus(cast(value, InteractiveObject));
			}
			return this._focus;
		}
		if (this._focus != null) {
			if (Std.is(this._focus, IUIControl)) {
				this._focus.removeEventListener(FeathersEvent.DISABLE, defaultFocusManager_focus_disableHandler);
			}
			this._focus.showFocus(false);
		}
		this._focus = value;
		if (this._focus != null) {
			if (Std.is(this._focus, IUIControl)) {
				this._focus.addEventListener(FeathersEvent.DISABLE, defaultFocusManager_focus_disableHandler, false, 0, true);
			}
		}
		if (this._enabled && this._root.stage != null) {
			this.setStageFocus(cast(value, InteractiveObject));
		}
		return this._focus;
	}

	/**
		@see `feathers.core.IFocusManager.findNextFocus()`
	**/
	public function findNextFocus(backward:Bool = false):IFocusObject {
		var result = this.findNextFocusInternal(backward);
		return result.newFocus;
	}

	private function findNextFocusInternal(backward:Bool = false):FocusResult {
		var newFocus:IFocusObject = null;
		var wrapped = false;
		var currentFocus = this._focus;
		if (backward) {
			if (currentFocus != null && currentFocus.parent != null) {
				newFocus = this.findPreviousContainerFocus(currentFocus.parent, cast(currentFocus, DisplayObject), true);
			}
			if (newFocus == null && Std.is(this._root, DisplayObjectContainer)) {
				var rootContainer = cast(this._root, DisplayObjectContainer);
				newFocus = this.findPreviousContainerFocus(rootContainer, null, false);
				wrapped = currentFocus != null;
			}
		} else {
			if (currentFocus != null) {
				if (Std.is(currentFocus, IFocusContainer) && cast(currentFocus, IFocusContainer).childFocusEnabled) {
					newFocus = this.findNextContainerFocus(cast(currentFocus, DisplayObjectContainer), null, true);
				} else if (currentFocus.parent != null) {
					newFocus = this.findNextContainerFocus(currentFocus.parent, cast(currentFocus, DisplayObject), true);
				}
			}
			if (newFocus == null && Std.is(this._root, DisplayObjectContainer)) {
				var rootContainer = cast(this._root, DisplayObjectContainer);
				newFocus = this.findNextContainerFocus(rootContainer, null, false);
				wrapped = currentFocus != null;
			}
		}
		return new FocusResult(newFocus, wrapped);
	}

	private function isValidFocus(target:IFocusObject):Bool {
		if (target == null || target.focusManager != this) {
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
		if (Std.is(target, IFocusManagerAware)) {
			var targetWithFocus = cast(target, IFocusManagerAware);
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
				if (Std.is(container, IFocusExtras)) {
					var containerWithExtras = cast(container, IFocusExtras);
					var extras = containerWithExtras.focusExtrasBefore;
					if (extras != null) {
						for (child in extras) {
							this.setFocusManager(child);
						}
					}
					extras = containerWithExtras.focusExtrasAfter;
					if (extras != null) {
						for (child in extras) {
							this.setFocusManager(child);
						}
					}
				}
			}
		}
	}

	private function clearFocusManager(target:DisplayObject):Void {
		if (Std.is(target, IFocusObject)) {
			var targetWithFocus = cast(target, IFocusObject);
			if (targetWithFocus.focusManager == this) {
				if (this._focus == targetWithFocus) {
					this.focus = null;
				}
				targetWithFocus.focusManager = null;
			}
		}
		var container = Std.downcast(target, DisplayObjectContainer);
		if (container != null) {
			for (i in 0...container.numChildren) {
				var child = container.getChildAt(i);
				this.clearFocusManager(child);
			}
			if (Std.is(container, IFocusExtras)) {
				var containerWithExtras = cast(container, IFocusExtras);
				var extras = containerWithExtras.focusExtrasBefore;
				if (extras != null) {
					for (child in extras) {
						this.clearFocusManager(child);
					}
				}
				extras = containerWithExtras.focusExtrasAfter;
				if (extras != null) {
					for (child in extras) {
						this.clearFocusManager(child);
					}
				}
			}
		}
	}

	private function findPreviousContainerFocus(container:DisplayObjectContainer, beforeChild:DisplayObject, fallbackToGlobal:Bool):IFocusObject {
		if (Std.is(container, IViewPort) && !Std.is(container, IFocusContainer)) {
			container = container.parent;
		}
		var hasProcessedBeforeChild = beforeChild == null;
		if (Std.is(container, IFocusExtras)) {
			var focusWithExtras = cast(container, IFocusExtras);
			var extras = focusWithExtras.focusExtrasAfter;
			if (extras != null) {
				var skip = false;
				var startIndex = extras.length - 1;
				if (beforeChild != null) {
					startIndex = extras.indexOf(beforeChild) - 1;
					hasProcessedBeforeChild = startIndex >= -1;
					skip = !hasProcessedBeforeChild;
				}
				if (!skip) {
					var i = startIndex;
					while (i >= 0) {
						var child = extras[i];
						var foundChild = this.findPreviousChildFocus(child);
						if (foundChild != null) {
							return foundChild;
						}
						i--;
					}
				}
			}
		}
		var startIndex = container.numChildren - 1;
		if (beforeChild != null && !hasProcessedBeforeChild) {
			startIndex = container.getChildIndex(beforeChild) - 1;
			hasProcessedBeforeChild = startIndex >= -1;
		}

		var i = startIndex;
		while (i >= 0) {
			var child = container.getChildAt(i);
			var foundChild = this.findPreviousChildFocus(child);
			if (foundChild != null) {
				return foundChild;
			}
			i--;
		}
		if (Std.is(container, IFocusExtras)) {
			var focusWithExtras = cast(container, IFocusExtras);
			var extras = focusWithExtras.focusExtrasBefore;
			if (extras != null) {
				var skip = false;
				var startIndex = extras.length - 1;
				if (beforeChild != null && !hasProcessedBeforeChild) {
					startIndex = extras.indexOf(beforeChild) - 1;
					hasProcessedBeforeChild = startIndex >= -1;
					skip = !hasProcessedBeforeChild;
				}
				if (!skip) {
					var i = startIndex;
					while (i >= 0) {
						var child = extras[i];
						var foundChild = this.findPreviousChildFocus(child);
						if (foundChild != null) {
							return foundChild;
						}
						i--;
					}
				}
			}
		}

		if (fallbackToGlobal && container != this._root) {
			// try the container itself before moving backwards
			if (Std.is(container, IFocusObject)) {
				var focusContainer = cast(container, IFocusObject);
				if (this.isValidFocus(focusContainer)) {
					return focusContainer;
				}
			}
			return this.findPreviousContainerFocus(container.parent, container, true);
		}
		return null;
	}

	private function findNextContainerFocus(container:DisplayObjectContainer, afterChild:DisplayObject, fallbackToGlobal:Bool):IFocusObject {
		if (Std.is(container, IViewPort) && !Std.is(container, IFocusContainer)) {
			container = container.parent;
		}
		var hasProcessedAfterChild = afterChild == null;
		if (Std.is(container, IFocusExtras)) {
			var focusWithExtras = cast(container, IFocusExtras);
			var extras = focusWithExtras.focusExtrasBefore;
			if (extras != null) {
				var skip = false;
				var startIndex = 0;
				if (afterChild != null) {
					startIndex = extras.indexOf(afterChild) + 1;
					hasProcessedAfterChild = startIndex > 0;
					skip = !hasProcessedAfterChild;
				}
				if (!skip) {
					for (i in startIndex...extras.length) {
						var child = extras[i];
						var foundChild = this.findNextChildFocus(child);
						if (foundChild != null) {
							return foundChild;
						}
					}
				}
			}
		}
		var startIndex = 0;
		if (afterChild != null && !hasProcessedAfterChild) {
			startIndex = container.getChildIndex(afterChild) + 1;
			hasProcessedAfterChild = startIndex > 0;
		}
		for (i in startIndex...container.numChildren) {
			var child = container.getChildAt(i);
			var foundChild = this.findNextChildFocus(child);
			if (foundChild != null) {
				return foundChild;
			}
		}
		if (Std.is(container, IFocusExtras)) {
			var focusWithExtras = cast(container, IFocusExtras);
			var extras = focusWithExtras.focusExtrasAfter;
			if (extras != null) {
				var skip = false;
				var startIndex = 0;
				if (afterChild != null && !hasProcessedAfterChild) {
					startIndex = extras.indexOf(afterChild) + 1;
					hasProcessedAfterChild = startIndex > 0;
					skip = !hasProcessedAfterChild;
				}
				if (!skip) {
					for (i in startIndex...extras.length) {
						var child = extras[i];
						var foundChild = this.findNextChildFocus(child);
						if (foundChild != null) {
							return foundChild;
						}
					}
				}
			}
		}

		if (fallbackToGlobal && container != this._root) {
			var foundChild = this.findNextContainerFocus(container.parent, container, true);
			if (foundChild != null) {
				return foundChild;
			}
		}
		return null;
	}

	private function findPreviousChildFocus(child:DisplayObject):IFocusObject {
		var childContainer = Std.downcast(child, DisplayObjectContainer);
		if (childContainer != null) {
			var findPrevChildContainer = !Std.is(childContainer, IFocusObject);
			if (!findPrevChildContainer && Std.is(childContainer, IFocusContainer)) {
				var focusContainer = cast(childContainer, IFocusContainer);
				findPrevChildContainer = focusContainer.childFocusEnabled;
			}
			if (findPrevChildContainer) {
				var foundChild = this.findPreviousContainerFocus(childContainer, null, false);
				if (foundChild != null) {
					return foundChild;
				}
			}
		}
		if (Std.is(child, IFocusObject)) {
			var childWithFocus = cast(child, IFocusObject);
			if (this.isValidFocus(childWithFocus)) {
				return childWithFocus;
			}
		}
		return null;
	}

	private function findNextChildFocus(child:DisplayObject):IFocusObject {
		if (Std.is(child, IFocusObject)) {
			var childWithFocus = cast(child, IFocusObject);
			if (this.isValidFocus(childWithFocus)) {
				return childWithFocus;
			}
		}
		var childContainer = Std.downcast(child, DisplayObjectContainer);
		if (childContainer != null) {
			var findNextChildContainer = !Std.is(childContainer, IFocusObject);
			if (!findNextChildContainer && Std.is(childContainer, IFocusContainer)) {
				var focusContainer = cast(childContainer, IFocusContainer);
				findNextChildContainer = focusContainer.childFocusEnabled;
			}
			if (findNextChildContainer) {
				var foundChild = this.findNextContainerFocus(childContainer, null, false);
				if (foundChild != null) {
					return foundChild;
				}
			}
		}
		return null;
	}

	private function setStageFocus(value:InteractiveObject):Void {
		if (Std.is(value, IStageFocusDelegate)) {
			var newFocusTarget = cast(value, IStageFocusDelegate).stageFocusTarget;
			if (newFocusTarget != null) {
				value = newFocusTarget;
			}
		}
		this._root.stage.focus = value;
	}

	private function handleRootAddedToStage(root:DisplayObject):Void {
		var stage = this.root.stage;
		if (stage == null) {
			return;
		}
		stage.stageFocusRect = false;
		if (this._enabled && stage.focus == null) {
			// needed for some targets, like Neko
			stage.focus = stage;
		}
		stage.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, defaultFocusManager_stage_mouseFocusChangeHandler, false, 0, true);
		#if (html5 && openfl < "9.0.0")
		stage.addEventListener(KeyboardEvent.KEY_DOWN, defaultFocusManager_stage_keyDownHandler, false, 0, true);
		#else
		stage.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, defaultFocusManager_stage_keyFocusChangeHandler, false, 0, true);
		#end
	}

	private function handleRootRemovedFromStage(root:DisplayObject):Void {
		this.focus = null;
		var stage = this.root.stage;
		if (stage == null) {
			return;
		}
		stage.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, defaultFocusManager_stage_mouseFocusChangeHandler);
		#if (html5 && openfl < "9.0.0")
		stage.removeEventListener(KeyboardEvent.KEY_DOWN, defaultFocusManager_stage_keyDownHandler);
		#else
		stage.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, defaultFocusManager_stage_keyFocusChangeHandler);
		#end
	}

	private function defaultFocusManager_root_addedToStageHandler(event:Event):Void {
		this.handleRootAddedToStage(cast(event.currentTarget, DisplayObjectContainer));
	}

	private function defaultFocusManager_root_removedFromStageHandler(event:Event):Void {
		this.handleRootRemovedFromStage(cast(event.currentTarget, DisplayObjectContainer));
	}

	private function shouldBeManaged(target:DisplayObject):Bool {
		if (target == this._root) {
			return true;
		}
		var container = target.parent;
		if (Std.is(container, IViewPort) && !Std.is(container, IFocusContainer)) {
			container = container.parent;
		}
		var valid = false;
		try {
			valid = container.getChildIndex(target) != -1;
		} catch (e:Dynamic) {
			// throws on some targets
		}
		if (!valid && Std.is(container, IFocusExtras)) {
			var container = cast(container, IFocusExtras);
			if (container.focusExtrasBefore != null) {
				for (child in container.focusExtrasBefore) {
					if (child == target) {
						valid = true;
						break;
					}
					if (Std.is(child, DisplayObjectContainer)) {
						valid = cast(child, DisplayObjectContainer).contains(child);
						if (valid) {
							break;
						}
					}
				}
			}
			if (!valid && container.focusExtrasAfter != null) {
				for (child in container.focusExtrasAfter) {
					if (child == target) {
						valid = true;
						break;
					}
					if (Std.is(child, DisplayObjectContainer)) {
						valid = cast(child, DisplayObjectContainer).contains(child);
						if (valid) {
							break;
						}
					}
				}
			}
		}
		if (!valid) {
			return false;
		}
		if (container != null && container != this._root) {
			return this.shouldBeManaged(container);
		}
		return true;
	}

	private function defaultFocusManager_root_addedHandler(event:Event):Void {
		var target = cast(event.target, DisplayObject);
		var valid = this.shouldBeManaged(target);
		if (!valid) {
			return;
		}
		this.setFocusManager(target);
	}

	private function defaultFocusManager_root_removedHandler(event:Event):Void {
		var target = cast(event.target, DisplayObject);
		this.clearFocusManager(target);
	}

	private function defaultFocusManager_stage_mouseFocusChangeHandler(event:FocusEvent):Void {
		if (!this._enabled) {
			return;
		}
		var textField = Std.downcast(event.relatedObject, TextField);
		if (textField != null && textField.type == INPUT) {
			// let OpenFL handle setting mouse focus on an input TextField
			// because it also sets the caret position and stuff
			return;
		}

		// for everything else, we'll handle focus changes in a pointer event
		event.preventDefault();
	}

	#if (html5 && openfl < "9.0.0")
	private function defaultFocusManager_stage_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (event.keyCode != Keyboard.TAB) {
			return;
		}
		var result = this.findNextFocusInternal(event.shiftKey);
		this.focus = result.newFocus;
		if (this._focus != null) {
			this._focus.showFocus(true);
			event.preventDefault();
		}
	}
	#else
	private function defaultFocusManager_stage_keyFocusChangeHandler(event:FocusEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (event.keyCode == Keyboard.UP || event.keyCode == Keyboard.DOWN || event.keyCode == Keyboard.LEFT || event.keyCode == Keyboard.RIGHT) {
			event.preventDefault();
			return;
		}
		if (event.keyCode != Keyboard.TAB && event.keyCode != 0) {
			return;
		}
		var result = this.findNextFocusInternal(event.shiftKey);
		this.focus = result.newFocus;
		if (result.wrapped) {
			var skipWrap = Capabilities.playerType != "StandAlone" && Capabilities.playerType != "Desktop";
			if (skipWrap) {
				return;
			}
		}
		if (this._focus != null) {
			this._focus.showFocus(true);
			event.preventDefault();
		}
	}
	#end

	private function defaultFocusManager_root_mouseDownHandler(event:MouseEvent):Void {
		if (!this._enabled) {
			return;
		}
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

	private function defaultFocusManager_root_activateHandler(event:Event):Void {
		if (!this._enabled) {
			return;
		}
		if (this._focus != null && this._root.stage != null) {
			if (this.isValidFocus(this._focus)) {
				this.setStageFocus(cast(this._focus, InteractiveObject));
				this._focus.showFocus(true);
			} else {
				// if it's no longer valid focus, for some reason, clear it
				this.focus = null;
			}
		}
	}

	private function defaultFocusManager_root_deactivateHandler(event:Event):Void {
		if (!this._enabled) {
			return;
		}
		if (this._focus != null) {
			this._focus.showFocus(false);
		}
	}

	private function defaultFocusManager_focus_disableHandler(event:Event):Void {
		// clear the focus, if it becomes disabled
		this.focus = null;
	}
}

private class FocusResult {
	public function new(newFocus:IFocusObject, wrapped:Bool) {
		this.newFocus = newFocus;
		this.wrapped = wrapped;
	}

	public var newFocus:IFocusObject;
	public var wrapped:Bool;
}
