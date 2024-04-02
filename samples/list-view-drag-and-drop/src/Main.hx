import feathers.layout.HorizontalLayoutData;
import feathers.layout.HorizontalLayout;
import feathers.controls.Header;
import openfl.events.Event;
import feathers.data.ArrayCollection;
import feathers.controls.PopUpListView;
import feathers.controls.ListView;
import feathers.layout.AnchorLayoutData;
import feathers.layout.AnchorLayout;
import feathers.controls.Panel;
import feathers.controls.LayoutGroup;
import feathers.controls.Application;
import com.feathersui.controls.PoweredByFeathersUI;

class Main extends Application {
	public function new() {
		super();

		// just some bootstrapping code for our app
		this.initializeView();

		this.listView1 = new ListView();
		this.listView1.dataProvider = new ArrayCollection([
			{text: "One"},
			{text: "Two"},
			{text: "Three"},
		]);
		this.listView1.itemToText = (item:Dynamic) -> {
			return item.text;
		};
		// allow items to be dragged from this list view
		this.listView1.dragEnabled = true;
		// if they are successfully dropped on the other list view,
		// the items will be removed from this list view's data provider
		this.listView1.removeOnDragDropComplete = true;
		this.listView1.layoutData = HorizontalLayoutData.fill();
		this.view.addChild(this.listView1);

		this.listView2 = new ListView();
		this.listView2.dataProvider = new ArrayCollection([
			{text: "One"},
			{text: "Two"},
			{text: "Three"},
			{text: "Four"},
			{text: "Five"},
			{text: "Six"},
			{text: "Seven"},
			{text: "Eight"},
			{text: "Nine"},
			{text: "Ten"},
		]);
		this.listView2.itemToText = (item:Dynamic) -> {
			return item.text;
		};
		// allow items from the other list view to be dropped on this one
		this.listView2.dropEnabled = true;
		this.listView2.layoutData = HorizontalLayoutData.fill();
		this.view.addChild(this.listView2);
	}

	private var listView1:ListView;
	private var listView2:ListView;
	private var view:Panel;

	private function initializeView():Void {
		this.layout = new AnchorLayout();

		this.view = new Panel();
		this.view.layoutData = AnchorLayoutData.fill();

		var header = new Header();
		header.text = "Drag and Drop";
		this.view.header = header;

		var footer = new LayoutGroup();
		footer.variant = LayoutGroup.VARIANT_TOOL_BAR;
		footer.layout = new AnchorLayout();
		var poweredBy = new PoweredByFeathersUI();
		poweredBy.layoutData = AnchorLayoutData.center();
		footer.addChild(poweredBy);
		this.view.footer = footer;

		this.view.layout = new HorizontalLayout();
		this.addChild(this.view);
	}
}

/**
	A custom class to hold data for the PopUpListView where the user chooses how
	the ListView data provider should be sorted.
**/
class SortItem {
	public function new(text:String, sortCompareFunction:(Dynamic, Dynamic) -> Int) {
		this.text = text;
		this.sortCompareFunction = sortCompareFunction;
	}

	public var text:String;
	public var sortCompareFunction:(Dynamic, Dynamic) -> Int;

	@:keep
	public function toString():String {
		return this.text;
	}
}
