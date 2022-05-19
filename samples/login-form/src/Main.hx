import openfl.events.Event;
import feathers.controls.Alert;
import feathers.controls.Application;
import feathers.controls.Button;
import feathers.controls.Form;
import feathers.controls.FormItem;
import feathers.controls.TextInput;
import feathers.events.FormEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

class Main extends Application {
	public function new() {
		super();

		this.layout = new AnchorLayout();

		var form = new Form();
		// the SUBMIT event is dispatched when the submit button is triggered,
		// or when the user presses Enter/Return when a component is the form
		// has focus.
		form.addEventListener(FormEvent.SUBMIT, form_submitHandler);
		form.layoutData = AnchorLayoutData.center();
		this.addChild(form);

		var emailItem = new FormItem();
		// position the text on any of the four sides
		emailItem.textPosition = LEFT;
		emailItem.text = "Email";
		emailItem.required = true;
		this.emailInput = new TextInput();
		this.emailInput.addEventListener(Event.CHANGE, emailInput_changeHandler);
		emailItem.content = this.emailInput;
		form.addChild(emailItem);

		var passwordItem = new FormItem();
		passwordItem.textPosition = LEFT;
		passwordItem.text = "Password";
		passwordItem.required = true;
		this.passwordInput = new TextInput();
		this.passwordInput.displayAsPassword = true;
		this.passwordInput.addEventListener(Event.CHANGE, passwordInput_changeHandler);
		passwordItem.content = this.passwordInput;
		form.addChild(passwordItem);

		this.loginButton = new Button();
		this.loginButton.text = "Login";
		// one button may be designated to submit the form
		// all other buttons can be triggered without submitting
		form.submitButton = loginButton;
		form.addChild(this.loginButton);
	}

	private var emailInput:TextInput;
	private var passwordInput:TextInput;
	private var loginButton:Button;

	private function resetForm():Void {
		this.emailInput.text = "";
		this.emailInput.errorString = null;
		this.passwordInput.text = "";
		this.passwordInput.errorString = null;
	}

	private function emailInput_changeHandler(event:Event):Void {
		if (this.emailInput.text.length == 0) {
			return;
		}
		this.emailInput.errorString = null;
	}

	private function passwordInput_changeHandler(event:Event):Void {
		if (this.passwordInput.text.length == 0) {
			return;
		}
		this.passwordInput.errorString = null;
	}

	private function form_submitHandler(event:FormEvent):Void {
		var email = this.emailInput.text;
		var password = this.passwordInput.text;

		this.emailInput.errorString = null;
		this.passwordInput.errorString = null;
		if (email.length == 0) {
			this.emailInput.errorString = "Email is required.";
			return;
		}
		if (password.length == 0) {
			this.passwordInput.errorString = "Password is required.";
			return;
		}

		Alert.show('Email: ${email}\nPassword: ${password}', "Form Submitted", ["OK"]);

		this.resetForm();
	}
}
