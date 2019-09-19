/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.events.Event;
import openfl.errors.IllegalOperationError;
import feathers.events.FeathersEvent;
import feathers.layout.ILayoutData;
import feathers.layout.ILayoutObject;
import feathers.style.IStyleObject;
import feathers.style.IStyleProvider;
import feathers.style.Theme;

/**
	Base class for all Feathers UI controls. Implements invalidation for changed
	properties and sets up some basic template functions for component
	lifecycle, like [`initialize()`](#initialize) and [`update()`](#update).

	This is a base class for Feathers components that isn't meant to be
	instantiated directly. It should only be subclassed. For a simple
	component that will automatically measure itself based on its children
	(including optional support for layouts), see
	`feathers.controls.LayoutGroup`.

	@since 1.0.0

	@see `feathers.controls.LayoutGroup`
**/
@:autoBuild(feathers.macros.StyleContextMacro.build())
@:autoBuild(feathers.macros.StyleMacro.build())
class FeathersControl extends MeasureSprite implements IUIControl implements IStyleObject implements ILayoutObject {
	private function new() {
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, feathersControl_addedToStageHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, feathersControl_removedFromStageHandler);
	}

	private var _initializing:Bool = false;

	/**
		Determines if the component has been initialized yet. The `initialize()`
		function is called one time only, when the Feathers UI control is added
		to the display list for the first time.

		In the following example, we check if the component is initialized
		or not, and we listen for an event if it isn't initialized:

		```hx
		if( !control.isInitialized )
		{
			control.addEventListener(FeathersEvent.INITIALIZE, initializeHandler);
		}
		```

		@see `FeathersEvent.INITIALIZE`
		@see `FeathersControl.initialize()`

		@since 1.0.0
	**/
	public var initialized(default, null):Bool = false;

	/**
		Determines if the component has been initialized and validated for the
		first time.

		In the following example, we check if the component is created or not,
		and we listen for an event if it isn't:

		```hx
		if( !control.isCreated )
		{
			control.addEventListener( FeathersEventType.CREATION_COMPLETE, creationCompleteHandler );
		}
		```

		@see `FeathersEvent.CREATION_COMPLETE`
		@see `FeathersControl.update()`
	**/
	public var created(default, null):Bool = false;

	/**
		Indicates whether the control should respond when a user attempts to
		interact with it. The appearance of the control may also be affected by
		whether the control is enabled or disabled.

		In the following example, the control is disabled:

		```hx
		component.enabled = false;
		```

		@default true

		@since 1.0.0
	**/
	@:isVar
	public var enabled(get, set):Bool = true;

	private function get_enabled():Bool {
		return this.enabled;
	}

	private function set_enabled(value:Bool):Bool {
		if (this.enabled == value) {
			return this.enabled;
		}
		this.enabled = value;
		this.setInvalid(InvalidationFlag.STATE);
		return this.enabled;
	}

	private var _currentStyleProvider:IStyleProvider = null;
	private var _fallbackStyleProvider:IStyleProvider = null;
	private var _customStyleProvider:IStyleProvider = null;

	/**
		When a component initializes, a style provider may be used to set
		properties that affect the component's visual appearance.

		You can set or replace an existing style provider at any time before a
		component initializes without immediately affecting the component's
		visual appearance. After the component initializes, the style provider
		may still be changed, and any properties that were set by the previous
		style provider will be reset to their default values before applying the
		new style provider.

		@see #variant
		@see [Introduction to Feathers UI themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public var styleProvider(get, set):IStyleProvider;

	private function get_styleProvider():IStyleProvider {
		if (this._customStyleProvider != null) {
			return this._customStyleProvider;
		}
		return this._currentStyleProvider;
	}

	private function set_styleProvider(value:IStyleProvider):IStyleProvider {
		if (this._customStyleProvider == value) {
			return this._customStyleProvider;
		}
		this._customStyleProvider = value;
		if (this.initialized) {
			// ignore if we're not initialized yet because it will be handled
			// later. otherwise, apply the new styles immediately.
			this.applyStyles();
		}
		this.setInvalid(InvalidationFlag.STYLES);
		return this._customStyleProvider;
	}

	/**
		The class used as the context for styling the component. If a subclass
		of a component should have different styles than its superclass, it
		should override the `get_styleContext` getter. However, if a subclass
		should continue using the same styles as its superclass, it happens
		automatically.

		@since 1.0.0
	**/
	public var styleContext(get, never):Class<IStyleObject>;

	private function get_styleContext():Class<IStyleObject> {
		return null;
	}

	/**
		Determines if the `ILayout` of the parent container should measure and
		position this object or ignore it.

		In the following example, the object is excluded from the layout:

		```hx
		object.includeInLayout = false;
		```

		@since 1.0.0
	**/
	public var includeInLayout(default, set):Bool = true;

	private function set_includeInLayout(value:Bool):Bool {
		if (this.includeInLayout == value) {
			return this.includeInLayout;
		}
		this.includeInLayout = value;
		FeathersEvent.dispatch(this, FeathersEvent.LAYOUT_DATA_CHANGE);
		return this.includeInLayout;
	}

	/**
		Optional, extra data used by some `ILayout` implementations.

		@since 1.0.0
	**/
	@style
	public var layoutData(default, set):ILayoutData = null;

	private function set_layoutData(value:ILayoutData):ILayoutData {
		if (!this.setStyle("layoutData")) {
			return this.layoutData;
		}
		if (this._clearingStyles) {
			value = null;
		}
		if (this.layoutData == value) {
			return this.layoutData;
		}
		if (this.layoutData != null) {
			this.layoutData.removeEventListener(Event.CHANGE, layoutData_changeHandler);
		}
		this.layoutData = value;
		if (this.layoutData != null) {
			this.layoutData.addEventListener(Event.CHANGE, layoutData_changeHandler, false, 0, true);
		}
		FeathersEvent.dispatch(this, FeathersEvent.LAYOUT_DATA_CHANGE);
		return this.layoutData;
	}

	/**
		May be used to provide multiple different variations of the same UI
		component, each with a different appearance.

		@since 1.0.0
	**/
	public var variant(default, set):String = null;

	private function set_variant(value:String):String {
		if (this.variant == value) {
			return this.variant;
		}
		this.variant = value;
		if (this.initialized) {
			// ignore if we're not initialized yet because it will be handled
			// later. otherwise, apply the new styles immediately.
			this.applyStyles();
		}
		this.setInvalid(InvalidationFlag.STYLES);
		return this.variant;
	}

	private var _applyingStyles:Bool = false;
	private var _clearingStyles:Bool = false;
	private var _styleProviderStyles:Array<StyleDefinition> = [];
	private var _restrictedStyles:Array<StyleDefinition> = [];

	override public function validateNow():Void {
		if (!this.initialized) {
			if (this._initializing) {
				throw new IllegalOperationError("A component cannot validate until after it has finished initializing.");
			}
			this.initializeNow();
			this.applyStyles();
		}
		super.validateNow();
		if (!this.created) {
			this.created = true;
			FeathersEvent.dispatch(this, FeathersEvent.CREATION_COMPLETE);
		}
	}

	/**
		If the component has not yet initialized, initializes immediately. The
		`initialize()` method will be called, and the `FeathersEvent.INITIALIZE`
		event will be dispatched. Then, if the component has a style provider, it
		will be applied. The component will not validate, though. To both
		initialize and validate immediately, call `validateNow()` instead.

		@since 1.0.0
	**/
	public function initializeNow():Void {
		if (this.initialized || this._initializing) {
			return;
		}
		this._initializing = true;
		this.initialize();
		this.setInvalid(); // set everything invalid
		this._initializing = false;
		this.initialized = true;
		FeathersEvent.dispatch(this, FeathersEvent.INITIALIZE);
	}

	/**
		Sets both the `x` and `y` positions of the control in a single function
		call.

		@see `DisplayObject.x`
		@see `DisplayObject.y`

		@since 1.0.0
	**/
	public function move(x:Float, y:Float):Void {
		this.x = x;
		this.y = y;
	}

	/**
		Sets both the `width` and `height` dimensions of the control in a single
		function call.

		@see `DisplayObject.width`
		@see `DisplayObject.height`

		@since 1.0.0
	**/
	public function setSize(width:Float, height:Float):Void {
		this.width = width;
		this.height = height;
	}

	/**
		Called the first time that the UI control is added to the stage, and
		you should override this function to customize the initialization
		process. Do things like create children and set up event listeners.
		After this function is called, `Event.INIT` is dispatched.

		@since 1.0.0
	**/
	@:dox(show)
	private function initialize():Void {}

	/**
		Determines if a style may be changed, and restricts the style from being
		changed in the future, if necessary.

		@since 1.0.0
	**/
	@:dox(show)
	private function setStyle(styleName:String, ?state:EnumValue):Bool {
		var styleDef = state == null ? StyleDefinition.Name(styleName) : StyleDefinition.NameAndState(styleName, state);
		var restricted = containsStyleDef(this._restrictedStyles, styleDef);
		if (this._applyingStyles && restricted) {
			return false;
		}
		if (this._applyingStyles) {
			if (!this._clearingStyles && !containsStyleDef(this._styleProviderStyles, styleDef)) {
				this._styleProviderStyles.push(styleDef);
			}
		} else if (!restricted) {
			if (!this._clearingStyles && containsStyleDef(this._styleProviderStyles, styleDef)) {
				this._styleProviderStyles.remove(styleDef);
			}
			this._restrictedStyles.push(styleDef);
		}
		return true;
	}

	private function isStyleRestricted(styleName:String, ?state:EnumValue):Bool {
		var styleDef = state == null ? StyleDefinition.Name(styleName) : StyleDefinition.NameAndState(styleName, state);
		return containsStyleDef(this._restrictedStyles, styleDef);
	}

	private function containsStyleDef(target:Array<StyleDefinition>, styleDef:StyleDefinition):Bool {
		for (other in target) {
			if (styleDef.equals(other)) {
				return true;
			}
		}
		return false;
	}

	private function applyStyles():Void {
		if (!this.initialized) {
			throw new IllegalOperationError("Cannot apply styles until after a Feathers component has initialized.");
		}
		var styleProvider = this._customStyleProvider;
		if (styleProvider == null) {
			styleProvider = this._currentStyleProvider;
		}
		if (styleProvider == null) {
			var theme = Theme.getTheme(this);
			if (theme != null) {
				styleProvider = theme.getStyleProvider(this);
			}
		}
		if (this._currentStyleProvider != styleProvider) {
			if (this._currentStyleProvider != null) {
				this._currentStyleProvider.removeEventListener(Event.CHANGE, styleProvider_changeHandler);
				this._currentStyleProvider.removeEventListener(Event.CLEAR, styleProvider_clearHandler);
			}
			this._currentStyleProvider = styleProvider;
			if (this._currentStyleProvider != null) {
				this._currentStyleProvider.addEventListener(Event.CHANGE, styleProvider_changeHandler, false, 0, true);
				this._currentStyleProvider.addEventListener(Event.CLEAR, styleProvider_clearHandler, false, 0, true);
			}
		}

		var oldApplyingStyles = this._applyingStyles;
		// this flag ensures that the styles do not get restricted when the
		// theme sets them
		this._applyingStyles = true;

		// if there was a different style provider previously, clear old styles
		this.clearStyles();

		// then, set the styles from the main style provider
		if (this._currentStyleProvider != null) {
			this._currentStyleProvider.applyStyles(this);
		}

		// finally, set the styles from the fallback style provider
		styleProvider = null;
		if (Theme.fallbackTheme != null) {
			styleProvider = Theme.fallbackTheme.getStyleProvider(this);
		}
		if (this._fallbackStyleProvider != styleProvider) {
			if (this._fallbackStyleProvider != null) {
				this._fallbackStyleProvider.removeEventListener(Event.CHANGE, styleProvider_changeHandler);
				this._fallbackStyleProvider.removeEventListener(Event.CLEAR, styleProvider_clearHandler);
			}
			this._fallbackStyleProvider = styleProvider;
			if (this._fallbackStyleProvider != null) {
				this._fallbackStyleProvider.addEventListener(Event.CHANGE, styleProvider_changeHandler, false, 0, true);
				this._fallbackStyleProvider.addEventListener(Event.CLEAR, styleProvider_clearHandler, false, 0, true);
			}
		}
		if (this._fallbackStyleProvider != null) {
			this._fallbackStyleProvider.applyStyles(this);
		}

		this._applyingStyles = oldApplyingStyles;
	}

	private function clearStyles():Void {
		var oldClearingStyles = this._clearingStyles;
		this._clearingStyles = true;
		for (styleDef in this._styleProviderStyles) {
			switch (styleDef) {
				case Name(name):
					{
						Reflect.setProperty(this, name, null);
					}
				case NameAndState(name, state):
					{
						var method = Reflect.field(this, name);
						Reflect.callMethod(this, method, [state, null]);
					}
			}
		}
		this._styleProviderStyles = [];
		this._clearingStyles = oldClearingStyles;
	}

	private function feathersControl_addedToStageHandler(event:Event):Void {
		// initialize before setting the validation queue to avoid
		// getting added to the validation queue before initialization
		// completes.
		if (!this.initialized) {
			this.initializeNow();
		}
		this.applyStyles();
	}

	private function feathersControl_removedFromStageHandler(event:Event):Void {
		if (this._currentStyleProvider != null) {
			this._currentStyleProvider.removeEventListener(Event.CHANGE, styleProvider_changeHandler);
			this._currentStyleProvider.removeEventListener(Event.CLEAR, styleProvider_clearHandler);
			this._currentStyleProvider = null;
		}
	}

	private function styleProvider_changeHandler(event:Event):Void {
		this.applyStyles();
	}

	private function styleProvider_clearHandler(event:Event):Void {
		this._currentStyleProvider.removeEventListener(Event.CHANGE, styleProvider_changeHandler);
		this._currentStyleProvider.removeEventListener(Event.CLEAR, styleProvider_clearHandler);
		this._currentStyleProvider = null;
		this.applyStyles();
	}

	private function layoutData_changeHandler(event:Event):Void {
		FeathersEvent.dispatch(this, FeathersEvent.LAYOUT_DATA_CHANGE);
	}
}

private enum StyleDefinition {
	Name(name:String);
	NameAndState(name:String, state:EnumValue);
}
