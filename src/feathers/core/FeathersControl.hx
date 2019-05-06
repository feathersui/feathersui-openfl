/*
	Feathers
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
import haxe.rtti.Meta;

/**
	Base class for all Feathers UI controls. Implements invalidation for changed
	properties and sets up some basic template functions for component
	lifecycle, like [`initialize()`](#initialize) and [`update()`](#upetad).

	This is a base class for Feathers components that isn't meant to be
	instantiated directly. It should only be subclassed. For a simple
	component that will automatically measure itself based on its children
	(including optional support for layouts, see
	`feathers.controls.LayoutGroup`.

	@since 1.0.0

	@see `feathers.controls.LayoutGroup`
**/
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
		Indicates whether the control is interactive or not.

		In the following example, the control is disabled:

		```hx
		component.enabled = false;
		```

		@default true

		@since 1.0.0
	**/
	public var enabled(default, set):Bool = true;

	private function set_enabled(value:Bool):Bool {
		if (this.enabled == value) {
			return this.enabled;
		}
		this.enabled = value;
		this.setInvalid(InvalidationFlag.STATE);
		return this.enabled;
	}

	private var _styleProvider:IStyleProvider = null;

	/**
		The class used as the context for styling the component. If a subclass
		of a component should have different styles than its superclass, it
		should override the `get_styleContext` getter. However, if a subclass
		should continue using the same styles as its superclass, it happens
		automatically.

		@since 1.0.0
	**/
	public var styleContext(get, null):Class<IStyleObject>;

	private function get_styleContext():Class<IStyleObject> {
		return null;
	}

	/**
		Returns the component's default style provider. The
		`get_defaultStyleProvider` getter should be overridden by subclasses to
		provide default styles for a component.

		For best performance and lower memory, wait to create the default style
		provider until the first time that `get_styleProvider` is called on a
		component of that type. Store that style provider in a static variable
		so that all future instances of the same component can re-use the same
		style provider.

		@since 1.0.0
	**/
	public var defaultStyleProvider(get, null):IStyleProvider = null;

	private function get_defaultStyleProvider():IStyleProvider {
		return null;
	}

	public var includeInLayout(default, set):Bool = true;

	private function set_includeInLayout(value:Bool):Bool {
		if (this.includeInLayout == value) {
			return this.includeInLayout;
		}
		this.includeInLayout = value;
		FeathersEvent.dispatch(this, FeathersEvent.LAYOUT_DATA_CHANGE);
		return this.includeInLayout;
	}

	@style
	public var layoutData(default, set):ILayoutData;

	private function set_layoutData(value:ILayoutData):ILayoutData {
		if (!this.setStyle("layoutData")) {
			return this.layoutData;
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

	public var variant(default, set):String = null;

	private function set_variant(value:String):String {
		if (this.variant == value) {
			return this.variant;
		}
		this.variant = value;
		if (this.initialized) {
			this.applyStyles();
		}
		this.setInvalid(InvalidationFlag.STYLES);
		return this.variant;
	}

	private var _applyingStyles:Bool = false;
	private var _restrictedStyles:Array<String> = [];

	override public function validateNow():Void {
		if (!this.initialized) {
			if (this._initializing) {
				throw new IllegalOperationError("A component cannot validate until after it has finished initializing.");
			}
			this.initializeNow();
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
		will be applied. The component will not validate, though. To initialize
		and validate immediately, call `validateNow()` instead.

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
		this.width = x;
		this.height = y;
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
	private function setStyle(styleName:String):Bool {
		var restricted = this._restrictedStyles.indexOf(styleName) != -1;
		if (this._applyingStyles && restricted) {
			return false;
		}
		if (!this._applyingStyles && !restricted) {
			this._restrictedStyles.push(styleName);
		}
		return true;
	}

	private function isStyleRestricted(styleName:String):Bool {
		return this._restrictedStyles.indexOf(styleName) != -1;
	}

	private function applyStyles():Void {
		if (!this.initialized) {
			throw new IllegalOperationError("Cannot apply styles until after a Feathers component has initialized.");
		}
		var styleProvider = Theme.getStyleProvider(this);
		if (styleProvider == null) {
			styleProvider = this.defaultStyleProvider;
		}
		if (this._styleProvider != styleProvider) {
			if (this._styleProvider != null) {
				this._styleProvider.removeEventListener(Event.CHANGE, styleProvider_changeHandler);
			}
			this._styleProvider = styleProvider;
			this._styleProvider.addEventListener(Event.CHANGE, styleProvider_changeHandler, false, 0, true);
		}
		if (this._styleProvider == null) {
			return;
		}
		if (this.styleContext != null) {
			var oldApplyingStyles = this._applyingStyles;
			this._applyingStyles = true;
			this.clearStyles();
			this._styleProvider.applyStyles(this);
			this._applyingStyles = oldApplyingStyles;
		}
	}

	private function clearStyles():Void {
		var thisType = Type.getClass(this);
		var meta = Meta.getFields(thisType);
		for (fieldName in Type.getInstanceFields(thisType)) {
			// don't know why, but this seems to be necessary for C++ targets
			if (!Reflect.hasField(this, fieldName)) {
				continue;
			}
			var field = Reflect.field(meta, fieldName);
			if (field == null) {
				continue;
			};
			if (!Reflect.hasField(field, "style")) {
				continue;
			}
			// if this style is restricted, this call won't change anything
			Reflect.setProperty(this, fieldName, null);
		}
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
		if (this._styleProvider != null) {
			this._styleProvider.removeEventListener(Event.CHANGE, styleProvider_changeHandler);
			this._styleProvider = null;
		}
	}

	private function styleProvider_changeHandler(event:Event):Void {
		this.applyStyles();
	}

	private function layoutData_changeHandler(event:Event):Void {
		FeathersEvent.dispatch(this, FeathersEvent.LAYOUT_DATA_CHANGE);
	}
}
