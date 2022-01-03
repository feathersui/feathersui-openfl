/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.controls.IGroupedToggle;
import feathers.controls.supportClasses.IViewPort;
import feathers.core.IFocusContainer;
import feathers.core.IFocusManager;
import feathers.core.IFocusObject;
import feathers.core.IUIControl;
import feathers.events.FeathersEvent;
import feathers.layout.RelativePosition;
import feathers.utils.DPadFocusUtil;
import feathers.utils.FocusUtil;
import feathers.utils.PopUpUtil;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.InteractiveObject;
import openfl.display.Sprite;
import openfl.errors.ArgumentError;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.ui.Keyboard;
#if (!html5 || openfl >= "9.0.0")
import openfl.system.Capabilities;
#end

/**
	The default implementation of `IFocusManager`.

	@event openfl.events.Event.CLEAR Dispatched when the focus manager is disposed.

	@since 1.0.0
**/
@:event(openfl.events.Event.CLEAR)
class DefaultFocusManager extends EventDispatcher implements IFocusManager {
	private static final WRAP_OBJECT_HIGH_TAB_INDEX = 0x7FFFFFFF;

	/**
		Creates a new `DefaultFocusManager` object with the given arguments.

		@since 1.0.0
	**/
	public function new(root:DisplayObject) {
		super();
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
		if (this._root.stage != null) {
			if (this._enabled) {
				this.restoreFocus();
			} else {
				this.focus = null;
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
			this._root.removeEventListener(MouseEvent.MOUSE_DOWN, defaultFocusManager_root_mouseDownCaptureHandler, true);
			this._root.removeEventListener(FocusEvent.FOCUS_IN, defaultFocusManager_root_focusInCaptureHandler, true);
			this._root.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, defaultFocusManager_root_mouseFocusChangeHandler);
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
			this._root.addEventListener(MouseEvent.MOUSE_DOWN, defaultFocusManager_root_mouseDownCaptureHandler, true, 0, true);
			this._root.addEventListener(FocusEvent.FOCUS_IN, defaultFocusManager_root_focusInCaptureHandler, true, 0, true);
			this._root.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, defaultFocusManager_root_mouseFocusChangeHandler, false, 0, true);
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

	private var _showFocusIndicator:Bool = false;

	/**
		@see `feathers.core.IFocusManager.showFocusIndicator`
	**/
	@:flash.property
	public var showFocusIndicator(get, never):Bool;

	private function get_showFocusIndicator():Bool {
		return this._showFocusIndicator;
	}

	private var _focusToRestore:IFocusObject;

	/**
		@see `feathers.core.IFocusManager.focus`
	**/
	@:flash.property
	public var focus(get, set):IFocusObject;

	private function get_focus():IFocusObject {
		if (this._root.stage == null) {
			return null;
		}
		return this.findFocusForDisplayObject(this._root.stage.focus);
	}

	private function set_focus(value:IFocusObject):IFocusObject {
		var oldFocus = this.findFocusForDisplayObject(this._root.stage.focus);
		if (oldFocus == value) {
			if (this._enabled && this._root.stage != null) {
				// in some cases, the stage focus seems to get cleared, so even
				// though our focus hasn't changed, we should still pass it to the
				// stage
				this.setStageFocus(cast(value, InteractiveObject));
			}
			return this.focus;
		}
		if (value != null && value.focusManager != this) {
			throw new ArgumentError("Failed to change focus. Object is not managed by this focus manager: " + value);
		}
		if (this._enabled && this._root.stage != null) {
			this.setStageFocus(cast(value, InteractiveObject));
		}
		return this.focus;
	}

	private var _wrapObject:InteractiveObject;

	/**
		@see `feathers.core.IFocusManager.dispose()`
	**/
	public function dispose():Void {
		if (this.focus != null) {
			this.focus = null;
		}
		if (this._focusPane != null) {
			if (this._focusPane.parent != null) {
				this._focusPane.parent.removeChild(this._focusPane);
			}
			this._focusPane = null;
		}
		var savedRoot = this._root;
		this.root = null;
		// temporarily put the root back (without calling the setter) so that it
		// is accessible in event listeners. we'll set it back to null after
		this._root = savedRoot;
		FeathersEvent.dispatch(this, Event.CLEAR);
		// okay, now clear _root for real
		this._root = null;
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
		var currentFocus = this.focus;
		if (currentFocus != null && currentFocus.focusOwner != null) {
			var focusOwner = currentFocus.focusOwner;
			if (focusOwner != null && focusOwner.focusManager != this) {
				focusOwner = null;
			}
			if (focusOwner != null) {
				newFocus = focusOwner;
			}
		} else if (backward) {
			if (currentFocus != null && currentFocus.parent != null) {
				newFocus = this.findPreviousContainerFocus(currentFocus.parent, cast(currentFocus, DisplayObject), true);
			}
			if (newFocus == null) {
				newFocus = this.findPreviousChildFocus(this._root);
				wrapped = currentFocus != null;
			}
		} else {
			if (currentFocus != null) {
				if ((currentFocus is IFocusContainer) && cast(currentFocus, IFocusContainer).childFocusEnabled) {
					newFocus = this.findNextContainerFocus(cast(currentFocus, DisplayObjectContainer), null, true);
				} else if (currentFocus.parent != null) {
					newFocus = this.findNextContainerFocus(currentFocus.parent, cast(currentFocus, DisplayObject), true);
				}
			}
			if (newFocus == null) {
				newFocus = this.findNextChildFocus(this._root);
				wrapped = currentFocus != null;
			}
		}
		return new FocusResult(newFocus, wrapped);
	}

	private function findNextRelativeFocusInternal(keyCode:Int):FocusResult {
		var relativePosition = switch (keyCode) {
			case Keyboard.UP: RelativePosition.TOP;
			case Keyboard.RIGHT: RelativePosition.RIGHT;
			case Keyboard.DOWN: RelativePosition.BOTTOM;
			case Keyboard.LEFT: RelativePosition.LEFT;
			default: return new FocusResult(null, false);
		}
		var currentFocus = this.focus;
		var focusableObjects = FocusUtil.findAllFocusableObjects(this._root);
		if (currentFocus == null) {
			if (focusableObjects.length > 0) {
				return new FocusResult(focusableObjects[0], false);
			}
			return new FocusResult(null, false);
		}
		var newFocus = currentFocus;
		var focusedRect = cast(currentFocus, DisplayObject).getBounds(currentFocus.stage);
		for (focusableObject in focusableObjects) {
			if (focusableObject == currentFocus) {
				continue;
			}
			if (!this.isValidFocus(focusableObject)) {
				continue;
			}
			if (DPadFocusUtil.isBetterFocusForRelativePosition(cast(focusableObject, DisplayObject), cast(newFocus, DisplayObject), focusedRect,
				relativePosition)) {
				newFocus = focusableObject;
			}
		}
		return new FocusResult(newFocus, false);
	}

	private function isValidFocusWithKeyboard(target:IFocusObject):Bool {
		if ((target is InteractiveObject) && !cast(target, InteractiveObject).tabEnabled) {
			return false;
		}
		return this.isValidFocus(target);
	}

	private function isValidFocus(target:IFocusObject):Bool {
		if (target == null || target.stage == null || target.focusManager != this) {
			return false;
		}
		if (!target.focusEnabled) {
			return false;
		}
		if ((target is IUIControl)) {
			var uiTarget = cast(target, IUIControl);
			if (!uiTarget.enabled) {
				return false;
			}
		}
		var popUpManager = PopUpManager.forStage(this._root.stage);
		if (popUpManager.hasModalPopUps()) {
			var displayTarget = cast(target, DisplayObject);
			if (!PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(displayTarget)) {
				return false;
			}
		}

		return true;
	}

	private function setFocusManager(target:DisplayObject):Void {
		if ((target is IFocusManagerAware)) {
			var targetWithFocus = cast(target, IFocusManagerAware);
			targetWithFocus.focusManager = this;
		}
		var container = Std.downcast(target, DisplayObjectContainer);
		if (container != null) {
			for (i in 0...container.numChildren) {
				var child = container.getChildAt(i);
				this.setFocusManager(child);
			}
			if ((container is IFocusExtras)) {
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

	private function clearFocusManager(target:DisplayObject):Void {
		if ((target is IFocusManagerAware)) {
			var targetWithFocus = cast(target, IFocusManagerAware);
			if (targetWithFocus.focusManager == this) {
				if (targetWithFocus == this._focusToRestore) {
					this._focusToRestore = null;
				}
				if (this.focus == targetWithFocus) {
					// change to focus owner, which falls back to null
					var focusOwner:IFocusObject = null;
					if ((target is IFocusObject)) {
						focusOwner = cast(targetWithFocus, IFocusObject).focusOwner;
					}
					if (focusOwner != null && focusOwner.focusManager != this) {
						focusOwner = null;
					}
					this.focus = focusOwner;
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
			if ((container is IFocusExtras)) {
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
		if ((container is IViewPort) && !(container is IFocusContainer)) {
			container = container.parent;
		}
		var hasProcessedBeforeChild = beforeChild == null;
		if ((container is IFocusExtras)) {
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
		if ((container is IFocusExtras)) {
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
			if ((container is IFocusObject)) {
				var focusContainer = cast(container, IFocusObject);
				if (this.isValidFocusWithKeyboard(focusContainer)) {
					return focusContainer;
				}
			}
			return this.findPreviousContainerFocus(container.parent, container, true);
		}
		return null;
	}

	private function findNextContainerFocus(container:DisplayObjectContainer, afterChild:DisplayObject, fallbackToGlobal:Bool):IFocusObject {
		var outerContainer:DisplayObjectContainer = container;
		if ((container is IViewPort) && !(container is IFocusContainer)) {
			outerContainer = container.parent;
		}
		var hasProcessedAfterChild = afterChild == null;
		var exclusions:Array<DisplayObject> = null;
		if ((outerContainer is IFocusExclusions)) {
			exclusions = cast(outerContainer, IFocusExclusions).focusExclusions;
		}
		if ((outerContainer is IFocusExtras)) {
			var focusWithExtras = cast(outerContainer, IFocusExtras);
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
						if (exclusions != null && exclusions.indexOf(child) != -1) {
							continue;
						}
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
			if (exclusions != null && exclusions.indexOf(child) != -1) {
				continue;
			}
			var foundChild = this.findNextChildFocus(child);
			if (foundChild != null) {
				return foundChild;
			}
		}
		if ((outerContainer is IFocusExtras)) {
			var focusWithExtras = cast(outerContainer, IFocusExtras);
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
						if (exclusions != null && exclusions.indexOf(child) != -1) {
							continue;
						}
						var foundChild = this.findNextChildFocus(child);
						if (foundChild != null) {
							return foundChild;
						}
					}
				}
			}
		}

		if (fallbackToGlobal && outerContainer != this._root && outerContainer.parent != null) {
			var foundChild = this.findNextContainerFocus(outerContainer.parent, outerContainer, true);
			if (foundChild != null) {
				return foundChild;
			}
		}
		return null;
	}

	private function findPreviousChildFocus(child:DisplayObject):IFocusObject {
		var childContainer = Std.downcast(child, DisplayObjectContainer);
		if (childContainer != null) {
			var findPrevChildContainer = !(childContainer is IFocusObject);
			if (!findPrevChildContainer && (childContainer is IFocusContainer)) {
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
		if ((child is IFocusObject)) {
			var childWithFocus = cast(child, IFocusObject);
			if (this.isValidFocusWithKeyboard(childWithFocus)) {
				if (!(childWithFocus is IGroupedToggle)) {
					return childWithFocus;
				}
				var toggleGroup = cast(childWithFocus, IGroupedToggle).toggleGroup;
				if (toggleGroup == null) {
					return childWithFocus;
				}
				if ((toggleGroup.selectedItem is IFocusObject)) {
					var selectedItem = cast(toggleGroup.selectedItem, IFocusObject);
					if (this.focus != selectedItem) {
						// don't let it keep the same focus
						return selectedItem;
					}
				}
			}
		}
		return null;
	}

	private function findNextChildFocus(child:DisplayObject):IFocusObject {
		if ((child is IFocusObject)) {
			var childWithFocus = cast(child, IFocusObject);
			if (this.isValidFocusWithKeyboard(childWithFocus)) {
				if (!(childWithFocus is IGroupedToggle)) {
					return childWithFocus;
				}
				var toggleGroup = cast(childWithFocus, IGroupedToggle).toggleGroup;
				if (toggleGroup == null) {
					return childWithFocus;
				}
				if ((toggleGroup.selectedItem is IFocusObject)) {
					var selectedItem = cast(toggleGroup.selectedItem, IFocusObject);
					if (this.focus != selectedItem) {
						// don't let it keep the same focus
						return selectedItem;
					}
				}
			}
		}

		var childContainer = Std.downcast(child, DisplayObjectContainer);
		if (childContainer != null) {
			var findNextChildContainer = !(childContainer is IFocusObject);
			if (!findNextChildContainer && (childContainer is IFocusContainer)) {
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
		while ((value is IStageFocusDelegate)) {
			var newFocusTarget = cast(value, IStageFocusDelegate).stageFocusTarget;
			if (newFocusTarget == null) {
				break;
			}
			value = newFocusTarget;
		}
		if (value == null) {
			value = this._root.stage;
		}
		#if !flash
		if (this._root.stage.window == null) {
			return;
		}
		#end
		if (this._root.stage.focus != value) {
			this._root.stage.focus = value;
		}
	}

	private function handleRootAddedToStage(root:DisplayObject):Void {
		var stage = this._root.stage;
		if (stage == null) {
			return;
		}
		stage.stageFocusRect = false;
		if (this._enabled && stage.focus == null) {
			// needed for some targets, like Neko
			stage.focus = stage;
		}
		#if (html5 && openfl < "9.0.0")
		this._root.addEventListener(KeyboardEvent.KEY_DOWN, defaultFocusManager_root_keyDownHandler2, false, 0, true);
		#else
		this._root.addEventListener(KeyboardEvent.KEY_DOWN, defaultFocusManager_root_keyDownHandler, false, 0, true);
		this._root.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, defaultFocusManager_root_keyFocusChangeHandler, false, 0, true);
		#end
	}

	private function handleRootRemovedFromStage(root:DisplayObject):Void {
		this.focus = null;
		var stage = this._root.stage;
		if (stage == null) {
			return;
		}
		#if (html5 && openfl < "9.0.0")
		this._root.removeEventListener(KeyboardEvent.KEY_DOWN, defaultFocusManager_root_keyDownHandler2);
		#else
		this._root.removeEventListener(KeyboardEvent.KEY_DOWN, defaultFocusManager_root_keyDownHandler);
		this._root.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, defaultFocusManager_root_keyFocusChangeHandler);
		#end
	}

	private function defaultFocusManager_root_addedToStageHandler(event:Event):Void {
		this.handleRootAddedToStage(cast(event.currentTarget, DisplayObject));
	}

	private function defaultFocusManager_root_removedFromStageHandler(event:Event):Void {
		this.handleRootRemovedFromStage(cast(event.currentTarget, DisplayObject));
	}

	private function restoreFocus():Void {
		if (this._root.stage == null || this._focusToRestore == null || !this.isValidFocus(this._focusToRestore)) {
			return;
		}
		this.focus = this._focusToRestore;
	}

	private function shouldBeManaged(target:DisplayObject):Bool {
		if (target == this._root) {
			return true;
		}
		var container = target.parent;
		if ((container is IViewPort) && !(container is IFocusContainer)) {
			container = container.parent;
		}
		var valid = false;
		try {
			valid = container.getChildIndex(target) != -1;
		} catch (e:Dynamic) {
			// throws on some targets
		}
		if (!valid && (container is IFocusExtras)) {
			var container = cast(container, IFocusExtras);
			if (container.focusExtrasBefore != null) {
				for (child in container.focusExtrasBefore) {
					if (child == target) {
						valid = true;
						break;
					}
					if ((child is DisplayObjectContainer)) {
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
					if ((child is DisplayObjectContainer)) {
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
		if (this._focusPane != null) {
			if (this._focusPane == target || this._focusPane.contains(target)) {
				// move focusPane to top so that it's not below other pop-ups
				PopUpManager.forStage(this._root.stage).addPopUp(this._focusPane, false, false);
				return;
			}
		}
		if (this.shouldBeManaged(target)) {
			this.setFocusManager(target);
		}
		var currentFocus = this.focus;
		var clearFocus = currentFocus != null && !this.isValidFocus(currentFocus);
		if (!clearFocus && this._root.stage != null) {
			// needs an extra check because the focus getter might return null
			var stageFocus = this._root.stage.focus;
			clearFocus = stageFocus != null && (stageFocus is IFocusObject) && !this.isValidFocus(cast(stageFocus, IFocusObject));
		}
		if (clearFocus) {
			// it's possible that a modal pop-up has been added, and the current
			// focus is no longer valid
			this.focus = null;
		}
	}

	private function defaultFocusManager_root_removedHandler(event:Event):Void {
		var target = cast(event.target, DisplayObject);
		this.clearFocusManager(target);
	}

	private function defaultFocusManager_root_mouseFocusChangeHandler(event:FocusEvent):Void {
		if (event.isDefaultPrevented()) {
			return;
		}
		if (!this._enabled) {
			return;
		}
		var textField = Std.downcast(event.relatedObject, TextField);
		if (textField != null && (textField.type == INPUT || textField.selectable)) {
			// let OpenFL handle setting mouse focus on an input TextField
			// because it also sets the caret position and stuff
			return;
		}

		// for everything else, we'll handle focus changes in a pointer event
		event.preventDefault();
	}

	#if (html5 && openfl < "9.0.0")
	private function defaultFocusManager_root_keyDownHandler2(event:KeyboardEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (event.keyCode != Keyboard.TAB) {
			return;
		}
		this._showFocusIndicator = true;
		var result = this.findNextFocusInternal(event.shiftKey);
		this.focus = result.newFocus;
		if (this.focus != null) {
			event.preventDefault();
		}
	}
	#else
	private function handleKeyDownFocusWrapping(event:KeyboardEvent):Void {
		if (Capabilities.playerType == "StandAlone" || Capabilities.playerType == "Desktop") {
			// we care about wrapping in the browser only
			return;
		}

		if (!this._enabled || event.isDefaultPrevented()) {
			return;
		}
		if (event.keyCode != Keyboard.TAB && event.keyCode != 0) {
			return;
		}

		if (this._wrapObject != null) {
			// we can be fairly confident that if the tabIndex is equal to
			// WRAP_OBJECT_HIGH_TAB_INDEX, it was set programmatically by us,
			// so we can clear it safely.
			// on the other hand, if it is 0, we don't know if we can clear it
			// or not. that's not ideal, but it shouldn't have a huge impact.
			if (this._wrapObject.tabIndex == WRAP_OBJECT_HIGH_TAB_INDEX) {
				this._wrapObject.tabIndex = -1;
			}
			this._wrapObject = null;
		}
		var result = this.findNextFocusInternal(event.shiftKey);
		if (result.wrapped) {
			// if the current focus is the absolute first or last object in the
			// tab order, we can set its tabIndex property to a value that will
			// ensure that focus escapes OpenFL and goes to the browser chrome.
			// this isn't foolproof, but it should work most of the time.
			this._wrapObject = this._root.stage.focus;
			if (this._wrapObject != null && this._wrapObject.tabIndex == -1) {
				this._wrapObject.tabIndex = event.shiftKey ? 0 : WRAP_OBJECT_HIGH_TAB_INDEX;
			}
			return;
		}
	}

	private function handleDPadArrowKeys(event:KeyboardEvent):Void {
		if (event.keyLocation != 4 /* KeyLocation.D_PAD */) {
			return;
		}
		if (event.keyCode != Keyboard.UP && event.keyCode != Keyboard.DOWN && event.keyCode != Keyboard.LEFT && event.keyCode != Keyboard.RIGHT) {
			return;
		}
		if (event.isDefaultPrevented()) {
			return;
		}
		this._showFocusIndicator = true;
		var result = this.findNextRelativeFocusInternal(event.keyCode);
		this.focus = result.newFocus;
	}

	private function defaultFocusManager_root_keyDownHandler(event:KeyboardEvent):Void {
		this.handleKeyDownFocusWrapping(event);
		this.handleDPadArrowKeys(event);
	}

	private function defaultFocusManager_root_keyFocusChangeHandler(event:FocusEvent):Void {
		if (!this._enabled || event.isDefaultPrevented()) {
			return;
		}
		if (event.keyCode != Keyboard.TAB && event.keyCode != 0) {
			return;
		}
		this._showFocusIndicator = true;
		var result = this.findNextFocusInternal(event.shiftKey);
		this.focus = result.newFocus;
		if (this._wrapObject == null) {
			// cancel only when we aren't wrapping, so that focus may be passed
			// to the browser chrome or to another framework
			event.preventDefault();
		}
	}
	#end

	private function findFocusForDisplayObject(target:DisplayObject):IFocusObject {
		if (target == null) {
			return null;
		}
		var focusTarget:IFocusObject = null;
		do {
			if ((target is IFocusObject)) {
				var tempFocusTarget = cast(target, IFocusObject);
				if (this.isValidFocus(tempFocusTarget)) {
					if (focusTarget == null
						|| !(tempFocusTarget is IFocusContainer)
						|| !cast(tempFocusTarget, IFocusContainer).childFocusEnabled) {
						focusTarget = tempFocusTarget;
					}
				} else if (tempFocusTarget.focusOwner != null && this.isValidFocus(tempFocusTarget.focusOwner)) {
					focusTarget = tempFocusTarget.focusOwner;
					target = cast(tempFocusTarget, DisplayObject);
				}
			}
			if (target == this._root) {
				break;
			}
			target = target.parent;
		} while (target != null);
		return focusTarget;
	}

	private function defaultFocusManager_root_mouseDownCaptureHandler(event:MouseEvent):Void {
		this._showFocusIndicator = false;
		if (!this._enabled) {
			return;
		}
		var interactiveTarget = event.target;
		var newFocus = this.findFocusForDisplayObject(interactiveTarget);
		this.focus = newFocus;
	}

	private function defaultFocusManager_root_focusInCaptureHandler(event:FocusEvent):Void {
		this._focusToRestore = this.findFocusForDisplayObject(cast(event.target, DisplayObject));
	}

	private function defaultFocusManager_root_activateHandler(event:Event):Void {
		if (!this._enabled) {
			return;
		}
		this.restoreFocus();
	}

	private function defaultFocusManager_root_deactivateHandler(event:Event):Void {
		if (!this._enabled) {
			return;
		}
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
