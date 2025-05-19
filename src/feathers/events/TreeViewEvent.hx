/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.events;

import feathers.data.TreeViewItemState;
import openfl.events.Event;
import openfl.events.EventType;
import openfl.events.IEventDispatcher;
#if !flash
#if (openfl >= "9.1.0")
import openfl.utils.ObjectPool;
#else
import openfl._internal.utils.ObjectPool;
#end
#end

/**
	Events dispatched by the `TreeView` component.

	@see `feathers.controls.TreeView`

	@since 1.0.0
**/
class TreeViewEvent extends Event {
	/**
		The `TreeViewEvent.ITEM_TRIGGER` event type is dispatched when an item
		renderer is clicked or tapped.

		@since 1.0.0
	**/
	public static inline var ITEM_TRIGGER:EventType<TreeViewEvent> = "itemTrigger";

	/**
		The `TreeViewEvent.BRANCH_OPEN` event type is dispatched when a branch
		is opened.

		@since 1.0.0
	**/
	public static inline var BRANCH_OPEN:EventType<TreeViewEvent> = "branchOpen";

	/**
		The `TreeViewEvent.BRANCH_CLOSE` event type is dispatched when a branch
		is closed.

		@since 1.0.0
	**/
	public static inline var BRANCH_CLOSE:EventType<TreeViewEvent> = "branchClose";

	/**
		The `TreeViewEvent.BRANCH_OPENING` event type is dispatched before a
		branch opens.

		@since 1.4.0
	**/
	public static inline var BRANCH_OPENING:EventType<TreeViewEvent> = "branchOpening";

	/**
		The `TreeViewEvent.BRANCH_CLOSING` event type is dispatched before a
		branch closes.

		@since 1.4.0
	**/
	public static inline var BRANCH_CLOSING:EventType<TreeViewEvent> = "branchClosing";

	#if !flash
	private static var _pool = new ObjectPool<TreeViewEvent>(() -> return new TreeViewEvent(null, null), (event) -> {
		event.target = null;
		event.currentTarget = null;
		event.__preventDefault = false;
		event.__isCanceled = false;
		event.__isCanceledNow = false;
		event.cancelable = false;
		event.state = null;
	});
	#end

	/**
		Dispatches a pooled event with the specified properties.

		```haxe
		TreeViewEvent.dispatch(component, TreeViewEvent.ITEM_TRIGGER, state);
		```

		@since 1.0.0
	**/
	public static function dispatch(dispatcher:IEventDispatcher, type:String, state:TreeViewItemState, cancelable:Bool = false):Bool {
		#if flash
		var event = new TreeViewEvent(type, state, cancelable);
		return dispatcher.dispatchEvent(event);
		#else
		var event = _pool.get();
		event.type = type;
		event.state = state;
		event.cancelable = cancelable;
		var result = dispatcher.dispatchEvent(event);
		_pool.release(event);
		return result;
		#end
	}

	/**
		Creates a new `TreeViewEvent` object with the given arguments.

		@see `TreeViewEvent.dispatch`

		@since 1.0.0
	**/
	public function new(type:String, state:TreeViewItemState, cancelable:Bool = false) {
		super(type, false, cancelable);
		this.state = state;
	}

	/**
		The current state of the item associated with this event.

		@since 1.0.0
	**/
	public var state:TreeViewItemState;

	override public function clone():Event {
		return new TreeViewEvent(this.type, this.state, this.cancelable);
	}
}
