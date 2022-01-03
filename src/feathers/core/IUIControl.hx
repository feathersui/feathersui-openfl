/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

/**
	A user interface control.

	@event feathers.events.FeathersEvent.INITIALIZE

	@event feathers.events.FeathersEvent.ENABLE

	@event feathers.events.FeathersEvent.DISABLE

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

		```hx
		component.enabled = false;
		```

		@since 1.0.0
	**/
	@:flash.property
	public var enabled(get, set):Bool;

	/**
		Text to display in a tool tip to when hovering the mouse over this
		component, if the `ToolTipManager` is enabled.

		The following example sets a tool tip:

		```hx
		component.toolTip = "Description of component";
		```

		Note: This property will be ignored if no tool tip manager is enabled.
		If you are using the `Application` component, a tool tip manager will
		be enabled automatically.

		@default null

		@see `feathers.core.ToolTipManager`

		@since 1.0.0
	**/
	@:flash.property
	public var toolTip(get, set):String;

	/**
		If the component has not yet initialized, initializes immediately. The
		`FeathersEvent.INITIALIZE` event will be dispatched. To both initialize
		and validate immediately, call `validateNow()` instead.

		@since 1.0.0
	**/
	public function initializeNow():Void;
}
