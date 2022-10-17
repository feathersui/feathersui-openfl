import feathers.controls.Application;
import feathers.controls.Button;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.style.IDarkModeTheme;
import feathers.style.Theme;

class Main extends Application {
	public function new() {
		// to enable dark mode for all UI components by default, set the
		// darkMode property before calling the root class super() constructor
		var theme = cast(Theme.fallbackTheme, IDarkModeTheme);
		theme.darkMode = true;

		super();

		this.initializeView();
	}

	private var switchModeButton:Button;

	private function initializeView():Void {
		this.layout = new AnchorLayout();

		this.switchModeButton = new Button();
		this.switchModeButton.layoutData = AnchorLayoutData.center();
		this.switchModeButton.addEventListener(TriggerEvent.TRIGGER, event -> {
			toggleMode();
		});
		this.addChild(this.switchModeButton);
		updateButtonText();
	}

	private function toggleMode():Void {
		var theme = cast(Theme.fallbackTheme, IDarkModeTheme);
		theme.darkMode = !theme.darkMode;
		updateButtonText();
	}

	private function updateButtonText():Void {
		var theme = cast(Theme.fallbackTheme, IDarkModeTheme);
		switchModeButton.text = theme.darkMode ? "Switch to Light Mode" : "Switch to Dark Mode";
	}
}
