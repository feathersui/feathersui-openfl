package com.feathersui.hn.views;

import com.feathersui.hn.views.controls.FeedItemRenderer;
import com.feathersui.hn.vo.FeedItem;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.data.ArrayCollection;
import feathers.data.ListViewItemState;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.utils.DisplayObjectRecycler;
import haxe.Json;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.events.TextEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;

class FeedView extends LayoutGroup {
	private static final MAX_PER_PAGE = 30;
	private static final MORE_ITEM = {};
	private static final LOADING_ITEM = {};
	private static final ERROR_ITEM = {};
	private static final MORE_ITEM_RECYCLER_ID = "more";
	private static final LOADING_ITEM_RECYCLER_ID = "loading";
	private static final ERROR_ITEM_RECYCLER_ID = "error";

	public function new(title:String, baseURL:String, feedName:String, maxPages:Int) {
		super();
		_title = title;
		_baseURL = baseURL;
		_feedName = feedName;
		_maxPages = maxPages;
	}

	private var _title:String;
	private var _baseURL:String;
	private var _feedName:String;
	private var _maxPages:Int;

	private var _feedLoader:URLLoader;

	@:isVar
	public var pageIndex(default, set):Int;

	private function set_pageIndex(value:Int):Int {
		if (value < 1) {
			value = 1;
		} else if (value > _maxPages) {
			value = _maxPages;
		}

		if (pageIndex == value) {
			return pageIndex;
		}
		pageIndex = value;

		if (initialized) {
			loadFeed();
		}

		setInvalid(DATA);
		return pageIndex;
	}

	private var _feedItemListView:ListView;

	override private function initialize():Void {
		super.initialize();

		layout = new AnchorLayout();

		_feedItemListView = new ListView();
		_feedItemListView.itemToText = (item:Any) -> {
			if (item == MORE_ITEM) {
				return "More...";
			}
			if (item == LOADING_ITEM) {
				return "Loading...";
			}
			if (item == ERROR_ITEM) {
				return "Error loading feed";
			}
			return (item : FeedItem).title;
		}

		_feedItemListView.itemRendererRecycler = DisplayObjectRecycler.withClass(FeedItemRenderer, (itemRenderer, state:ListViewItemState) -> {
			itemRenderer.pageIndex = pageIndex;
			itemRenderer.maxPerPage = MAX_PER_PAGE;
		});
		_feedItemListView.setItemRendererRecycler(MORE_ITEM_RECYCLER_ID, DisplayObjectRecycler.withFunction(() -> {
			var itemRenderer = new ItemRenderer();
			itemRenderer.addEventListener(TriggerEvent.TRIGGER, event -> {
				var nextPageIndex = pageIndex + 1;
				dispatchEvent(new TextEvent(TextEvent.LINK, false, false, 'router:${_baseURL}/${nextPageIndex}'));
			});
			return itemRenderer;
		}));
		_feedItemListView.setItemRendererRecycler(LOADING_ITEM_RECYCLER_ID, DisplayObjectRecycler.withClass(ItemRenderer));
		_feedItemListView.setItemRendererRecycler(ERROR_ITEM_RECYCLER_ID, DisplayObjectRecycler.withClass(ItemRenderer));
		_feedItemListView.itemRendererRecyclerIDFunction = (state) -> {
			if (state.data == LOADING_ITEM) {
				return LOADING_ITEM_RECYCLER_ID;
			}
			if (state.data == ERROR_ITEM) {
				return ERROR_ITEM_RECYCLER_ID;
			}
			if (state.data == MORE_ITEM) {
				return MORE_ITEM_RECYCLER_ID;
			}
			return null;
		}
		_feedItemListView.selectable = false;
		_feedItemListView.layoutData = AnchorLayoutData.fill();
		addChild(_feedItemListView);

		loadFeed();
	}

	private function loadFeed():Void {
		if (_feedLoader != null) {
			_feedLoader.close();
			_feedLoader = null;
		}

		_feedItemListView.dataProvider = new ArrayCollection([LOADING_ITEM]);

		_feedLoader = new URLLoader();
		_feedLoader.dataFormat = TEXT;
		_feedLoader.addEventListener(Event.COMPLETE, feedLoader_completeHandler);
		_feedLoader.addEventListener(IOErrorEvent.IO_ERROR, feedLoader_errorHandler);
		_feedLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, feedLoader_errorHandler);
		_feedLoader.load(new URLRequest('https://api.hnpwa.com/v0/$_feedName/$pageIndex.json'));
	}

	private function feedLoader_errorHandler(event:ErrorEvent):Void {
		trace("error: " + event);

		_feedLoader = null;

		_feedItemListView.dataProvider = new ArrayCollection([ERROR_ITEM]);
	}

	private function feedLoader_completeHandler(event:Event):Void {
		var feedData = (_feedLoader.data : String);
		_feedLoader = null;
		try {
			var feed = (Json.parse(feedData) : Array<Any>);
			if (pageIndex < _maxPages) {
				feed.push(MORE_ITEM);
			}
			_feedItemListView.dataProvider = new ArrayCollection(feed);
		} catch (e:Dynamic) {
			trace("error: " + e);
			_feedItemListView.dataProvider = new ArrayCollection([ERROR_ITEM]);
		}
	}
}
