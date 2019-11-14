import openfl.net.URLRequest;
import openfl.Lib;
import openfl.events.MouseEvent;
import feathers.controls.AssetLoader;
import feathers.controls.Label;
import feathers.layout.VerticalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.controls.Button;
import feathers.layout.HorizontalLayout;
import feathers.controls.LayoutGroup;
import feathers.controls.Application;
import com.feathersui.controls.PoweredByFeathersUI;

class Main extends Application {
	public function new() {
		super();

		// we're going to stack several containers vertically.
		// they'll each fill the entire width of the app (minus some padding).
		var appLayout = new VerticalLayout();
		appLayout.verticalAlign = MIDDLE;
		appLayout.horizontalAlign = JUSTIFY;
		appLayout.paddingTop = 10.0;
		appLayout.paddingRight = 10.0;
		appLayout.paddingBottom = 10.0;
		appLayout.paddingLeft = 10.0;
		appLayout.gap = 20.0;
		this.layout = appLayout;

		var title = new Label();
		title.variant = Label.VARIANT_HEADING;
		title.text = "Percentage Sizing";
		this.addChild(title);

		// this group will have 3 items with percentWidth set to 33%
		this.create33PercentGroup();
		// this group will have 2 items with percentWidth set to 50%
		this.create50PercentGroup();
		// this group will have 1 item with percentWidth set to 100%
		this.create100PercentGroup();
		// this group will have several items with different percentWidth values
		this.createMixedPercentGroup();

		this.addChild(new PoweredByFeathersUI());
	}

	private function create33PercentGroup():LayoutGroup {
		var group = new LayoutGroup();
		group.layout = new HorizontalLayout();
		this.addChild(group);

		for (i in 0...3) {
			var child = new Button();
			child.text = "33%";
			var layoutData = new HorizontalLayoutData();
			layoutData.percentWidth = 33.3333;
			child.layoutData = layoutData;
			child.height = 100.0; // pixels
			group.addChild(child);
		}

		return group;
	}

	private function create50PercentGroup():LayoutGroup {
		var group = new LayoutGroup();
		group.layout = new HorizontalLayout();
		this.addChild(group);

		for (i in 0...2) {
			var child = new Button();
			child.text = "50%";
			var layoutData = new HorizontalLayoutData();
			layoutData.percentWidth = 50.0;
			child.layoutData = layoutData;
			child.height = 100.0; // pixels
			group.addChild(child);
		}

		return group;
	}

	private function create100PercentGroup():LayoutGroup {
		var group = new LayoutGroup();
		group.layout = new HorizontalLayout();
		this.addChild(group);

		var child = new Button();
		child.text = "100%";
		var layoutData = new HorizontalLayoutData();
		layoutData.percentWidth = 100.0;
		child.layoutData = layoutData;
		child.height = 100.0; // pixels
		group.addChild(child);

		return group;
	}

	private function createMixedPercentGroup():LayoutGroup {
		var group = new LayoutGroup();
		group.layout = new HorizontalLayout();
		this.addChild(group);

		var child10 = new Button();
		child10.text = "10%";
		var child10LayoutData = new HorizontalLayoutData();
		child10LayoutData.percentWidth = 10.0;
		child10.layoutData = child10LayoutData;
		child10.height = 100.0; // pixels
		group.addChild(child10);

		var child25 = new Button();
		child25.text = "25%";
		var child25LayoutData = new HorizontalLayoutData();
		child25LayoutData.percentWidth = 25.0;
		child25.layoutData = child25LayoutData;
		child25.height = 100.0; // pixels
		group.addChild(child25);

		var child45 = new Button();
		child45.text = "45%";
		var child45LayoutData = new HorizontalLayoutData();
		child45LayoutData.percentWidth = 45.0;
		child45.layoutData = child45LayoutData;
		child45.height = 100.0; // pixels
		group.addChild(child45);

		var child20 = new Button();
		child20.text = "20%";
		var child20LayoutData = new HorizontalLayoutData();
		child20LayoutData.percentWidth = 20.0;
		child20.layoutData = child20LayoutData;
		child20.height = 100.0; // pixels
		group.addChild(child20);

		return group;
	}
}
