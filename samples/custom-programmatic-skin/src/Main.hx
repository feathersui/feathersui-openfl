import feathers.controls.Application;
import feathers.controls.Label;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.text.TextFormat;

class Main extends Application {
	public function new() {
		super();

		this.layout = new AnchorLayout();

		var label = new Label();
		label.backgroundSkin = new CustomSkin();
		label.text = "CINEMA\nADMIT ONE";
		label.textFormat = new TextFormat("_sans", 30, 0xee5555, true, null, null, null, null, CENTER);
		label.verticalAlign = MIDDLE;
		label.layoutData = AnchorLayoutData.center();
		label.width = 250.0;
		label.height = 125.0;
		this.addChild(label);
	}
}
