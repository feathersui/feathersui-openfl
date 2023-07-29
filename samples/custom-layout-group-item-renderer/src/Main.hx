import feathers.controls.Application;
import feathers.controls.AssetLoader;
import feathers.controls.Label;
import feathers.controls.ListView;
import feathers.controls.dataRenderers.LayoutGroupItemRenderer;
import feathers.data.ArrayCollection;
import feathers.data.ListViewItemState;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.TiledRowsListLayout;
import feathers.layout.VerticalLayout;
import feathers.utils.DisplayObjectRecycler;

class Main extends Application {
	public function new() {
		super();

		this.layout = new AnchorLayout();

		this.listView = new ListView();
		this.listView.dataProvider = new ArrayCollection([
			new ListItem("Haxe", "assets/img/haxe.png"),
			new ListItem("Lime", "assets/img/lime.png"),
			new ListItem("OpenFL", "assets/img/openfl.png"),
			new ListItem("Feathers UI", "assets/img/feathersui.png"),
		]);
		this.listView.itemToText = (item:ListItem) -> {
			return item.name;
		};
		this.listView.layout = new TiledRowsListLayout();
		this.listView.itemRendererRecycler = DisplayObjectRecycler.withFunction(() -> {
			var itemRenderer = new LayoutGroupItemRenderer();
			var layout = new VerticalLayout();
			layout.gap = 5;
			layout.setPadding(5);
			layout.horizontalAlign = CENTER;
			layout.verticalAlign = MIDDLE;
			itemRenderer.layout = layout;

			var iconLoader = new AssetLoader();
			iconLoader.name = "loader";
			iconLoader.width = 75.0;
			iconLoader.height = 75.0;
			itemRenderer.addChild(iconLoader);
			var titleLabel = new Label();
			titleLabel.name = "title";
			itemRenderer.addChild(titleLabel);
			return itemRenderer;
		}, (itemRenderer:LayoutGroupItemRenderer, state:ListViewItemState) -> {
			var iconLoader = cast(itemRenderer.getChildByName("loader"), AssetLoader);
			var titleLabel = cast(itemRenderer.getChildByName("title"), Label);

			var data = cast(state.data, ListItem);

			iconLoader.source = data.icon;
			titleLabel.text = state.text;
		});
		this.listView.layoutData = AnchorLayoutData.fill();
		this.addChild(this.listView);
	}

	private var listView:ListView;
}
