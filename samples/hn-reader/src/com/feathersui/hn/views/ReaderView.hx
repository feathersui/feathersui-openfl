package com.feathersui.hn.views;

import com.feathersui.hn.views.controls.ReaderHeaderView;
import com.feathersui.hn.views.events.ReaderHeaderViewEvent;
import feathers.controls.Panel;
import feathers.controls.navigators.Route;
import feathers.controls.navigators.RouterNavigator;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalLayoutData;
import openfl.events.Event;

class ReaderView extends Panel {
	public function new() {
		super();
	}

	private var _navigator:RouterNavigator;

	override private function initialize():Void {
		super.initialize();

		layout = new AnchorLayout();

		var headerView = new ReaderHeaderView();
		headerView.layoutData = HorizontalLayoutData.fillHorizontal();
		headerView.addEventListener(ReaderHeaderViewEvent.GOTO_TOP, event -> {
			_navigator.push("/top");
		});
		headerView.addEventListener(ReaderHeaderViewEvent.GOTO_NEW, event -> {
			_navigator.push("/new");
		});
		headerView.addEventListener(ReaderHeaderViewEvent.GOTO_SHOW, event -> {
			_navigator.push("/show");
		});
		headerView.addEventListener(ReaderHeaderViewEvent.GOTO_ASK, event -> {
			_navigator.push("/ask");
		});
		headerView.addEventListener(ReaderHeaderViewEvent.GOTO_JOBS, event -> {
			_navigator.push("/jobs");
		});
		headerView.addEventListener(ReaderHeaderViewEvent.GOTO_ABOUT, event -> {
			_navigator.push("/about");
		});
		header = headerView;

		_navigator = new RouterNavigator();
		#if feathersui.com
		// to build for the feathersui.com website, run the following command:
		// haxelib run openfl build html5 -final --haxedef=feathersui.com
		_navigator.basePath = "/samples/haxe-openfl/hn-reader";
		#end
		_navigator.layoutData = AnchorLayoutData.fill();
		_navigator.backTransition = null;
		_navigator.forwardTransition = null;
		addChild(_navigator);

		_navigator.addRoute(Route.withClass("/about", AboutView));
		_navigator.addRoute(Route.withClass("/user", UserView));
		_navigator.addRoute(Route.withClass("/item", ItemView));
		_navigator.addRoute(Route.withFunction("/top", () -> {
			return new FeedView("Top", "/top", "news", 10);
		}));
		_navigator.addRoute(Route.withFunction("/new", () -> {
			return new FeedView("New", "/new", "newest", 12);
		}));
		_navigator.addRoute(Route.withFunction("/show", () -> {
			return new FeedView("Show", "/show", "show", 2);
		}));
		_navigator.addRoute(Route.withFunction("/ask", () -> {
			return new FeedView("Ask", "/ask", "ask", 2);
		}));
		_navigator.addRoute(Route.withFunction("/jobs", () -> {
			return new FeedView("Jobs", "/jobs", "jobs", 1);
		}));

		// keep the header view's location updated so that it can update which
		// section is selected
		headerView.pathname = _navigator.pathname;
		_navigator.addEventListener(Event.CHANGE, event -> {
			headerView.pathname = _navigator.pathname;
		});

		// redirect to Top feed, if starting at the base path
		if (_navigator.pathname == "/") {
			_navigator.replace("/top");
		}
	}
}
