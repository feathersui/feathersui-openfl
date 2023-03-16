/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.display.DisplayObject;
import openfl.display.Stage;
import openfl.errors.ArgumentError;

/**
	Manages tool tips for UI components.

	@see `feathers.core.IUIControl.toolTip`

	@since 1.0.0
**/
class ToolTipManager {
	private function ToolTipManager() {}

	private static function defaultToolTipManagerFactory(root:DisplayObject):IToolTipManager {
		return new DefaultToolTipManager(root);
	}

	private static var _toolTipManagerFactory:(DisplayObject) -> IToolTipManager = defaultToolTipManagerFactory;

	/**
		Returns a new instance of an `IToolTipManager` implementation. May be
		used to replace the default tool tip manager with a custom
		implementation.

		@see `feathers.core.DefaultToolTipManager`

		@since 1.0.0
	**/
	public static var toolTipManagerFactory(get, set):(DisplayObject) -> IToolTipManager;

	private static function get_toolTipManagerFactory():(DisplayObject) -> IToolTipManager {
		return _toolTipManagerFactory;
	}

	private static function set_toolTipManagerFactory(value:(DisplayObject) -> IToolTipManager):(DisplayObject) -> IToolTipManager {
		if (value == null) {
			_toolTipManagerFactory = defaultToolTipManagerFactory;
		}
		if (_toolTipManagerFactory == value) {
			return _toolTipManagerFactory;
		}
		_toolTipManagerFactory = value;
		return _toolTipManagerFactory;
	}

	private static var stageToManager:Map<Stage, IToolTipManager> = [];

	/**
		Indicates if a specific stage object is a tool tip manager root.

		@since 1.0.0
	**/
	public static function hasRoot(stage:Stage):Bool {
		return stageToManager.exists(stage);
	}

	/**
		Return the tool tip manager for the specified root, or `null`.

		@since 1.0.0
	**/
	public static function forRoot(stage:Stage):IToolTipManager {
		return stageToManager.get(stage);
	}

	/**
		Returns the `IToolTipManager` instance associated with the specified
		`Stage` instance. If a tool tip manager hasn't been created for this
		stage yet, one will be created automatically using
		`ToolTipManager.toolTipManagerFactory`.

		@see `ToolTipManager.toolTipManagerFactory`

		@since 1.0.0
	**/
	public static function addRoot(stage:Stage):IToolTipManager {
		if (stage == null) {
			throw new ArgumentError("ToolTipManager stage argument must not be null.");
		}
		if (stageToManager.exists(stage)) {
			throw new ArgumentError("Tool tip manager root already exists");
		}
		var toolTipManager = stageToManager.get(stage);
		var factory = ToolTipManager.toolTipManagerFactory;
		if (factory == null) {
			factory = ToolTipManager.defaultToolTipManagerFactory;
		}
		toolTipManager = factory(stage);
		stageToManager.set(stage, toolTipManager);
		return toolTipManager;
	}

	/**
		Removes a tool tip manager root that was enabled with `addRoot()`.

		@since 1.0.0
	**/
	public static function removeRoot(stage:Stage):Void {
		var toolTipManager = stageToManager.get(stage);
		if (toolTipManager == null) {
			return;
		}
		toolTipManager.dispose();
		stageToManager.remove(stage);
	}

	/**
		Removes all `IToolTipManager` instances created by calling
		`ToolTipManager.forStage()`.

		@since 1.0.0
	**/
	public static function dispose():Void {
		for (stage in stageToManager.keys()) {
			stageToManager.remove(stage);
		}
	}
}
