import feathers.controls.Panel;
import feathers.controls.LayoutGroup;
import feathers.controls.Label;
import com.feathersui.controls.PoweredByFeathersUI;
import feathers.layout.VerticalLayout;
import feathers.style.Theme;
import feathers.layout.AnchorLayoutData;
import feathers.layout.AnchorLayout;
import feathers.controls.Application;
import feathers.controls.Button;

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

	private function createHeader():LayoutGroup {
		var header = new LayoutGroup();
		header.variant = LayoutGroup.VARIANT_TOOL_BAR;
		header.layout = new AnchorLayout();

		var title = new Label();
		title.variant = Label.VARIANT_HEADING;
		title.text = "Custom Theme";
		title.layoutData = AnchorLayoutData.center();
		header.addChild(title);

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
