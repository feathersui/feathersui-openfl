import feathers.controls.Application;
import feathers.controls.navigators.Route;
import feathers.controls.navigators.RouterNavigator;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;
import valueObjects.WelcomeData;
import views.OtherView;
import views.WelcomeView;

class Main extends Application {
	public function new() {
		super();
	}

	override private function initialize():Void {
		super.initialize();

		this.layout = new AnchorLayout();

		var navigator = new RouterNavigator();
		#if feathersui.com
		// to build for the feathersui.com website, run the following command:
		// haxelib run openfl build html5 -final --haxedef=feathersui.com
		navigator.basePath = "/samples/haxe-openfl/router-navigator-save-and-restore";
		#end
		navigator.layoutData = AnchorLayoutData.fill();

		var welcomeRoute = Route.withClass(WelcomeView.ROUTE_PATH, WelcomeView, [Event.COMPLETE => Push(OtherView.ROUTE_PATH)]);
		welcomeRoute.saveData = (view:WelcomeView) -> {
			return view.welcomeData;
		};
		welcomeRoute.restoreData = (view:WelcomeView, data:WelcomeData) -> {
			view.welcomeData = data;
		};
		navigator.addRoute(welcomeRoute);

		navigator.addRoute(Route.withClass(OtherView.ROUTE_PATH, OtherView, [Event.CANCEL => GoBack()]));

		this.addChild(navigator);
	}
}
