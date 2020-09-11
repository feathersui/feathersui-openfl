import openfl.filters.DropShadowFilter;
import openfl.text.TextFormat;
import feathers.controls.Application;
import feathers.controls.Button;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

class Main extends Application {
	public function new() {
		super();

		this.layout = new AnchorLayout();

		var button = new Button();
		button.text = "CLICK ME";
		button.backgroundSkin = new CustomSkin();
		button.textFormat = new TextFormat("_sans", 16, 0xffffff, true);
		button.layoutData = AnchorLayoutData.center();
		button.width = 150.0;
		button.height = 70.0;
		this.addChild(button);
	}
}
