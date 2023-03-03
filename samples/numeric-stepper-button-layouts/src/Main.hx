import feathers.controls.Application;
import feathers.controls.Button;
import feathers.controls.ButtonState;
import feathers.controls.LayoutGroup;
import feathers.controls.NumericStepper;
import feathers.controls.TextInput;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.Direction;
import feathers.layout.HorizontalAlign;
import feathers.layout.TiledRowsLayout;
import feathers.skins.RectangleSkin;
import openfl.display.DisplayObject;

class Main extends Application {
	public function new() {
		super();

		var appLayout = new TiledRowsLayout();
		appLayout.requestedColumnCount = 3;
		appLayout.setGap(30.0);
		appLayout.horizontalAlign = CENTER;
		appLayout.verticalAlign = MIDDLE;
		this.layout = appLayout;

		addChild(createNumericStepper(HORIZONTAL, LEFT));
		addChild(createNumericStepper(HORIZONTAL, CENTER));
		addChild(createNumericStepper(HORIZONTAL, RIGHT));
		addChild(createNumericStepper(VERTICAL, LEFT));
		addChild(createNumericStepper(VERTICAL, CENTER));
		addChild(createNumericStepper(VERTICAL, RIGHT));
	}

	private function createNumericStepper(buttonDirection:Direction, textInputPosition:HorizontalAlign):DisplayObject {
		var stepper = new NumericStepper();
		stepper.buttonDirection = buttonDirection;
		stepper.textInputPosition = textInputPosition;
		function buttonFactory() {
			var button = new Button();
			button.themeEnabled = false;
			var backgroundSkin = new RectangleSkin();
			backgroundSkin.border = None;
			backgroundSkin.fill = SolidColor(0xbbbbbb);
			backgroundSkin.setFillForState(ButtonState.HOVER, SolidColor(0xaaaaaa));
			backgroundSkin.setFillForState(ButtonState.HOVER, SolidColor(0x999999));
			backgroundSkin.cornerRadius = 4.0;
			button.backgroundSkin = backgroundSkin;
			button.width = 30.0;
			if (buttonDirection == VERTICAL && textInputPosition != CENTER) {
				button.height = 15.0;
			} else {
				button.height = 30.0;
			}
			return button;
		}
		stepper.decrementButtonFactory = buttonFactory;
		stepper.incrementButtonFactory = buttonFactory;
		stepper.textInputFactory = () -> {
			var textInput = new TextInput();
			var backgroundSkin = new RectangleSkin();
			backgroundSkin.border = SolidColor(1.0, 0x333333);
			backgroundSkin.fill = SolidColor(0xcccccc);
			backgroundSkin.cornerRadius = 4.0;
			textInput.backgroundSkin = backgroundSkin;
			return textInput;
		}
		stepper.textInputGap = 4.0;
		stepper.buttonGap = 2.0;
		stepper.layoutData = AnchorLayoutData.center();
		var wrapper = new LayoutGroup();
		wrapper.layout = new AnchorLayout();
		wrapper.addChild(stepper);
		return wrapper;
	}
}
