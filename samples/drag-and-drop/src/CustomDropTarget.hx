import feathers.controls.LayoutGroup;
import feathers.dragDrop.IDropTarget;
import feathers.events.DragDropEvent;
import feathers.skins.RectangleSkin;
import openfl.display.DisplayObject;

class CustomDropTarget extends LayoutGroup implements IDropTarget {
	private static final DEFAULT_COLOR:UInt = 0x36322e;
	private static final HOVER_COLOR:UInt = 0x26221e;

	public function new(dragFormat:String) {
		super();
		this._dragFormat = dragFormat;
		this.addEventListener(DragDropEvent.DRAG_ENTER, dragEnterHandler);
		this.addEventListener(DragDropEvent.DRAG_EXIT, dragExitHandler);
		this.addEventListener(DragDropEvent.DRAG_DROP, dragDropHandler);
	}

	private var _dragFormat:String;
	private var _rectSkin:RectangleSkin;

	override private function initialize():Void {
		super.initialize();
		this._rectSkin = new RectangleSkin(SolidColor(DEFAULT_COLOR));
		this.backgroundSkin = this._rectSkin;
	}

	private function dragEnterHandler(event:DragDropEvent):Void {
		if (!event.dragData.exists(this._dragFormat)) {
			return;
		}
		event.acceptDrag(this);
		this._rectSkin.fill = SolidColor(HOVER_COLOR);
	}

	private function dragExitHandler(event:DragDropEvent):Void {
		this._rectSkin.fill = SolidColor(DEFAULT_COLOR);
	}

	private function dragDropHandler(event:DragDropEvent):Void {
		var droppedObject = cast(event.dragData.get(this._dragFormat), DisplayObject);
		droppedObject.x = Math.min(Math.max(event.localX - droppedObject.width / 2.0, 0.0),
			this.actualWidth - droppedObject.width); // keep within the bounds of the target
		droppedObject.y = Math.min(Math.max(event.localY - droppedObject.height / 2.0, 0.0),
			this.actualHeight - droppedObject.height); // keep within the bounds of the target
		this.addChild(droppedObject);

		this._rectSkin.fill = SolidColor(DEFAULT_COLOR);
	}
}
