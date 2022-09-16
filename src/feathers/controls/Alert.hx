/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.popups.IPopUpAdapter;
import feathers.core.IUIControl;
import feathers.core.InvalidationFlag;
import feathers.core.PopUpManager;
import feathers.data.ArrayCollection;
import feathers.data.ButtonBarItemState;
import feathers.data.IFlatCollection;
import feathers.events.ButtonBarEvent;
import feathers.layout.Measurements;
import feathers.skins.IProgrammaticSkin;
import feathers.utils.AbstractDisplayObjectFactory;
import feathers.utils.DisplayObjectFactory;
import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;

/**
	Displays a message in a modal pop-up dialog with a title and a set of
	buttons.

	In the following example, an alert is shown when a `Button` is triggered:

	```haxe
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

		To override this default variant, set the
		`Alert.customHeaderVariant` property.

		@see `Alert.customHeaderVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_HEADER = "alert_header";

	/**
		The variant used to style the message `Label` child component.

		To override this default variant, set the
		`Alert.customMessageLabelVariant` property.

		@see `Alert.customMessageLabelVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_MESSAGE_LABEL = "alert_messageLabel";

	/**
		The variant used to style the `ButtonBar` child component.

		To override this default variant, set the
		`Alert.customButtonBarVariant` property.

		@see `Alert.customButtonBarVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_BUTTON_BAR = "alert_buttonBar";

	/**
		Creates an alert, sets a few common properties, and adds it to the
		`PopUpManager`.

		Note: If no text is provided for the buttons, no buttons will be
		displayed, and the Alert will need to be closed manually with
		`PopUpManager.removePopUp()`.

		@since 1.0.0
	**/
	public static function show(text:String, ?titleText:String, ?buttonsText:Array<String>, ?callback:(state:ButtonBarItemState) -> Void,
			?alertFactory:() -> Alert, ?popUpAdapter:IPopUpAdapter):Alert {
		var alert = (alertFactory != null) ? alertFactory() : new Alert();
		alert.text = text;
		alert.titleText = titleText;
		var buttonsData = (buttonsText != null) ? buttonsText.map(text -> new StringWrapper(text)) : [];
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

	private static final defaultButtonBarFactory = DisplayObjectFactory.withClass(ButtonBar);

	private static final defaultHeaderFactory = DisplayObjectFactory.withClass(Header);

	private static final defaultMessageLabelFactory = DisplayObjectFactory.withClass(Label);

	/**
		Creates a new `Alert` object.

		@since 1.0.0
	**/
	public function new(text:String = "") {
		initializeAlertTheme();
		super();

		this.text = text;
	}

	private var messageLabel:Label;

	private var _text:String;

	/**
		The message displayed by the alert.

		The following example sets the alert's text:

		```haxe
		alert.text = "Good afternoon!";
		```

		@default ""

		@since 1.0.0
	**/
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

	private var _htmlText:String = null;

	/**
		Text displayed by the alert that is parsed as a simple form of HTML.

		The following example sets the alert's HTML text:

		```haxe
		alert.htmlText = "<b>Hello</b> <i>World</i>";
		```

		@default null

		@see `Alert.text`
		@see [`openfl.text.TextField.htmlText`](https://api.openfl.org/openfl/text/TextField.html#htmlText)

		@since 1.0.0
	**/
	public var htmlText(get, set):String;

	private function get_htmlText():String {
		return this._htmlText;
	}

	private function set_htmlText(value:String):String {
		if (this._htmlText == value) {
			return this._htmlText;
		}
		this._htmlText = value;
		this.setInvalid(DATA);
		return this._htmlText;
	}

	private var alertHeader:Header;

	private var _titleText:String = "";

	/**
		The text displayed as the alert's title.

		@since 1.0.0
	**/
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

	private var _oldMessageLabelFactory:DisplayObjectFactory<Dynamic, Label>;

	private var _messageLabelFactory:DisplayObjectFactory<Dynamic, Label>;

	/**
		Creates the message label, which must be of type
		`feathers.controls.Label`.

		In the following example, a custom message label factory is provided:

		```haxe
		alert.messageLabelFactory = () ->
		{
			return new Label();
		};
		```

		@see `feathers.controls.Label`

		@since 1.0.0
	**/
	public var messageLabelFactory(get, set):AbstractDisplayObjectFactory<Dynamic, Label>;

	private function get_messageLabelFactory():AbstractDisplayObjectFactory<Dynamic, Label> {
		return this._messageLabelFactory;
	}

	private function set_messageLabelFactory(value:AbstractDisplayObjectFactory<Dynamic, Label>):AbstractDisplayObjectFactory<Dynamic, Label> {
		if (this._messageLabelFactory == value) {
			return this._messageLabelFactory;
		}
		this._messageLabelFactory = value;
		this.setInvalid(INVALIDATION_FLAG_MESSAGE_LABEL_FACTORY);
		return this._messageLabelFactory;
	}

	private var _oldHeaderFactory:DisplayObjectFactory<Dynamic, Header>;

	private var _headerFactory:DisplayObjectFactory<Dynamic, Header>;

	/**
		Creates the header, which must be of type `feathers.controls.Header`.

		In the following example, a custom header factory is provided:

		```haxe
		alert.headerFactory = () ->
		{
			return new Header();
		};
		```

		@see `feathers.controls.Header`

		@since 1.0.0
	**/
	public var headerFactory(get, set):AbstractDisplayObjectFactory<Dynamic, Header>;

	private function get_headerFactory():AbstractDisplayObjectFactory<Dynamic, Header> {
		return this._headerFactory;
	}

	private function set_headerFactory(value:AbstractDisplayObjectFactory<Dynamic, Header>):AbstractDisplayObjectFactory<Dynamic, Header> {
		if (this._headerFactory == value) {
			return this._headerFactory;
		}
		this._headerFactory = value;
		this.setInvalid(INVALIDATION_FLAG_HEADER_FACTORY);
		return this._headerFactory;
	}

	private var _oldButtonBarFactory:DisplayObjectFactory<Dynamic, ButtonBar>;

	private var _buttonBarFactory:DisplayObjectFactory<Dynamic, ButtonBar>;

	/**
		Creates the button bar, which must be of type
		`feathers.controls.ButtonBar`.

		In the following example, a custom button bar factory is provided:

		```haxe
		alert.buttonBarFactory = () ->
		{
			return new ButtonBar();
		};
		```

		@see `feathers.controls.ButtonBar`

		@since 1.0.0
	**/
	public var buttonBarFactory(get, set):AbstractDisplayObjectFactory<Dynamic, ButtonBar>;

	private function get_buttonBarFactory():AbstractDisplayObjectFactory<Dynamic, ButtonBar> {
		return this._buttonBarFactory;
	}

	private function set_buttonBarFactory(value:AbstractDisplayObjectFactory<Dynamic, ButtonBar>):AbstractDisplayObjectFactory<Dynamic, ButtonBar> {
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

		```haxe
		alert.icon = new Bitmap(bitmapData);
		```

		To change the position of the icon relative to the alert's text, see
		`iconPosition` and `gap`.

		```haxe
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
		An optional custom variant to use for the alert's button bar, instead of
		`Alert.CHILD_VARIANT_BUTTON_BAR`.

		The `customButtonBarVariant` will be not be used if the result of
		`buttonBarFactory` already has a variant set.

		@see `Alert.CHILD_VARIANT_BUTTON_BAR`

		@since 1.0.0
	**/
	@:style
	public var customButtonBarVariant:String = null;

	/**
		An optional custom variant to use for the alert's header, instead of
		`Alert.CHILD_VARIANT_HEADER`.

		The `customHeaderVariant` will be not be used if the result of
		`headerFactory` already has a variant set.

		@see `Alert.CHILD_VARIANT_HEADER`

		@since 1.0.0
	**/
	@:style
	public var customHeaderVariant:String = null;

	/**
		An optional custom variant to use for the alert's message label, instead
		of `Alert.CHILD_VARIANT_MESSAGE_LABEL`.

		The `customMessageLabelVariant` will be not be used if the result of
		`messageLabelFactory` already has a variant set.

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
		feathers.themes.steel.components.SteelAlertStyles.initialize();
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

		if (dataInvalid || stylesInvalid || stateInvalid || messageLabelInvalid) {
			this.refreshText();
		}

		if (dataInvalid || stylesInvalid || stateInvalid || headerInvalid) {
			this.refreshTitleText();
		}

		if (dataInvalid || buttonBarInvalid) {
			this.refreshButtons();
		}

		super.update();
	}

	private function createButtonBar():Void {
		if (this.buttonBar != null) {
			this.buttonBar.removeEventListener(ButtonBarEvent.ITEM_TRIGGER, alert_buttonBar_itemTriggerHandler);
			if (this._oldButtonBarFactory.destroy != null) {
				this._oldButtonBarFactory.destroy(this.buttonBar);
			}
			this._oldButtonBarFactory = null;
			this.buttonBar = null;
			super.footer = null;
		}
		var factory = this._buttonBarFactory != null ? this._buttonBarFactory : defaultButtonBarFactory;
		this._oldButtonBarFactory = factory;
		this.buttonBar = factory.create();
		if (this.buttonBar.variant == null) {
			this.buttonBar.variant = this.customButtonBarVariant != null ? this.customButtonBarVariant : Alert.CHILD_VARIANT_BUTTON_BAR;
		}
		this.buttonBar.addEventListener(ButtonBarEvent.ITEM_TRIGGER, alert_buttonBar_itemTriggerHandler);
		super.footer = this.buttonBar;
	}

	private function createHeader():Void {
		if (this.alertHeader != null) {
			if (this._oldHeaderFactory.destroy != null) {
				this._oldHeaderFactory.destroy(this.alertHeader);
			}
			this._oldHeaderFactory = null;
			this.alertHeader = null;
			super.header = null;
		}
		var factory = this._headerFactory != null ? this._headerFactory : defaultHeaderFactory;
		this._oldHeaderFactory = factory;
		this.alertHeader = factory.create();
		if (this.alertHeader.variant == null) {
			this.alertHeader.variant = this.customHeaderVariant != null ? this.customHeaderVariant : Alert.CHILD_VARIANT_HEADER;
		}
		super.header = this.alertHeader;
	}

	private function createMessageLabel():Void {
		if (this.messageLabel != null) {
			this.removeChild(this.messageLabel);
			if (this._oldMessageLabelFactory.destroy != null) {
				this._oldMessageLabelFactory.destroy(this.messageLabel);
			}
			this._oldMessageLabelFactory = null;
			this.messageLabel = null;
		}
		var factory = this._messageLabelFactory != null ? this._messageLabelFactory : defaultMessageLabelFactory;
		this._oldMessageLabelFactory = factory;
		this.messageLabel = factory.create();
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
		this.messageLabel.htmlText = this._htmlText;
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
		if ((this._currentIcon is IUIControl)) {
			cast(this._currentIcon, IUIControl).initializeNow();
		}
		if (this._iconMeasurements == null) {
			this._iconMeasurements = new Measurements(this._currentIcon);
		} else {
			this._iconMeasurements.save(this._currentIcon);
		}
		if ((this._currentIcon is IProgrammaticSkin)) {
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
		if ((icon is IProgrammaticSkin)) {
			cast(icon, IProgrammaticSkin).uiContext = null;
		}
		// we need to restore these values so that they won't be lost the
		// next time that this icon is used for measurement
		this._iconMeasurements.restore(icon);
		if (icon.parent == this) {
			this.removeChild(icon);
		}
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
