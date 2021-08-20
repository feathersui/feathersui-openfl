import feathers.core.ScreenDensityScaleManager;
import feathers.core.DefaultToolTipManager;
import feathers.skins.MultiSkin;
import feathers.controls.Application;
import feathers.style.IDarkModeTheme;
import feathers.style.IStyleProvider;
import feathers.style.IStyleObject;
import feathers.style.ITheme;
import feathers.style.ClassVariantStyleProvider;
import feathers.style.Theme;
import openfl.text.TextFormatAlign;
import feathers.controls.Label;
import openfl.text.TextFormat;
import feathers.controls.ButtonState;
import feathers.controls.Button;
import feathers.skins.RectangleSkin;

class CalculatorTheme implements ITheme {
	public static final VARIANT_INPUT_DISPLAY_LABEL = "calculator-theme-input-display-label";
	public static final VARIANT_OPERATION_BUTTON = "calculator-theme-operation-button";

	public function new() {
		// this is a dark theme, set set the default theme to dark mode
		cast(Theme.fallbackTheme, IDarkModeTheme).darkMode = true;

		this.styleProvider = new ClassVariantStyleProvider();
		this.styleProvider.setStyleFunction(Application, null, setApplicationStyles);
		this.styleProvider.setStyleFunction(Button, null, setButtonStyles);
		this.styleProvider.setStyleFunction(Label, DefaultToolTipManager.CHILD_VARIANT_TOOL_TIP, setToolTipStyles);
		this.styleProvider.setStyleFunction(Button, VARIANT_OPERATION_BUTTON, setOperationButtonStyles);
		this.styleProvider.setStyleFunction(Label, VARIANT_INPUT_DISPLAY_LABEL, setInputDisplayLabelStyles);
	}

	private var fontName = "_sans";
	private var fontSize = 50;
	private var textColor = 0xf1f1f1;
	private var backgroundColor = 0x383838;
	private var activeColor = 0x000000;
	private var controlColor = 0x5f5f5f;
	private var operationColor = 0xff9500;
	private var toolTipBackgroundColor = 0x000000;
	private var padding = 6.0;

	private var styleProvider:ClassVariantStyleProvider;

	public function getStyleProvider(target:IStyleObject):IStyleProvider {
		return styleProvider;
	}

	public function dispose():Void {}

	private function getInputDisplayLabelTextFormat():TextFormat {
		var result = this.getTextFormat();
		result.align = TextFormatAlign.RIGHT;
		return result;
	}

	private function getTextFormat():TextFormat {
		return new TextFormat(this.fontName, this.fontSize, this.textColor);
	}

	private function setApplicationStyles(app:Application):Void {
		if (app.backgroundSkin == null) {
			var skin = new RectangleSkin();
			skin.fill = SolidColor(this.backgroundColor);
			app.backgroundSkin = skin;
		}
		app.stage.color = this.backgroundColor;
		if (app.scaleManager == null) {
			app.scaleManager = new ScreenDensityScaleManager();
		}
	}

	private function setButtonStyles(button:Button):Void {
		if (button.backgroundSkin == null) {
			var skin = new RectangleSkin();
			skin.fill = SolidColor(this.controlColor);
			skin.setFillForState(ButtonState.DOWN, SolidColor(this.activeColor));
			button.backgroundSkin = skin;
		}

		if (button.textFormat == null) {
			button.textFormat = this.getTextFormat();
		}

		button.setPadding(this.padding);
		button.gap = this.padding;
	}

	private function setOperationButtonStyles(button:Button):Void {
		if (button.backgroundSkin == null) {
			var skin = new RectangleSkin();
			skin.fill = SolidColor(this.operationColor);
			skin.setFillForState(ButtonState.DOWN, SolidColor(this.activeColor));
			button.backgroundSkin = skin;
		}

		if (button.textFormat == null) {
			button.textFormat = this.getTextFormat();
		}

		button.setPadding(this.padding);
		button.gap = this.padding;
	}

	private function setInputDisplayLabelStyles(label:Label):Void {
		if (label.textFormat == null) {
			label.textFormat = this.getInputDisplayLabelTextFormat();
		}

		label.setPadding(this.padding);
	}

	private function setToolTipStyles(toolTip:Label):Void {
		if (toolTip.backgroundSkin == null) {
			var skin = new RectangleSkin();
			skin.fill = SolidColor(this.toolTipBackgroundColor);
			toolTip.backgroundSkin = skin;
		}

		if (toolTip.textFormat == null) {
			toolTip.textFormat = this.getTextFormat();
		}

		toolTip.setPadding(this.padding);
	}
}
