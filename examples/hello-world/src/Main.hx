import feathers.controls.Button;
import feathers.events.FeathersEvent;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new() {
		super();

		var button = new Button();
		button.x = 10.0;
		button.y = 10.0;
		button.text = "Click Me";
		button.addEventListener(FeathersEvent.TRIGGERED, button_triggeredHandler);
		this.addChild(button);
	}

	private function button_triggeredHandler(event:FeathersEvent):Void
	{
		trace("Hello World!");
	}
}