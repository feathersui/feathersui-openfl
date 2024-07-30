# Feathers UI for OpenFL and Haxe Change Log

## 1.3.0 (2024-??-??)

- General: Added a `dispose()` method to `FeathersControl` to allow UI components to be optionally disposed when they are no longer needed. Clears data providers, removes sub-components, removes selection, and some event listeners. Developers are not required to call `dispose()`, but it can help with garbage collection and general cleanup.
- Collapsible: New component with a header and content, where toggling the header shows and hides the content.
- DragDropManager: Added support for drag-and-drop. Used by `ListView` and `GridView`. Includes new `drag-and-drop` and `list-view-drag-and-drop` sample projects.
- Default Theme: Improved sizing of all UI control skins by detecting if currently running on mobile or desktop.
- New Sample: `custom-layout-group-item-renderer` demonstrates how to create a subclass of `LayoutGroupItemRenderer`.
- New Sample: `anchor-layout-three-column-header-and-footer` to demonstrate a common app layout with a header on top, three vertical columns in the middle, and a footer on the bottom.
- AnchorLayout: Improve error messages in when `relativeTo` is a circular reference or has a different parent.
- AnchorLayout: An `Anchor` constructor can now be called with zero arguments to allow it to be used declaratively.
- AssetLoader: Added `sourceScale` property to specify which scale factor the `source` was designed for, allowing it to be scaled for the current scale factor.
- BaseScrollContainer: The default step value is now `1.0`.
- BaseScrollContainer: Ignore keyboard navigation events if the current stage focus is a `TextField` of type `INPUT`.
- BaseScrollContainer: Added `scrollBarsCornerSkin` style to optionally display a skin in the corner between the horizontal and vertical scroll bars, when both are displayed and fixed.
- BaseScrollContainer: Fixed missing `Event.SCROLL` when automatically snapping to minimum or maximum.
- Callout: Fixed issues where `Event.RESIZE` listener on content was added to early.
- Callout: Fixed null exception when validating without an `origin`.
- ComboBox: Added `text` getter to get the text of the currently selected item.
- ComboBox: Fixed setting `selectedIndex` or `selectedItem` in `Event.CLOSE` listener getting ignored.
- ComboBox: Fixed `selectedItem` setter when the list view is opened.
- ComboBox: Fixed missing `ListViewEvent.ITEM_TRIGGER` dispatch on `Keyboard.ENTER`.
- Data Containers: Fixed previous animation not getting cancelled when new animation duration is `0.0`.
- Data Containers: Added support for raw `String` values in data providers for all targets.
- Data Containers: Added new `itemToItemState()` method to get the state object passed to the item renderer recyclers in other contexts.
- Data Containers: Scrolls an item renderer into view when it is triggered.
- Data Containers: When using keyboard to navigate, and selection does not change, scroll to display that item, if not completely in view port.
- DatePicker, PopUpDatePicker: Added keyboard navigation with arrow keys, page up/down, home, and end.
- DefaultFocusManager: Fixed focus indicator being rendered on mouse focus change because a flag wasn't cleared.
- Default Theme: Explicitly sets `bold`, `italic`, and `underline` to `false` instead of `null` to ensure that the previous `TextFormat` does not affect the new value.
- Default Theme: Instead of setting background skins on `GridView` and `TreeGridView` cells, set them on the row renderers that contain the cells.
- DisplayObjectFactory, DisplayObjectRecycler: Automatically calls `dispose()` on destroying a view created with `withClass()`, unless a custom destroy function is provided.
- DisplayObjectRecycler: Added `withFactory()` method to convert a `DisplayObjectFactory` to a `DisplayObjectRecycler`.
- Drawer: Added `animateOpenProperty` property, to control whether setting `opened` should trigger with animation or not. See also new `openDrawer()` and `closeDrawer()` methods.
- FeathersControl: Added `disabledAlpha` property to automatically change the `alpha` property when `enabled` is set to `false`.
- FeathersControl: Added `alwaysShowFocus` property to show focus indicator on both mouse focus change and key focus change.
- FormItem: Fixed failure to listen for `Event.RESIZE` from content.
- FormItem: Fixed measurement of `requiredSkin` when it implements `IMeasureObject`.
- FormItem: Fixed meaurement of `content` when setting the content's `width` may change its `height`, such as wrapping text.
- FormItem: Ensure that `Event.RESIZE` is dispatched when showing or hiding `requiredSkin` or changing text.
- FormLayout: Fixed incorrect text column width measurement because the old value was not cleared.
- General: Fixed issues with macros when using Haxe 5 nightly builds.
- General: Fixed issue with `__restrict` variable name when compiling for HashLink/C.
- General: Added `@:inspectable` metadata to certain properties, to allow them to be customized by GUI developer tooling.
- General: Added a number of extra `null` checks for `Meaurements` values.
- General: Use unsafe casts when type is known by checking with `is` first, for improved performance.
- General: Use `-dce no` when building _.swc_ file for Flash, so that Haxe standard library is not modified.
- General: Removed workaround for HashLink's broken `array.resize()` when targeting Haxe 4.3 and newer because the issue was fixed.
- GridView, TreeGridView: Fixed a number of issues with `customColumnWidths`.
- GridView, TreeGridView: Fixed `TriggerEvent.TRIGGER` not getting dispatched by row renderers.
- GridView, TreeGridView: Fixed row getting incorrectly selected when clicking focusable child.
- GridView, TreeGridView: Added `headerCornerSkin` style to optionally display a skin in the corner between the headers and scroll bar.
- GridView, TreeGridView: Fixed `headerRendererFactory` not allowing an explicit height to be set on headers.
- GridView, TreeGridView: Added `rowRendererFactory` to allow the row renderers to be customized.
- GridView, TreeGridView: Fixed `RangeError` when inserting an extra column before other columns.
- GridView, TreeGridView: Fixed positon of new cell renderer when a column is inserted after validation.
- GridViewHeaderState: Added `sortOrder` property.
- Header: Fixed `LAYOUT` invalidation flag getting ignored.
- Header: Added missing `setPadding()` convenience method.
- HDividedBox, VDividedBox: Improved detection of which item should be considered fluid when resized.
- HDividedBox, VDividedBox: Added missing handling of `includeInLayout` property.
- HDividedBox, VDividedBox: Fixed `removeRawChildren()`, which was calling itself instead of `removeChildren()`.
- HDividedBox, VDividedBox: Fixed programmatic change of child `width` or `height` not being reflected in layout.
- HProgressBar, VProgressBar: Added `indeterminate` property and `indeterminateFillSkin` style to allow the progress bar to display an indeterminate animation. Also added `indeterminateDuration` style.
- HScrollBar, VScrollBar: added optional decrement and increment button factories and `showIncrementAndDecrementButtons` style.
- IDragDropLayout: New interface for implementing drag-and-drop for a custom layout.
- ItemRenderer, LayoutGroupItemRenderer: Added `showHoverAndDownStates` property to allow those states to be disabled for item renderers that are non-interactive.
- ItemRenderer, LayoutGroupItemRenderer: Fixed custom hit test for focusable objects.
- Label: Fixed being focusable when text is not selectable.
- LayoutGroup, ScrollContainer: Added new `collectChildren()` method to return an array of all children in the layout.
- LayoutGroup, ScrollContainer: Fixed detection of automatic child removal when added to another container without manually removing from original parent.
- LayoutGroup, ScrollContainer: Added new `readjustLayout()` method to allow a manual layout update when no events are dispatched.
- Layouts: Fixed some missing checks for `includeInLayout == false` on items.
- ListView, GridView: Added `dragEnabled`, `dropEnabled`, and `removeOnDragDropComplete` properties to enable drag-and-drop behaviors.
- LongPress: Added `maxMoveDistance` property to allow the gesture to be cancelled if the pointer moves too far between start and end.
- Navigators: Added `withFactory()` method to create views with a `DisplayObjectFactory`.
- PageNavigator, TabNavigator: Fixed measurement of content when `autoSizeMode == CONTENT`.
- PageNavigator, TabNavigator: Optimize setting data provider to `null` by calling `removeAllItems()`.
- Panel: Fixed `Event.RESIZE` listener for footer incorrectly being removed from header instead, which could lead to null exception.
- Panel: Fixed measurement when changing header `width` causes its `height` to change, such as with wrapping text.
- PopUpListView: Fixed missing stage `null` checks.
- PopUpManager: added `bringToFront()` method to change a pop-up's depth to the top.
- Skinning: Added `ButtonMultiSkin`, `ToggleButtonMultiSkin`, and `TextInputMultiSkin` to be used in declarative environments, such as MXHX.
- StyleMacro: Hide deprecation warnings for generated methods that users have no control over.
- TextArea, TextInput: Added optional `errorFocusRectSkin` style that takes precedence over `focusRectSkin` for `TextInputState.ERROR`.
- TextArea: Fixed wrong default variant for the error callout.
- TextArea, TextInput: Added `errorStatePriority` and `focusedStatePriority` properties to customize state precedence when focused and `errorString` is non-null.
- TextArea, TextInput: Fixed wrong value returned by `errorString` setter.
- TextArea, TextInput: Fixed prompt not rendering differently when disabled by using `disabledTextFormat`.
- TextArea, TextInput: Added `errorCalloutFactory` property to allow the error callout to be customized.
- TextArea, TextInput: Fixed missing styles on prompt text if prompt was initially `null` and added after the first validation.
- ToggleButton: Fixed `!=` comparison that should have been `==` that caused `htmlText` to fail to update.
- ToggleSwitch: Added `onText` and `offText` properties to optionally display text on each side.
- ValidatingSprite: Fixed "all" invalidation flag never getting cleared, causing too many validations.
- ValidatingSprite: Optimize invalidation flag checks.
- VerticalListFixedRowLayout: Fixed only one item getting displayed in view port, even though view port was sized to display more items, because of a missing dispatch of `Event.CHANGE`.

## 1.2.0 (2023-06-01)

- General: Haxe 4.3 compatibility. When upgrading to Haxe 4.3, you should also upgrade to OpenFL 9.2.2 and Lime 8.0.2.
- General: Improved performance by fixing a number of unnecessary `setInvalid()` calls that threw exceptions when `feathersui_strict_set_invalid` was defined.
- AnchorLayout: Fix measurement of items where setting width or height causes the other dimension to resize too.
- BaseScrollContainer: Improved performance by refactoring the code that determines if scroll bars are necessary.
- Data Containers: Added new `itemToEnabled` function, which may be used to customized the `enabled` property of item renderers.
- Data Containers: Improved performance by avoiding calls to `DisplayObjectRecycler.update` and `DisplayObjectRecycler.reset` when item state has not changed. To restore the original behavior temporarily, set the new `forceItemStateUpdate` property to `true`.
- Data Containers: Improved performance by fixing an issue where item renderers were sometimes destroyed and recreated on first validation.
- Data Containers: Improved performance of `updateAt()` and `updateAll()` collection event handling.
- Data Containers: Fixed issue where view port scroll positions weren't always updated.
- Data Containers: Fixed issue where additional recyclers added with `setItemRendererRecycler()` didn't always receive the default `DisplayObjectRecycler.update` and `DisplayObjectRecycler.reset` methods.
- Drawer, PageNavigator, TabNavigator: Fixed `simulateTouch` not working properly after first touch simulated by a mouse event.
- HorizontalListLayout, VerticalListLayout: Improved performance by allowing up to 5 "cache misses" when calculating the estimated size of items that are not visible, which helps to avoid destroying and recreating items unnecessarily in some situations.
- HorizontalListLayout, VerticalListLayout: Dispatch `ScrollEvent.SCROLL` when a layout shift is needed after replacing a virtual item with a real item.
- HScrollBar, VScrollBar: Fixed drag behavior of track when padding is used.
- LayoutGroup: Now detects if layouts dispatch `Event.CHANGE` during their `layout()` method, where previously, it listened only between validations.
- LayoutGroup: Fixed exception where calling `addChild()` with an existing child at index 0 could result in an exception.
- NumericStepper: Added new `enableButtonsAtRangeLimits` property to automatically disable decrement button at minimum value and increment button at maximum value.
- NumericStepper: Fixed issue where decrement and increment buttons might not be ignored when disabled.
- PageIndicator: Fixed up and down arrow keys changing value in wrong direction.
- RouterNavigator: `Location` object on non-html5 targets now has a `toString()` method to match the behavior of html5.
- ScrollEvent: Added new `x` and `y` properties.
- Scroller: Added new `applyLayoutShift()` method (advanced) that may be used with containers that support virtual layouts to adjust the layout after a virtual item's size is calculated to adjust from the previous estimated size.
- StackNavigator: Added new `popMultipleItems()` method to allow popping to any arbitrary position in the history, instead of only one item or to the root.
- ValidatingSprite: Added new `runWithInvalidationFlagsOnly()` method to run some code where `setInvalid()` calls will be redirected to `setInvalidationFlag()` instead, to avoid multiple validations.
- Defines: Added new `feathersui_strict_set_invalid` define that will throw an exception if `setInvalid()` is called during validation. Useful when developing custom components or item renderers to find performance issues. See also: `runWithInvalidationFlagsOnly()` or `runWithoutInvalidation()`.

## 1.1.0 (2023-03-16)

- ActivityIndicator: New component to display indeterminate progress with animation.
- AssetLoader: Fix calculation of `minWidth` and `minHeight` during measurement.
- BaseScrollContainer: view port mask extends under scroll bars, if scroll bars are fixed.
- Collections: Fixed incorrect results from `indexOf()` and `locationOf()` during filter and sort refresh.
- ComboBox: Fixed issue where `ListView` closes without selection when clicked, if `focusManager` is null.
- Data Containers: When using arrow keys to navigate, scroll position may be updated, even if selection is not updated.
- DefaultFocusManager: Respects `isDefaultPrevented()` on `mouseFocusChange` event.
- DonutSkin: New skin class that is similar to `CircleSkin`, but with an inner radius that is not filled.
- DropDownPopUpAdapter: Added `closeOnPointerActiveOutside` property to customize behavior.
- GradientBoxTransform: New enum that may be used to define gradient line/fill styles to skins. Previously, line/fill styles accepted a `Float` rotation value or a `Matrix` only. Those are still supported, but this enum makes customization easier.
- GridView: Fixed incorrect height measurement of cells if the content might change after the first validation.
- GridView, TreeGridView: Fixed issue where automatically populated columns were not updated when passing new value to `dataProvider` property.
- GroupListView, TreeView, TreeGridView: Fixed missing selection refresh after filter or sort change.
- HorizontalLayoutData: Added `marginLeft` and `marginRight` properties to affect gap between individual items.
- HorizontalLineSkin, VerticalLineSkin: Added padding properties to optionally add extra empty space to the sides of the line.
- HorizontalLineSkin, VerticalLineSkin: Fixed issue where alignment properties were incorrectly defined as fields instead of getters/setters. They should have invalidated the skin on change.
- HorizontalListLayout, VerticalListLayout: Fixed minimum column/row count not affecting the calculated minimum width or height of all content.
- HProgressBar, VProgressBar: Added `fillMode` property, which can be `RESIZE` (default, same as old behavior), but also `SCROLL_RECT` or `MASK`.
- Label: Added `VARIANT_DANGER` to highlight errors and other important messages.
- Layouts: Fixed calculation of view port bounds when combining requested column/row count and padding/gap.
- NumericStepper: Does not override increment and decrement button text if text is already set in button factory.
- PageNavigator, TabNavigator: Fixed issue where setting `selectedIndex` or `selectedItem` before the first validation was ignored.
- PopUpListView: Fixed null exception on mouse focus change, if `relatedObject` is missing.
- Radio: Arrow keys are ignored for selection changes if `keyLocation` is `D_PAD`.
- Samples: Added new _dark-mode_ sample to demonstrate switching between light and dark mode with the default theme.
- Samples: Added new _numeric-stepper-button-layouts_ sample to demonstrate the different ways that the buttons can be positioned relative to the text input.
- ScrollContainer: Added `manageChildVisibility` property to allow container to change `visible` property on all children during scrolling to optimize rendering.
- Scroller: Calls `preventDefault()` when handling mouse wheel event to prevent page from scrolling on html5 target.
- TextArea, TextInput: Added `showPromptWhenEmptyAndFocused` (default: true) to allow hiding the prompt on focus.
- TextCallout: Added `wordWrap` property.
- TextInput: Set `TextField.type` on creation to avoid focus issue in OpenFL 9.2.0 and older.
- VerticalLayoutData: Added `marginTop` and `marginBottom` properties to affect gap between individual items.
- Fixed issue in some components where setting a custom child variant would cause children to be recreated on every validation, which wasn't necessary.
- If `feathersui_disable_default_theme` is defined, default styles will not be initialized at all by components.
- If `feathersui_innogames_openfl` is defined, some things may behave differently for better compatibility with the [innogames/openfl](https://github.com/innogames/openfl) fork.
- Added `@:bindable` meta to certain properties that dispatch events. Not used for anything now, but available for future enhancements.
- Added _include.xml_ to automatically add **openfl** and **actuate** as dependencies (previously, they needed to be added manually).

## 1.0.0 (2022-09-01)

- BaseScrollContainer: Fixed touch claim not being cleared when `simulateTouch == true`
- ComboBox: Fixed pop-up list view closing immediately on button click if `openListViewOnFocus == true`.
- Various: Fixed exception when `layout` is `null`.
- Various: Fixed `selectedItem` failing to update after settings new `dataProvider`.

## 1.0.0-rc.2 (2022-06-15)

- BaseNavigator: Fixed navigator sometimes failing to resize the "next" view in transition correctly.
- BaseScrollContainer: Fixed issue where the view port did not receeive updated `scrollX` and `scrollY` values in some situations.
- CalendarGrid: Removed deprecated class. Replaced by `DatePicker` in beta.9.
- ComboBox: Fixed duplicate `Event.CHANGE` dispatch when selected item changes.
- ComboBox: Fixed issue where up and down arrow keys would sometimes go to the wrong index after opening the pop-up `ListView`.
- ComboBox, PopUpListView: Fixed `selectedIndex` being cleared to `-1` instead of resetting to `0` when `dataProvider` is replaced.
- Data Containers: Fixed `selectedItem` setter sometimes failing to detect that the `selectedIndex` is different, and `Event.CHANGE` needs to be dispatched.
- ExclusivePointer: Removed deprecated `claimPointer()`, `getClaim()`, and `removeClaim()`. Replaced with separate APIs for mouse and touch claims in rc.1.
- GridView, TreeGridView: Fixed non-string values being incorrectly treated as strings when columns are not defined and are auto-populated with reflection instead.
- GridViewHeaderRenderer: Removed deprecated class. Replaced by `SortOrderHeaderRenderer` in rc.1.
- GroupListView, TreeView, TreeGridView: Fixed failure to clear selected item after removing or replacing it (or a parent branch, for trees) in the `dataProvider`.
- GroupListView, TreeView, TreeGridView: Fixed clearing the layout's virtual cache when the layout changes. Was incorrectly clearing a different array.
- GroupListView, TreeView, TreeGridView: Fixed performance issue caused by calculating the total number of items in the layout too frequently.
- GroupListView, TreeView, TreeGridView: Fixed performance issue caused by traversing the entire `dataProvider` when it was necessary to loop through only part of it.
- ItemRenderer: Fixed issue where changing the `secondaryText` to `null` and repopulating later would result in the wrong text format.
- Route: Removed deprecated `injectState()` and `restoreData()`. Replaced by `updateState()` in beta.9.
- ScrollContainer: Fixed issue where the view port may not be updated often enough for layouts that implements `IScrollLayout`.
- TreeView, TreeGridView: Fixed failure to update open branches after removing or replacing an item in the `dataProvider`.
- magic-8-ball-chat: New sample project that demonstrates how to create a chat client with the `ListView` component.

## 1.0.0-rc.1 (2022-05-12)

- AssetLoader: Uses a mask when the `scaleMode` makes the content larger than the bounds of the loader.
- BaseScrollContainer: Added `ScrollMode.MASKLESS` to allow scrolling without using `mask` or `scrollRect`. May be useful for optimization, but children may appear outside the bounds of the container, so covering the edges is important.
- CustomScaleManager, LetterboxScaleManager, ScreenDensityScaleManager: Added new properties similar to the constructor arguments to allow further customization after creation.
- ExclusivePointer: Deprecated `claimPointer()`, `getClaim()`, and `removeClaim()`. Replaced with separate APIs for mouse and touch claims. Required because some environments return negative touch IDs, which were previously treated as either special values or invalid.
- FadeTransitions: Removed deprecated class. Replaced by `FadeTransitionBuilder` in beta.6.
- FeathersEvent: Removed deprecated `TRANSITION_START`, `TRANSITION_COMPLETE` and `TRANSITION_CANCEL`. Replaced by `TransitionEvent` in beta.6.
- FormItem: Can now set `required` property in constructor arguments.
- GridView: Removed deprecated `CHILD_VARIANT_HEADER` constant. Replaced by `CHILD_VARIANT_HEADER_RENDERER` in beta.4.
- GridView, TreeGridView: Added missing `customCellRendererVariant` style property.
- HorizontalLayout, VerticalLayout: Added new `percentWidthResetEnabled` and `percentHeightResetEnabled` properties.
- ItemRenderer: Added `secondaryHtmlText` property to display secondary text as simple HTML.
- OverAndUnderlineSkin: Removed deprecated class. Replaced by `TopAndBottomBorderSkin` in beta.3.
- ResponsiveGridLayout: Added `setGap()` convenience function to set all gap properties.
- ResponsiveGridLayout: Added new "xxl" breakpoint that defaults to 1400 pixels.
- ResponsiveGridLayout: Added `rowVerticalAlign` property to adjust the alignment of items within a row, along with `justifyResetEnabled` to customize how it works when `rowVerticalAlign` is set to `JUSTIFY`.
- ResponsiveGridLayoutData: Added `display` property (and `mdDisplay`, `lgDisplay`, etc.) to allow items to be hidden from certain breakpoints.
- Scroller: When scroll position is less than minimum or greater than maximum by less than a pixel, snap with no animation duration so that continuous tapping won't make the scroller think it is still scrolling when there's no visual indication that it is anymore.
- SortOrderHeaderRenderer: Deprecated `GridViewHeaderRenderer` and replaced with `SortOrderHeaderRenderer` because it may be used by other components too.
- SlideTransitions: Removed deprecated class. Replaced by `SlideTransitionBuilder` in beta.6.
- TransitionEvent: Extends `openfl.events.Event` instead of `FeathersEvent`.
- TreeView, TreeGridView: Significant performance optimizations for `toggleBranch()` and `toggleChildrenOf()`.
- TreeViewItemRenderer: Removed deprecated class. Replaced with `HierarchicalItemRenderer` in beta.8.
- Themes: Added `feathersui_theme_manage_stage_color` define to allow the theme to set the stage color to match the theme. Disabled by default.

## 1.0.0-beta.9 (2022-02-25)

- BaseScrollContainer: `scrollMode` property defaults to `MASK` instead of `SCROLL_RECT` to avoid forcex pixel rounding.
- Button, ToggleButton: Does not trigger on space/enter key when a button's child has focus instead of the button itself. This isn't common with simple buttons, but `ItemRenderer` is a subclass, and it may have children that can receive focus.
- CalendarGrid: Deprecated in favor of `DatePicker`. Hide the items in a `DatePicker` header to make it behave like the old `CalendarGrid`.
- General: All haxedefs to change Feathers UI behavior at compile time now start with `feathersui_` to avoid potential conflicts. Example: `disable_default_theme` is now `feathersui_disable_default_theme`.
- General: More constructor arguments for UI components to automatically add listeners for common events.
- General: Children of data containers, like `ListView`, can receive tab focus. Data containers now implement `IFocusContainer`.
- HierarchicalItemRenderer: The disclosure toggle button is no longer allowed to receive tab focus.
- HierarchicalItemRenderer: Added `disclosureButtonFactory` property to customize the creation of the disclosure toggle button.
- hn-reader: A new sample application that displays feeds from Hacker News, and uses URL parameters in `RouterNavigator`.
- HorizontalLineSkin, VerticalSkinSkin: new properties to align the line to the edges or center.
- ItemRenderer: Fixed support for `Math.POSITIVE_INFINITY` as a valid `gap` value.
- ItemRenderer: Respects the `includeInLayout` property of the `accessoryView`.
- LayoutGroupItemRenderer: Added `alternateBackgroundSkin`, similar to the same property on `ItemRenderer`.
- Route: Added `Route.withRedirect()` to allow a URL to automatically redirect to another.
- Route: Deprecated `injectState()` and `restoreData()`. Use the new `updateState()` function instead, which replaces both.
- Route: Static methods like `Route.withClass()` and `Route.withFunction()` replace `injectState` function argument with `updateState` instead. `updateState` accepts the new `RouteState` type.
- RouterNavigator: The order that routes are added is enforced on all targets when matching route URL paths.
- RouterNavigator: Route paths may now have parameters, like "/users/:id" where `:id` is a parameter. URL parameters are passed to the new `updateState()` function of the `Route`.
- RouterNavigator: Now listens for `TextEvent.LINK` bubbled from the currently active view, and navigates if the event's text starts with "router:". For example, you can set the `htmlText` of a `Label` to `<a href="text:router:/users/list">Show all users</a>`. If the user clicks this link, the navigator will navigate to "/users/list". Requires OpenFL >= 9.2.0.
- Scale9Bitmap: When width or height is set smaller than `scale9Grid` corners/edges allow, scales corners down.
- Text: Components with `htmlText` property now have a `styleSheet` property. Requires OpenFL >= 9.2.0.
- todomvc: New sample application based on the popular todomvc.com.
- TreeGridView: Left and right arrow keys behave similarly to `TreeView`, to open and close branches and jump between a branch and its children.
- ValidatingSprite: Added public `validating` property to indicate if it is currently validating or not.

## 1.0.0-beta.8 (2022-01-06)

- TreeGridView: New component that displays a tree of hierarchical data with multiple columns, like a mix between `TreeView` and `GridView`.
- HierarchicalItemRenderer: New subclass of `ItemRenderer` that is used by both `TreeView` and `TreeGridView`. Includes a toggle button to open and close branches, and an optional branch or leaf icon, in addition to the text, secondary text, icon and accessory provided by `ItemRenderer`. This component replaces `TreeViewItemRenderer`, which is now deprecated and will be removed in a future update.
- FlowRowsLayout: New layout that displays items in multiple rows. Starts by positioning items from left to right. When the combined width of items in a row reaches the width of the container, a new row will be created below. Similar to `TiledRowsLayout`, but the items may be different sizes.
- BitmapDataCache: New utility class for sharing references to `BitmapData` that was loaded from a URL.
- FormItem: Added `required` and `requiredSkin` properties, to optionally indicate if the form item is required.
- FormItem: Added `submitOnEnterEnabled` property to allow form submission to be disabled when pressing the Enter/Return key for that specific item. Useful for components like `TextArea`, which needs to use Enter/Return to insert a line break in its text.
- HScrollBar/VScrollBar: Minor tweak to the sizing behavior of the thumb to more accurately match the behavior of native scroll bars.
- IHierarchicalCollection: The `removeAll()` method now accepts an optional `?location:Array<Int>` argument that may be used to remove all children from a specific branch.

## 1.0.0-beta.7 (2021-11-02)

- DatePicker: New component for selecting a date from a calendar view.
- FeathersControl: Added `disabledAlpha` property to change the `alpha` value of the component when disabled.
- FeathersControl: Added `setFocusPadding()` convenience method.
- LayoutGroup: Prevents mouse/touch from reaching children when disabled.
- PopUpDatePicker: New component that displays a date as an input field, with a pop-up `DatePicker`.
- RouterNavigator: Support for "hash" routing instead of URL routing. Will fall back to hash routing when loaded with the `file:` protocol. Can also set `preferHashRouting` to use hash routing as default.
- RouterNavigator: Added optional `saveData` and `restoreData` methods to `Route` to allow a view's state to be saved when navigating away and restored when returning.
- StackNavigator: Added optional `saveData` and `restoreData` methods to `StackItem` to allow a view's state to be saved when navigating away and restored when returning.
- TextArea, TextInput: Added `selectable` property, which can be set to `false` to disable selection when `editable` is also `false`.
- TextArea: Added `setTextPadding()` convenience method.
- stack-navigator-save-and-restore: New sample that demonstrates how to use the `saveData` and `restoreData` methods on `StackItem`.
- router-navigator-save-and-restore: New sample that demonstrates how to use the `saveData` and `restoreData` methods on `Route`.

## 1.0.0-beta.6 (2021-10-04)

- ArrayCollection, ArrayHierarchicalCollection: These collections now implement the `IExternalizable` interface.
- BaseNavigator: Uses the new `TransitionEvent` instead of `FeathersEvent` for transition start, complete, and cancel events. This allows references to the views involved in the transition to be included as properties of the event. The old transition constants on `FeathersEvent` are now deprecated and will be removed in a future version.
- BaseNavigator: Now dispatches `Event.CHANGE` after a transition is completed, instead of at the start of the transition.
- BaseScrollContainer: Added new `scrollMode` property that controls how scrolling is implemented on the OpenFL display list. This property may be set to either `SCROLL_RECT` or `MASK`. It defaults to `SCROLL_RECT`, which was the existing behavior.
- Transition Builders: An improved way to create transitions for navigators. The following transitions are implemented: Color Fade, Cover, Fade, Iris, Reveal, Slide, and Wipe.
- TreeView: Added `toggleChildrenOf()` method to open or close all children of a branch.
- TreeView: Left and right keyboard arrow keys will open and close a branch.
- Various bug fixes.

## 1.0.0-beta.5 (2021-08-20)

- ArrayCollection: Added `toArray()` method to return a new array of the items in the collection (respecting filter and sort).
- DefaultFocusManager: Handle focus changes with keyboard arrow keys, if they originate from `KeyLocation.D_PAD`.
- HorizontalLayout, HorizontalListLayout, VerticalLayout, VerticalListLayout: The `gap` property may be set to `Math.POSITIVE_INFINITY` to position items as far from each other as possible while staying within the container's view port bounds. Use `minGap` to set the minimum spacing.
- ItemRenderer: Added `showSecondaryText` property to optionally hide the secondary text, even if not `null`, similar to how `showText` works.
- LayoutGroup, ScrollContainer: Added `maskSkin` to optionally mask the content of the container. The `maskSkin` is resized automatically when the container resizes. Useful for masking with rounded corners or other non-rectangular shapes.
- ScrollContainer: Added `viewPortMaskSkin` to optionally mask only the view port. Works similarly to `maskSkin`.
- TiledRowsLayout, TiledRowsListLayout: New layout for containers that positions items as tiles (all items have equal dimensions) in one or more rows.
- PagedTiledRowsListLayout: A variation of `TiledRowsListLayout` that separates tiles across multiple pages instead of scrolling continuously.
- Scroller: Added `snapPositionsX` and `snapPositionsY` properties that accept an array of snap positions, which is populated by subclasses of `BaseScrollContainer`, when a layout supports snapping.
- A ton of stability and bug fixes!

## 1.0.0-beta.4 (2021-07-09)

- AssetLoader: Added new `originalSourceWidth` and `originalSourceHeight` properties that return the original dimensions of the content, after loading completes.
- BaseScrollContainer: Added new `restrictedScrollX` and `restrictedScrollY` that may be used instead of `scrollX` and `scrollY` if it is necessary to clamp to the `minimum` and `maximum` bounds.
- Button, ToggleButton: Added new `showText` style to allow the text to be hidden so that it does not affect the layout (such as for a button that contains only an icon).
- ButtonBar, TabBar: Added support for multiple button/tab renderers.
- ButtonBar, TabBar: Added a new `indexToButton()/indexToTab()` method to access one of the current renderers based on its position in the data provider.
- Callout: New `closeOnPointerOutside` property that can be set to `false` to prevent the callout from automatically closing when clicking or tapping outside of its bounds.
- CalloutPopUpAdapter: New implementation of `IPopUpAdapter` that adds the content to a `Callout` positioned near the origin.
- ComboBox: Now allows the user to type a custom value. Will be returned by `selectedItem`, but `selectedIndex` will be `-1`. Set the new `allowCustomUserValue` property to `false` to restrict the value to only items from the data provider.
- ComboBox: Added new `textToItem()` method that allows custom text to be converted into the same format as items in the data provider.
- ComboBox, PopUpListView: Added a new `prompt` property to display some text when no item is currently selected.
- DisplayObjectFactory: New class that's similar to `DisplayObjectRecycler`, but has only `create` and `destroy` functions. No `update` or `reset` functions.
- DropDownPopUpAdapter: Can now open above origin, if there is not enough space below the origin.
- FocusManager: The `addRoot()` method has been restricted to the `Stage` type only. To create a focus manager with a root other than the stage, use the `DefaultFocusManager` constructor instead.
- GridView: Added new `sortableColumns`, `sortedColumn`, and `sortOrder` properties that enable the user to sort the data provider by clicking a column header, or to sort the columns programatically.
- GridView: Added new `CHILD_VARIANT_CELL_RENDERER` static constant to allow targeting of `GridView` cell renderers in a theme.
- GridView: Renamed `CHILD_VARIANT_HEADER` to `CHILD_VARIANT_HEADER_RENDERER` for consistency with `CHILD_VARIANT_CELL_RENDERER`. `CHILD_VARIANT_HEADER` is now deprecated and will be removed in a future update.
- GridView: Added new `columnDividerFactory` and `headerDividerFactory` for displaying dividers between columns and column headers.
- GridViewColumn: Added new constructor parameter to optionally set the width of the column.
- HorizontalLayout, VerticalLayout: Added new `justifyResetEnabled` property that will optionally reset the size of all items before measuring them.
- HorizontalLayoutData, VerticalLayoutData: Added new `fillHorizontal()`, `fillVertical()`, and `fill()` static helper functions to quickly create an object with `percentWidth`, `percentHeight` (or both) set to `100.0` in a single function call.
- HorizontalLineSkin, VerticalLineSkin: New skin classes that draw a simple line in the center.
- HorizontalListLayout, VerticalListLayout: Added new `heightResetEnabled` and `widthResetEnabled` (respectively) to reset the size of all items before measuring them.
- IPopUpManager: Added new `hasModalPopUps()`, `topLevelPopUpCount`, and `getPopUpAt()` APIs.
- IScaleManager: New interface for custom application scaling behavior. Includes `ScreenDensityScaleManager`, `LetterboxScaleManager`, and `CustomScaleManager` implementations.
- ItemRenderer: Addded new `accessoryView` property to optionally display a UI component on the right side of the item renderer.
- ListView: Added new `VARIANT_POP_UP` static constant for list views that are added as pop-ups, for components like `PopUpListView` and `ComboBox`.
- NumericStepper: New UI component that displays a numeric value in a `TextInput`, with two buttons to increment or decrement the value.
- PageIndicator: Added a new `indexToToggleButton()` method to access one of the current toggle butons based on its selection index.
- PopUpUtil: Added new `isTopLevelPopUpOrIsContainedByTopLevelPopUp()` utility method.
- TextArea, TextInput: All text is automatically selected when `showFocus(true)` is called.
- TextArea, TextInput: Added new `errorString` property to optionally display validation errors in a `TextCallout` when focused.
- TextArea: Added new `displayAsPassword` property to mask the rendered text, similar to the same property that `TextInput` already had.
- TextCallout: Added new `VARIANT_DANGER` static constant to optionally display the callout in a style that indicates something potentially dangerous or destructive.
- TextInput: Added new `measureText` property, which can specify custom text to use when measuring the text input's ideal size. Similar to `autoSizeWidth`, but uses a different value than the current value of the `text` property.
- ValidationQueue: Uses `Event.RENDER` and `stage.invalidate()` instead of `Event.ENTER_FRAME` because it gives more stable results and doesn't run code every frame if no components need validation.

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
- IHierarchicalCollection: Added `filterFunction` and `sortCompareFunction`, similar to `IFlatCollection`.
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