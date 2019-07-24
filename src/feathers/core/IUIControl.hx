/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.style.IStyleObject;
import feathers.style.IStyleProvider;
import openfl.events.IEventDispatcher;

/**
	A user interface control.

	@since 1.0.0
**/
interface IUIControl extends IEventDispatcher {
	/**
		Indicates whether the control should respond when a user attempts to
		interact with it. The appearance of the control may also be affected by
		whether the control is enabled or disabled.

		@since 1.0.0
	**/
	public var enabled(get, set):Bool;

	/**
		The class used as the context for styling the component. For instance,
		a subclass of a component may have different styles than its superclass,
		or it may inherit styles from its superclass.

		@since 1.0.0
	**/
	public var styleContext(get, never):Class<IStyleObject>;

	/**
		May be used to provide multiple different variations of the same UI
		component, each with a different appearance.

		@since 1.0.0
	**/
	public var variant(default, set):String;

	/**
		If the component has not yet initialized, initializes immediately. The
		`FeathersEvent.INITIALIZE` event will be dispatched. To both initialize
		and validate immediately, call `validateNow()` instead.

		@since 1.0.0
	**/
	public function initializeNow():Void;
}
