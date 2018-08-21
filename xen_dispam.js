const rl = require("readline");
const readline = rl.createInterface({
	input: process.stdin,
	output: process.stdout
});
var http;

var http_options = {
	headers: {
		"User-Agent": "Maks reacts script",
		"Connection": "keep-alive",
		"Cookie": ""
	}
};
var type = 11; // default reaction on INFO
var time = 0;
var reactData = "";
var delay = 50;
var uri = "";

async function question(str) {
	return new Promise((resolve, reject) => {
		readline.question(str, (ans) => {
			resolve(ans);
		});
	});
}

// <url> [data] <callback>
function http_request(urlPath, callback, data="") {
	if ( typeof callback === "string" ) {
		let transition = callback;
		callback = data;
		data = transition;
	}
	http_options["path"] = uri + urlPath;
	if ( data == "" ) {
		http_options["method"] = "GET";
		http_options["headers"]["Content-Type"] = "text/html; charset=UTF-8";
		if ( http_options["headers"]["Content-Length"] )
			delete http_options["headers"]["Content-Length"];
	} else {
		http_options["method"] = "POST";
		http_options["headers"]["Content-Type"] = "application/x-www-form-urlencoded; charset=UTF-8";
		http_options["headers"]["Content-Length"] = data.length;
	}
	let request = http.request(http_options, (res) => {
		res.setEncoding("utf8");

		var body = "";

		res.on("data", (chunk) => {
			body += chunk;
		});

		res.on("end", () => {
			if ( typeof callback === "function" )
				callback(res, body);
		});
	});
	if ( data != "" ) {
		request.write(data);
	}
	request.end();
}

// <url to message> <data> <type (2:Like, 3:Dislike, 4:Agree, 6:Disagree)>
function react(url) {
	let RegPost = /\d+\/post-(\d+)/;
	let RegProfile = /posts\/(\d+)/;
	let RegComment = /\/comments\/(\d+)/;
	if (type === 502) {
		if ( url.search(/\/comments\//) > 0 ) { // comment on profile post
			http_request("profile-posts/comments/" + RegComment.exec(url)[1] + "/like", reactData);
		} else if ( url.search(/\/profile-posts\//) > 0 ) { // profile post
			http_request("profile-posts/" + RegProfile.exec(url)[1] + "/like", reactData);
		} else if ( url.search(/\/threads\/(?:.+?\.\d+|\d+)\/$/) === -1 ) { // post
			http_request("posts/" + RegPost.exec(url)[1] + "/like", reactData);
		}
	} else if (type === 404) {
		if ( url.search(/\/comments\//) > 0 ) { // comment on profile post
			http_request("reactions/unreacts/profile_post_comment/" + RegComment.exec(url)[1], reactData);
		} else if ( url.search(/\/profile-posts\//) > 0 ) { // profile post
			http_request("reactions/unreacts/profile_post/" + RegProfile.exec(url)[1], reactData);
		} else if ( url.search(/\/threads\/(?:.+?\.\d+|\d+)\/$/) === -1 ) { // post
			http_request("reactions/unreacts/post/" + RegPost.exec(url)[1], reactData);
		}
	} else {
		if ( url.search(/\/comments\//) > 0 ) { // comment on profile post
			http_request("reactions/react/profile_post_comment/" + RegComment.exec(url)[1] + '/' + type, reactData);
		} else if ( url.search(/\/profile-posts\//) > 0 ) { // profile post
			http_request("reactions/react/profile_post/" + RegProfile.exec(url)[1] + '/' + type, reactData);
		} else if ( url.search(/\/threads\/(?:.+?\.\d+|\d+)\/$/) === -1 ) { // post
			http_request("reactions/react/post/" + RegPost.exec(url)[1] + '/' + type, reactData);
		}
	}
}

function loopPost(body) {
	let reg = /<h3 class="contentRow-title">\s*?<a href="(.+?)">/gs;
	if ( reactData === "" )
		reactData = "_xfRequestUri=%2Fforums%2Fthreads%2F&_xfResponseType=json&_xfWithData=1&_xfToken=" + encodeURIComponent(/name="_xfToken" value="(.+?)"/.exec(body)[1]);
	let match;
	do {
		match = reg.exec(body);
		if (match) {
			let keepMatch = match[1];
			setTimeout(() => { // Seems like spamming REALLY HARD isn't allowed
				console.log(keepMatch);
				react(keepMatch);
			}, time);
			time += delay;
		}

	} while (match);
}

function listPost(url) {
	http_request(url, (res, body) => {
		if ( !res.headers["location"] )
			return;
		let searchURL = res.headers["location"].replace(RegExp("^https?://(?:www\.)?[a-zA-Z-_]+?\.[a-zA-Z]{2,4}" + uri), "");
		for (let i = 1; i <= 10; i++) {
			http_request(searchURL, (res, body) => {
				loopPost(body);
					let RegButton = /<a href=".+?\/(search\/\d+\/older\?before=\d+)"/s;
					let match = RegButton.exec(body);
					if (match && match[1]) {
						listPost(match[1]);
					}
			});
		}
	});
}

function login(username, password, callback) {
	http_request("login/login", (res, body) => {
		let reg = /(.+?)=(.+?);/;
		for ( let header of res.headers["set-cookie"] ) {
			let cookie = reg.exec(header);
			http_options["headers"]["Cookie"] += cookie[1] + '=' + cookie[2] + ';';
		}
		http_options["headers"]["Cookie"] = http_options["headers"]["Cookie"].slice(0, -1);

		let xfTokenReg = /name="_xfToken" value="(.+?)"/
		if (body.search(xfTokenReg) === -1) {
			console.log("Error getting csrf token, dumping body :\n", body);
			return;
		}

		let data = "remember=1&ct_checkjs=2018&_xfToken=" + encodeURIComponent(xfTokenReg.exec(body)[1])
			+ "&login=" + encodeURIComponent(username)
			+ "&password=" + encodeURIComponent(password);

		http_request("login/login", data, (res, body) => {

			http_options["headers"]["Cookie"] += ";";
			if (!res.headers["location"]) {
				console.log("Invalid password or username");
				readline.close();
				process.exit();
			}
			for ( let header of res.headers["set-cookie"] ) {
				let cookie = reg.exec(header);
				http_options["headers"]["Cookie"] += cookie[1] + '=' + cookie[2] + ';';
			}
			http_options["headers"]["Cookie"] = http_options["headers"]["Cookie"].slice(0, -1);
			callback();
		});
	});
}

async function start(webURL) {
	if ( !/^https?:\/\/(?:www\.)?[a-zA-Z-_]+?\.[a-zA-Z]{2,4}/.test(webURL) ) {
		console.log("Give me a real URL please");
		readline.close();
		process.exit();
	}
	
	http_options["host"] = /https?:\/\/((?:www\.)?[a-zA-Z-_]+?\.[a-zA-Z]{2,4})/.exec(webURL)[1];
	uri = /^https?:\/\/(?:www\.)?[a-zA-Z-_]+?\.[a-zA-Z]{2,4}(.*)/.exec(webURL)[1];
	if ( uri.slice(-1) !== "/" )
		uri += "/";
	http = require(/^(https?)/.exec(webURL)[1]);

	let username = await question("Username: ");
	let password = await question("Password: ");
	login(username, password, async function() {
		let victim = await question("URL of profile to react: ");

		if ( !victim.startsWith(/^(https?)/.exec(webURL)[1] + "://" + http_options["host"] + uri + "members/") ) {
			console.log("Be smart. Thanks.");
			readline.close();
			process.exit();
		}

		let yesno = await question("Does the website have Reactions addon? (Y/N): ");
		if (yesno === 'Y') {
			let answer = await question("Like (Y) Dislike (N) Unreact (R) Disagree (X) Agree (A) or a number\n> ");
			if ( isNaN(answer) ) {
				switch (answer) {
					case 'Y':
						type = 2;
						break;
					case 'N':
						type = 3;
						break;
					case 'R':
						type = 404;
						break;
					case 'X':
						type = 6;
						break;
					case 'A':
						type = 4;
						break;
				}
			} else if ( answer = parseInt(answer) && answer > 0 && answer < 18 )
				type = answer;
		} else
			type = 502;
		let del = await question("Delay between each reaction (Default: 50)\n> ");
		if ( !isNaN(del) )
			delay = parseInt(del);
		listPost("search/member?user_id=" + victim.match(/\/members\/.+?\.(\d+)\//)[1]);
		readline.close();
	});
}

question("Website url (with http(s)://): ").then(start);
