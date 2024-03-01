/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.dragDrop;

import feathers.core.PopUpManager;
import feathers.events.DragDropEvent;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.InteractiveObject;
import openfl.display.Stage;
import openfl.errors.ArgumentError;
import openfl.errors.IllegalOperationError;
import openfl.events.MouseEvent;
import openfl.geom.Point;

/**
	Handles drag and drop operations that originate with display objects that
	implement the `IDragSource` interface and end with display objects that
	implement the `IDropTarget` interface.

	@since 1.3.0
**/
class DragDropManager {
	/**
		The `IDragSource` that started the current drag action, or `null` if no
		drag action is currently active.

		@since 1.3.0
	**/
	public static var dragSource(default, null):IDragSource = null;

	/**
		The data associated with the current drag action, or `null` if no drag
		action is currently active.

		@since 1.3.0
	**/
	public static var dragData(default, null):DragData = null;

	/**
		Indicates if a drag action is currently active or not.

		@since 1.3.0
	**/
	public static var dragging(get, null):Bool;

	private static function get_dragging():Bool {
		return dragData != null;
	}

	private static var _dragSourceBitmapData:BitmapData;
	private static var _dragSourceStage:Stage;
	private static var _dropTargetLocalX = 0.0;
	private static var _dropTargetLocalY = 0.0;
	private static var _dragAvatarOffsetX = 0.0;

	/**
		The x position offset for the drag avatar that was passed into the
		`startDrag()` method.

		@see `DragDropManager.dragAvatar`

		@since 1.3.0
	**/
	public static var dragAvatarOffsetX(default, null):Float = 1.0;

	/**
		The y position offset for the drag avatar that was passed into the
		`startDrag()` method.

		@see `DragDropManager.dragAvatar`

		@since 1.3.0
	**/
	public static var dragAvatarOffsetY(default, null):Float = 1.0;

	/**
		Returns the drop target that has accepted the current drag action, or
		`null` if either no target has accepted or if no drag action is
		currently active.

		@since 1.3.0
	**/
	public static var currentDropTarget(default, null):IDropTarget = null;

	/**
		Indicates if a drop has been accepted for the current drag action. If
		no drag action is currently active, returns `false`.

		@since 1.3.0
	**/
	public static var dropAccepted(default, null):Bool = false;

	private static var _oldDragAvatarMouseEnabled = false;
	private static var _oldDragAvatarMouseChildren = false;

	/**
		The avatar displayed for the current drag action, or `null` if no drag
		action is currently active.

		@since 1.3.0
	**/
	public static var dragAvatar(default, null):DisplayObject = null;

	/**
		Starts a new drag. If another drag is currently active, it is
		immediately cancelled. Includes an optional "avatar", a visual
		representation of the data that is being dragged.

		@since 1.3.0
	**/
	public static function startDrag(source:IDragSource, data:DragData, avatar:DisplayObject = null, avatarOffsetX:Float = 0.0,
			avatarOffsetY:Float = 0.0):Void {
		if (dragging) {
			cancelDrag();
		}
		if (source == null) {
			throw new ArgumentError("Drag source must not be null.");
		}
		if (data == null) {
			throw new ArgumentError("Drag data must not be null.");
		}
		dragSource = source;
		dragData = data;
		dragAvatar = avatar;
		dragAvatarOffsetX = avatarOffsetX;
		dragAvatarOffsetY = avatarOffsetY;

		var displaySource = cast(source, DisplayObject);
		_dragSourceStage = displaySource.stage;

		if (dragAvatar == null) {
			_dragSourceBitmapData = new BitmapData(Math.ceil(displaySource.width), Math.ceil(displaySource.height));
			_dragSourceBitmapData.draw(displaySource);
			dragAvatar = new Bitmap(_dragSourceBitmapData);
			dragAvatar.alpha = 0.75;
		}
		if ((dragAvatar is InteractiveObject)) {
			var interactiveAvatar:InteractiveObject = cast dragAvatar;
			_oldDragAvatarMouseEnabled = interactiveAvatar.mouseEnabled;
			interactiveAvatar.mouseEnabled = false;
		}
		if ((dragAvatar is DisplayObjectContainer)) {
			var containerAvatar:DisplayObjectContainer = cast dragAvatar;
			_oldDragAvatarMouseChildren = containerAvatar.mouseChildren;
			containerAvatar.mouseChildren = false;
		}
		dragAvatar.x = _dragSourceStage.mouseX + dragAvatarOffsetX;
		dragAvatar.y = _dragSourceStage.mouseY + dragAvatarOffsetY;
		PopUpManager.addPopUp(dragAvatar, _dragSourceStage, false, false);
		_dragSourceStage.addEventListener(MouseEvent.MOUSE_MOVE, dragDropManager_stage_mouseMoveHandler, false, 0, true);
		_dragSourceStage.addEventListener(MouseEvent.MOUSE_UP, dragDropManager_stage_mouseUpHandler, false, 0, true);
		DragDropEvent.dispatch(dragSource, DragDropEvent.DRAG_START, data, false, null, null, dragSource);
		updateDropTarget(_dragSourceStage, _dragSourceStage.mouseX, _dragSourceStage.mouseY);
	}

	/**
		Tells the drag and drop manager if the target will accept the current
		drop. Meant to be called in a listener for the target's
		`DragDropEvent.DRAG_ENTER`event.

		@since 1.3.0
	**/
	public static function acceptDrag(target:IDropTarget):Void {
		if (currentDropTarget != target) {
			throw new ArgumentError("Drop target cannot accept a drag at this time. Acceptance may only happen after the DragDropEvent.DRAG_ENTER event is dispatched and before the DragDropEvent.DRAG_EXIT event is dispatched.");
		}
		dropAccepted = true;
	}

	private static function cancelDrag():Void {
		if (!dragging) {
			return;
		}
		completeDrag(false);
	}

	private static function completeDrag(dropped:Bool):Void {
		if (!dragging) {
			throw new IllegalOperationError("Drag cannot be completed because none is currently active.");
		}
		if (currentDropTarget != null) {
			DragDropEvent.dispatch(currentDropTarget, DragDropEvent.DRAG_EXIT, dragData, false, _dropTargetLocalX, _dropTargetLocalY, dragSource);
			currentDropTarget = null;
		}
		var source = dragSource;
		var data = dragData;
		cleanup();
		DragDropEvent.dispatch(source, DragDropEvent.DRAG_COMPLETE, data, dropped, null, null, source);
	}

	private static function cleanup():Void {
		if (_dragSourceStage != null) {
			_dragSourceStage.removeEventListener(MouseEvent.MOUSE_MOVE, dragDropManager_stage_mouseMoveHandler);
			_dragSourceStage.removeEventListener(MouseEvent.MOUSE_UP, dragDropManager_stage_mouseUpHandler);
			_dragSourceStage = null;
		}
		if (_dragSourceBitmapData != null) {
			_dragSourceBitmapData.dispose();
			_dragSourceBitmapData = null;
		}
		if (dragAvatar != null) {
			// may have been removed from parent already in the drop listener
			if (PopUpManager.isPopUp(dragAvatar)) {
				PopUpManager.removePopUp(dragAvatar);
			}
			if ((dragAvatar is InteractiveObject)) {
				(cast dragAvatar : InteractiveObject).mouseEnabled = _oldDragAvatarMouseEnabled;
			}
			if ((dragAvatar is DisplayObjectContainer)) {
				(cast dragAvatar : DisplayObjectContainer).mouseChildren = _oldDragAvatarMouseChildren;
			}
			dragAvatar = null;
		}
		dragSource = null;
		dragData = null;
	}

	private static function updateDropTarget(stage:Stage, globalX:Float, globalY:Float):Void {
		var location = new Point(globalX, globalY);
		var newTarget:IDropTarget = null;
		var objectsUnderPoint = stage.getObjectsUnderPoint(location);
		for (object in objectsUnderPoint) {
			if ((object is InteractiveObject)) {
				var interactiveObject = (cast object : InteractiveObject);
				if (!interactiveObject.mouseEnabled) {
					continue;
				}
			}
			var current = object;
			while (current != null) {
				if ((current is IDropTarget)) {
					newTarget = cast current;
					break;
				}
				current = current.parent;
			}
			if (newTarget != null) {
				break;
			}
		}
		if (newTarget != null) {
			location = (cast newTarget : DisplayObject).globalToLocal(location);
		}
		if (newTarget != currentDropTarget) {
			if (currentDropTarget != null) {
				// notice that we can reuse the previously saved location
				DragDropEvent.dispatch(currentDropTarget, DragDropEvent.DRAG_EXIT, dragData, false, _dropTargetLocalX, _dropTargetLocalY, dragSource);
			}
			currentDropTarget = newTarget;
			dropAccepted = false;
			if (currentDropTarget != null) {
				_dropTargetLocalX = location.x;
				_dropTargetLocalY = location.y;
				DragDropEvent.dispatch(currentDropTarget, DragDropEvent.DRAG_ENTER, dragData, false, _dropTargetLocalX, _dropTargetLocalY, dragSource);
			}
		} else if (currentDropTarget != null) {
			_dropTargetLocalX = location.x;
			_dropTargetLocalY = location.y;
			DragDropEvent.dispatch(currentDropTarget, DragDropEvent.DRAG_MOVE, dragData, false, _dropTargetLocalX, _dropTargetLocalY, dragSource);
		}
	}

	private static function dragDropManager_stage_mouseMoveHandler(event:MouseEvent):Void {
		var stage = cast(event.currentTarget, Stage);
		if (dragAvatar != null) {
			dragAvatar.x = stage.mouseX + dragAvatarOffsetX;
			dragAvatar.y = stage.mouseY + dragAvatarOffsetY;
		}
		updateDropTarget(stage, stage.mouseX, stage.mouseY);
	}

	private static function dragDropManager_stage_mouseUpHandler(event:MouseEvent):Void {
		var isDropped = false;
		if (currentDropTarget != null && dropAccepted) {
			DragDropEvent.dispatch(currentDropTarget, DragDropEvent.DRAG_DROP, dragData, true, _dropTargetLocalX, _dropTargetLocalY, dragSource);
			isDropped = true;
		}
		currentDropTarget = null;
		completeDrag(isDropped);
	}
}
