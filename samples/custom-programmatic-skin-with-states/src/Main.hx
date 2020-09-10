import feathers.controls.Application;
import feathers.controls.Button;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

class Main extends Application {
	public function new() {
		super();

		this.layout = new AnchorLayout();

		var button = new Button();
		button.text = "Click Me";
		button.backgroundSkin = new CustomButtonSkin();
		button.width = 200.0;
		button.height = 100.0;
		button.layoutData = AnchorLayoutData.center();
		this.addChild(button);
	}
}
