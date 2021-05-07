import events.ContactEvent;
import feathers.controls.Application;
import feathers.controls.navigators.Route;
import feathers.controls.navigators.RouterNavigator;
import feathers.data.ArrayCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import valueObjects.Contact;
import views.ChooseContactView;
import views.ComposeMessageView;

class Main extends Application {
	public function new() {
		super();
	}

	override private function initialize():Void {
		super.initialize();

		this.layout = new AnchorLayout();

		// the full list of contacts
		var contacts = new ArrayCollection([
			new Contact(1, "Matt Murdock", "matt@example.com"),
			new Contact(2, "Franklin Nelson", "foggy@example.com"),
			new Contact(3, "Karen Page", "karen@example.com")
		]);

		var navigator = new RouterNavigator();
		#if feathersui.com
		// to build for the feathersui.com website, run the following command:
		// haxelib run openfl build html5 -final --haxedef=feathersui.com
		navigator.basePath = "/samples/haxe-openfl/router-navigator-pass-data-between-views";
		#end
		navigator.layoutData = AnchorLayoutData.fill();

		navigator.addRoute(Route.withClass(ComposeMessageView.ROUTE_PATH, ComposeMessageView, [
			ContactEvent.REQUEST_CONTACT => NewAction((event:ContactEvent) -> {
				var newState = null;
				var contact = event.contact;
				if (contact != null) {
					newState = {contactID: contact.id};
				}
				return Push(ChooseContactView.ROUTE_PATH, newState);
			})
		], (view:ComposeMessageView, state:Dynamic) -> {
			if (state == null) {
				return;
			}
			var contactID:Null<Int> = state.contactID;
			if (contactID != null) {
				for (otherContact in contacts) {
					if (contactID == otherContact.id) {
						view.recipient = otherContact;
						break;
					}
				}
			}
		}));

		navigator.addRoute(Route.withFunction(ChooseContactView.ROUTE_PATH, () -> {
			var picker = new ChooseContactView();
			picker.contacts = contacts;
			return picker;
		}, [
			ContactEvent.CHOOSE_CONTACT => NewAction((event:ContactEvent) -> {
				var newState = null;
				var contact = event.contact;
				if (contact != null) {
					newState = {contactID: contact.id};
				}
				// pass the selected contact back to the compose screen
				return Push(ComposeMessageView.ROUTE_PATH, newState);
			})
		], (view:ChooseContactView, state:Dynamic) -> {
			if (state == null) {
				return;
			}
			var contactID:Null<Int> = state.contactID;
			if (contactID != null) {
				for (otherContact in contacts) {
					if (contactID == otherContact.id) {
						view.selectedContact = otherContact;
						break;
					}
				}
			}
		}));

		this.addChild(navigator);
	}
}
