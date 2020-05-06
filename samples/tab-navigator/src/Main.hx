import feathers.controls.Application;
import feathers.controls.navigators.TabItem;
import feathers.controls.navigators.TabNavigator;
import feathers.data.ArrayCollection;
import views.A;
import views.B;
import views.C;

class Main extends Application {
	public function new() {
		super();

		var navigator = new TabNavigator();
		navigator.dataProvider = new ArrayCollection([
			// @formatter:off
			TabItem.withClass("A", A),
			TabItem.withClass("B", B),
			TabItem.withClass("C", C)
			// @formatter:on
		]);
		this.addChild(navigator);
	}
}
