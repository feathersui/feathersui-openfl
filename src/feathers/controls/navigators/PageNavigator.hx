/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.navigators;

import feathers.core.IDataSelector;
import feathers.core.IIndexSelector;
import feathers.core.InvalidationFlag;
import feathers.data.IFlatCollection;
import feathers.events.FeathersEvent;
import feathers.events.FlatCollectionEvent;
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
	A container that supports navigation between views using a `PageIndicator`.

	The following example creates a page navigator and adds some items:

	```haxe
	var navigator = new PageNavigator();
	navigator.dataProvider = new ArrayCollection([
		PageItem.withClass(WizardView1),
		PageItem.withClass(WizardView1),
		PageItem.withClass(WizardView3)
	]);
	addChild(this.navigator);
	```

	@see [Tutorial: How to use the PageNavigator component](https://feathersui.com/learn/haxe-openfl/page-navigator/)
	@see [Transitions for Feathers UI navigators](https://feathersui.com/learn/haxe-openfl/navigator-transitions/)
	@see `feathers.controls.navigators.PageItem`
	@see `feathers.controls.PageIndicator`

	@since 1.0.0
**/
@:access(feathers.controls.navigators.PageItem)
@defaultXmlProperty("dataProvider")
@:styleContext
class PageNavigator extends BaseNavigator implements IIndexSelector implements IDataSelector<PageItem> {
	private static final INVALIDATION_FLAG_PAGE_INDICATOR_FACTORY = InvalidationFlag.CUSTOM("pageIndicatorFactory");

	/**
		The variant used to style the `PageIndicator` child component.

		To override this default variant, set the
		`PageNavigator.customPageIndicatorVariant` property.

		@see `PageNavigator.customPageIndicatorVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_PAGE_INDICATOR = "pageNavigator_pageIndicator";

	private static final defaultPageIndicatorFactory = DisplayObjectFactory.withClass(PageIndicator);

	private static final NO_PENDING_SELECTED_INDEX:Int = -2;
	private static final NO_PENDING_SELECTED_ITEM:Any = {};

	/**
		Creates a new `PageNavigator` object.

		@since 1.0.0
	**/
	public function new(?dataProvider:IFlatCollection<PageItem>) {
		initializePageNavigatorTheme();

		this.dataProvider = dataProvider;

		super();

		this._viewsContainer = new LayoutGroup();
		this.addChild(this._viewsContainer);
	}

	private var pageIndicator:PageIndicator;

	private var _previousEdgePuller:EdgePuller;
	private var _nextEdgePuller:EdgePuller;

	private var _dataProvider:IFlatCollection<PageItem>;

	/**
		The collection of `PageItem` data displayed by the navigator.

		All `PageItem` instances in the collection must be unique. Do not add
		the same instance to the collection more than once because a runtime
		exception may be thrown.

		@since 1.0.0
	**/
	@:bindable("dataChange")
	public var dataProvider(get, set):IFlatCollection<PageItem>;

	private function get_dataProvider():IFlatCollection<PageItem> {
		return this._dataProvider;
	}

	private function set_dataProvider(value:IFlatCollection<PageItem>):IFlatCollection<PageItem> {
		if (this._dataProvider == value) {
			return this._dataProvider;
		}
		// removing items will result in Event.CHANGE getting dispatched, so
		// ensure that the selection is updated before that happens
		if (value == null || value.length == 0) {
			// use the setter
			this.selectedIndex = -1;
		} else {
			// use the setter
			this.selectedIndex = 0;
		}
		if (this._dataProvider != null) {
			this._dataProvider.removeEventListener(FlatCollectionEvent.ADD_ITEM, pageNavigator_dataProvider_addItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.REMOVE_ITEM, pageNavigator_dataProvider_removeItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.REPLACE_ITEM, pageNavigator_dataProvider_replaceItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.REMOVE_ALL, pageNavigator_dataProvider_removeAllHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.RESET, pageNavigator_dataProvider_resetHandler);
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
			this._dataProvider.addEventListener(FlatCollectionEvent.ADD_ITEM, pageNavigator_dataProvider_addItemHandler, false, 0, true);
			this._dataProvider.addEventListener(FlatCollectionEvent.REMOVE_ITEM, pageNavigator_dataProvider_removeItemHandler, false, 0, true);
			this._dataProvider.addEventListener(FlatCollectionEvent.REPLACE_ITEM, pageNavigator_dataProvider_replaceItemHandler, false, 0, true);
			this._dataProvider.addEventListener(FlatCollectionEvent.REMOVE_ALL, pageNavigator_dataProvider_removeAllHandler, false, 0, true);
			this._dataProvider.addEventListener(FlatCollectionEvent.RESET, pageNavigator_dataProvider_resetHandler, false, 0, true);
		}
		this.setInvalid(DATA);
		FeathersEvent.dispatch(this, "dataChange");
		return this._dataProvider;
	}

	private var _activeItemIndex:Int = -1;

	private var _pendingSelectedItem:Any = NO_PENDING_SELECTED_ITEM;
	private var _pendingSelectedIndex:Int = NO_PENDING_SELECTED_INDEX;

	private var _selectedIndex:Int = -1;

	/**
		@see `feathers.core.IIndexSelector.selectedIndex`
	**/
	@:inspectable
	public var selectedIndex(get, set):Int;

	private function get_selectedIndex():Int {
		if (this._pendingSelectedIndex != NO_PENDING_SELECTED_INDEX) {
			return this._pendingSelectedIndex;
		}
		return this._selectedIndex;
	}

	private function set_selectedIndex(value:Int):Int {
		if (this._pendingSelectedIndex != NO_PENDING_SELECTED_INDEX && this._pendingSelectedIndex == value) {
			return this._pendingSelectedIndex;
		}
		this._pendingSelectedIndex = value;
		this._pendingSelectedItem = NO_PENDING_SELECTED_ITEM;
		this.setInvalid(SELECTION);
		return this._pendingSelectedIndex;
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

	private var _selectedItem:PageItem = null;

	/**
		@see `feathers.core.IDataSelector.selectedItem`
	**/
	public var selectedItem(get, set):#if flash Dynamic #else PageItem #end;

	private function get_selectedItem():#if flash Dynamic #else PageItem #end {
		if (this._pendingSelectedItem != NO_PENDING_SELECTED_ITEM) {
			return cast(this._pendingSelectedItem, PageItem);
		}
		var currentSelectedIndex = this._pendingSelectedIndex != NO_PENDING_SELECTED_INDEX ? this._pendingSelectedIndex : this._selectedIndex;
		if (currentSelectedIndex == -1 || this._dataProvider == null) {
			return null;
		}
		if (this._selectedIndex >= this._dataProvider.length) {
			return null;
		}
		return this._dataProvider.get(this._selectedIndex);
	}

	private function set_selectedItem(value:#if flash Dynamic #else PageItem #end):#if flash Dynamic #else PageItem #end {
		if (this._pendingSelectedItem != NO_PENDING_SELECTED_ITEM && this._pendingSelectedItem == value) {
			return cast(this._pendingSelectedItem, PageItem);
		}
		this._pendingSelectedItem = value;
		this._pendingSelectedIndex = NO_PENDING_SELECTED_INDEX;
		this.setInvalid(SELECTION);
		return cast(this._pendingSelectedItem, PageItem);
	}

	/**
		The position of the navigator's page indicator.

		@since 1.0.0
	**/
	@:style
	public var pageIndicatorPosition:RelativePosition = BOTTOM;

	private var _swipeEnabled:Bool = true;

	/**
		If `true`, a swipe left or right with touch may be used to navigate to
		the previous or next page.

		@see `PageNavigator.simulateTouch`

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

	/**
		Determines if mouse events should be treated like touch events when
		detecting a swipe.

		@see `PageNavigator.swipeEnabled`

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
		The default transition to use for navigating to the previous page.

		@since 1.0.0
	**/
	@:style
	public var previousTransition:(DisplayObject, DisplayObject) -> IEffectContext = null;

	/**
		The default transition to use for navigating to the next page.

		@since 1.0.0
	**/
	@:style
	public var nextTransition:(DisplayObject, DisplayObject) -> IEffectContext = null;

	/**
		The space, measured in pixels, between the navigator's active view and
		its page indicator.

		@since 1.0.0
	**/
	@:style
	public var gap:Float = 0.0;

	private var _previousCustomPageIndicatorVariant:String = null;

	/**
		An optional custom variant to use for the page indicator sub-component,
		instead of `PageNavigator.CHILD_VARIANT_PAGE_INDICATOR`.

		The `customPageIndicatorVariant` will be not be used if the result of
		`pageIndicatorFactory` already has a variant set.

		@see `PageNavigator.CHILD_VARIANT_PAGE_INDICATOR`

		@since 1.0.0
	**/
	@:style
	public var customPageIndicatorVariant:String = null;

	private var _oldPageIndicatorFactory:DisplayObjectFactory<Dynamic, PageIndicator>;

	private var _pageIndicatorFactory:DisplayObjectFactory<Dynamic, PageIndicator>;

	/**
		Creates the page indicator, which must be of type
		`feathers.controls.PageIndicator`.

		In the following example, a custom page indicator factory is provided:

		```haxe
		navigator.pageIndicatorFactory = () ->
		{
			return new PageIndicator();
		};
		```

		@see `feathers.controls.PageIndicator`

		@since 1.0.0
	**/
	public var pageIndicatorFactory(get, set):AbstractDisplayObjectFactory<Dynamic, PageIndicator>;

	private function get_pageIndicatorFactory():AbstractDisplayObjectFactory<Dynamic, PageIndicator> {
		return this._pageIndicatorFactory;
	}

	private function set_pageIndicatorFactory(value:AbstractDisplayObjectFactory<Dynamic, PageIndicator>):AbstractDisplayObjectFactory<Dynamic, PageIndicator> {
		if (this._pageIndicatorFactory == value) {
			return this._pageIndicatorFactory;
		}
		this._pageIndicatorFactory = value;
		this.setInvalid(INVALIDATION_FLAG_PAGE_INDICATOR_FACTORY);
		return this._pageIndicatorFactory;
	}

	/**
		Shows or hides the page indicator. If the page indicator is hidden, the
		selection may only be changed programatically, or with a user swipe
		gesture, if `swipeEnabled` is `true`.

		@since 1.4.0
	**/
	@:style
	public var showPageIndicator:Bool = true;

	private var _ignoreSelectionChange = false;

	private var _dragTransitionContext:EventToPositionEffectContext;

	override public function dispose():Void {
		this._pendingItemID = null;
		this._pendingItemTransition = null;
		this._transitionActive = false;
		if (this._activeTransition != null) {
			this._activeTransition.removeEventListener(Event.COMPLETE, transition_completeHandler);
			this._activeTransition.removeEventListener(Event.CANCEL, transition_cancelHandler);
			this._activeTransition.stop();
		}
		this.destroyPageIndicator();
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
			this._previousEdgePuller.addEventListener(FeathersEvent.OPENING, pageNavigator_previousEdgePuller_openingHandler);
			this._previousEdgePuller.addEventListener(Event.CANCEL, pageNavigator_previousEdgePuller_cancelHandler);
			this._previousEdgePuller.addEventListener(Event.OPEN, pageNavigator_previousEdgePuller_openHandler);
		}
		if (this._nextEdgePuller == null) {
			this._nextEdgePuller = new EdgePuller(this, RIGHT);
			this._nextEdgePuller.addEventListener(FeathersEvent.OPENING, pageNavigator_nextEdgePuller_openingHandler);
			this._nextEdgePuller.addEventListener(Event.CANCEL, pageNavigator_nextEdgePuller_cancelHandler);
			this._nextEdgePuller.addEventListener(Event.OPEN, pageNavigator_nextEdgePuller_openHandler);
		}
	}

	private function initializePageNavigatorTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelPageNavigatorStyles.initialize();
		#end
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var selectionInvalid = this.isInvalid(SELECTION);
		var stylesInvalid = this.isInvalid(STYLES);
		if (this._previousCustomPageIndicatorVariant != this.customPageIndicatorVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_PAGE_INDICATOR_FACTORY);
		}
		var pageIndicatorInvalid = this.isInvalid(INVALIDATION_FLAG_PAGE_INDICATOR_FACTORY);

		if (pageIndicatorInvalid) {
			this.createPageIndicator();
		}

		if (pageIndicatorInvalid || stylesInvalid) {
			this.refreshPageIndicator();
		}

		if (dataInvalid) {
			this._previousEdgePuller.simulateTouch = this._simulateTouch;
			this._nextEdgePuller.simulateTouch = this._simulateTouch;
		}

		if (dataInvalid || selectionInvalid || pageIndicatorInvalid) {
			this.commitSelection();
			this.refreshSelection();
		}

		super.update();

		this._previousCustomPageIndicatorVariant = this.customPageIndicatorVariant;
	}

	override private function measure():Bool {
		if (!this.showPageIndicator) {
			return super.measure();
		}
		if (this.explicitWidth != null) {
			this.pageIndicator.width = this.explicitWidth;
		} else if (this._autoSizeMode == STAGE && this.stage != null) {
			this.pageIndicator.width = this.stage.stageWidth;
		} else {
			this.pageIndicator.resetWidth();
		}
		this.pageIndicator.validateNow();
		this.chromeMeasuredWidth = Math.max(this.chromeMeasuredWidth, this.pageIndicator.width);
		switch (this.pageIndicatorPosition) {
			case TOP:
				this.topContentOffset += this.pageIndicator.height + this.gap;
			case BOTTOM:
				this.bottomContentOffset += this.pageIndicator.height + this.gap;
			default:
				throw new ArgumentError('Invalid pageIndicatorPosition ${this.pageIndicatorPosition}');
		}

		return super.measure();
	}

	private function commitSelection():Void {
		var pendingSelectedItem = this._pendingSelectedItem;
		var pendingSelectedIndex = this._pendingSelectedIndex;
		this._pendingSelectedItem = NO_PENDING_SELECTED_ITEM;
		this._pendingSelectedIndex = NO_PENDING_SELECTED_INDEX;
		if (this._dataProvider == null) {
			this._selectedIndex = -1;
			this._selectedItem = null;
			return;
		}
		if (pendingSelectedItem != NO_PENDING_SELECTED_ITEM) {
			this._selectedIndex = this._dataProvider.indexOf(pendingSelectedItem);
			if (this._selectedIndex != -1) {
				this._selectedItem = pendingSelectedItem;
			} else {
				this._selectedItem = null;
			}
		}
		if (pendingSelectedIndex != NO_PENDING_SELECTED_INDEX) {
			if (pendingSelectedIndex >= 0 && pendingSelectedIndex < this._dataProvider.length) {
				this._selectedIndex = pendingSelectedIndex;
				this._selectedItem = this._dataProvider.get(pendingSelectedIndex);
			} else {
				this._selectedIndex = -1;
				this._selectedItem = null;
			}
		}
	}

	private function createPageIndicator():Void {
		this.destroyPageIndicator();
		var factory = this._pageIndicatorFactory != null ? this._pageIndicatorFactory : defaultPageIndicatorFactory;
		this._oldPageIndicatorFactory = factory;
		this.pageIndicator = factory.create();
		if (this.pageIndicator.variant == null) {
			this.pageIndicator.variant = this.customPageIndicatorVariant != null ? this.customPageIndicatorVariant : PageNavigator.CHILD_VARIANT_PAGE_INDICATOR;
		}
		this.pageIndicator.addEventListener(Event.CHANGE, pageNavigator_pageIndicator_changeHandler);
		this.addChild(this.pageIndicator);
	}

	private function destroyPageIndicator():Void {
		if (this.pageIndicator == null) {
			return;
		}
		this.pageIndicator.removeEventListener(Event.CHANGE, pageNavigator_pageIndicator_changeHandler);
		this.removeChild(this.pageIndicator);
		if (this._oldPageIndicatorFactory.destroy != null) {
			this._oldPageIndicatorFactory.destroy(this.pageIndicator);
		}
		this._oldPageIndicatorFactory = null;
		this.pageIndicator = null;
	}

	private function refreshPageIndicator():Void {
		this.pageIndicator.visible = this.showPageIndicator;
	}

	override private function layoutContent():Void {
		this.pageIndicator.x = 0.0;
		this.pageIndicator.width = this.actualWidth;
		this.pageIndicator.validateNow();
		switch (this.pageIndicatorPosition) {
			case TOP:
				this.pageIndicator.y = 0.0;
			case BOTTOM:
				this.pageIndicator.y = this.actualHeight - this.pageIndicator.height;
			default:
				throw new ArgumentError('Invalid pageIndicatorPosition ${this.pageIndicatorPosition}');
		}
		super.layoutContent();
	}

	override private function getView(id:String):DisplayObject {
		var item = cast(this._addedItems.get(id), PageItem);
		return item.getView(this);
	}

	override private function disposeView(id:String, view:DisplayObject):Void {
		var item = cast(this._addedItems.get(id), PageItem);
		item.returnView(view);
	}

	private function refreshSelection():Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		this.pageIndicator.maxSelectedIndex = this.maxSelectedIndex;
		this.pageIndicator.selectedIndex = this._selectedIndex;
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

	private function pageNavigator_pageIndicator_changeHandler(event:Event):Void {
		if (this._ignoreSelectionChange) {
			return;
		}
		// use the setter
		this.selectedIndex = this.pageIndicator.selectedIndex;
	}

	private function pageNavigator_dataProvider_addItemHandler(event:FlatCollectionEvent):Void {
		var item = cast(event.addedItem, PageItem);
		this.addItemInternal(item.internalID, item);
		this.setInvalid(DATA);

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

	private function pageNavigator_dataProvider_removeItemHandler(event:FlatCollectionEvent):Void {
		var item = cast(event.removedItem, PageItem);
		this.removeItemInternal(item.internalID);
		this.setInvalid(DATA);

		if (this._dataProvider.length == 0) {
			// use the setter
			this.selectedIndex = -1;
		} else if (this._selectedIndex >= event.index) {
			// use the setter
			this.selectedIndex--;
		}
	}

	private function pageNavigator_dataProvider_replaceItemHandler(event:FlatCollectionEvent):Void {
		var addedItem = cast(event.addedItem, PageItem);
		var removedItem = cast(event.removedItem, PageItem);
		this.removeItemInternal(removedItem.internalID);
		this.addItemInternal(addedItem.internalID, addedItem);
		this.setInvalid(DATA);

		if (this._selectedIndex == event.index) {
			this.selectedItem = this._dataProvider.get(this._selectedIndex);
		}
	}

	private function pageNavigator_dataProvider_removeAllHandler(event:FlatCollectionEvent):Void {
		// use the setter
		this.selectedIndex = -1;
		for (id in this._addedItems.keys()) {
			var item = this._addedItems.get(id);
			this.removeItemInternal(item.internalID);
		}
	}

	private function pageNavigator_dataProvider_resetHandler(event:FlatCollectionEvent):Void {
		// use the setter
		this.selectedIndex = -1;
		for (id in this._addedItems.keys()) {
			var item = this._addedItems.get(id);
			this.removeItemInternal(item.internalID);
		}
	}

	private function pageNavigator_previousEdgePuller_openingHandler(event:FeathersEvent):Void {
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

	private function pageNavigator_previousEdgePuller_cancelHandler(event:Event):Void {
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

	private function pageNavigator_previousEdgePuller_openHandler(event:Event):Void {
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

	private function pageNavigator_nextEdgePuller_openingHandler(event:FeathersEvent):Void {
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

	private function pageNavigator_nextEdgePuller_cancelHandler(event:Event):Void {
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

	private function pageNavigator_nextEdgePuller_openHandler(event:Event):Void {
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
