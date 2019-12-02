import openfl.text.TextFormatAlign;
import feathers.controls.Label;
import openfl.text.TextFormat;
import feathers.controls.ButtonState;
import feathers.controls.Button;
import feathers.skins.RectangleSkin;
import feathers.themes.steel.SteelTheme;

class CalculatorTheme extends SteelTheme {
	public static final VARIANT_INPUT_DISPLAY_LABEL = "calculator-theme-input-display-label";
	public static final VARIANT_OPERATION_BUTTON = "calculator-theme-operation-button";

	public function new() {
		super();
		this.darkMode = true;

		this.styleProvider.setStyleFunction(Button, null, setButtonStyles);
		this.styleProvider.setStyleFunction(Button, VARIANT_OPERATION_BUTTON, setOperationButtonStyles);
		this.styleProvider.setStyleFunction(Label, VARIANT_INPUT_DISPLAY_LABEL, setInputDisplayLabelStyles);
	}

	override private function refreshFontSizes():Void {
		super.refreshFontSizes();
		this.fontSize = 60;
	}

	private function setInputDisplayLabelStyles(label:Label):Void {
		if (label.textFormat == null) {
			label.textFormat = new TextFormat(this.fontName, this.fontSize, this.textColor, null, null, null, null, null, TextFormatAlign.RIGHT);
		}

		label.paddingTop = 4.0;
		label.paddingRight = 4.0;
		label.paddingBottom = 4.0;
		label.paddingLeft = 4.0;
	}

	private function setButtonStyles(button:Button):Void {
		if (button.backgroundSkin == null) {
			var skin = new RectangleSkin();
			skin.fill = SolidColor(0x5f5f5f);
			button.backgroundSkin = skin;
		}
		if (button.getSkinForState(ButtonState.DOWN) == null) {
			var skin = new RectangleSkin();
			skin.fill = SolidColor(0x000000);
			button.setSkinForState(ButtonState.DOWN, skin);
		}

		if (button.textFormat == null) {
			button.textFormat = this.getTextFormat();
		}
		if (button.disabledTextFormat == null) {
			button.disabledTextFormat = this.getDisabledTextFormat();
		}

		if (button.getTextFormatForState(ButtonState.DOWN) == null) {
			button.setTextFormatForState(ButtonState.DOWN, this.getActiveTextFormat());
		}

		button.paddingTop = 4.0;
		button.paddingRight = 10.0;
		button.paddingBottom = 4.0;
		button.paddingLeft = 10.0;
		button.gap = 6.0;
	}

	private function setOperationButtonStyles(button:Button):Void {
		if (button.backgroundSkin == null) {
			var skin = new RectangleSkin();
			skin.fill = SolidColor(0xff9500);
			button.backgroundSkin = skin;
		}
		if (button.getSkinForState(ButtonState.DOWN) == null) {
			var skin = new RectangleSkin();
			skin.fill = SolidColor(0x000000);
			button.setSkinForState(ButtonState.DOWN, skin);
		}

		if (button.textFormat == null) {
			button.textFormat = this.getTextFormat();
		}
		if (button.disabledTextFormat == null) {
			button.disabledTextFormat = this.getDisabledTextFormat();
		}

		if (button.getTextFormatForState(ButtonState.DOWN) == null) {
			button.setTextFormatForState(ButtonState.DOWN, this.getActiveTextFormat());
		}

		button.paddingTop = 4.0;
		button.paddingRight = 10.0;
		button.paddingBottom = 4.0;
		button.paddingLeft = 10.0;
		button.gap = 6.0;
	}
}
