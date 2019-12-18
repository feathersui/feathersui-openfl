import openfl.display.Sprite;
import massive.munit.client.RichPrintClient;
import massive.munit.client.HTTPClient;
import massive.munit.client.SummaryReportClient;
import massive.munit.TestRunner;

/**
 * Auto generated Test Application.
 * Refer to munit command line tool for more information (haxelib run munit)
 */
class TestMain extends Sprite {
	public static var openfl_root:Sprite;

	public function new() {
		super();

		openfl_root = this;

		var suites = new Array<Class<massive.munit.TestSuite>>();
		suites.push(TestSuite);

		#if MCOVER
		var client = new mcover.coverage.munit.client.MCoverPrintClient();
		var httpClient = new HTTPClient(new mcover.coverage.munit.client.MCoverSummaryReportClient());
		#else
		var client = new RichPrintClient();
		var httpClient = new HTTPClient(new SummaryReportClient());
		#end

		var runner = new TestRunner(client);
		runner.addResultClient(httpClient);
		// runner.addResultClient(new HTTPClient(new JUnitReportClient()));

		runner.completionHandler = completionHandler;

		#if (js && !nodejs)
		var seconds = 0; // edit here to add some startup delay
		function delayStartup() {
			if (seconds > 0) {
				seconds--;
				js.Browser.document.getElementById("munit").innerHTML = "Tests will start in " + seconds + "s...";
				haxe.Timer.delay(delayStartup, 1000);
			} else {
				js.Browser.document.getElementById("munit").innerHTML = "";
				runner.run(suites);
			}
		}
		delayStartup();
		#else
		runner.run(suites);
		#end
	}

	/**
	 * updates the background color and closes the current browser
	 * for flash and html targets (useful for continous integration servers)
	 */
	function completionHandler(successful:Bool) {
		try {
			#if flash
			flash.external.ExternalInterface.call("testResult", successful);
			#elseif js
			js.Lib.eval("testResult(" + successful + ");");
			#elseif (neko || cpp || java || cs || python || php || hl || eval)
			Sys.exit(0);
			#end
		}
		// if run from outside browser can get error which we can ignore
		catch (e:Dynamic) {}
	}
}
