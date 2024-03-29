import events.ContactEvent;
import feathers.controls.Application;
import feathers.controls.navigators.StackItem;
import feathers.controls.navigators.StackNavigator;
import feathers.data.ArrayCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;
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
			new Contact("Matt Murdock", "matt@example.com"),
			new Contact("Franklin Nelson", "foggy@example.com"),
			new Contact("Karen Page", "karen@example.com")
		]);

		var navigator = new StackNavigator();
		navigator.layoutData = AnchorLayoutData.fill();

		navigator.addItem(StackItem.withClass(ComposeMessageView.ID, ComposeMessageView, [
			ContactEvent.REQUEST_CONTACT => NewAction((event:ContactEvent) -> {
				var contact = event.contact;

				return Push(ChooseContactView.ID, (target:ChooseContactView) -> {
					// if a contact has already been chosen, and the user wants
					// to choose a different one instead, we can pre-select the
					// existing contact.
					target.selectedContact = contact;
				});
			})
		], [
			// when ChooseContactView is popped, we need to handle its
			// returned object
			ChooseContactView.ID => (composeView:ComposeMessageView, result:Contact) -> {
				// return the new recipient to the compose message view
				composeView.recipient = result;
			}
		]));

		navigator.addItem(StackItem.withFunction(ChooseContactView.ID, () -> {
			var picker = new ChooseContactView();
			picker.contacts = contacts;
			return picker;
		}, [
			ContactEvent.CHOOSE_CONTACT => NewAction((event:ContactEvent) -> {
				var contact = event.contact;

				// return the selected contact to the previous screen
				return Pop(contact);
			})
		]));

		this.addChild(navigator);

		// start by showing ComposeMessageView
		navigator.rootItemID = ComposeMessageView.ID;
	}
}
