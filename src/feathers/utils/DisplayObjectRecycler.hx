/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import feathers.core.IUIControl;
import openfl.display.DisplayObject;

/**
	Manages display objects that may be used to render data, in a component like
	`ListView` or `TabBar`.

	@see `DisplayObjectRecycler.withClass()`
	@see `DisplayObjectRecycler.withFunction()`

	@since 1.0.0
**/
class DisplayObjectRecycler<T:B, S, B:DisplayObject> extends DisplayObjectFactory<T, B> {
	/**
		Creates a `DisplayObjectRecycler` that instantiates a display object by
		instantiating the specified class. The class must have a constructor
		with zero required arguments.

		To instantiate an object with one or more required constructor
		arguments, use `DisplayObjectRecycler.withFunction()` instead.

		@since 1.0.0
	**/
	public static function withClass<T:B, S, B:DisplayObject>(displayObjectType:Class<T>, ?update:(target:T, state:S) -> Void,
			?reset:(target:T, state:S) -> Void, ?destroy:(T) -> Void):DisplayObjectRecycler<T, S, B> {
		if (destroy == null) {
			// since we create the instance, we can safely dispose it
			destroy = (target) -> {
				if ((target is IUIControl)) {
					(cast target : IUIControl).dispose();
				}
			}
		}
		var item = new DisplayObjectRecycler<T, S, B>();
		item.create = () -> {
			Type.createInstance(displayObjectType, []);
		};
		item.update = update;
		item.reset = reset;
		item.destroy = destroy;
		return item;
	}

	/**
		Creates a `DisplayObjectRecycler` that instantiates a display object by
		calling the specified function.

		@since 1.0.0
	**/
	public static function withFunction<T:B, S, B:DisplayObject>(create:() -> T, ?update:(target:T, state:S) -> Void, ?reset:(target:T, state:S) -> Void,
			?destroy:(T) -> Void):DisplayObjectRecycler<T, S, B> {
		var item = new DisplayObjectRecycler<T, S, B>();
		item.create = create;
		item.update = update;
		item.reset = reset;
		item.destroy = destroy;
		return item;
	}

	/**
		Creates a `DisplayObjectRecycler` that instantiates a display object 
		from a `DisplayObjectFactory`.

		@since 1.3.0
	**/
	public static function withFactory<T:B, S, B:DisplayObject>(factory:DisplayObjectFactory<T, B>, ?update:(target:T, state:S) -> Void,
			?reset:(target:T, state:S) -> Void):DisplayObjectRecycler<T, S, B> {
		var item = new DisplayObjectRecycler<T, S, B>();
		item.create = factory.create;
		item.update = update;
		item.reset = reset;
		item.destroy = factory.destroy;
		return item;
	}

	private function new() {
		super();
	}

	/**
		Updates the properties an existing display object. It may be a display
		object that was used previously, but it will have been passed to
		`reset()` first, to ensure that it has been restored to its original
		state when it was returned from `create()`.

		@since 1.0.0
	**/
	public dynamic function update(target:T, state:S):Void {};

	/**
		Prepares a display object to be used again. This method should restore
		the display object to its original state from when it was returned by
		`create()`.

		_Warning:_ This method is not guaranteed to be called by the parent
		component when that component is removed from stage (or later when it is
		garbage collected). If this method must be called to clean up something
		that would cause a memory leak, you should manually update the
		appropriate property on the parent component that will cause all 
		instances to be removed, and then validate the parent component. For
		example, on a `ListView`, you would set the `dataProvider` property to
		`null` before calling `validateNow()`.

		```haxe
		listView.dataProvider = null;
		listView.validateNow();
		```

		@since 1.0.0
	**/
	public dynamic function reset(target:T, state:S):Void {}
}
