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
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.InteractiveObject;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.ui.Keyboard;
#if html5
import openfl.events.KeyboardEvent;
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
			this.root.removeEventListener(Event.ADDED_TO_STAGE, defaultFocusManager_root_addedToStageHandler);
			this.root.removeEventListener(Event.ADDED, defaultFocusManager_root_addedHandler);
			this.root.removeEventListener(Event.REMOVED, defaultFocusManager_root_removedHandler);
			this.root.removeEventListener(MouseEvent.MOUSE_DOWN, defaultFocusManager_root_mouseDownHandler);
			this.root.removeEventListener(Event.ACTIVATE, defaultFocusManager_root_activateHandler);
			var stage = this.root.stage;
			stage.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, defaultFocusManager_stage_mouseFocusChangeHandler);
			#if html5
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, defaultFocusManager_stage_keyDownHandler);
			#else
			stage.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, defaultFocusManager_stage_keyFocusChangeHandler);
			#end
		}
		this.root = value;
		if (this.root != null) {
			if (this.root.stage == null) {
				this.root.addEventListener(Event.ADDED_TO_STAGE, defaultFocusManager_root_addedToStageHandler, false, 0, true);
			} else {
				this.root.stage.stageFocusRect = false;
				if (this.root.stage.focus == null) {
					// needed for some targets, like Neko
					this.root.stage.focus = this.root.stage;
				}
			}
			this.setFocusManager(this.root);
			this.root.addEventListener(Event.ADDED, defaultFocusManager_root_addedHandler, false, 0, true);
			this.root.addEventListener(Event.REMOVED, defaultFocusManager_root_removedHandler, false, 0, true);
			this.root.addEventListener(MouseEvent.MOUSE_DOWN, defaultFocusManager_root_mouseDownHandler, false, 0, true);
			this.root.addEventListener(Event.ACTIVATE, defaultFocusManager_root_activateHandler, false, 0, true);
			var stage = this.root.stage;
			stage.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, defaultFocusManager_stage_mouseFocusChangeHandler, false, 0, true);
			#if html5
			stage.addEventListener(KeyboardEvent.KEY_DOWN, defaultFocusManager_stage_keyDownHandler, false, 0, true);
			#else
			stage.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, defaultFocusManager_stage_keyFocusChangeHandler, false, 0, true);
			#end
		}
		return this.root;
	}

	/**
		@see `feathers.core.IFocusManager.focusPane`
	**/
	public var focusPane(get, null):DisplayObjectContainer = null;

	private function get_focusPane():DisplayObjectContainer {
		if (this.focusPane == null) {
			this.focusPane = new Sprite();
			PopUpManager.forStage(this.root.stage).addPopUp(this.focusPane, false, false);
		}
		return this.focusPane;
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
			// in some cases, the stage focus seems to get cleared, so even
			// though our focus hasn't changed, we should still pass it to the
			// stage
			this.root.stage.focus = cast(value, InteractiveObject);
			return this.focus;
		}
		if (this.focus != null) {
			this.focus.showFocus(false);
		}
		this.focus = value;
		this.root.stage.focus = cast(value, InteractiveObject);
		return this.focus;
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
				if (this.focus == targetWithFocus) {
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

		if (fallbackToGlobal && container != this.root) {
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

		if (fallbackToGlobal && container != this.root) {
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

	private function defaultFocusManager_root_addedToStageHandler(event:Event):Void {
		this.root.stage.stageFocusRect = false;
		if (this.root.stage.focus == null) {
			// needed for some targets, like Neko
			this.root.stage.focus = this.root.stage;
		}
	}

	private function shouldBeManaged(target:DisplayObject):Bool {
		if (target == this.root) {
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
		if (container != null && container != this.root) {
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
		var textField = Std.downcast(event.relatedObject, TextField);
		if (textField != null && textField.type == INPUT) {
			// let OpenFL handle setting mouse focus on an input TextField
			// because it also sets the caret position and stuff
			return;
		}

		// for everything else, we'll handle focus changes in a pointer event
		event.preventDefault();
	}

	private function handleKeyboardFocusChange(event:Event, shiftKey:Bool):IFocusObject {
		var newFocus:IFocusObject = null;
		var currentFocus = this.focus;
		if (shiftKey) {
			if (currentFocus != null && currentFocus.parent != null) {
				newFocus = this.findPreviousContainerFocus(currentFocus.parent, cast(currentFocus, DisplayObject), true);
			}
			if (newFocus == null) {
				newFocus = this.findPreviousContainerFocus(this.root, null, false);
			}
		} else {
			if (currentFocus != null) {
				if (Std.is(currentFocus, IFocusContainer) && cast(currentFocus, IFocusContainer).childFocusEnabled) {
					newFocus = this.findNextContainerFocus(cast(currentFocus, DisplayObjectContainer), null, true);
				} else if (currentFocus.parent != null) {
					newFocus = this.findNextContainerFocus(currentFocus.parent, cast(currentFocus, DisplayObject), true);
				}
			}
			if (newFocus == null) {
				newFocus = this.findNextContainerFocus(this.root, null, false);
			}
		}
		this.focus = newFocus;
		if (this.focus != null) {
			this.focus.showFocus(true);
		}
		return newFocus;
	}

	#if html5
	private function defaultFocusManager_stage_keyDownHandler(event:KeyboardEvent):Void {
		if (event.keyCode != Keyboard.TAB) {
			return;
		}
		var newFocus = this.handleKeyboardFocusChange(event, event.shiftKey);
		if (newFocus != null) {
			event.preventDefault();
		}
	}
	#end

	#if !html5
	private function defaultFocusManager_stage_keyFocusChangeHandler(event:FocusEvent):Void {
		if (event.keyCode == Keyboard.UP || event.keyCode == Keyboard.DOWN || event.keyCode == Keyboard.LEFT || event.keyCode == Keyboard.RIGHT) {
			event.preventDefault();
			return;
		}
		if (event.keyCode != Keyboard.TAB && event.keyCode != 0) {
			return;
		}
		event.preventDefault();
		this.handleKeyboardFocusChange(event, event.shiftKey);
	}
	#end

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

	private function defaultFocusManager_root_activateHandler(event:Event):Void {
		if (this.focus != null) {
			this.root.stage.focus = cast(this.focus, InteractiveObject);
		}
	}
}
