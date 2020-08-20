# Feather UI for OpenFL and Haxe Change Log

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