package com.feathersui.hn.views;

import com.feathersui.hn.vo.User;
import feathers.controls.Label;
import feathers.controls.ScrollContainer;
import feathers.controls.navigators.RouterNavigator;
import feathers.layout.VerticalLayout;
import haxe.Json;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;

class UserView extends ScrollContainer {
	public function new() {
		super();
	}

	private var _title:Label;
	private var _meta:Label;
	private var _links:Label;
	private var _description:Label;

	override private function initialize():Void {
		super.initialize();

		var viewLayout = new VerticalLayout();
		viewLayout.horizontalAlign = JUSTIFY;
		viewLayout.gap = 8.0;
		viewLayout.setPadding(8.0);
		layout = viewLayout;

		_title = new Label();
		_title.text = "Loading...";
		_title.variant = Label.VARIANT_HEADING;
		_title.wordWrap = true;
		addChild(_title);

		_meta = new Label();
		_meta.variant = Label.VARIANT_DETAIL;
		_meta.wordWrap = true;
		addChild(_meta);

		_description = new Label();
		_description.wordWrap = true;
		_description.selectable = true;
		addChild(_description);

		_links = new Label();
		_links.wordWrap = true;
		addChild(_links);

		var navigator = cast(parent, RouterNavigator);
		var userName = Reflect.field(navigator.urlVariables, "id");

		var loader = new URLLoader();
		loader.dataFormat = TEXT;
		loader.addEventListener(Event.COMPLETE, userLoader_completeHandler);
		loader.addEventListener(IOErrorEvent.IO_ERROR, userLoader_errorHandler);
		loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, userLoader_errorHandler);
		loader.load(new URLRequest('https://api.hnpwa.com/v0/user/${userName}.json'));
	}

	private function userLoader_completeHandler(event:Event):Void {
		var userLoader = cast(event.currentTarget, URLLoader);
		var userData = (userLoader.data : String);
		try {
			var user = (Json.parse(userData) : User);
			_title.text = user.id;
			_meta.htmlText = 'joined <b>${user.created}</b> and has <b>${user.karma}</b> karma';
			_description.htmlText = user.about;
			_links.htmlText = '<li><u><a href="https://news.ycombinator.com/submitted?id=${user.id}">submissions</a></u></li>'
				+ '<li><u><a href="https://news.ycombinator.com/threads?id=${user.id}">comments</a></u></li>'
				+ '<li><u><a href="https://news.ycombinator.com/favorites?id=${user.id}">favorites</a></u></li>';
		} catch (e) {
			_title.text = "Error loading user";
			_meta.text = null;
			_links.text = null;
			_description.text = null;
		}
	}

	private function userLoader_errorHandler(event:Event):Void {
		_title.text = "Error loading user";
		_meta.text = null;
		_links.text = null;
		_description.text = null;
	}
}
