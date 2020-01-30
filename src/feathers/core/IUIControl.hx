/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.style.IStyleObject;

/**
	A user interface control.

	@since 1.0.0
**/
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
	public var enabled(get, set):Bool;

	/**
		If the component has not yet initialized, initializes immediately. The
		`FeathersEvent.INITIALIZE` event will be dispatched. To both initialize
		and validate immediately, call `validateNow()` instead.

		@since 1.0.0
	**/
	public function initializeNow():Void;
}
