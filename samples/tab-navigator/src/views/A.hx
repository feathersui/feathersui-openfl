package views;

import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

class A extends Panel {
	public function new() {
		super();
	}

	override private function initialize():Void {
		super.initialize();

		this.layout = new AnchorLayout();

		var header = new LayoutGroup();
		header.variant = LayoutGroup.VARIANT_TOOL_BAR;
		header.layout = new AnchorLayout();
		this.header = header;

		var title = new Label();
		title.variant = Label.VARIANT_HEADING;
		title.text = "A";
		title.layoutData = AnchorLayoutData.center();
		header.addChild(title);
	}
}
