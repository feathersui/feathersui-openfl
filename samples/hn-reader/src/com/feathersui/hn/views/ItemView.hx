package com.feathersui.hn.views;

import com.feathersui.hn.views.controls.CommentItemRenderer;
import com.feathersui.hn.views.controls.ItemHeaderItemRenderer;
import com.feathersui.hn.vo.Item;
import feathers.controls.LayoutGroup;
import feathers.controls.TreeView;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.data.ArrayHierarchicalCollection;
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

	private var _itemLoader:URLLoader;

	@:isVar
	public var itemID(default, set):String;

	private function set_itemID(value:String):String {
		if (itemID == value) {
			return itemID;
		}
		itemID = value;

		if (initialized) {
			loadItem();
		}

		setInvalid(DATA);
		return itemID;
	}

	private var _itemsTreeView:TreeView;

	override private function initialize():Void {
		super.initialize();

		layout = new AnchorLayout();

		_itemsTreeView = new TreeView();
		_itemsTreeView.itemToText = (item:Any) -> {
			if (item == LOADING_ITEM) {
				return "Loading...";
			}
			if (item == ERROR_ITEM) {
				return "Error loading feed";
			}
			return (item : Item).content;
		}
		_itemsTreeView.itemRendererRecycler = DisplayObjectRecycler.withClass(CommentItemRenderer);
		_itemsTreeView.setItemRendererRecycler(HEADER_ITEM_RECYCLER_ID, DisplayObjectRecycler.withClass(ItemHeaderItemRenderer));
		_itemsTreeView.setItemRendererRecycler(LOADING_ITEM_RECYCLER_ID, DisplayObjectRecycler.withClass(ItemRenderer));
		_itemsTreeView.setItemRendererRecycler(ERROR_ITEM_RECYCLER_ID, DisplayObjectRecycler.withClass(ItemRenderer));
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

		loadItem();
	}

	private function loadItem():Void {
		if (_itemLoader != null) {
			_itemLoader.close();
			_itemLoader = null;
		}

		if (itemID == null) {
			return;
		}

		_itemsTreeView.dataProvider = new ArrayHierarchicalCollection([LOADING_ITEM]);

		_itemLoader = new URLLoader();
		_itemLoader.dataFormat = TEXT;
		_itemLoader.addEventListener(Event.COMPLETE, itemLoader_completeHandler);
		_itemLoader.addEventListener(IOErrorEvent.IO_ERROR, itemLoader_errorHandler);
		_itemLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, itemLoader_errorHandler);
		_itemLoader.load(new URLRequest('https://api.hnpwa.com/v0/item/${itemID}.json'));
	}

	private function itemLoader_errorHandler(event:Event):Void {
		trace("error: " + event);

		_itemLoader = null;

		_itemsTreeView.dataProvider = new ArrayHierarchicalCollection([ERROR_ITEM]);
	}

	private function itemLoader_completeHandler(event:Event):Void {
		var itemData = (_itemLoader.data : String);
		_itemLoader = null;

		try {
			var rootItem = (Json.parse(itemData) : Item);
			_itemsTreeView.dataProvider = new ArrayHierarchicalCollection([rootItem], (item:Item) -> {
				return item.comments;
			});
			_itemsTreeView.toggleChildrenOf(rootItem, true);
		} catch (e:Dynamic) {
			trace("error: " + e);
			_itemsTreeView.dataProvider = new ArrayHierarchicalCollection([ERROR_ITEM]);
		}
	}
}
