import feathers.controls.LayoutGroup;
import feathers.dragDrop.DragData;
import feathers.dragDrop.DragDropManager;
import feathers.dragDrop.IDragSource;
import feathers.events.DragDropEvent;
import feathers.skins.RectangleSkin;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

class CustomDragSource extends LayoutGroup implements IDragSource {
	public function new(dragFormat:String) {
		super();
		this._dragFormat = dragFormat;
		this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		this.addEventListener(DragDropEvent.DRAG_START, dragStartHandler);
		this.addEventListener(DragDropEvent.DRAG_COMPLETE, dragCompleteHandler);
	}

	private var _draggedObject:DisplayObject;
	private var _dragFormat:String;

	override private function initialize():Void {
		super.initialize();
		this.backgroundSkin = new RectangleSkin(SolidColor(0x36322e));
	}

	private function mouseDownHandler(event:MouseEvent):Void {
		if (DragDropManager.dragging) {
			// one drag at a time, please
			return;
		}
		if (event.target == this || event.target == this.backgroundSkin) {
			return;
		}

		this._draggedObject = event.target;

		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler, false, 0, true);
	}

	private function stage_mouseMoveHandler(event:MouseEvent):Void {
		if (DragDropManager.dragging) {
			// one drag at a time, please
			return;
		}

		var dragAvatar = new Sprite();
		dragAvatar.graphics.beginFill(0xff8800);
		dragAvatar.graphics.drawRect(0.0, 0.0, 100.0, 100.0);
		dragAvatar.graphics.endFill();
		dragAvatar.alpha = 0.5;

		var dragData = new DragData();
		dragData.set(this._dragFormat, this._draggedObject);
		DragDropManager.startDrag(this, dragData, dragAvatar, -dragAvatar.width / 2, -dragAvatar.height / 2);
	}

	private function dragStartHandler(event:DragDropEvent):Void {
		// the drag was started with the call to DragDropManager.startDrag()
	}

	private function dragCompleteHandler(event:DragDropEvent):Void {
		this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);

		if (event.dropped) {
			// the object was dropped somewhere
		} else {
			// the drag was cancelled and the object was not dropped
		}
	}
}
