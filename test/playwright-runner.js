//@ts-check
const { firefox, chromium, webkit } = require("playwright");
const serveHandler = require("serve-handler");
const http = require("http");

process.chdir("bin/html5/bin");
const server = http.createServer((request, response) => {
	return serveHandler(request, response);
});
server.listen(3000, async () => {
	for (var browserType of [chromium, webkit, firefox]) {
		const browser = await browserType.launch();
		const page = await browser.newPage();
		page.on("console", message => console.log(message.text()));
		page.on("pageerror", error => console.error(error));

		await page.goto("http://localhost:3000/");

		await page.evaluate(() => console.log(navigator.userAgent));
		const resultHandle = await page.waitForFunction(() => window["utestResult"]);
		const statsHandle = await resultHandle.getProperty("stats");
		const isOkHandle = await statsHandle.getProperty("isOk");
		const isOk = await isOkHandle.jsonValue();
		if (!isOk) {
			server.close();
			process.exit(1);
		}
	}
	server.close();
	process.exit(0);
});

