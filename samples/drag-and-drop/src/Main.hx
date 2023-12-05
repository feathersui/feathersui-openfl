import feathers.layout.VerticalLayout;
import feathers.layout.HorizontalLayout;
import feathers.controls.LayoutGroup;
import feathers.controls.Application;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.events.TriggerEvent;
import openfl.display.Sprite;

class Main extends Application {
	private static final CUSTOM_DRAG_FORMAT:String = "myDraggableSprite";

	public function new() {
		super();
	}

	private var _draggableSprite:Sprite;
	private var _dragSource:CustomDragSource;
	private var _dropTarget:CustomDropTarget;
	private var _resetButton:Button;

	override private function initialize():Void {
		super.initialize();

		var appLayout = new VerticalLayout();
		appLayout.horizontalAlign = CENTER;
		appLayout.verticalAlign = MIDDLE;
		appLayout.gap = 20.0;
		this.layout = appLayout;

		var instructions = new Label();
		instructions.text = "Drag the square from the left container to the right container.";
		this.addChild(instructions);

		var centerLayout = new HorizontalLayout();
		centerLayout.gap = 20.0;
		var centerContainer = new LayoutGroup();
		centerContainer.layout = centerLayout;
		this.addChild(centerContainer);

		this._dragSource = new CustomDragSource(CUSTOM_DRAG_FORMAT);
		this._dragSource.width = 320;
		this._dragSource.height = 420;
		this._dragSource.x = 80;
		this._dragSource.y = 80;
		centerContainer.addChild(this._dragSource);

		this._dropTarget = new CustomDropTarget(CUSTOM_DRAG_FORMAT);
		this._dropTarget.width = 320;
		this._dropTarget.height = 420;
		this._dropTarget.x = 560;
		this._dropTarget.y = 80;
		centerContainer.addChild(this._dropTarget);

		this._resetButton = new Button();
		this._resetButton.text = "Reset";
		this._resetButton.addEventListener(TriggerEvent.TRIGGER, resetButton_triggerHandler);
		this.addChild(this._resetButton);

		this._draggableSprite = new Sprite();
		this._draggableSprite.graphics.beginFill(0xff8800);
		this._draggableSprite.graphics.drawRect(0.0, 0.0, 100.0, 100.0);
		this._draggableSprite.graphics.endFill();

		this.reset();
	}

	private function reset():Void {
		this._draggableSprite.x = 40;
		this._draggableSprite.y = 40;
		this._dragSource.addChild(this._draggableSprite);
	}

	private function resetButton_triggerHandler(event:TriggerEvent):Void {
		this.reset();
	}
}
