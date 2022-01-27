package com.feathersui.hn.views;

import com.feathersui.hn.vo.User;
import feathers.controls.Label;
import feathers.controls.ScrollContainer;
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

	private var _user:User;
	private var _errorMessage:String;
	private var _userLoader:URLLoader;

	@:isVar
	public var userID(default, set):String;

	private function set_userID(value:String):String {
		if (userID == value) {
			return userID;
		}
		userID = value;
		_user = null;
		_errorMessage = null;

		if (initialized) {
			loadUser();
		}

		setInvalid(DATA);
		return userID;
	}

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

		loadUser();
	}

	override private function update():Void {
		if (_user != null) {
			_title.text = _user.id;
			_meta.htmlText = 'joined <b>${_user.created}</b> and has <b>${_user.karma}</b> karma';
			_description.htmlText = _user.about;
			_links.htmlText = '<li><u><a href="https://news.ycombinator.com/submitted?id=${_user.id}">submissions</a></u></li>'
				+ '<li><u><a href="https://news.ycombinator.com/threads?id=${_user.id}">comments</a></u></li>'
				+ '<li><u><a href="https://news.ycombinator.com/favorites?id=${_user.id}">favorites</a></u></li>';
		} else {
			if (_errorMessage != null) {
				_title.text = _errorMessage;
			} else if (_userLoader != null) {
				_title.text = "Loading...";
			}
			_meta.text = null;
			_description.text = null;
			_links.text = null;
		}
		super.update();
	}

	private function loadUser():Void {
		if (_userLoader != null) {
			_userLoader.close();
			_userLoader = null;
		}

		if (userID == null) {
			return;
		}

		_userLoader = new URLLoader();
		_userLoader.dataFormat = TEXT;
		_userLoader.addEventListener(Event.COMPLETE, userLoader_completeHandler);
		_userLoader.addEventListener(IOErrorEvent.IO_ERROR, userLoader_errorHandler);
		_userLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, userLoader_errorHandler);
		_userLoader.load(new URLRequest('https://api.hnpwa.com/v0/user/${userID}.json'));
	}

	private function userLoader_completeHandler(event:Event):Void {
		var userData = (_userLoader.data : String);
		_userLoader = null;
		try {
			_user = (Json.parse(userData) : User);
		} catch (e:Dynamic) {
			trace("error: " + e);
			_errorMessage = "Error loading user";
		}
		setInvalid(DATA);
	}

	private function userLoader_errorHandler(event:Event):Void {
		trace("error: " + event);

		_userLoader = null;
		setInvalid(DATA);
	}
}
