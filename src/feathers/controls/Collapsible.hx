/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IMeasureObject;
import feathers.core.IOpenCloseToggle;
import feathers.core.ITextControl;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.core.InvalidationFlag;
import feathers.events.FeathersEvent;
import feathers.events.TriggerEvent;
import feathers.layout.Measurements;
import feathers.style.IVariantStyleObject;
import feathers.utils.AbstractDisplayObjectFactory;
import feathers.utils.DisplayObjectFactory;
import feathers.utils.MeasurementsUtil;
import motion.Actuate;
import motion.actuators.SimpleActuator;
import motion.easing.IEasing;
import motion.easing.Quart;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;

/**
	A container that displays primary `content` that may be collapsed and
	expanded by clicking or tapping a `header`.

	The following example creates a closed collapsible container with
	word-wrapped text as content:

	```haxe
	var collapsible = new Collapsible();
	collapsible.text = "What is Feathers UI?";
	collapsible.opened = false;
	var textContent = new Label();
	textContent.width = 200.0;
	textContent.wordWrap = true;
	textContent.text = "Feathers UI is an open source framework of graphical user interface (GUI) components for creative, cross-platform projects.";
	collapsible.content = textContent;
	addChild(collapsible);
	```

	@event openfl.events.Event.OPEN Dispatched when the content has completely
	opened.

	@event openfl.events.Event.CLOSE Dispatched when the content has completely
	closed.

	@event openfl.events.Event.CANCEL Dispatched when an open or close action
	is cancelled before completing.

	@event feathers.events.FeathersEvent.OPENING Dispatched when the content
	starts opening. This event may be cancelled.

	@event feathers.events.FeathersEvent.CLOSING Dispatched when the content
	starts closing. This event may be cancelled.

	@see [Tutorial: How to use the Collapsible component](https://feathersui.com/learn/haxe-openfl/collapsible/)

	@since 1.3.0
**/
@:event(openfl.events.Event.OPEN)
@:event(openfl.events.Event.CLOSE)
@:event(openfl.events.Event.CANCEL)
@:event(feathers.events.FeathersEvent.OPENING)
@:event(feathers.events.FeathersEvent.CLOSING)
@defaultXmlProperty("content")
@:styleContext
class Collapsible extends FeathersControl implements IOpenCloseToggle {
	private static final INVALIDATION_FLAG_HEADER_FACTORY = InvalidationFlag.CUSTOM("headerFactory");

	/**
		The variant used to style the header child component in a theme.

		To override this default variant, set the
		`Collapsible.customHeaderVariant` property.

		@see `Collapsible.customHeaderVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.3.0
	**/
	public static final CHILD_VARIANT_HEADER = "collapsible_header";

	private static final defaultHeaderFactory = DisplayObjectFactory.withClass(ToggleButton);

	/**
		Creates a new `Collapsible` object with the given arguments.

		@since 1.3.0
	**/
	public function new(?text:String, ?content:DisplayObject) {
		initializeCollapsibleTheme();
		super();
		this.text = text;
		this.content = content;
	}

	private var _collapseActuator:SimpleActuator<Dynamic, Dynamic> = null;
	private var _pendingHeight:Null<Float> = null;
	private var _measuredOpenHeight:Float = 0.0;

	private var header:DisplayObject;
	private var headerMeasurements:Measurements = new Measurements();

	private var _ignoreHeaderEvents:Bool = false;

	private var _currentScrollRect:Rectangle;
	private var _scrollRect1:Rectangle = new Rectangle();
	private var _scrollRect2:Rectangle = new Rectangle();

	private var _contentMeasurements:Measurements = new Measurements();
	private var _contentOriginalAlpha:Float = 1.0;
	private var _ignoreContentResize:Bool = false;
	private var _content:DisplayObject;

	/**
		The primary content to display in the container. When the header is
		toggled, this content will be hidden or shown.

		@since 1.3.0
	**/
	public var content(get, set):DisplayObject;

	private function get_content():DisplayObject {
		return this._content;
	}

	private function set_content(value:DisplayObject):DisplayObject {
		if (this._content == value) {
			return this._content;
		}
		if (this._content != null) {
			this._content.removeEventListener(Event.RESIZE, collapsible_content_resizeHandler);
			this._content.alpha = this._contentOriginalAlpha;
			this._contentMeasurements.restore(this._content);
			this.removeChild(this._content);
		}
		this._content = value;
		if (this._content != null) {
			this.addChild(this._content);
			this._contentMeasurements.save(this._content);
			this._contentOriginalAlpha = this._content.alpha;
			this._content.addEventListener(Event.RESIZE, collapsible_content_resizeHandler);
		}
		setInvalid(DATA);
		return this._content;
	}

	private var _text:String;

	/**
		The text to display in the header.

		The header must implement `ITextControl` to display text. The default
		header is a `ToggleButton`, which can display text.

		The following example sets the header's text:

		```haxe
		collapsible.text = "Header Text";
		```

		@since 1.3.0
	**/
	@:inspectable
	public var text(get, set):String;

	private function get_text():String {
		return this._text;
	}

	private function set_text(value:String):String {
		if (this._text == value) {
			return this._text;
		}
		this._text = value;
		setInvalid(DATA);
		return this._text;
	}

	private var _pendingOpened:Null<Bool> = null;
	private var _pendingAnimation:Bool = false;

	private var _opened:Bool = true;

	/**
		@see `feathers.core.IOpenCloseToggle.opened`
	**/
	public var opened(get, set):Bool;

	private function get_opened():Bool {
		if (this._pendingOpened != null) {
			return this._pendingOpened;
		}
		return this._opened;
	}

	private function set_opened(value:Bool):Bool {
		if (value) {
			this.openContent(this._animateOpenedProperty);
		} else {
			this.closeContent(this._animateOpenedProperty);
		}
		if (this._pendingOpened != null) {
			return this._pendingOpened;
		}
		return this._opened;
	}

	private var _animateOpenedProperty:Bool = true;

	/**
		Indicates if setting the `opened` property causes the drawer to animate
		open and closed, or if it causes the drawer to open and close instantly.

		@see `Collapsible.opened`
		@see `Collapsible.openContent()`
		@see `Collapsible.closeContent()`

		@since 1.3.0
	**/
	public var animateOpenedProperty(get, set):Bool;

	private function get_animateOpenedProperty():Bool {
		return this._animateOpenedProperty;
	}

	private function set_animateOpenedProperty(value:Bool):Bool {
		this._animateOpenedProperty = value;
		return this._animateOpenedProperty;
	}

	private var _oldHeaderFactory:DisplayObjectFactory<Dynamic, DisplayObject>;

	private var _headerFactory:DisplayObjectFactory<Dynamic, DisplayObject>;

	/**
		Creates the header control that is used to toggle the visibility of the
		content. The header of a `Collapsible` must be of type
		`openfl.display.DisplayObject`.

		`Collapsible` supports a few different events for determining when to
		toggle the visibility of the content, depending on whether the header
		implements certain specific interfaces. The following interfaces and
		events are supported, in the following order of precedence.

		- If the header implements `feathers.core.IOpenCloseToggle`, the
		`Collapsible` will listen for the header to dispatch
		`openfl.events.Event.OPEN` and `openfl.events.Event.CLOSE` to
		determine when to toggle the visibility of the content.

		- If the header implements `feathers.controls.IToggle`, the
		`Collapsible` will listen for the header to dispatch
		`openfl.events.Event.CHANGE` to determine when to toggle the visibility
		of the content.

		- If the header implements `feathers.controls.ITriggerView`, the
		`Collapsible` will listen for the header to dispatch
		`feathers.events.TriggerEvent.TRIGGER` to determine when to toggle the
		visibility of the content.

		- If the header does not implement any of the above events, the header
		will listen for `openfl.events.MouseEvent.CLICK`.

		In the following example, a custom header factory is provided:

		```haxe
		collapsible.headerFactory = () ->
		{
			return new ToggleButton();
		};
		```

		@since 1.3.0
	**/
	public var headerFactory(get, set):AbstractDisplayObjectFactory<Dynamic, DisplayObject>;

	private function get_headerFactory():AbstractDisplayObjectFactory<Dynamic, DisplayObject> {
		return this._headerFactory;
	}

	private function set_headerFactory(value:AbstractDisplayObjectFactory<Dynamic, DisplayObject>):AbstractDisplayObjectFactory<Dynamic, DisplayObject> {
		if (this._headerFactory == value) {
			return this._headerFactory;
		}
		this._headerFactory = value;
		this.setInvalid(INVALIDATION_FLAG_HEADER_FACTORY);
		return this._headerFactory;
	}

	private var _previousCustomHeaderVariant:String = null;

	/**
		A custom variant to set on the header, instead of
		`Collapsible.CHILD_VARIANT_HEADER`.

		The `customHeaderVariant` will be not be used if the result of
		`headerFactory` already has a variant set.

		@see `Collapsible.CHILD_VARIANT_HEADER`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.3.0
	**/
	@:style
	public var customHeaderVariant:String = null;

	/**
		The easing function to use when animating open or closed.

		@default motion.easing.Quart.easeOut

		@since 1.3.0

		@see `Collapsible.openCloseDuration`
	**/
	public var openCloseEase:IEasing = Quart.easeOut;

	/**
		The duration, measured in seconds, of the animation when the content
		opens and closes.

		In the following example, the duration of the animation that toggles the
		thumb is set to 500 milliseconds:

		```haxe
		collapsible.openCloseDuration = 0.5;
		```

		@since 1.3.0

		@see `Collapsible.openCloseEase`
	**/
	@:style
	public var openCloseDuration:Float = 0.2;

	/**
		Optionally fades the `alpha` value of the content when opening and
		closing.

		In the following example, the alpha value fades on open and close:

		```haxe
		collapsible.animateContentAlpha = true;
		```

		@since 1.3.0
	**/
	@:style
	public var animateContentAlpha:Bool = false;

	override public function dispose():Void {
		if (this._collapseActuator != null) {
			Actuate.stop(this._collapseActuator);
			this._collapseActuator = null;
		}
		this.content = null;
		this.destroyHeader();
		super.dispose();
	}

	/**
		Opens the content, if it is currently closed.

		@since 1.3.0
	**/
	public function openContent(animate:Bool = true):Void {
		this._pendingAnimation = animate;
		if (this._pendingOpened != null && this._pendingOpened) {
			return;
		}
		if (this._opened) {
			return;
		}
		var result = FeathersEvent.dispatch(this, FeathersEvent.OPENING, false, true);
		if (!result) {
			return;
		}
		this._pendingOpened = true;
		this.setInvalid(DATA);
	}

	/**
		Closes the content, if it is currently open.

		@since 1.3.0
	**/
	public function closeContent(animate:Bool = true):Void {
		this._pendingAnimation = animate;
		if (this._pendingOpened != null && !this._pendingOpened) {
			return;
		}
		if (!this._opened) {
			return;
		}
		var result = FeathersEvent.dispatch(this, FeathersEvent.CLOSING, false, true);
		if (!result) {
			return;
		}
		this._pendingOpened = false;
		this.setInvalid(DATA);
	}

	private function initializeCollapsibleTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelCollapsibleStyles.initialize();
		#end
	}

	override private function update():Void {
		if (this._previousCustomHeaderVariant != this.customHeaderVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_HEADER_FACTORY);
		}
		var dataInvalid = this.isInvalid(DATA);
		var stateInvalid = this.isInvalid(STATE);
		var headerFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_HEADER_FACTORY);

		if (headerFactoryInvalid) {
			this.createHeader();
		}

		if (dataInvalid) {
			this.updateText();
			this.updateOpened();
		}

		if (stateInvalid || headerFactoryInvalid) {
			this.refreshEnabled();
		}

		this.measure();
		this.layoutChildren();

		this._previousCustomHeaderVariant = this.customHeaderVariant;
	}

	private function measure():Bool {
		var measureHeader:IMeasureObject = null;
		if ((this.header is IMeasureObject)) {
			measureHeader = cast this.header;
		}
		MeasurementsUtil.resetFluidlyWithParentValues(this.headerMeasurements, this.header, this.explicitWidth, null, this.explicitMinWidth, null,
			this.explicitMaxWidth, null);
		if ((this.header is IValidating)) {
			(cast this.header : IValidating).validateNow();
		}
		var measureContent:IMeasureObject = null;
		if (this._content != null) {
			if ((this._content is IMeasureObject)) {
				measureContent = cast this._content;
			}
			MeasurementsUtil.resetFluidlyWithParentValues(this._contentMeasurements, this._content, this.explicitWidth, null, this.explicitMinWidth, null,
				this.explicitMaxWidth, null);
			if ((this._content is IValidating)) {
				(cast this._content : IValidating).validateNow();
			}
		}

		this._measuredOpenHeight = this.header.height;
		if (this._content != null) {
			this._measuredOpenHeight += this._content.height;
		}

		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight && !needsMaxWidth && !needsMaxHeight) {
			return false;
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			newWidth = this.header.width;
			if (this._content != null) {
				newWidth = Math.max(newWidth, this._content.width);
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			if (this._pendingHeight != null) {
				newHeight = this._pendingHeight;
			} else {
				if (this._content != null && this._content.visible) {
					newHeight = this._measuredOpenHeight;
				} else {
					newHeight = this.header.height;
				}
			}
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			if (measureHeader != null) {
				newMinWidth = measureHeader.minWidth;
			} else {
				newMinWidth = this.header.width;
			}
			if (this._content != null) {
				if (measureContent != null) {
					newMinWidth = Math.max(newMinWidth, measureContent.minWidth);
				} else {
					newMinWidth = Math.max(newMinWidth, this._content.width);
				}
			}
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			newMinHeight = this.header.height;
		}

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}

	private function updateText():Void {
		if ((this.header is ITextControl)) {
			(cast this.header : ITextControl).text = this._text;
		}
	}

	private function updateOpened():Void {
		if (this._pendingOpened != null) {
			if (this._collapseActuator != null) {
				Actuate.stop(this._collapseActuator);
				this._collapseActuator = null;
				FeathersEvent.dispatch(this, Event.CANCEL);
			}
			var oldIgnoreHeaderEvents = this._ignoreHeaderEvents;
			this._ignoreHeaderEvents = true;
			if ((this.header is IOpenCloseToggle)) {
				(cast this.header : IOpenCloseToggle).opened = this._pendingOpened;
			} else if ((this.header is IToggle)) {
				(cast this.header : IToggle).selected = this._pendingOpened;
			}
			this._ignoreHeaderEvents = oldIgnoreHeaderEvents;
			if (this._pendingAnimation) {
				this._pendingHeight = this.actualHeight;
				if (this._pendingOpened) {
					if (this._content != null) {
						this._content.visible = true;
					}
					var targetHeight = this.header.height;
					if (this._content != null) {
						targetHeight += this._content.height;
					}
					var tween = Actuate.update((height:Float, alpha:Float) -> {
						if (this.animateContentAlpha && this._content != null) {
							this._content.alpha = alpha;
						}
						this._pendingHeight = height;
						this.setInvalid(SIZE);
					},
						this.openCloseDuration, [this.actualHeight, this._content != null ? this._content.alpha : 0.0],
						[targetHeight, this._contentOriginalAlpha]).ease(this.openCloseEase).onComplete(() -> {
							this._pendingHeight = null;
							this.setInvalid(SIZE);
							FeathersEvent.dispatch(this, Event.OPEN);
						});
					this._collapseActuator = cast tween;
				} else {
					if (this._content != null) {
						this._content.visible = true;
					}
					var tween = Actuate.update((height:Float, alpha:Float) -> {
						if (this.animateContentAlpha && this._content != null) {
							this._content.alpha = alpha;
						}
						this._pendingHeight = height;
						this.setInvalid(SIZE);
					},
						this.openCloseDuration, [this.actualHeight, this._content != null ? this._content.alpha : 1.0],
						[this.header.height, 0.0]).ease(this.openCloseEase).onComplete(() -> {
							this._pendingHeight = null;
							if (this._content != null) {
								this._content.visible = false;
							}
							this.setInvalid(SIZE);
							FeathersEvent.dispatch(this, Event.CLOSE);
						});
					this._collapseActuator = cast tween;
				}
			} else {
				if (this._content != null) {
					this._content.visible = this._pendingOpened;
				}
			}
			this._opened = this._pendingOpened;
			this._pendingOpened = null;
		} else {
			var oldIgnoreHeaderEvents = this._ignoreHeaderEvents;
			this._ignoreHeaderEvents = true;
			if ((this.header is IOpenCloseToggle)) {
				(cast this.header : IOpenCloseToggle).opened = this._opened;
			} else if ((this.header is IToggle)) {
				(cast this.header : IToggle).selected = this._opened;
			}
			this._ignoreHeaderEvents = oldIgnoreHeaderEvents;
			if (this._content != null) {
				this._content.visible = this._opened;
			}
		}
	}

	private function createHeader():Void {
		this.destroyHeader();
		var factory = this._headerFactory != null ? this._headerFactory : defaultHeaderFactory;
		this._oldHeaderFactory = factory;
		this.header = factory.create();
		if ((this.header is IVariantStyleObject)) {
			var styleHeader:IVariantStyleObject = cast header;
			if (styleHeader.variant == null) {
				styleHeader.variant = this.customHeaderVariant != null ? this.customHeaderVariant : Collapsible.CHILD_VARIANT_HEADER;
			}
		}
		if ((this.header is IOpenCloseToggle)) {
			this.header.addEventListener(Event.OPEN, collapsible_header_openHandler);
			this.header.addEventListener(Event.CLOSE, collapsible_header_closeHandler);
		} else if ((this.header is IToggle)) {
			this.header.addEventListener(Event.CHANGE, collapsible_header_changeHandler);
		} else if ((this.header is ITriggerView)) {
			this.header.addEventListener(TriggerEvent.TRIGGER, collapsible_header_triggerHandler);
		} else {
			this.header.addEventListener(MouseEvent.CLICK, collapsible_header_clickHandler);
		}
		if ((this.header is IUIControl)) {
			(cast this.header : IUIControl).initializeNow();
		}
		this.headerMeasurements.save(this.header);
		this.addChild(this.header);
	}

	private function destroyHeader():Void {
		if (this.header == null) {
			return;
		}
		this.header.removeEventListener(Event.OPEN, collapsible_header_openHandler);
		this.header.removeEventListener(Event.CLOSE, collapsible_header_closeHandler);
		this.header.removeEventListener(Event.CHANGE, collapsible_header_changeHandler);
		this.header.removeEventListener(TriggerEvent.TRIGGER, collapsible_header_triggerHandler);
		this.header.removeEventListener(MouseEvent.CLICK, collapsible_header_clickHandler);
		this.removeChild(this.header);
		if (this._oldHeaderFactory.destroy != null) {
			this._oldHeaderFactory.destroy(this.header);
		}
		this._oldHeaderFactory = null;
		this.header = null;
	}

	private function layoutChildren():Void {
		this.header.x = 0.0;
		this.header.y = 0.0;
		this.header.width = this.actualWidth;
		if ((this.header is IValidating)) {
			(cast this.header : IValidating).validateNow();
		}

		if (this._content != null) {
			var oldIgnoreContentResize = this._ignoreContentResize;
			this._ignoreContentResize = true;
			this._content.x = 0.0;
			this._content.y = this.header.height;
			if (this._content.width != this.actualWidth) {
				this._content.width = this.actualWidth;
			}
			var contentHeight = (this._explicitHeight != null ? this._explicitHeight : this._measuredOpenHeight) - this.header.height;
			if (contentHeight < 0.0) {
				contentHeight = 0.0;
			}
			if (this._content.height != contentHeight) {
				this._content.height = contentHeight;
			}
			if ((this._content is IValidating)) {
				(cast this._content : IValidating).validateNow();
			}
			if (this._pendingHeight != null) {
				// instead of creating a new Rectangle each time, swap between
				// two Rectangles that are reused
				var scrollRect = this._currentScrollRect == this._scrollRect1 ? this._scrollRect2 : this._scrollRect1;
				scrollRect.setTo(0.0, 0.0, this.actualWidth, this._pendingHeight - this.header.height);
				this._currentScrollRect = scrollRect;
				this._content.scrollRect = scrollRect;
			} else if (this._currentScrollRect != null) {
				this._currentScrollRect = null;
				this._content.scrollRect = null;
			}
			this._ignoreContentResize = oldIgnoreContentResize;
		}
	}

	private function refreshEnabled():Void {
		if ((this.header is IUIControl)) {
			(cast this.header : IUIControl).enabled = this._enabled;
		}
	}

	private function collapsible_header_openHandler(event:Event):Void {
		if (this._ignoreHeaderEvents) {
			return;
		}
		this.openContent(true);
	}

	private function collapsible_header_closeHandler(event:Event):Void {
		if (this._ignoreHeaderEvents) {
			return;
		}
		this.closeContent(true);
	}

	private function collapsible_header_changeHandler(event:Event):Void {
		if (this._ignoreHeaderEvents) {
			return;
		}
		var toggleHeader:IToggle = cast header;
		if (toggleHeader.selected) {
			this.openContent(true);
		} else {
			this.closeContent(true);
		}
	}

	private function collapsible_header_triggerHandler(event:TriggerEvent):Void {
		if (this._ignoreHeaderEvents) {
			return;
		}
		if (this._opened) {
			this.closeContent(true);
		} else {
			this.openContent(true);
		}
	}

	private function collapsible_header_clickHandler(event:MouseEvent):Void {
		if (this._ignoreHeaderEvents) {
			return;
		}
		if (this._opened) {
			this.closeContent(true);
		} else {
			this.openContent(true);
		}
	}

	private function collapsible_content_resizeHandler(event:Event):Void {
		setInvalid(LAYOUT);
	}
}
