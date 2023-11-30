/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.navigators;

import feathers.core.IDataSelector;
import feathers.core.IIndexSelector;
import feathers.core.IValidating;
import feathers.core.InvalidationFlag;
import feathers.data.IFlatCollection;
import feathers.events.FeathersEvent;
import feathers.events.FlatCollectionEvent;
import feathers.events.TabBarEvent;
import feathers.layout.RelativePosition;
import feathers.motion.effects.EventToPositionEffectContext;
import feathers.motion.effects.IEffectContext;
import feathers.utils.AbstractDisplayObjectFactory;
import feathers.utils.DisplayObjectFactory;
import feathers.utils.EdgePuller;
import feathers.utils.ExclusivePointer;
import openfl.display.DisplayObject;
import openfl.errors.ArgumentError;
import openfl.events.Event;

/**
	A container that supports navigation between views using a tab bar.

	The following example creates a tab navigator and adds some items:

	```haxe
	var navigator = new TabNavigator();
	navigator.dataProvider = new ArrayCollection([
		TabItem.withClass("Home", HomeView),
		TabItem.withClass("Profile", ProfileView),
		TabItem.withClass("Settings", SettingsView)
	]);
	addChild(this.navigator);
	```

	@see [Tutorial: How to use the TabNavigator component](https://feathersui.com/learn/haxe-openfl/tab-navigator/)
	@see [Transitions for Feathers UI navigators](https://feathersui.com/learn/haxe-openfl/navigator-transitions/)
	@see `feathers.controls.navigators.TabItem`
	@see `feathers.controls.TabBar`

	@since 1.0.0
**/
@:access(feathers.controls.navigators.TabItem)
@defaultXmlProperty("dataProvider")
@:styleContext
class TabNavigator extends BaseNavigator implements IIndexSelector implements IDataSelector<TabItem> {
	private static final INVALIDATION_FLAG_TAB_BAR_FACTORY = InvalidationFlag.CUSTOM("tabBarFactory");

	/**
		The variant used to style the `TabBar` child component.

		To override this default variant, set the
		`TabNavigator.customTabBarVariant` property.

		@see `TabNavigator.customTabBarVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_TAB_BAR = "tabNavigator_tabBar";

	private static final defaultTabBarFactory = DisplayObjectFactory.withClass(TabBar);

	/**
		Creates a new `TabNavigator` object.

		@since 1.0.0
	**/
	public function new(?dataProvider:IFlatCollection<TabItem>) {
		initializeTabNavigatorTheme();

		super();

		this.dataProvider = dataProvider;

		this._viewsContainer = new LayoutGroup();
		this.addChild(this._viewsContainer);
	}

	private var tabBar:TabBar;

	private var _previousEdgePuller:EdgePuller;
	private var _nextEdgePuller:EdgePuller;

	private var _dataProvider:IFlatCollection<TabItem>;

	/**
		The collection of `TabItem` data displayed by the navigator.

		All `TabItem` instances in the collection must be unique. Do not add
		the same instance to the collection more than once because a runtime
		exception may be thrown.

		@since 1.0.0
	**/
	@:bindable("dataChange")
	public var dataProvider(get, set):IFlatCollection<TabItem>;

	private function get_dataProvider():IFlatCollection<TabItem> {
		return this._dataProvider;
	}

	private function set_dataProvider(value:IFlatCollection<TabItem>):IFlatCollection<TabItem> {
		if (this._dataProvider == value) {
			return this._dataProvider;
		}
		if (this._dataProvider != null) {
			this._dataProvider.removeEventListener(FlatCollectionEvent.ADD_ITEM, tabNavigator_dataProvider_addItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.REMOVE_ITEM, tabNavigator_dataProvider_removeItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.REPLACE_ITEM, tabNavigator_dataProvider_replaceItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.REMOVE_ALL, tabNavigator_dataProvider_removeAllHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.RESET, tabNavigator_dataProvider_resetHandler);
			if (value == null) {
				this.removeAllItems();
			} else {
				for (item in this._dataProvider) {
					this.removeItemInternal(item.internalID);
				}
			}
		}
		this._dataProvider = value;
		if (this._dataProvider != null) {
			for (item in this._dataProvider) {
				this.addItemInternal(item.internalID, item);
			}
			this._dataProvider.addEventListener(FlatCollectionEvent.ADD_ITEM, tabNavigator_dataProvider_addItemHandler, false, 0, true);
			this._dataProvider.addEventListener(FlatCollectionEvent.REMOVE_ITEM, tabNavigator_dataProvider_removeItemHandler, false, 0, true);
			this._dataProvider.addEventListener(FlatCollectionEvent.REPLACE_ITEM, tabNavigator_dataProvider_replaceItemHandler, false, 0, true);
			this._dataProvider.addEventListener(FlatCollectionEvent.REMOVE_ALL, tabNavigator_dataProvider_removeAllHandler, false, 0, true);
			this._dataProvider.addEventListener(FlatCollectionEvent.RESET, tabNavigator_dataProvider_resetHandler, false, 0, true);
		}
		this.setInvalid(DATA);
		if (this._dataProvider == null || this._dataProvider.length == 0) {
			// use the setter
			this.selectedIndex = -1;
		} else {
			// use the setter
			this.selectedIndex = 0;
		}
		FeathersEvent.dispatch(this, "dataChange");
		return this._dataProvider;
	}

	private var _activeItemIndex:Int = -1;

	private var _selectedIndex:Int = -1;

	/**
		@see `feathers.core.IIndexSelector.selectedIndex`
	**/
	public var selectedIndex(get, set):Int;

	private function get_selectedIndex():Int {
		return this._selectedIndex;
	}

	private function set_selectedIndex(value:Int):Int {
		if (this._dataProvider == null) {
			value = -1;
		}
		if (this._selectedIndex == value) {
			return this._selectedIndex;
		}
		this._selectedIndex = value;
		// using variable because if we were to call the selectedItem setter,
		// then this change wouldn't be saved properly
		if (this._selectedIndex == -1) {
			this._selectedItem = null;
		} else {
			this._selectedItem = this._dataProvider.get(this._selectedIndex);
		}
		this.setInvalid(SELECTION);
		// don't dispatch Event.CHANGE here because it will be dispatched as
		// part of the process of changing the view in BaseNavigator
		return this._selectedIndex;
	}

	/**
		@see `feathers.core.IIndexSelector.maxSelectedIndex`
	**/
	public var maxSelectedIndex(get, never):Int;

	private function get_maxSelectedIndex():Int {
		if (this._dataProvider == null) {
			return -1;
		}
		return this._dataProvider.length - 1;
	}

	private var _selectedItem:TabItem = null;

	/**
		@see `feathers.core.IDataSelector.selectedItem`
	**/
	public var selectedItem(get, set):#if flash Dynamic #else TabItem #end;

	private function get_selectedItem():#if flash Dynamic #else TabItem #end {
		return this._selectedItem;
	}

	private function set_selectedItem(value:#if flash Dynamic #else TabItem #end):#if flash Dynamic #else TabItem #end {
		if (this._dataProvider == null) {
			// use the setter
			this.selectedIndex = -1;
			return this._selectedItem;
		}
		// use the setter
		this.selectedIndex = this._dataProvider.indexOf(value);
		return this._selectedItem;
	}

	/**
		The position of the navigator's tab bar.

		@since 1.0.0
	**/
	@:style
	public var tabBarPosition:RelativePosition = BOTTOM;

	private var _swipeEnabled:Bool = false;

	/**
		If `true`, a swipe left or right with touch may be used to navigate to
		the previous or next tab.

		@see `TabNavigator.simulateTouch`

		@since 1.0.0
	**/
	public var swipeEnabled(get, set):Bool;

	private function get_swipeEnabled():Bool {
		return this._swipeEnabled;
	}

	private function set_swipeEnabled(value:Bool):Bool {
		if (this._swipeEnabled == value) {
			return this._swipeEnabled;
		}
		this._swipeEnabled = value;
		this.setInvalid(DATA);
		return this._swipeEnabled;
	}

	private var _simulateTouch:Bool = false;

	private var _dragTransitionContext:EventToPositionEffectContext;

	/**
		Determines if mouse events should be treated like touch events when
		detecting a swipe.

		@see `TabNavigator.swipeEnabled`

		@since 1.0.0
	**/
	public var simulateTouch(get, set):Bool;

	private function get_simulateTouch():Bool {
		return this._simulateTouch;
	}

	private function set_simulateTouch(value:Bool):Bool {
		if (this._simulateTouch == value) {
			return this._simulateTouch;
		}
		this._simulateTouch = value;
		this.setInvalid(DATA);
		return this._simulateTouch;
	}

	/**
		The default transition to use for navigating to the previous tab.

		@since 1.0.0
	**/
	@:style
	public var previousTransition:(DisplayObject, DisplayObject) -> IEffectContext = null;

	/**
		The default transition to use for navigating to the next tab.

		@since 1.0.0
	**/
	@:style
	public var nextTransition:(DisplayObject, DisplayObject) -> IEffectContext = null;

	/**
		The space, measured in pixels, between the navigator's active view and
		its tab bar.

		@since 1.0.0
	**/
	@:style
	public var gap:Float = 0.0;

	private var _previousCustomTabBarVariant:String = null;

	/**
		An optional custom variant to use for the tab bar sub-component,
		instead of `TabNavigator.CHILD_VARIANT_TAB_BAR`.

		The `customTabBarVariant` will be not be used if the result of
		`tabBarFactory` already has a variant set.

		@see `TabNavigator.CHILD_VARIANT_TAB_BAR`

		@since 1.0.0
	**/
	@:style
	public var customTabBarVariant:String = null;

	private var _oldTabBarFactory:DisplayObjectFactory<Dynamic, TabBar>;

	private var _tabBarFactory:DisplayObjectFactory<Dynamic, TabBar>;

	/**
		Creates the tab bar, which must be of type `feathers.controls.TabBar`.

		In the following example, a custom tab bar factory is provided:

		```haxe
		navigator.tabBarFactory = () ->
		{
			return new TabBar();
		};
		```

		@see `feathers.controls.TabBar`

		@since 1.0.0
	**/
	public var tabBarFactory(get, set):AbstractDisplayObjectFactory<Dynamic, TabBar>;

	private function get_tabBarFactory():AbstractDisplayObjectFactory<Dynamic, TabBar> {
		return this._tabBarFactory;
	}

	private function set_tabBarFactory(value:AbstractDisplayObjectFactory<Dynamic, TabBar>):AbstractDisplayObjectFactory<Dynamic, TabBar> {
		if (this._tabBarFactory == value) {
			return this._tabBarFactory;
		}
		this._tabBarFactory = value;
		this.setInvalid(INVALIDATION_FLAG_TAB_BAR_FACTORY);
		return this._tabBarFactory;
	}

	private var _ignoreSelectionChange = false;

	override public function dispose():Void {
		this._pendingItemID = null;
		this._pendingItemTransition = null;
		this._transitionActive = false;
		if (this._activeTransition != null) {
			this._activeTransition.removeEventListener(Event.COMPLETE, transition_completeHandler);
			this._activeTransition.removeEventListener(Event.CANCEL, transition_cancelHandler);
			this._activeTransition.stop();
		}
		this.destroyTabBar();
		// manually clear the active view so that removing the data provider
		// doesn't result in Event.CHANGE getting dispatched
		this._activeItemID = null;
		this._activeItemView = null;
		this.dataProvider = null;
		super.dispose();
	}

	override private function initialize():Void {
		super.initialize();

		if (this._previousEdgePuller == null) {
			this._previousEdgePuller = new EdgePuller(this, LEFT);
			this._previousEdgePuller.addEventListener(FeathersEvent.OPENING, tabNavigator_previousEdgePuller_openingHandler);
			this._previousEdgePuller.addEventListener(Event.CANCEL, tabNavigator_previousEdgePuller_cancelHandler);
			this._previousEdgePuller.addEventListener(Event.OPEN, tabNavigator_previousEdgePuller_openHandler);
		}
		if (this._nextEdgePuller == null) {
			this._nextEdgePuller = new EdgePuller(this, RIGHT);
			this._nextEdgePuller.addEventListener(FeathersEvent.OPENING, tabNavigator_nextEdgePuller_openingHandler);
			this._nextEdgePuller.addEventListener(Event.CANCEL, tabNavigator_nextEdgePuller_cancelHandler);
			this._nextEdgePuller.addEventListener(Event.OPEN, tabNavigator_nextEdgePuller_openHandler);
		}
	}

	private function itemToText(item:TabItem):String {
		return item.text;
	}

	private function initializeTabNavigatorTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelTabNavigatorStyles.initialize();
		#end
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var selectionInvalid = this.isInvalid(SELECTION);
		if (this._previousCustomTabBarVariant != this.customTabBarVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_TAB_BAR_FACTORY);
		}
		var tabBarInvalid = this.isInvalid(INVALIDATION_FLAG_TAB_BAR_FACTORY);

		if (tabBarInvalid) {
			this.createTabBar();
		}

		if (dataInvalid || tabBarInvalid) {
			this.tabBar.itemToText = this.itemToText;
			var oldIgnoreSelectionChange = this._ignoreSelectionChange;
			this._ignoreSelectionChange = true;
			this.tabBar.dataProvider = this._dataProvider;
			this._ignoreSelectionChange = oldIgnoreSelectionChange;
		}

		if (dataInvalid) {
			this._previousEdgePuller.simulateTouch = this._simulateTouch;
			this._nextEdgePuller.simulateTouch = this._simulateTouch;
		}

		if (dataInvalid || selectionInvalid || tabBarInvalid) {
			this.refreshSelection();
		}

		super.update();

		this._previousCustomTabBarVariant = this.customTabBarVariant;
	}

	override private function measure():Bool {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight && !needsMaxWidth && !needsMaxHeight) {
			return false;
		}

		var needsToMeasureContent = this._autoSizeMode == CONTENT || this.stage == null;

		if (needsToMeasureContent) {
			if (this.explicitWidth != null) {
				this.tabBar.width = this.explicitWidth;
			} else {
				this.tabBar.resetWidth();
			}
			this.tabBar.validateNow();
			switch (this.tabBarPosition) {
				case TOP:
					this.topContentOffset = this.tabBar.height + this.gap;
				case BOTTOM:
					this.bottomContentOffset = this.tabBar.height + this.gap;
				default:
					throw new ArgumentError('Invalid tabBarPosition ${this.tabBarPosition}');
			}
		}
		return super.measure();
	}

	private function createTabBar():Void {
		this.destroyTabBar();
		var factory = this._tabBarFactory != null ? this._tabBarFactory : defaultTabBarFactory;
		this._oldTabBarFactory = factory;
		this.tabBar = factory.create();
		if (this.tabBar.variant == null) {
			this.tabBar.variant = this.customTabBarVariant != null ? this.customTabBarVariant : TabNavigator.CHILD_VARIANT_TAB_BAR;
		}
		this.tabBar.addEventListener(TabBarEvent.ITEM_TRIGGER, tabNavigator_tabBar_itemTriggerHandler);
		this.tabBar.addEventListener(Event.CHANGE, tabNavigator_tabBar_changeHandler);
		this.addChild(this.tabBar);
	}

	private function destroyTabBar():Void {
		if (this.tabBar == null) {
			return;
		}
		this.tabBar.removeEventListener(TabBarEvent.ITEM_TRIGGER, tabNavigator_tabBar_itemTriggerHandler);
		this.tabBar.removeEventListener(Event.CHANGE, tabNavigator_tabBar_changeHandler);
		this.removeChild(this.tabBar);
		if (this._oldTabBarFactory.destroy != null) {
			this._oldTabBarFactory.destroy(this.tabBar);
		}
		this._oldTabBarFactory = null;
		this.tabBar = null;
	}

	override private function layoutContent():Void {
		this.tabBar.x = 0.0;
		this.tabBar.width = this.actualWidth;
		this.tabBar.validateNow();
		switch (this.tabBarPosition) {
			case TOP:
				this.tabBar.y = 0.0;
			case BOTTOM:
				this.tabBar.y = this.actualHeight - this.tabBar.height;
			default:
				throw new ArgumentError('Invalid tabBarPosition ${this.tabBarPosition}');
		}

		this._viewsContainer.x = 0.0;
		switch (this.tabBarPosition) {
			case TOP:
				this._viewsContainer.y = this.tabBar.height + this.gap;
			case BOTTOM:
				this._viewsContainer.y = 0.0;
			default:
				throw new ArgumentError('Invalid tabBarPosition ${this.tabBarPosition}');
		}
		this._viewsContainer.width = this.actualWidth;
		this._viewsContainer.height = this.actualHeight - this.tabBar.height - this.gap;

		if (this._activeItemView != null) {
			this._activeItemView.x = 0.0;
			this._activeItemView.y = 0.0;
			this._activeItemView.width = this._viewsContainer.width;
			this._activeItemView.height = this._viewsContainer.height;
		}

		if (this._nextViewInTransition != null) {
			this._nextViewInTransition.x = 0.0;
			this._nextViewInTransition.y = 0.0;
			this._nextViewInTransition.width = this._viewsContainer.width;
			this._nextViewInTransition.height = this._viewsContainer.height;
		}

		if ((this._viewsContainer is IValidating)) {
			(cast this._viewsContainer : IValidating).validateNow();
		}
	}

	override private function getView(id:String):DisplayObject {
		var item = cast(this._addedItems.get(id), TabItem);
		return item.getView(this);
	}

	override private function disposeView(id:String, view:DisplayObject):Void {
		var item = cast(this._addedItems.get(id), TabItem);
		item.returnView(view);
	}

	private function refreshSelection():Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		this.tabBar.selectedIndex = this._selectedIndex;
		this._ignoreSelectionChange = oldIgnoreSelectionChange;

		if (this._selectedItem == null) {
			this._activeItemIndex = -1;
			if (this.activeItemID != null) {
				this.clearActiveItemInternal();
			}
		} else if (this._selectedItem != null) {
			var oldIndex = this._activeItemIndex;
			this._activeItemIndex = this._selectedIndex;
			if (!this._previousEdgePuller.active && !this._nextEdgePuller.active) {
				var activeID = this._transitionActive ? this._nextViewInTransitionID : this._activeItemID;
				if (activeID != this._selectedItem.internalID) {
					var transition:(DisplayObject, DisplayObject) -> IEffectContext = null;
					if (oldIndex != -1 && oldIndex != this._selectedIndex) {
						transition = (oldIndex < this._selectedIndex) ? this.nextTransition : this.previousTransition;
					}
					this.runWithInvalidationFlagsOnly(() -> {
						this.showItemInternal(this._selectedItem.internalID, transition);
					});
				}
			}
		}

		this._previousEdgePuller.enabled = this._enabled && this._swipeEnabled && this._selectedIndex > 0 && !this._nextEdgePuller.active;
		this._nextEdgePuller.enabled = this._enabled
			&& this._swipeEnabled
			&& this._selectedIndex < this.maxSelectedIndex
			&& !this._previousEdgePuller.active;
	}

	private function startPreviousDragTransition(one:DisplayObject, two:DisplayObject):IEffectContext {
		var effectContext = this.previousTransition(one, two);
		this._previousEdgePuller.snapDuration = effectContext.duration;
		this._dragTransitionContext = new EventToPositionEffectContext(effectContext, this._previousEdgePuller, Event.CHANGE, (event) -> {
			this._dragTransitionContext.position = this._previousEdgePuller.pullDistance / this.actualWidth;
		});
		return this._dragTransitionContext;
	}

	private function startNextDragTransition(one:DisplayObject, two:DisplayObject):IEffectContext {
		var effectContext = this.nextTransition(one, two);
		this._nextEdgePuller.snapDuration = effectContext.duration;
		this._dragTransitionContext = new EventToPositionEffectContext(effectContext, this._nextEdgePuller, Event.CHANGE, (event) -> {
			this._dragTransitionContext.position = this._nextEdgePuller.pullDistance / this.actualWidth;
		});
		return this._dragTransitionContext;
	}

	private function tabNavigator_tabBar_changeHandler(event:Event):Void {
		if (this._ignoreSelectionChange) {
			return;
		}
		// use the setter
		this.selectedIndex = this.tabBar.selectedIndex;
	}

	private function tabNavigator_tabBar_itemTriggerHandler(event:TabBarEvent):Void {
		this.dispatchEvent(event);
	}

	private function tabNavigator_dataProvider_addItemHandler(event:FlatCollectionEvent):Void {
		var item = cast(event.addedItem, TabItem);
		this.addItemInternal(item.internalID, item);

		if (this._selectedIndex >= event.index) {
			// use the setter
			this.selectedIndex++;
		} else if (this._selectedIndex == -1) {
			// if the data provider was previously empty, automatically select
			// the new item

			// use the setter
			this.selectedIndex = 0;
		}
	}

	private function tabNavigator_dataProvider_removeItemHandler(event:FlatCollectionEvent):Void {
		var item = cast(event.removedItem, TabItem);
		this.removeItemInternal(item.internalID);

		if (this._dataProvider.length == 0) {
			// use the setter
			this.selectedIndex = -1;
		} else if (this._selectedIndex >= event.index) {
			// use the setter
			this.selectedIndex--;
		}
	}

	private function tabNavigator_dataProvider_replaceItemHandler(event:FlatCollectionEvent):Void {
		var addedItem = cast(event.addedItem, TabItem);
		var removedItem = cast(event.removedItem, TabItem);
		this.removeItemInternal(removedItem.internalID);
		this.addItemInternal(addedItem.internalID, addedItem);

		if (this._selectedIndex == event.index) {
			this.selectedItem = this._dataProvider.get(this._selectedIndex);
		}
	}

	private function tabNavigator_dataProvider_removeAllHandler(event:FlatCollectionEvent):Void {
		// use the setter
		this.selectedIndex = -1;
		for (id in this._addedItems.keys()) {
			var item = this._addedItems.get(id);
			this.removeItemInternal(item.internalID);
		}
	}

	private function tabNavigator_dataProvider_resetHandler(event:FlatCollectionEvent):Void {
		// use the setter
		this.selectedIndex = -1;
		for (id in this._addedItems.keys()) {
			var item = this._addedItems.get(id);
			this.removeItemInternal(item.internalID);
		}
	}

	private function tabNavigator_previousEdgePuller_openingHandler(event:FeathersEvent):Void {
		var newIndex = this._selectedIndex - 1;
		if (newIndex < 0) {
			event.preventDefault();
			return;
		}

		var touchPointID = this._previousEdgePuller.touchPointID;
		if (touchPointID != null) {
			var exclusivePointer = ExclusivePointer.forStage(this.stage);
			if (this._previousEdgePuller.touchPointIsSimulated) {
				var result = exclusivePointer.claimMouse(this);
				if (!result) {
					event.preventDefault();
					return;
				}
			} else {
				var result = exclusivePointer.claimTouch(touchPointID, this);
				if (!result) {
					event.preventDefault();
					return;
				}
			}
		}

		if (this.previousTransition != null) {
			// disable the other edge until this edge's gesture is done
			this._nextEdgePuller.enabled = false;

			var item = this._dataProvider.get(newIndex);
			this.showItemInternal(item.internalID, this.startPreviousDragTransition);
		} else {
			event.preventDefault();
			this.selectedIndex = newIndex;
		}
	}

	private function tabNavigator_previousEdgePuller_cancelHandler(event:Event):Void {
		this._previousEdgePuller.enabled = this._enabled && this._swipeEnabled && this._selectedIndex > 0;
		this._nextEdgePuller.enabled = this._enabled && this._swipeEnabled && this._selectedIndex < this.maxSelectedIndex;

		var context = this._dragTransitionContext;
		this._dragTransitionContext = null;
		// can be null if cancelled before the transition starts
		if (context != null) {
			context.dispatcher = null;
			FeathersEvent.dispatch(context, Event.CANCEL);
		}
	}

	private function tabNavigator_previousEdgePuller_openHandler(event:Event):Void {
		// reset back to the closed state so that we can detect the next swipe
		var oldSnapDuration = this._previousEdgePuller.snapDuration;
		// temporarily disable the animation
		this._previousEdgePuller.snapDuration = 0.0;
		this._previousEdgePuller.opened = false;
		this._previousEdgePuller.snapDuration = oldSnapDuration;

		this.selectedIndex--;
		this._previousEdgePuller.enabled = this._enabled && this._swipeEnabled && this._selectedIndex > 0;
		this._nextEdgePuller.enabled = this._enabled && this._swipeEnabled && this._selectedIndex < this.maxSelectedIndex;

		var context = this._dragTransitionContext;
		this._dragTransitionContext = null;
		if (context != null) {
			context.dispatcher = null;
			FeathersEvent.dispatch(context, Event.COMPLETE);
		}
	}

	private function tabNavigator_nextEdgePuller_openingHandler(event:FeathersEvent):Void {
		var newIndex = this._selectedIndex + 1;
		if (newIndex > this.maxSelectedIndex) {
			event.preventDefault();
			return;
		}

		var touchPointID = this._nextEdgePuller.touchPointID;
		if (touchPointID != null) {
			var exclusivePointer = ExclusivePointer.forStage(this.stage);
			if (this._nextEdgePuller.touchPointIsSimulated) {
				var result = exclusivePointer.claimMouse(this);
				if (!result) {
					event.preventDefault();
					return;
				}
			} else {
				var result = exclusivePointer.claimTouch(touchPointID, this);
				if (!result) {
					event.preventDefault();
					return;
				}
			}
		}

		if (this.nextTransition != null) {
			// disable the other edge until this edge's gesture is done
			this._previousEdgePuller.enabled = false;

			var item = this._dataProvider.get(newIndex);
			this.showItemInternal(item.internalID, this.startNextDragTransition);
		} else {
			event.preventDefault();
			this.selectedIndex = newIndex;
		}
	}

	private function tabNavigator_nextEdgePuller_cancelHandler(event:Event):Void {
		this._previousEdgePuller.enabled = this._enabled && this._swipeEnabled && this._selectedIndex > 0;
		this._nextEdgePuller.enabled = this._enabled && this._swipeEnabled && this._selectedIndex < this.maxSelectedIndex;

		var context = this._dragTransitionContext;
		this._dragTransitionContext = null;
		// can be null if cancelled before the transition starts
		if (context != null) {
			context.dispatcher = null;
			FeathersEvent.dispatch(context, Event.CANCEL);
		}
	}

	private function tabNavigator_nextEdgePuller_openHandler(event:Event):Void {
		// reset back to the closed state so that we can detect the next swipe
		var oldSnapDuration = this._nextEdgePuller.snapDuration;
		// temporarily disable the animation
		this._nextEdgePuller.snapDuration = 0.0;
		this._nextEdgePuller.opened = false;
		this._nextEdgePuller.snapDuration = oldSnapDuration;

		this.selectedIndex++;
		this._previousEdgePuller.enabled = this._enabled && this._swipeEnabled && this._selectedIndex > 0;
		this._nextEdgePuller.enabled = this._enabled && this._swipeEnabled && this._selectedIndex < this.maxSelectedIndex;

		var context = this._dragTransitionContext;
		this._dragTransitionContext = null;
		if (context != null) {
			context.dispatcher = null;
			FeathersEvent.dispatch(context, Event.COMPLETE);
		}
	}
}
