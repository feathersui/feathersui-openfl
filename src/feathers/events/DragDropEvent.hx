/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.events;

import feathers.dragDrop.DragDropManager;
import feathers.dragDrop.IDropTarget;
import openfl.events.Event;
import openfl.events.EventType;
import openfl.events.IEventDispatcher;
import feathers.dragDrop.DragData;
import feathers.dragDrop.IDragSource;
#if !flash
#if (openfl >= "9.1.0")
import openfl.utils.ObjectPool;
#else
import openfl._internal.utils.ObjectPool;
#end
#end

/**
	Events used by the `DragDropManager`.

	@see `feathers.dragDrop.DragDropManager`

	@since 1.3.0
**/
class DragDropEvent extends Event {
	/**
		The `DragDropEvent.DRAG_START` event type is dispatched by an
		`IDragSource` when it a drag is started.

		@see `feathers.dragDrop.IDragSource`

		@since 1.3.0
	**/
	public static inline var DRAG_START:EventType<DragDropEvent> = "dragStart";

	/**
		The `DragDropEvent.DRAG_COMPLETE` event type is dispatched by an
		`IDragSource` when a drag completes. This event is always dispatched —
		even when there was no successful drop. See the `dropped` property to
		determine if the drop was successful.

		@see `feathers.dragDrop.IDragSource`

		@since 1.3.0
	**/
	public static inline var DRAG_COMPLETE:EventType<DragDropEvent> = "dragComplete";

	/**
		The `DragDropEvent.DRAG_ENTER` event type is dispatched by an
		`IDropTarget` when the mouse or a touch enters the target's bounds
		during a drag action.

		@see `feathers.dragDrop.IDropTarget`

		@since 1.3.0
	**/
	public static inline var DRAG_ENTER:EventType<DragDropEvent> = "dragEnter";

	/**
		The `DragDropEvent.DRAG_MOVE` event type is dispatched by an
		`IDropTarget` when the mouse or a touch moves within the target's bounds
		during a drag action. A `DRAG_ENTER` event is always dispatched before
		any `DRAG_MOVE` events are dispatched.

		@see `feathers.dragDrop.IDropTarget`

		@since 1.3.0
	**/
	public static inline var DRAG_MOVE:EventType<DragDropEvent> = "dragMove";

	/**
		The `DragDropEvent.DRAG_EXIT` event type is dispatched by an
		`IDropTarget` when the mouse or a touch exits the target's bounds
		during a drag action.

		@see `feathers.dragDrop.IDropTarget`

		@since 1.3.0
	**/
	public static inline var DRAG_EXIT:EventType<DragDropEvent> = "dragExit";

	/**
		The `DragDropEvent.DRAG_DROP` event type is dispatched by an
		`IDropTarget` when a drop occurs.

		@see `feathers.dragDrop.IDropTarget`

		@since 1.3.0
	**/
	public static inline var DRAG_DROP:EventType<DragDropEvent> = "dragDrop";

	#if !flash
	private static var _pool = new ObjectPool<DragDropEvent>(() -> return new DragDropEvent(null, null, false), (event) -> {
		event.target = null;
		event.currentTarget = null;
		event.__preventDefault = false;
		event.__isCanceled = false;
		event.__isCanceledNow = false;
	});
	#end

	/**
		Dispatches a pooled event with the specified properties.

		```haxe
		DragDropEvent.dispatch(component, DragDropEvent.DRAG_START, dragData, false, null, null, component);
		```

		@since 1.3.0
	**/
	public static function dispatch(dispatcher:IEventDispatcher, type:String, dragData:DragData, dropped:Bool, localX:Null<Float> = null,
			localY:Null<Float> = null, dragSource:IDragSource = null):Bool {
		#if flash
		var event = new DragDropEvent(type, dragData, dropped, localX, localY, dragSource);
		return dispatcher.dispatchEvent(event);
		#else
		var event = _pool.get();
		event.type = type;
		event.dragData = dragData;
		event.dropped = dropped;
		event.localX = localX;
		event.localY = localY;
		event.dragSource = dragSource;
		var result = dispatcher.dispatchEvent(event);
		_pool.release(event);
		return result;
		#end
	}

	/**
		Creates a new `DragDropEvent` object with the given arguments.

		@see `DragDropEvent.dispatch`

		@since 1.3.0
	**/
	public function new(type:String, dragData:DragData, dropped:Bool, localX:Null<Float> = null, localY:Null<Float> = null, dragSource:IDragSource = null) {
		super(type, false, cancelable);
		this.dragData = dragData;
		this.dropped = dropped;
		this.localX = localX;
		this.localY = localY;
		this.dragSource = dragSource;
	}

	/**
		The `DragData` associated with the current drag.

		@since 1.3.0
	**/
	public var dragData(default, null):DragData;

	/**
		Indicates if a drop has occurred. Can be `true` of the event's `type` is
		`DragDropEvent.DRAG_DROP` only. For all other types, it will be `false`.

		@since 1.3.0
	**/
	public var dropped(default, null):Bool;

	/**
		The local x position of the current drop target, or `null` if there is
		no current drop target.

		@since 1.3.0
	**/
	public var localX(default, null):Null<Float>;

	/**
		The local y position of the current drop target, or `null` if there is
		no current drop target.

		@since 1.3.0
	**/
	public var localY(default, null):Null<Float>;

	/**
		The display object where the current drag originated.

		@since 1.3.0
	**/
	public var dragSource(default, null):IDragSource;

	/**
		May be called for an `IDropTarget` after the `DragDropEvent.DRAG_ENTER`
		event is dispatched and before the `DragDropEvent.DRAG_EXIT` event is
		dispatched. If called at any other time, an exception is thrown.

		@since 1.3.0
	**/
	public function acceptDrag(target:IDropTarget):Void {
		DragDropManager.acceptDrag(target);
	}

	override public function clone():Event {
		return new DragDropEvent(this.type, this.dragData, this.dropped, this.localX, this.localY, this.dragSource);
	}
}
