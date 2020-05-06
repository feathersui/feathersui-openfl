import feathers.controls.Label;
import feathers.controls.Application;
import feathers.controls.Button;
import feathers.controls.TextInput;
import feathers.events.TriggerEvent;
import feathers.layout.VerticalLayout;

class Main extends Application {
	public function new() {
		super();

		var layout = new VerticalLayout();
		layout.paddingTop = 20.0;
		layout.paddingRight = 20.0;
		layout.paddingBottom = 20.0;
		layout.paddingLeft = 20.0;
		layout.gap = 10.0;
		this.layout = layout;

		var usernameLabel = new Label();
		usernameLabel.text = "User Name";
		this.addChild(usernameLabel);

		this.usernameInput = new TextInput();
		this.addChild(this.usernameInput);

		var passwordLabel = new Label();
		passwordLabel.text = "Password";
		this.addChild(passwordLabel);

		this.passwordInput = new TextInput();
		this.passwordInput.displayAsPassword = true;
		this.addChild(this.passwordInput);

		this.submitButton = new Button();
		this.submitButton.text = "Login";
		this.submitButton.addEventListener(TriggerEvent.TRIGGER, submitButton_triggerHandler);
		this.addChild(this.submitButton);
	}

	private var usernameInput:TextInput;
	private var passwordInput:TextInput;
	private var submitButton:Button;

	private function submitButton_triggerHandler(event:TriggerEvent):Void {
		this.usernameInput.text = "";
		this.passwordInput.text = "";
	}
}
