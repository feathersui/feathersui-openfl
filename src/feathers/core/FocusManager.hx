/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.errors.ArgumentError;

/**
	Manages mouse/touch and keyboard focus.

	@since 1.0.0
**/
class FocusManager {
	private function FocusManager() {}

	private static function defaultFocusManagerFactory(root:DisplayObject):IFocusManager {
		return new DefaultFocusManager(root);
	}

	private static var _focusManagerFactory:(DisplayObject) -> IFocusManager = defaultFocusManagerFactory;

	/**
		Returns a new instance of an `IFocusManager` implementation. May be used
		to replace the default focus manager with a custom implementation.

		@see `feathers.core.DefaultFocusManager`

		@since 1.0.0
	**/
	@:flash.property
	public static var focusManagerFactory(get, set):(DisplayObject) -> IFocusManager;

	private static function get_focusManagerFactory():(DisplayObject) -> IFocusManager {
		return _focusManagerFactory;
	}

	private static function set_focusManagerFactory(value:(DisplayObject) -> IFocusManager):(DisplayObject) -> IFocusManager {
		if (value == null) {
			_focusManagerFactory = defaultFocusManagerFactory;
		}
		if (_focusManagerFactory == value) {
			return _focusManagerFactory;
		}
		_focusManagerFactory = value;
		return _focusManagerFactory;
	}

	private static var _rootToData:Map<DisplayObject, FocusManagerRootData> = [];

	/**
		Indicates if a specific display object is a focus manager root.

		@since 1.0.0
	**/
	public static function hasRoot(root:DisplayObject):Bool {
		return _rootToData.exists(root);
	}

	/**
		Adds a focus manager root.

		@since 1.0.0
	**/
	public static function addRoot(root:DisplayObject, ?customFactory:(DisplayObject) -> IFocusManager):IFocusManager {
		if (_rootToData.exists(root)) {
			throw new ArgumentError("Focus manager root already exists");
		}
		for (otherRoot in _rootToData.keys()) {
			if ((otherRoot is DisplayObjectContainer)) {
				var rootContainer = cast(otherRoot, DisplayObjectContainer);
				if (rootContainer.contains(root)) {
					throw new ArgumentError("Cannot nest focus manager roots");
				}
			}
		}
		var rootData = new FocusManagerRootData();
		rootData.root = root;
		rootData.factory = customFactory;
		rootData.stack = [];
		_rootToData.set(root, rootData);
		return pushWithRootData(rootData, root);
	}

	/**
		Removes a focus manager root that was enabled with `addRoot()`.

		@since 1.0.0
	**/
	public static function removeRoot(root:DisplayObject):Void {
		if (!_rootToData.exists(root)) {
			return;
		}
		var rootData = _rootToData.get(root);
		var stack = rootData.stack;
		for (focusManager in stack) {
			focusManager.enabled = false;
			focusManager.dispose();
		}
		stack.resize(0);
		_rootToData.remove(root);
	}

	/**
		Changes the currently focused object.

		Throws `ArgumentError` if the object does not have a focus manager.

		@since 1.0.0
	**/
	public static function setFocus(focusable:IFocusObject):Void {
		var focusManager = focusable.focusManager;
		if (focusManager == null) {
			throw new ArgumentError("Cannot set focus because focus manager is null.");
		}
		focusManager.focus = focusable;
	}

	private static function pushForPopUpManager(rootManager:IFocusManager, secondaryRoot:DisplayObject):IFocusManager {
		var rootData = _rootToData.get(rootManager.root);
		return pushWithRootData(rootData, secondaryRoot);
	}

	private static function pushWithRootData(rootData:FocusManagerRootData, secondaryRoot:DisplayObject):IFocusManager {
		var stack = rootData.stack;
		for (focusManager in stack) {
			focusManager.enabled = false;
		}
		var customFactory = rootData.factory;
		var factory = (customFactory != null) ? customFactory : _focusManagerFactory;
		var focusManager = factory(secondaryRoot);
		stack.push(focusManager);
		focusManager.enabled = true;
		return focusManager;
	}

	private static function removeForPopUpManager(rootManager:IFocusManager, secondaryManager:IFocusManager):Void {
		var rootData = _rootToData.get(rootManager.root);
		var stack = rootData.stack;
		for (i in 0...stack.length) {
			var manager = stack[i];
			if (manager != secondaryManager) {
				continue;
			}
			manager.enabled = false;
			manager.dispose();
			stack.splice(i, 1);
			// if this is the top-level focus manager, enable the previous one
			if (i == stack.length) {
				manager = stack[stack.length - 1];
				manager.enabled = true;
			}
			break;
		}
	}
}

private class FocusManagerRootData {
	public function new() {}

	public var root:DisplayObject;
	public var factory:(DisplayObject) -> IFocusManager;
	public var stack:Array<IFocusManager>;
}
