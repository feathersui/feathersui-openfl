package com.feathersui.hn.views.controls;

import com.feathersui.hn.views.events.ReaderHeaderViewEvent;
import feathers.controls.AssetLoader;
import feathers.controls.LayoutGroup;
import feathers.controls.ToggleButton;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;

class ReaderHeaderView extends LayoutGroup {
	public function new() {
		super();
	}

	@:isVar
	public var pathname(default, set):String;

	private function set_pathname(value:String):String {
		if (pathname == value) {
			return pathname;
		}
		pathname = value;
		setInvalid(DATA);
		return pathname;
	}

	private var _topButton:ToggleButton;
	private var _newButton:ToggleButton;
	private var _showButton:ToggleButton;
	private var _askButton:ToggleButton;
	private var _jobsButton:ToggleButton;
	private var _aboutButton:ToggleButton;

	override private function initialize():Void {
		super.initialize();

		var viewLayout = new HorizontalLayout();
		viewLayout.gap = 8.0;
		viewLayout.paddingTop = 2.0;
		viewLayout.paddingRight = 8.0;
		viewLayout.paddingBottom = 2.0;
		viewLayout.paddingLeft = 8.0;
		viewLayout.verticalAlign = MIDDLE;
		layout = viewLayout;

		var logo = new AssetLoader();
		logo.source = "feathersui";
		logo.width = 30.0;
		logo.height = 30.0;
		addChild(logo);

		_topButton = new ToggleButton();
		_topButton.text = "Top";
		_topButton.toggleable = false;
		_topButton.addEventListener(TriggerEvent.TRIGGER, event -> {
			dispatchEvent(new ReaderHeaderViewEvent(ReaderHeaderViewEvent.GOTO_TOP));
		});
		addChild(_topButton);

		_newButton = new ToggleButton();
		_newButton.text = "New";
		_newButton.toggleable = false;
		_newButton.addEventListener(TriggerEvent.TRIGGER, event -> {
			dispatchEvent(new ReaderHeaderViewEvent(ReaderHeaderViewEvent.GOTO_NEW));
		});
		addChild(_newButton);

		_showButton = new ToggleButton();
		_showButton.text = "Show";
		_showButton.toggleable = false;
		_showButton.addEventListener(TriggerEvent.TRIGGER, event -> {
			dispatchEvent(new ReaderHeaderViewEvent(ReaderHeaderViewEvent.GOTO_SHOW));
		});
		addChild(_showButton);

		_askButton = new ToggleButton();
		_askButton.text = "Ask";
		_askButton.toggleable = false;
		_askButton.addEventListener(TriggerEvent.TRIGGER, event -> {
			dispatchEvent(new ReaderHeaderViewEvent(ReaderHeaderViewEvent.GOTO_ASK));
		});
		addChild(_askButton);

		_jobsButton = new ToggleButton();
		_jobsButton.text = "Jobs";
		_jobsButton.toggleable = false;
		_jobsButton.addEventListener(TriggerEvent.TRIGGER, event -> {
			dispatchEvent(new ReaderHeaderViewEvent(ReaderHeaderViewEvent.GOTO_JOBS));
		});
		addChild(_jobsButton);

		var spacer = new LayoutGroup();
		spacer.layoutData = HorizontalLayoutData.fillHorizontal();
		addChild(spacer);

		_aboutButton = new ToggleButton();
		_aboutButton.text = "About";
		_aboutButton.toggleable = false;
		_aboutButton.addEventListener(TriggerEvent.TRIGGER, event -> {
			dispatchEvent(new ReaderHeaderViewEvent(ReaderHeaderViewEvent.GOTO_ABOUT));
		});
		addChild(_aboutButton);
	}

	override private function update():Void {
		_topButton.selected = pathname == "/top";
		_topButton.mouseEnabled = !_topButton.selected;

		_newButton.selected = pathname == "/new";
		_newButton.mouseEnabled = !_newButton.selected;

		_showButton.selected = pathname == "/show";
		_showButton.mouseEnabled = !_showButton.selected;

		_askButton.selected = pathname == "/ask";
		_askButton.mouseEnabled = !_askButton.selected;

		_jobsButton.selected = pathname == "/jobs";
		_jobsButton.mouseEnabled = !_jobsButton.selected;

		_aboutButton.selected = pathname == "/about";
		_aboutButton.mouseEnabled = !_aboutButton.selected;

		super.update();
	}
}
