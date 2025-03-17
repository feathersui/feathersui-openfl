/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

/**
	A user interface control.

	@event feathers.events.FeathersEvent.INITIALIZE Dispatched after the
	component's `initialize()` method has been called.

	@event feathers.events.FeathersEvent.ENABLE Dispatched when
	`IUIControl.enabled` is set to `true`.

	@event feathers.events.FeathersEvent.DISABLE Dispatched when
	`IUIControl.enabled` is set to `false`.

	@since 1.0.0
**/
@:event(feathers.events.FeathersEvent.INITIALIZE)
@:event(feathers.events.FeathersEvent.ENABLE)
@:event(feathers.events.FeathersEvent.DISABLE)
interface IUIControl extends IDisplayObject {
	/**
		Indicates whether the control should respond when a user attempts to
		interact with it. The appearance of the control may also be affected by
		whether the control is enabled or disabled.

		The following example disables a component:

		```haxe
		component.enabled = false;
		```

		@since 1.0.0
	**/
	public var enabled(get, set):Bool;

	/**
		Text to display in a tool tip to when hovering the mouse over this
		component, if the `ToolTipManager` is enabled.

		The following example sets a tool tip:

		```haxe
		component.toolTip = "Description of component";
		```

		Note: This property will be ignored if no tool tip manager is enabled.
		If you are using the `Application` component, a tool tip manager will
		be enabled automatically.

		@default null

		@see `feathers.core.ToolTipManager`

		@since 1.0.0
	**/
	public var toolTip(get, set):String;

	/**
		If the component has not yet initialized, initializes immediately. The
		`FeathersEvent.INITIALIZE` event will be dispatched. To both initialize
		and validate immediately, call `validateNow()` instead.

		@since 1.0.0

		@see `feathers.core.FeathersControl.initialize()`
		@see [The Feathers UI Component Lifecycle](https://feathersui.com/learn/haxe-openfl/ui-component-lifecycle/)
	**/
	public function initializeNow():Void;

	/**
		May be called manually to clear the component's data and dispose
		sub-components, if appropriate.

		In most cases, calling `dispose()` is _not_ required to ensure that a
		component may be garbage collected. This method is provided for advanced
		use cases where some extra cleanup may benefit memory usage.

		@since 1.3.0

		@see [The Feathers UI Component Lifecycle](https://feathersui.com/learn/haxe-openfl/ui-component-lifecycle/)
	**/
	public function dispose():Void;
}
