import feathers.controls.Application;
import feathers.controls.navigators.StackItem;
import feathers.controls.navigators.StackNavigator;
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

		var navigator = new StackNavigator();
		navigator.layoutData = AnchorLayoutData.fill();

		var welcomeRoute = StackItem.withClass(WelcomeView.ID, WelcomeView, [Event.COMPLETE => Push(OtherView.ID)]);
		welcomeRoute.saveData = (view:WelcomeView) -> {
			return view.welcomeData;
		};
		welcomeRoute.restoreData = (view:WelcomeView, data:WelcomeData) -> {
			view.welcomeData = data;
		};
		navigator.addItem(welcomeRoute);

		navigator.addItem(StackItem.withClass(OtherView.ID, OtherView, [Event.CANCEL => Pop()]));

		navigator.rootItemID = WelcomeView.ID;

		this.addChild(navigator);
	}
}
