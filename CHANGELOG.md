# Feather UI for OpenFL and Haxe Change Log

## 1.0.0-beta.3 (2021-04-12)

- Alert: New component to display a pop-up dialog with a message, a title, and an optional icon.
- AnchorLayoutData: New `fillHorizontal()` and `fillVertical()` static methods.
- Application: Added `topLevelApplication` static property to easily access the root `Application` globally.
- ArrayHierarchicalCollection: New collection type for hierarchical data containers, like `GroupListView` and `TreeView`.
- AssetLoader: Added missing `ProgressEvent.PROGRESS` dispatch when asset is loaded asynchronously.
- BaseScrollContainer: New `getViewPortVisibleBounds()` utility method.
- BaseScrollContainer: New `scrollPixelSnapping` property to allow snapping the scroll position to the nearest pixel.
- BaseScrollContainer: New `scrollerFactory` property to customize the `Scroller` behavior.
- BaseScrollContainer: New `showScrollBarMinimumDuration` style to ensure that scroll bars don't flicker when revealed by the mouse wheel.
- ButtonBar: New component to display a set of buttons based on an `IFlatCollection` data provider.
- Callout: Now automatically closes itself when its origin is removed from the stage.
- ComboBox: New `customButtonVariant`, `customListViewVariant` and `customTextInputVariant` styles to allow sub-component customization in themes.
- ComboBox: New `openListViewOnFocus` property allows the pop-up list view to automatically open when the `ComboBox` receives focus.
- ComboBox: Exposes `ListViewEvent.ITEM_TRIGGER` from the pop-up list view.
- Drawer: New `clickOverlayToClose`, `swipeOpenEnabled` and `swipeCloseEnabled` properties.
- DropDownPopUpAdapter: Forces the width of the pop-up to be at least as wide as the origin.
- Form: New component for displaying a group of fields to be submitted.
- FormItem: New component designed for use with `Form` to display a label next to each item.
- General: Added new `setPadding()` convenience functions to allow setting `paddingTop`, `paddingRight`, `paddingBottom`, and `paddingLeft` to the same value in a single call.
- GridView/GroupListView/ListView/TreeView: Methods like `scrollToIndex()` and `scrollToLocation()` now accept an optional animation duration.
- GridView: Added support for horizontal scrolling if the total width of the columns is larger than the width of the `GridView`.
- GroupListView: New `customHeaderRendererVariant` property to allow sub-component customization in themes.
- GroupListView/TreeView: New `locationToItemRenderer()` utilty method, similar to `itemToItemRenderer()`.
- Header: New component that displays a title in the center, plus optional views on the left and right sides.
- HScrollBar/VScrollBar: During touch interaction, if dragged out of range, the thumb will shrink like native scroll bars.
- HScrollBar/VScrollBar: New `hideThumbWhenDisabled` style that affects the thumb visiblility when `enabled` is `false`.
- IStageFocusDelegate: New interface that allows a component to specify one of its children to receive focus directly, when focus is passed by the `FocusManager`.
- ITextControl: New `baseline` property, which may be used for alignment of multiple `ITextControl` instances together.
- LeftAndRightBorderSkin: New skin class that is similar to `RectangleSkin`, but renders its border on the left and right sides only.
- ListView: New `indexToItemRenderer()` utilty method, similar to `itemToItemRenderer()`.
- OverlineAndUnderlineSkin: Deprecated. Replaced by `TopAndBottomBorderSkin`.
- PageNavigator: New `pageIndicatorFactory` and `customPageIndicatorVariant`, and `gap` properties.
- PopUpListView: New `customButtonVariant` and `customListViewVariant` styles to allow sub-component customization in themes.
- Radio: Selection may now be changed with keyboard arrow keys when a radio in the group has focus.
- ScrollContainer: New `autoSizeMode` property, similar to the same property on `LayoutGroup`.
- TabBar: Dispatches `TabBarEvent.ITEM_TRIGGER` when a tab is triggered.
- TabNavigator: New `tabBarFactory` and `customTabBarVariant` styles to to allow sub-component customization.
- TabNavigator: New `gap` style to add spacing between the active view and the `TabBar` sub-component.
- TabNavigator: Exposes `TabBarEvent.ITEM_TRIGGER` from the tab bar.
- TextArea: If the `prompt` is too long to fit horizontally, it will now wrap to multiple lines.
- TextArea/TextInput: New `maxChars` property to limit the number of allowed characters entered by the user.
- TopAndBottomBorderSkin: New skin class that is similar to `RectangleSkin`, but renders its border on the top and bottom sides only.
- TreeViewItemRenderer: New `branchIcon`, `branchOpenIcon`, `branchClosedIcon`, and `leafIcon` styles.

## 1.0.0-beta.2 (2020-12-08)

- Restored support for OpenFL version 8.9.
- Application: Enables the new `ToolTipManager` by default. May use `disable_tool_tip_manager` haxedef to disable.
- Application: Sets stage `scaleMode` and `align` for "flash" target so that using the compiled _.swc_ in ActionScript behaves the same as compiling with Haxe.
- AssetLoader: Added `@:styleContext` metadata.
- FeathersControl: Added `toolTip` property.
- FillStyle: Gradient matrix may now be specified as a `Float` for radians, a `Matrix` instance, or a function that accepts the same arguments as `createGradientBox()` and returns a `Matrix`.
- FillStyle: Added `None` to enum.
- GridView: May optionally define a different `cellRendererRecycler` for each column.
- GridView: Added `layout` style.
- GridView: Added `extendedScrollBarY` style to allow the vertical scroll bar to extend up into the headers.
- HorizontalListLayout: Added `requestedMinColumnCount` and `requestedMaxColumnCount` properties.
- HorizontalListLayout: The `requestedColumnCount` property now defaults to `null`, instead of `5.0`.
- LineStyle: Gradient matrix may now be specified as a `Float` for radians, a `Matrix` instance, or a function that accepts the same arguments as `createGradientBox()` and returns a `Matrix`.
- LineStyle: Added `Bitmap()` to enum.
- LineStyle: Added `None` to enum.
- ListView: May optionally define multiple item renderer recyclers with `setItemRendererRecycler()` and `itemRendererRecyclerIDFunction`.
- ToolTipManager: listens for stage mouse events and displays tool tips for UI components with a `toolTip` property.
- TreeView: May optionally define multiple item renderer recyclers with `setItemRendererRecycler()` and `itemRendererRecyclerIDFunction`.
- VerticalListFixedRowLayout: Added `requestedMinRowCount` and `requestedMaxRowCount` properties.
- VerticalListFixedRowLayout: The `requestedRowCount` property now defaults to `null`, instead of `5.0`.
- VerticalListLayout: Added `requestedMinRowCount` and `requestedMaxRowCount` properties.
- VerticalListLayout: The `requestedRowCount` property now defaults to `null`, instead of `5.0`.

## 1.0.0-beta.1 (2020-11-12)

- animated-tween-skin: new sample project that demonstrates how to create a skin with animations.
- Button: added `textOffsetX`, `textOffsetY`, `iconOffsetX`, and `iconOffsetY` properties.
- BaseScrollContainer: allow multiple nested containers, where the deepest container gets precedence for touch gestures.
- Callout: added support for "arrow" skins.
- CellRenderer: removed because it is no longer needed. Use `ItemRenderer` for `GridView` cell renderers instead.
- custom-programmatic-skin: new sample project that demonstrates how to create a custom skin with programmatically drawn graphics.
- custom-programmatic-skin-with-states: new sample project that demonstrates how to create a custom skin that handles state changes from a UI component, like a button.
- Drawer: new component that supports opening a drawer modally above other content.
- EdgePuller: new utility used for "pullable" component edges, used by `Drawer` and navigators.
- FeathersControl: dispatches `FeathersEvent.ENABLED` and `DISABLED` when the `enabled` property changes.
- FocusManager: optionally supports multiple root containers.
- FocusManager: disables focus management under the overlay when the `PopUpManager` has a modal popup.
- FocusManager: added `findNextFocus()` method.
- FocusManager: can pass focus to web browser when reaching beginning or end of all focusable objects.
- LayoutGroupItemRenderer: new component to use as base type for custom item renderers.
- ListView: added `allowMultipleSelection`, `selectedIndices`, and `selectedItems` properties.
- General: Added `@:event` metadata to all UI components, so that a list of events is available to macros.
- GridView: added `resizableColumns` and `columnResizeSkin` properties.
- GridView: added `GridViewEvent.CELL_TRIGGER` and `HEADER_TRIGGER` events.
- GridView: added `allowMultipleSelection`, `selectedIndices`, and `selectedItems` properties.
- GroupListView: added `GroupListView.ITEM_TRIGGER` event.
- HDividedBox and VDividedBox: new containers that add resizing dividers between children.
- HScrollBar/VScrollBar: added `snapInterval` and changed `step` to apply to increment/decrement buttons only.
- HSlider/VSlider: added `snapInterval` and changed `step` to apply to keyboard events only.
- HSlider/VSlider: `step` defaults to `0.01` because it is needed for keyboard events.
- MultiSkin: a skin for UI components that switches between different display objects when the UI component's state changes. Useful for ensuring that `MouseEvent.CLICK` and `TouchEvent.TOUCH_TAP` are correctly dispatched when the target below the pointer change.
- PageNavigator: added a touch swipe gesture to go back and forward.
- PageNavigator: added `previousTransition` and `nextTransition` properties.
- PillSkin: a skin for UI components shaped like a "pill".
- ProgrammaticSkin: new base class for custom programmatic skins.
- RectangleSkin: fixed issue where `cornerRadius` was incorrectly drawn at half size. Developers may need to update code to use smaller values than before.
- ResponsiveGridLayout: new layout
- StackNavigator: added `popSwipeEnabled` and `popSwipeActiveEdgeSize` properties to enable a touch swipe to go back gesture.
- TabNavigator: added `swipeEnabled` property to enable a touch swipe gesture to go back and forward.
- TabNavigator: added `previousTransition` and `nextTransition` properties.
- TabSkin: a skin for UI components shaped like a rectangle with two rounded corners on one side.
- TextInput: added `leftView` and `rightView` properties to display icons or other UI components inside the input.
- TextInput: added `VARIANT_SEARCH` for use in themes.
- TextInput: added `autoSizeWidth` property to resize based on the entered text.
- TreeView: instead of dispatching `Event.OPEN` and `CLOSE`, dispatches `TreeViewEvent.BRANCH_OPEN` and `BRANCH_CLOSE`.
- TriangleSkin: a skin for UI components shaped like a triangle.

## 1.0.0-alpha.3 (2020-08-20)

- GroupListView: new component
- ArrayCollection: added some functional methods, including `find()`, `findIndex()`, `some()`, `forEach()`, and `map()`.
- BaseScrollContainer: added `showScrollBars` property, which can be set to `false` to hide scroll bars completely.
- CLI: new projects compile to OpenFL's default _bin_ folder, instead of the custom _build_ folder.
- CLI: fixed issue where certain folder names could cause the main class name to contain invalid characters.
- Default Theme: some refinements to colors and sizing, especially on desktop.
- GridView: added `CHILD_VARIANT_HEADER` to customize styles of headers.
- IHTMLTextControl: added a new interface for components with `htmlText` property, similar to the existing `ITextControl`.
- IProgrammaticSkin: added a new interface for programmatic skins (plus a `ProgrammaticSkin` base class).
- IStyleObject: added `themeEnabled` property, which can be set to `false` to make a component and all of its children ignore the current theme.
- InvalidationFlag: this type is now an enum, and custom flags may be defined like `InvalidationFlag.CUSTOM("my-custom-flag")`.
- ItemRenderer: added optional `alternateBackgroundSkin` property to switch between backgrounds in data components like `ListView`.
- ValidatingSprite: added advanced `runWithoutInvalidation()` function for changing properties without an extra validation cycle.
- ListView: `ListViewItemState` includes new `owner` and `enabled` properties (similar for `TreeView`, `GridView` and other data rendering components).
- ListView: now handles `UPDATE_AT` and `UPDATE_ALL` events from the data provider collection.
- ListView: added `itemToItemRenderer()` and `itemRendererToItem()` methods (similar for `TreeView`, `GridView` and other data rendering components).
- RouterNavigator: added new `location` property to access the current location on all targets.
- Scroller: added new `mouseWheelYScrollX` property to optionally make vertical mouse wheel scroll horizontally.
- TabSkin: a new skin class with a tab-like shape (rounded corners on one side only), similar to the rectangle/circle/ellipse skins from previous versions.
- TextArea, TextInput: added new selection APIs, including `selectionAnchorIndex`, `selectionActiveIndex`, `selectRange()`, and `selectAll()`.
- TreeView: added `toggleBranch()` and `isBranchOpen()` methods.
- And many more bug fixes…

## 1.0.0-alpha.2 (2020-06-22)

- CLI: `create-project` command
- GridView: new component
- PageIndicator: new component
- PageNavigator: new component
- TabNavigator: new component
- TextArea: new component
- TreeView: new component
- AnchorLayoutData: anchors may optionally be relative to other children in the container
- HorizontalListLayout: new layout optimized for lists
- VerticalListLayout: new layout optimized for lists
- HorizontalDistributedLayout: new layout
- VerticalDistributedLayout: new layout
- ItemRenderer: added `secondaryText` property
- Label: added `htmlText` property
- TextInput: added `prompt` property
- Scale9Bitmap: new custom display object for rendering `BitmapData` with `scale9Grid`
- Basic keyboard focus management
- Improved support for Neko and HashLink
- login-form: new sample
- router-navigator-pass-data-between-views: new sample

## 1.0.0-alpha.1 (2020-02-03)

- Initial preview build