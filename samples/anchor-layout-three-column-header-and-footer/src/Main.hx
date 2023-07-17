import feathers.controls.Application;
import feathers.controls.LayoutGroup;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.RectangleSkin;

class Main extends Application {
	public function new() {
		super();
	}

	override private function initialize():Void {
		this.layout = new AnchorLayout();
		
		var header = new LayoutGroup();
		header.height = 60.0;
		header.backgroundSkin = new RectangleSkin(SolidColor(0x333333));
		var headerLayoutData = new AnchorLayoutData();
		headerLayoutData.top = 0.0;
		headerLayoutData.left = 0.0;
		headerLayoutData.right = 0.0;
		header.layoutData = headerLayoutData;
		this.addChild(header);

		var footer = new LayoutGroup();
		footer.height = 60.0;
		footer.backgroundSkin = new RectangleSkin(SolidColor(0x666666));
		var footerLayoutData = new AnchorLayoutData();
		footerLayoutData.bottom = 0.0;
		footerLayoutData.left = 0.0;
		footerLayoutData.right = 0.0;
		footer.layoutData = footerLayoutData;
		this.addChild(footer);

		var leftColumn = new LayoutGroup();
		leftColumn.width = 100.0;
		leftColumn.backgroundSkin = new RectangleSkin(SolidColor(0xcccccc));
		var leftColumnLayoutData = new AnchorLayoutData();
		leftColumnLayoutData.top = new Anchor(0.0, header);
		leftColumnLayoutData.bottom = new Anchor(0.0, footer);
		leftColumnLayoutData.left = 0.0;
		leftColumn.layoutData = leftColumnLayoutData;
		this.addChild(leftColumn);

		var rightColumn = new LayoutGroup();
		rightColumn.backgroundSkin = new RectangleSkin(SolidColor(0x999999));
		rightColumn.width = 100.0;
		var rightColumnLayoutData = new AnchorLayoutData();
		rightColumnLayoutData.top = new Anchor(0.0, header);
		rightColumnLayoutData.bottom = new Anchor(0.0, footer);
		rightColumnLayoutData.right = 0.0;
		rightColumn.layoutData = rightColumnLayoutData;
		this.addChild(rightColumn);

		var centerColumn = new LayoutGroup();
		centerColumn.backgroundSkin = new RectangleSkin(SolidColor(0xffffff));
		centerColumn.alpha = 0.5;
		var centerColumnLayoutData = new AnchorLayoutData();
		centerColumnLayoutData.top = new Anchor(0.0, header);
		centerColumnLayoutData.bottom = new Anchor(0.0, footer);
		centerColumnLayoutData.right = new Anchor(0.0, rightColumn);
		centerColumnLayoutData.left = new Anchor(0.0, leftColumn);
		centerColumn.layoutData = centerColumnLayoutData;
		this.addChild(centerColumn);
	}
}
