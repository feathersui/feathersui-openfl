/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.display.DisplayObject;
import openfl.display.Stage;
import openfl.errors.ArgumentError;
import openfl.events.Event;

/**
	Manages mouse/touch and keyboard focus.

	@since 1.0.0
**/
class FocusManager {
	private static var stageToManager:Map<Stage, IFocusManager> = [];

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

	/**
		Indicates if a specific stage object is a focus manager root.

		@since 1.0.0
	**/
	public static function hasRoot(stage:Stage):Bool {
		return stageToManager.exists(stage);
	}

	/**
		Returns the `IFocusManager` instance associated with the specified
		`Stage` instance. If a focus manager hasn't been created for this
		stage yet, one will be created automatically using
		`FocusManager.focusManagerFactory`.

		@see `FocusManager.focusManagerFactory`

		@since 1.0.0
	**/
	public static function addRoot(stage:Stage):IFocusManager {
		if (stage == null) {
			throw new ArgumentError("FocusManager stage argument must not be null.");
		}
		if (stageToManager.exists(stage)) {
			throw new ArgumentError("Focus manager root already exists");
		}
		var focusManager = stageToManager.get(stage);
		var factory = FocusManager.focusManagerFactory;
		if (factory == null) {
			factory = FocusManager.defaultFocusManagerFactory;
		}
		focusManager = factory(stage);
		focusManager.addEventListener(Event.CLEAR, focusManager_clearHandler, false, 0, true);
		stageToManager.set(stage, focusManager);
		return focusManager;
	}

	/**
		Removes a focus manager root that was enabled with `addRoot()`.

		@since 1.0.0
	**/
	public static function removeRoot(stage:Stage):Void {
		var focusManager = stageToManager.get(stage);
		if (focusManager == null) {
			return;
		}
		focusManager.dispose();
	}

	/**
		Removes all `IFocusManager` instances created by calling
		`FocusManager.forStage()`.

		@since 1.0.0
	**/
	public static function dispose():Void {
		for (stage in stageToManager.keys()) {
			var focusManager = stageToManager.get(stage);
			focusManager.dispose();
			stageToManager.remove(stage);
		}
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

	private static function focusManager_clearHandler(event:Event):Void {
		var focusManager = cast(event.currentTarget, IFocusManager);
		focusManager.removeEventListener(Event.CLEAR, focusManager_clearHandler);
		var stage = Std.downcast(focusManager.root, Stage);
		if (stage != null) {
			stageToManager.remove(stage);
		}
	}

	private function FocusManager() {}
}
