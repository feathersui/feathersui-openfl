package com.feathersui.hn.views;

import com.feathersui.hn.views.controls.CommentItemRenderer;
import com.feathersui.hn.views.controls.ItemHeaderItemRenderer;
import com.feathersui.hn.vo.Item;
import feathers.controls.LayoutGroup;
import feathers.controls.TreeView;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.controls.navigators.RouterNavigator;
import feathers.data.ArrayHierarchicalCollection;
import feathers.data.TreeViewItemState;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.utils.DisplayObjectRecycler;
import haxe.Json;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;

class ItemView extends LayoutGroup {
	private static final LOADING_ITEM = {};
	private static final ERROR_ITEM = {};
	private static final HEADER_ITEM_RECYCLER_ID = "header";
	private static final LOADING_ITEM_RECYCLER_ID = "loading";
	private static final ERROR_ITEM_RECYCLER_ID = "error";

	public function new() {
		super();
	}

	private var _itemsTreeView:TreeView;

	override private function initialize():Void {
		super.initialize();

		layout = new AnchorLayout();

		_itemsTreeView = new TreeView();
		_itemsTreeView.itemRendererRecycler = DisplayObjectRecycler.withClass(CommentItemRenderer);
		_itemsTreeView.setItemRendererRecycler(HEADER_ITEM_RECYCLER_ID, DisplayObjectRecycler.withClass(ItemHeaderItemRenderer));
		_itemsTreeView.setItemRendererRecycler(LOADING_ITEM_RECYCLER_ID,
			DisplayObjectRecycler.withClass(ItemRenderer, (itemRenderer, state:TreeViewItemState) -> {
				itemRenderer.text = "Loading...";
			}));
		_itemsTreeView.setItemRendererRecycler(ERROR_ITEM_RECYCLER_ID,
			DisplayObjectRecycler.withClass(ItemRenderer, (itemRenderer, state:TreeViewItemState) -> {
				itemRenderer.text = "Error loading feed";
			}));
		_itemsTreeView.itemRendererRecyclerIDFunction = (state) -> {
			if (state.data == LOADING_ITEM) {
				return LOADING_ITEM_RECYCLER_ID;
			}
			if (state.data == ERROR_ITEM) {
				return ERROR_ITEM_RECYCLER_ID;
			}
			if (state.location.length == 1 && state.location[0] == 0) {
				return HEADER_ITEM_RECYCLER_ID;
			}
			return null;
		}
		_itemsTreeView.selectable = false;
		_itemsTreeView.layoutData = AnchorLayoutData.fill();
		addChild(_itemsTreeView);

		var navigator = cast(parent, RouterNavigator);
		var itemID = Reflect.field(navigator.urlVariables, "id");

		_itemsTreeView.dataProvider = new ArrayHierarchicalCollection([LOADING_ITEM]);

		var loader = new URLLoader();
		loader.dataFormat = TEXT;
		loader.addEventListener(Event.COMPLETE, itemLoader_completeHandler);
		loader.addEventListener(IOErrorEvent.IO_ERROR, itemLoader_errorHandler);
		loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, itemLoader_errorHandler);
		loader.load(new URLRequest('https://api.hnpwa.com/v0/item/${itemID}.json'));
	}

	private function itemLoader_errorHandler(event:Event):Void {
		trace("error: " + event);

		_itemsTreeView.dataProvider = new ArrayHierarchicalCollection([ERROR_ITEM]);
	}

	private function itemLoader_completeHandler(event:Event):Void {
		var userLoader = cast(event.currentTarget, URLLoader);
		var userData = (userLoader.data : String);
		try {
			var rootItem = (Json.parse(userData) : Item);
			_itemsTreeView.dataProvider = new ArrayHierarchicalCollection([rootItem], (item:Item) -> {
				return item.comments;
			});
			_itemsTreeView.toggleChildrenOf(rootItem, true);
		} catch (e) {
			trace("error: " + e);
			_itemsTreeView.dataProvider = new ArrayHierarchicalCollection([ERROR_ITEM]);
		}
	}
}
