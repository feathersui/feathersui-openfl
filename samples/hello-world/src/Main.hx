import feathers.controls.Application;
import feathers.controls.Button;
import feathers.controls.TextCallout;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

// the Application component automatically scales the project to an appropriate
// size for any type of device, from mobile to desktop.
// using this component is optional. Feathers UI components may be added as
// children of any OpenFL display object.
class Main extends Application {
	public function new() {
		super();

		// a layout that allows easy positioning of children near the edges or
		// the center of a container
		this.layout = new AnchorLayout();

		this.button = new Button();
		// center the button both horizontally and vertically
		this.button.layoutData = AnchorLayoutData.center();
		// the text to display on the button
		this.button.text = "Click Me";
		// when the button is clicked or tapped, call a function
		this.button.addEventListener(TriggerEvent.TRIGGER, button_triggerHandler);

		// add the button as a child of the app
		this.addChild(this.button);
	}

	// store the button so that we can refer to it in other functions
	private var button:Button;

	private function button_triggerHandler(event:TriggerEvent):Void {
		// display a pop-up message when the button is clicked or tapped
		TextCallout.show("Hello World", this.button);
	}
}
