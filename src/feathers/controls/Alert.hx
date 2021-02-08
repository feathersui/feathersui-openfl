/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.errors.IllegalOperationError;
import feathers.controls.popups.IPopUpAdapter;
import feathers.core.IUIControl;
import feathers.core.PopUpManager;
import feathers.data.ArrayCollection;
import feathers.data.ButtonBarItemState;
import feathers.data.IFlatCollection;
import feathers.events.ButtonBarEvent;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.Measurements;
import feathers.skins.IProgrammaticSkin;
import feathers.themes.steel.components.SteelAlertStyles;
import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.events.Event;

/**
	Displays a message in a modal pop-up dialog with a title and a set of
	buttons.

	In the following example, an alert is shown when a `Button` is triggered:

	```hx
	var button = new Button();
	button.text = "Click Me";
	addChild(button);
	button.addEventListener(TriggerEvent.TRIGGER, (event) -> {
		Alert.show( "Something bad happened!", "Error", ["OK"]);
	});
	```

	@see [Tutorial: How to use the Alert component](https://feathersui.com/learn/haxe-openfl/alert/)

	@since 1.0.0
**/
@:styleContext
class Alert extends Panel {
	private static final INVALIDATION_FLAG_BUTTON_BAR_FACTORY = InvalidationFlag.CUSTOM("buttonBarFactory");
	private static final INVALIDATION_FLAG_HEADER_FACTORY = InvalidationFlag.CUSTOM("headerFactory");
	private static final INVALIDATION_FLAG_MESSAGE_LABEL_FACTORY = InvalidationFlag.CUSTOM("messageLabelFactory");

	/**
		The variant used to style the `Header` child component.

		@see `Alert.customHeaderVariant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_HEADER = "alert_header";

	/**
		The variant used to style the message `Label` child component.

		@see `Alert.customMessageLabelVariant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_MESSAGE_LABEL = "alert_messageLabel";

	/**
		The variant used to style the `ButtonBar` child component.

		@see `Alert.customButtonBarVariant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_BUTTON_BAR = "alert_buttonBar";

	/**
		Creates an alert, sets a few common properties, and adds it to the
		`PopUpManager`.

		@since 1.0.0
	**/
	public static function show(text:String, ?titleText:String, ?buttonsText:Array<String>, ?callback:(state:ButtonBarItemState) -> Void,
			?popUpAdapter:IPopUpAdapter):Alert {
		var alert = new Alert();
		alert.text = text;
		alert.titleText = titleText;
		var buttonsData = buttonsText.map(text -> new StringWrapper(text));
		alert.buttonsDataProvider = new ArrayCollection(buttonsData);
		if (callback != null) {
			alert.addEventListener(ButtonBarEvent.ITEM_TRIGGER, event -> {
				callback(event.state);
			});
		}
		return showAlert(alert, popUpAdapter);
	}

	private static function showAlert(alert:Alert, ?popUpAdapter:IPopUpAdapter):Alert {
		if (popUpAdapter != null) {
			popUpAdapter.open(alert, Lib.current);
		} else {
			PopUpManager.addPopUp(alert, Lib.current, true, true);
		}
		return alert;
	}

	private static function defaultButtonBarFactory():ButtonBar {
		return new ButtonBar();
	}

	private static function defaultHeaderFactory():Header {
		return new Header();
	}

	private static function defaultMessageLabelFactory():Label {
		return new Label();
	}

	/**
		Creates a new `Alert` object.

		@since 1.0.0
	**/
	public function new() {
		initializeAlertTheme();
		super();
	}

	private var messageLabel:Label;

	private var _text:String = "";

	/**
		The message displayed by the alert.

		The following example sets the alert's text:

		```hx
		alert.text = "Good afternoon!";
		```

		@default ""

		@since 1.0.0
	**/
	@:flash.property
	public var text(get, set):String;

	private function get_text():String {
		return this._text;
	}

	private function set_text(value:String):String {
		if (value == null) {
			// null gets converted to an empty string
			if (this._text.length == 0) {
				// already an empty string
				return this._text;
			}
			value = "";
		}
		if (this._text == value) {
			return this._text;
		}
		this._text = value;
		this.setInvalid(DATA);
		return this._text;
	}

	private var alertHeader:Header;

	private var _titleText:String = "";

	/**
		The text displayed as the alert's title.

		@since 1.0.0
	**/
	@:flash.property
	public var titleText(get, set):String;

	private function get_titleText():String {
		return this._titleText;
	}

	private function set_titleText(value:String):String {
		if (value == null) {
			// null gets converted to an empty string
			if (this._titleText.length == 0) {
				// already an empty string
				return this._titleText;
			}
			value = "";
		}
		if (this._titleText == value) {
			return this._titleText;
		}
		this._titleText = value;
		this.setInvalid(DATA);
		return this._titleText;
	}

	private var _messageLabelFactory:() -> Label;

	/**
		Creates the message label, which must be of type
		`feathers.controls.Label`.

		In the following example, a custom message label factory is provided:

		```hx
		alert.messageLabelFactory = () ->
		{
			return new Label();
		};
		```

		@see `feathers.controls.Label`

		@since 1.0.0
	**/
	@:flash.property
	public var messageLabelFactory(get, set):() -> Label;

	private function get_messageLabelFactory():() -> Label {
		return this._messageLabelFactory;
	}

	private function set_messageLabelFactory(value:() -> Label):() -> Label {
		if (this._messageLabelFactory == value) {
			return this._messageLabelFactory;
		}
		this._messageLabelFactory = value;
		this.setInvalid(INVALIDATION_FLAG_MESSAGE_LABEL_FACTORY);
		return this._messageLabelFactory;
	}

	private var _headerFactory:() -> Header;

	/**
		Creates the header, which must be of type `feathers.controls.Header`.

		In the following example, a custom header factory is provided:

		```hx
		alert.headerFactory = () ->
		{
			return new Header();
		};
		```

		@see `feathers.controls.Header`

		@since 1.0.0
	**/
	@:flash.property
	public var headerFactory(get, set):() -> Header;

	private function get_headerFactory():() -> Header {
		return this._headerFactory;
	}

	private function set_headerFactory(value:() -> Header):() -> Header {
		if (this._headerFactory == value) {
			return this._headerFactory;
		}
		this._headerFactory = value;
		this.setInvalid(INVALIDATION_FLAG_HEADER_FACTORY);
		return this._headerFactory;
	}

	private var _buttonBarFactory:() -> ButtonBar;

	/**
		Creates the button bar, which must be of type
		`feathers.controls.ButtonBar`.

		In the following example, a custom button bar factory is provided:

		```hx
		alert.buttonBarFactory = () ->
		{
			return new ButtonBar();
		};
		```

		@see `feathers.controls.ButtonBar`

		@since 1.0.0
	**/
	@:flash.property
	public var buttonBarFactory(get, set):() -> ButtonBar;

	private function get_buttonBarFactory():() -> ButtonBar {
		return this._buttonBarFactory;
	}

	private function set_buttonBarFactory(value:() -> ButtonBar):() -> ButtonBar {
		if (this._buttonBarFactory == value) {
			return this._buttonBarFactory;
		}
		this._buttonBarFactory = value;
		this.setInvalid(INVALIDATION_FLAG_BUTTON_BAR_FACTORY);
		return this._buttonBarFactory;
	}

	private var buttonBar:ButtonBar;

	private var _buttonsDataProvider:IFlatCollection<Dynamic> = null;

	/**

		@since 1.0.0
	**/
	@:flash.property
	public var buttonsDataProvider(get, set):IFlatCollection<Dynamic>;

	private function get_buttonsDataProvider():IFlatCollection<Dynamic> {
		return this._buttonsDataProvider;
	}

	private function set_buttonsDataProvider(value:IFlatCollection<Dynamic>):IFlatCollection<Dynamic> {
		if (this._buttonsDataProvider == value) {
			return this._buttonsDataProvider;
		}
		this._buttonsDataProvider = value;
		this.setInvalid(DATA);
		return this._buttonsDataProvider;
	}

	private var _iconMeasurements:Measurements = null;
	private var _currentIcon:DisplayObject = null;
	private var _ignoreIconResizes:Bool = false;

	/**
		The display object to use as the alert's icon.

		The following example gives the alert an icon:

		```hx
		alert.icon = new Bitmap(bitmapData);
		```

		To change the position of the icon relative to the alert's text, see
		`iconPosition` and `gap`.

		```hx
		alert.icon = new Bitmap(bitmapData);
		alert.iconPosition = LEFT;
		alert.gap = 20.0;
		```

		@see `Alert.iconPosition`
		@see `Alert.gap`

		@since 1.0.0
	**/
	@:style
	public var icon:DisplayObject = null;

	/**
		An optional custom variant to use for the alert's button bar.

		@see `Alert.CHILD_VARIANT_BUTTON_BAR`

		@since 1.0.0
	**/
	@:style
	public var customButtonBarVariant:String = null;

	/**
		An optional custom variant to use for the alert's header.

		@see `Alert.CHILD_VARIANT_HEADER`

		@since 1.0.0
	**/
	@:style
	public var customHeaderVariant:String = null;

	/**
		An optional custom variant to use for the alert's message label.

		@see `Alert.CHILD_VARIANT_MESSAGE_LABEL`

		@since 1.0.0
	**/
	@:style
	public var customMessageLabelVariant:String = null;

	override private function set_header(value:DisplayObject):DisplayObject {
		throw new IllegalOperationError("Alert header must be created with headerFactory");
	}

	override private function set_footer(value:DisplayObject):DisplayObject {
		throw new IllegalOperationError("Alert footer must be created with buttonBarFactory");
	}

	private function initializeAlertTheme():Void {
		SteelAlertStyles.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);
		var buttonBarInvalid = this.isInvalid(INVALIDATION_FLAG_BUTTON_BAR_FACTORY);
		var headerInvalid = this.isInvalid(INVALIDATION_FLAG_HEADER_FACTORY);
		var messageLabelInvalid = this.isInvalid(INVALIDATION_FLAG_MESSAGE_LABEL_FACTORY);

		if (headerInvalid) {
			this.createHeader();
		}

		if (buttonBarInvalid) {
			this.createButtonBar();
		}

		if (messageLabelInvalid) {
			this.createMessageLabel();
		}

		if (stylesInvalid || stateInvalid) {
			this.refreshIcon();
		}

		if (dataInvalid || stylesInvalid || stateInvalid) {
			this.refreshText();
		}

		if (dataInvalid || stylesInvalid || stateInvalid) {
			this.refreshTitleText();
		}

		if (dataInvalid) {
			this.refreshButtons();
		}

		super.update();
	}

	private function createButtonBar():Void {
		if (this.buttonBar != null) {
			this.buttonBar.removeEventListener(ButtonBarEvent.ITEM_TRIGGER, alert_buttonBar_itemTriggerHandler);
			this.buttonBar = null;
			super.footer = null;
		}
		var factory = this._buttonBarFactory != null ? this._buttonBarFactory : defaultButtonBarFactory;
		this.buttonBar = factory();
		if (this.buttonBar.variant == null) {
			this.buttonBar.variant = this.customButtonBarVariant != null ? this.customButtonBarVariant : Alert.CHILD_VARIANT_BUTTON_BAR;
		}
		this.buttonBar.addEventListener(ButtonBarEvent.ITEM_TRIGGER, alert_buttonBar_itemTriggerHandler);
		super.footer = this.buttonBar;
	}

	private function createHeader():Void {
		if (this.alertHeader != null) {
			this.alertHeader = null;
			super.header = null;
		}
		var factory = this._headerFactory != null ? this._headerFactory : defaultHeaderFactory;
		this.alertHeader = factory();
		if (this.alertHeader.variant == null) {
			this.alertHeader.variant = this.customHeaderVariant != null ? this.customHeaderVariant : Alert.CHILD_VARIANT_HEADER;
		}
		super.header = this.alertHeader;
	}

	private function createMessageLabel():Void {
		if (this.messageLabel != null) {
			this.removeChild(this.messageLabel);
			this.messageLabel = null;
		}
		var factory = this._messageLabelFactory != null ? this._messageLabelFactory : defaultMessageLabelFactory;
		this.messageLabel = factory();
		if (this.messageLabel.variant == null) {
			this.messageLabel.variant = this.customMessageLabelVariant != null ? this.customMessageLabelVariant : Alert.CHILD_VARIANT_MESSAGE_LABEL;
		}
		this.addChild(this.messageLabel);
	}

	private function refreshButtons():Void {
		this.buttonBar.dataProvider = this._buttonsDataProvider;
	}

	private function refreshText():Void {
		this.messageLabel.text = this._text;
	}

	private function refreshTitleText():Void {
		this.alertHeader.text = this._titleText;
	}

	private function refreshIcon():Void {
		var oldIcon = this._currentIcon;
		this._currentIcon = this.getCurrentIcon();
		if (this._currentIcon == oldIcon) {
			return;
		}
		this.removeCurrentIcon(oldIcon);
		if (this._currentIcon == null) {
			this._iconMeasurements = null;
			return;
		}
		if (Std.is(this._currentIcon, IUIControl)) {
			cast(this._currentIcon, IUIControl).initializeNow();
		}
		if (this._iconMeasurements == null) {
			this._iconMeasurements = new Measurements(this._currentIcon);
		} else {
			this._iconMeasurements.save(this._currentIcon);
		}
		if (Std.is(this._currentIcon, IProgrammaticSkin)) {
			cast(this._currentIcon, IProgrammaticSkin).uiContext = this;
		}
		var index = this.getChildIndex(this.messageLabel);
		// the icon should be below the text
		this.addChildAt(this._currentIcon, index);
	}

	private function getCurrentIcon():DisplayObject {
		return this.icon;
	}

	private function removeCurrentIcon(icon:DisplayObject):Void {
		if (icon == null) {
			return;
		}
		if (Std.is(icon, IProgrammaticSkin)) {
			cast(icon, IProgrammaticSkin).uiContext = null;
		}
		// we need to restore these values so that they won't be lost the
		// next time that this icon is used for measurement
		this._iconMeasurements.restore(icon);
		if (icon.parent == this) {
			this.removeChild(icon);
		}
	}

	private function alert_textFormat_changeHandler(event:Event):Void {
		this.setInvalid(STYLES);
	}

	private function alert_buttonBar_itemTriggerHandler(event:Event):Void {
		this.parent.removeChild(this);
		this.dispatchEvent(event);
	}
}

private class StringWrapper {
	public function new(text:String) {
		this._text = text;
	}

	private var _text:String;

	@:keep
	public function toString():String {
		return this._text;
	}
}
