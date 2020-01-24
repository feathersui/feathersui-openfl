import com.feathersui.components.ViewPaths;
import com.feathersui.components.views.AssetLoaderScreen;
import com.feathersui.components.views.ButtonScreen;
import com.feathersui.components.views.CalloutScreen;
import com.feathersui.components.views.CheckScreen;
import com.feathersui.components.views.ComboBoxScreen;
import com.feathersui.components.views.LabelScreen;
import com.feathersui.components.views.ListViewScreen;
import com.feathersui.components.views.MainMenu;
import com.feathersui.components.views.PanelScreen;
import com.feathersui.components.views.PopUpListScreen;
import com.feathersui.components.views.PopUpManagerScreen;
import com.feathersui.components.views.ProgressBarScreen;
import com.feathersui.components.views.RadioScreen;
import com.feathersui.components.views.SliderScreen;
import com.feathersui.components.views.TabBarScreen;
import com.feathersui.components.views.TextInputScreen;
import com.feathersui.components.views.ToggleSwitchScreen;
import feathers.controls.Application;
import feathers.controls.navigators.Route;
import feathers.controls.navigators.RouterAction;
import feathers.controls.navigators.RouterNavigator;
import feathers.motion.transitions.SlideTransitions;
import openfl.events.Event;

class Main extends Application {
	public function new() {
		super();
	}

	override private function initialize():Void {
		var navigator = new RouterNavigator();
		#if feathersui.com
		// to build for the feathersui.com website, run the following command:
		// haxelib run openfl build html5 -final --haxedef=feathersui.com
		navigator.basePath = "/samples/haxe-openfl/components-explorer";
		#end
		this.addChild(navigator);

		#if !html5
		navigator.backTransition = SlideTransitions.right();
		navigator.forwardTransition = SlideTransitions.left();
		#end

		var mainMenu = Route.withClass(ViewPaths.MAIN_MENU, MainMenu, [Event.CHANGE => NewAction(createPushPathAction)]);
		navigator.addRoute(mainMenu);

		var assetLoader = Route.withClass(ViewPaths.ASSET_LOADER, AssetLoaderScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		navigator.addRoute(assetLoader);

		var button = Route.withClass(ViewPaths.BUTTON, ButtonScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		navigator.addRoute(button);

		var callout = Route.withClass(ViewPaths.CALLOUT, CalloutScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		navigator.addRoute(callout);

		var check = Route.withClass(ViewPaths.CHECK, CheckScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		navigator.addRoute(check);

		var comboBox = Route.withClass(ViewPaths.COMBO_BOX, ComboBoxScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		navigator.addRoute(comboBox);

		var label = Route.withClass(ViewPaths.LABEL, LabelScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		navigator.addRoute(label);

		var listView = Route.withClass(ViewPaths.LIST_VIEW, ListViewScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		navigator.addRoute(listView);

		var panel = Route.withClass(ViewPaths.PANEL, PanelScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		navigator.addRoute(panel);

		var popUpList = Route.withClass(ViewPaths.POP_UP_LIST, PopUpListScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		navigator.addRoute(popUpList);

		var popUpManager = Route.withClass(ViewPaths.POP_UP_MANAGER, PopUpManagerScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		navigator.addRoute(popUpManager);

		var progressBar = Route.withClass(ViewPaths.PROGRESS_BAR, ProgressBarScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		navigator.addRoute(progressBar);

		var radio = Route.withClass(ViewPaths.RADIO, RadioScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		navigator.addRoute(radio);

		var slider = Route.withClass(ViewPaths.SLIDER, SliderScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		navigator.addRoute(slider);

		var tabBar = Route.withClass(ViewPaths.TAB_BAR, TabBarScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		navigator.addRoute(tabBar);

		var textInput = Route.withClass(ViewPaths.TEXT_INPUT, TextInputScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		navigator.addRoute(textInput);

		var toggleSwitch = Route.withClass(ViewPaths.TOGGLE_SWITCH, ToggleSwitchScreen, [Event.COMPLETE => createBackAction(ViewPaths.MAIN_MENU)]);
		navigator.addRoute(toggleSwitch);
	}

	private function createPushPathAction(event:Event):RouterAction {
		var screen = cast(event.currentTarget, MainMenu);
		return Push(screen.selectedViewPaths);
	}

	private function createBackAction(path:String):RouterAction {
		#if html5
		// on the web, links generally always go forward in history, even if
		// that doesn't match the direction of the navigation hierarchy
		return Push(path);
		#else
		// on other platforms, back goes back.
		// this may return to a different path than the parameter specifies
		return GoBack;
		#end
	}
}
