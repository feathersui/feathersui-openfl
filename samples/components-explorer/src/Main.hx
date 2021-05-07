import feathers.layout.AnchorLayoutData;
import feathers.layout.AnchorLayout;
import com.feathersui.components.ViewPaths;
import com.feathersui.components.views.AlertScreen;
import com.feathersui.components.views.AssetLoaderScreen;
import com.feathersui.components.views.ButtonBarScreen;
import com.feathersui.components.views.ButtonScreen;
import com.feathersui.components.views.CalloutScreen;
import com.feathersui.components.views.CheckScreen;
import com.feathersui.components.views.CircleSkinScreen;
import com.feathersui.components.views.ComboBoxScreen;
import com.feathersui.components.views.DrawerScreen;
import com.feathersui.components.views.EllipseSkinScreen;
import com.feathersui.components.views.FormScreen;
import com.feathersui.components.views.GridViewScreen;
import com.feathersui.components.views.GroupListViewScreen;
import com.feathersui.components.views.HDividedBoxScreen;
import com.feathersui.components.views.HeaderScreen;
import com.feathersui.components.views.LabelScreen;
import com.feathersui.components.views.LayoutGroupScreen;
import com.feathersui.components.views.ListViewScreen;
import com.feathersui.components.views.MainMenu;
import com.feathersui.components.views.NumericStepperScreen;
import com.feathersui.components.views.PageIndicatorScreen;
import com.feathersui.components.views.PageNavigatorScreen;
import com.feathersui.components.views.PanelScreen;
import com.feathersui.components.views.PillSkinScreen;
import com.feathersui.components.views.PopUpListViewScreen;
import com.feathersui.components.views.PopUpManagerScreen;
import com.feathersui.components.views.ProgressBarScreen;
import com.feathersui.components.views.RadioScreen;
import com.feathersui.components.views.RectangleSkinScreen;
import com.feathersui.components.views.ScrollContainerScreen;
import com.feathersui.components.views.SliderScreen;
import com.feathersui.components.views.StackNavigatorScreen;
import com.feathersui.components.views.TabBarScreen;
import com.feathersui.components.views.TabNavigatorScreen;
import com.feathersui.components.views.TabSkinScreen;
import com.feathersui.components.views.TextAreaScreen;
import com.feathersui.components.views.TextCalloutScreen;
import com.feathersui.components.views.TextInputScreen;
import com.feathersui.components.views.ToggleSwitchScreen;
import com.feathersui.components.views.TreeViewScreen;
import com.feathersui.components.views.TriangleSkinScreen;
import com.feathersui.components.views.VDividedBoxScreen;
import feathers.controls.Application;
import feathers.controls.navigators.Route;
import feathers.controls.navigators.RouterAction;
import feathers.controls.navigators.RouterNavigator;
import openfl.events.Event;

class Main extends Application {
	public function new() {
		super();
	}

	private var _navigator:RouterNavigator;

	override private function initialize():Void {
		this.layout = new AnchorLayout();

		this._navigator = new RouterNavigator();
		#if feathersui.com
		// to build for the feathersui.com website, run the following command:
		// haxelib run openfl build html5 -final --haxedef=feathersui.com
		this._navigator.basePath = "/samples/haxe-openfl/components-explorer";
		#end
		this._navigator.layoutData = AnchorLayoutData.fill();
		this.addChild(this._navigator);

		var mainMenu = Route.withClass(ViewPaths.MAIN_MENU, MainMenu, [Event.CHANGE => NewAction(createPushPathAction)]);
		this._navigator.addRoute(mainMenu);

		var alert = Route.withClass(ViewPaths.ALERT, AlertScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(alert);

		var assetLoader = Route.withClass(ViewPaths.ASSET_LOADER, AssetLoaderScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(assetLoader);

		var button = Route.withClass(ViewPaths.BUTTON, ButtonScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(button);

		var buttonBar = Route.withClass(ViewPaths.BUTTON_BAR, ButtonBarScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(buttonBar);

		var callout = Route.withClass(ViewPaths.CALLOUT, CalloutScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(callout);

		var check = Route.withClass(ViewPaths.CHECK, CheckScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(check);

		var circleSkin = Route.withClass(ViewPaths.CIRCLE_SKIN, CircleSkinScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(circleSkin);

		var comboBox = Route.withClass(ViewPaths.COMBO_BOX, ComboBoxScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(comboBox);

		var hDividedBox = Route.withClass(ViewPaths.HORIZONTAL_DIVIDED_BOX, HDividedBoxScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(hDividedBox);

		var vDividedBox = Route.withClass(ViewPaths.VERTICAL_DIVIDED_BOX, VDividedBoxScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(vDividedBox);

		var drawer = Route.withClass(ViewPaths.DRAWER, DrawerScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(drawer);

		var ellipseSkin = Route.withClass(ViewPaths.ELLIPSE_SKIN, EllipseSkinScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(ellipseSkin);

		var form = Route.withClass(ViewPaths.FORM, FormScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(form);

		var gridView = Route.withClass(ViewPaths.GRID_VIEW, GridViewScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(gridView);

		var groupListView = Route.withClass(ViewPaths.GROUP_LIST_VIEW, GroupListViewScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(groupListView);

		var header = Route.withClass(ViewPaths.HEADER, HeaderScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(header);

		var label = Route.withClass(ViewPaths.LABEL, LabelScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(label);

		var layoutGroup = Route.withClass(ViewPaths.LAYOUT_GROUP, LayoutGroupScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(layoutGroup);

		var listView = Route.withClass(ViewPaths.LIST_VIEW, ListViewScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(listView);

		var numericStepper = Route.withClass(ViewPaths.NUMERIC_STEPPER, NumericStepperScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(numericStepper);

		var pageIndicator = Route.withClass(ViewPaths.PAGE_INDICATOR, PageIndicatorScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(pageIndicator);

		var pageNavigator = Route.withClass(ViewPaths.PAGE_NAVIGATOR, PageNavigatorScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(pageNavigator);

		var panel = Route.withClass(ViewPaths.PANEL, PanelScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(panel);

		var pillSkin = Route.withClass(ViewPaths.PILL_SKIN, PillSkinScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(pillSkin);

		var popUpListView = Route.withClass(ViewPaths.POP_UP_LIST_VIEW, PopUpListViewScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(popUpListView);

		var popUpManager = Route.withClass(ViewPaths.POP_UP_MANAGER, PopUpManagerScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(popUpManager);

		var progressBar = Route.withClass(ViewPaths.PROGRESS_BAR, ProgressBarScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(progressBar);

		var radio = Route.withClass(ViewPaths.RADIO, RadioScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(radio);

		var rectangleSkin = Route.withClass(ViewPaths.RECTANGLE_SKIN, RectangleSkinScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(rectangleSkin);

		var scrollContainer = Route.withClass(ViewPaths.SCROLL_CONTAINER, ScrollContainerScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(scrollContainer);

		var slider = Route.withClass(ViewPaths.SLIDER, SliderScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(slider);

		var stackNavigator = Route.withClass(ViewPaths.STACK_NAVIGATOR, StackNavigatorScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(stackNavigator);

		var tabBar = Route.withClass(ViewPaths.TAB_BAR, TabBarScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(tabBar);

		var tabNavigator = Route.withClass(ViewPaths.TAB_NAVIGATOR, TabNavigatorScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(tabNavigator);

		var tabSkin = Route.withClass(ViewPaths.TAB_SKIN, TabSkinScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(tabSkin);

		var textArea = Route.withClass(ViewPaths.TEXT_AREA, TextAreaScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(textArea);

		var textCallout = Route.withClass(ViewPaths.TEXT_CALLOUT, TextCalloutScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(textCallout);

		var textInput = Route.withClass(ViewPaths.TEXT_INPUT, TextInputScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(textInput);

		var toggleSwitch = Route.withClass(ViewPaths.TOGGLE_SWITCH, ToggleSwitchScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(toggleSwitch);

		var treeView = Route.withClass(ViewPaths.TREE_VIEW, TreeViewScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(treeView);

		var triangleSkin = Route.withClass(ViewPaths.TRIANGLE_SKIN, TriangleSkinScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		this._navigator.addRoute(triangleSkin);
	}

	private function createPushPathAction(event:Event):RouterAction {
		var screen = cast(event.currentTarget, MainMenu);
		return Push(screen.selectedViewPaths);
	}

	private function createBackAction(path:String):RouterAction {
		#if html5
		// on the web, links generally always go forward in history, even if
		// that doesn't match the direction of the navigation hierarchy
		return Push(path, null, this._navigator.backTransition);
		#else
		// on other platforms, back goes back.
		// this may return to a different path than the parameter specifies
		return GoBack();
		#end
	}
}
