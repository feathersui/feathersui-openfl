/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import feathers.core.IUIControl;
import openfl.display.DisplayObject;

/**
	Manages display objects that need to be created dynamically, such as
	sub-components of a complex UI component.

	@see `DisplayObjectFactory.withClass()`
	@see `DisplayObjectFactory.withFunction()`

	@since 1.0.0
**/
class DisplayObjectFactory<T:B, B:DisplayObject> {
	/**
		Creates a `DisplayObjectFactory` that returns the same display object
		instance each time the factory is used.

		To instantiate a different display object each time, use
		`DisplayObjectFactory.withClass()` or
		`DisplayObjectFactory.withFunction()` instead.
	**/
	public static function withDisplayObject<T:B, B:DisplayObject>(displayObject:T, ?destroy:(T) -> Void):DisplayObjectFactory<T, B> {
		var item = new DisplayObjectFactory<T, B>();
		item.create = () -> {
			return displayObject;
		};
		item.destroy = destroy;
		return item;
	}

	/**
		Creates a `DisplayObjectFactory` that instantiates a display object by
		instantiating the specified class. The class must have a constructor
		with zero required arguments.

		To instantiate an object with one or more required constructor
		arguments, use `DisplayObjectFactory.withFunction()` instead.
	**/
	public static function withClass<T:B, B:DisplayObject>(displayObjectType:Class<T>, ?destroy:(T) -> Void):DisplayObjectFactory<T, B> {
		if (destroy == null) {
			// since we create the instance, we can safely dispose it
			destroy = (target) -> {
				if ((target is IUIControl)) {
					(cast target : IUIControl).dispose();
				}
			}
		}
		var item = new DisplayObjectFactory<T, B>();
		item.create = () -> {
			Type.createInstance(displayObjectType, []);
		};
		item.destroy = destroy;
		return item;
	}

	/**
		Creates a `DisplayObjectFactory` that instantiates a display object by
		calling the specified function.
	**/
	public static function withFunction<T:B, B:DisplayObject>(create:() -> T, ?destroy:(T) -> Void):DisplayObjectFactory<T, B> {
		var item = new DisplayObjectFactory<T, B>();
		item.create = create;
		item.destroy = destroy;
		return item;
	}

	private function new() {}

	/**
		Creates a new display object.

		@since 1.0.0
	**/
	public dynamic function create():T {
		return null;
	}

	/**
		Destroys/disposes a display object when it will no longer be used.

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
	public dynamic function destroy(target:T):Void {}
}
