package com.feathersui.hn.views;

import com.feathersui.hn.views.controls.FeedItemRenderer;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.controls.navigators.RouterNavigator;
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
	private var _pageIndex:Int;

	private var _feedItemListView:ListView;

	override private function initialize():Void {
		super.initialize();

		layout = new AnchorLayout();

		_feedItemListView = new ListView();

		_feedItemListView.itemRendererRecycler = DisplayObjectRecycler.withClass(FeedItemRenderer, (itemRenderer, state:ListViewItemState) -> {
			itemRenderer.pageIndex = _pageIndex;
			itemRenderer.maxPerPage = MAX_PER_PAGE;
		});
		_feedItemListView.setItemRendererRecycler(MORE_ITEM_RECYCLER_ID, DisplayObjectRecycler.withFunction(() -> {
			var itemRenderer = new ItemRenderer();
			itemRenderer.addEventListener(TriggerEvent.TRIGGER, event -> {
				var nextPageIndex = _pageIndex + 1;
				dispatchEvent(new TextEvent(TextEvent.LINK, false, false, 'router:${_baseURL}?p=${nextPageIndex}'));
			});
			return itemRenderer;
		}, (itemRenderer, state:ListViewItemState) -> {
			itemRenderer.text = "More...";
		}));
		_feedItemListView.setItemRendererRecycler(LOADING_ITEM_RECYCLER_ID,
			DisplayObjectRecycler.withClass(ItemRenderer, (itemRenderer, state:ListViewItemState) -> {
				itemRenderer.text = "Loading...";
			}));
		_feedItemListView.setItemRendererRecycler(ERROR_ITEM_RECYCLER_ID,
			DisplayObjectRecycler.withClass(ItemRenderer, (itemRenderer, state:ListViewItemState) -> {
				itemRenderer.text = "Error loading feed";
			}));
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

		var urlPageIndex = 1;
		var navigator = cast(parent, RouterNavigator);
		var pageString = Reflect.field(navigator.urlVariables, "p");
		if (pageString != null) {
			var result = Std.parseInt(pageString);
			if (result != null) {
				urlPageIndex = result;
			}
		}
		setPage(urlPageIndex);
	}

	private function setPage(index:Int):Void {
		if (index < 1) {
			index = 1;
		} else if (index > _maxPages) {
			index = _maxPages;
		}
		_pageIndex = index;

		_feedItemListView.dataProvider = new ArrayCollection([LOADING_ITEM]);

		var loader = new URLLoader();
		loader.dataFormat = TEXT;
		loader.addEventListener(Event.COMPLETE, feedLoader_completeHandler);
		loader.addEventListener(IOErrorEvent.IO_ERROR, feedLoader_errorHandler);
		loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, feedLoader_errorHandler);
		loader.load(new URLRequest('https://api.hnpwa.com/v0/$_feedName/$_pageIndex.json'));
	}

	private function feedLoader_errorHandler(event:ErrorEvent):Void {
		trace("error: " + event);

		_feedItemListView.dataProvider = new ArrayCollection([ERROR_ITEM]);
	}

	private function feedLoader_completeHandler(event:Event):Void {
		var feedLoader = cast(event.currentTarget, URLLoader);
		var feedData = (feedLoader.data : String);
		try {
			var feed = (Json.parse(feedData) : Array<Any>);
			if (_pageIndex < _maxPages) {
				feed.push(MORE_ITEM);
			}
			_feedItemListView.dataProvider = new ArrayCollection(feed);
		} catch (e:Dynamic) {
			trace("error: " + e);
			_feedItemListView.dataProvider = new ArrayCollection([ERROR_ITEM]);
		}
	}
}
