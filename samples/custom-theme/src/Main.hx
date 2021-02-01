import com.feathersui.controls.PoweredByFeathersUI;
import feathers.controls.Application;
import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.VerticalLayout;
import feathers.style.Theme;

class Main extends Application {
	public function new() {
		super();

		Theme.setTheme(new CustomTheme());

		// just some bootstrapping code for our app
		this.initializeView();

		var description = new Label();
		description.text = "The buttons are styled by the custom theme, but everything else uses the default theme.";
		this.view.addChild(description);

		var themedButton = new Button();
		themedButton.text = "Themed Button";
		this.view.addChild(themedButton);

		var fancyButton = new Button();
		// a custom theme may provide custom variants
		fancyButton.variant = CustomTheme.VARIANT_FANCY_BUTTON;
		fancyButton.text = "Fancy Themed Button";
		this.view.addChild(fancyButton);
	}

	private var view:Panel;

	private function initializeView():Void {
		this.layout = new AnchorLayout();

		this.view = new Panel();
		this.view.layoutData = AnchorLayoutData.fill();
		this.view.header = this.createHeader();
		this.view.footer = this.createFooter();
		var viewLayout = new VerticalLayout();
		viewLayout.horizontalAlign = CENTER;
		viewLayout.verticalAlign = MIDDLE;
		viewLayout.gap = 20.0;
		this.view.layout = viewLayout;
		this.addChild(this.view);
	}

	private function createHeader():Header {
		var header = new Header();
		header.text = "Custom Theme";
		return header;
	}

	private function createFooter():LayoutGroup {
		var footer = new LayoutGroup();
		footer.variant = LayoutGroup.VARIANT_TOOL_BAR;
		footer.layout = new AnchorLayout();

		var poweredBy = new PoweredByFeathersUI();
		poweredBy.layoutData = AnchorLayoutData.center();
		footer.addChild(poweredBy);

		return footer;
	}
}
