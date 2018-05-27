const http = require("https");
const rl = require("readline");
const readline = rl.createInterface({
	input: process.stdin,
	output: process.stdout
});

var http_options = {
	host: "www.mtxserv.fr",
	headers: {
		"User-Agent": "Just spamming dislike, don't worry",
		"Connection": "keep-alive",
		"Cookie": ""
	}
};
var type = 11; // default reaction on INFO

// <url> [data] <callback>
function http_request(urlPath, callback, data="") {
	if ( typeof callback === "string" ) {
		let transition = callback;
		callback = data;
		data = transition;
	}
	http_options["path"] = urlPath;
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
function react(url, data) {
	let RegPost = /\.\d+\/post-(\d+)/;
	let RegProfile = /posts\/(\d+)/;
	let RegComment = /\/comments\/(\d+)/;
	if ( url.search(/\/comments\//) > 0 ) { // comment on profile post
		http_request("/forums/reactions/react/profile_post_comment/" + RegComment.exec(url)[1] + '/' + type, data);
	} else if ( url.search(/\/profile-posts\//) > 0 ) { // profile post
		http_request("/forums/reactions/react/profile_post/" + RegProfile.exec(url)[1] + '/' + type, data);
	} else { // post
		http_request("/forums/reactions/react/post/" + RegPost.exec(url)[1] + '/' + type, data);
	}
}

function loopPost(body) {
	let reg = /<h3 class="contentRow-title">\s*?<a href="(.+?)">/gs;
	let data = "_xfRequestUri=%2Fforums%2Fthreads%2F&_xfResponseType=json&_xfWithData=1&_xfToken=" + encodeURIComponent(/name="_xfToken" value="(.+?)"/.exec(body)[1]);
	let time = 0;
	let match;
	do {
		match = reg.exec(body);
		if (match) {
			let keepMatch = match[1];
			setTimeout(() => { // Seems like spamming REALLY HARD isn't allowed
				console.log(keepMatch);
				react(keepMatch, data);
			}, time);
			time += 100;
		}

	} while (match);
}

function listPost(url) {
	let reg = /members\/.+?(\d+)/;
	let userID = url.match(reg)[1];
	http_request("/forums/search/member?user_id=" + userID, (res, body) => {
		let searchURL = res.headers["location"].replace("https://www.mtxserv.fr", "");
		http_request(searchURL, (res, body) => {
			// mettre ici une boucle pour chaque page
			loopPost(body);
		});
	});
}

function login(username, password, callback) {
	http_request("/forums/login/login", (res, body) => {
		let reg = /(.+?)=(.+?);/;
		for ( let header of res.headers["set-cookie"] ) {
			let cookie = reg.exec(header);
			http_options["headers"]["Cookie"] += cookie[1] + '=' + cookie[2] + ';';
		}
		http_options["headers"]["Cookie"] = http_options["headers"]["Cookie"].slice(0, -1);

		data = "remember=1&ct_checkjs=2018&_xfToken=" + encodeURIComponent(/name="_xfToken" value="(.+?)"/.exec(body)[1])
			+ "&login=" + encodeURIComponent(username)
			+ "&password=" + encodeURIComponent(password);

		http_request("/forums/login/login", data, (res, body) => {

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

readline.question("Username: ", (username) => {
	readline.question("Password: ", (password) => {
		login(username, password, () => {
			readline.question("URL of profile to react: ", (victim) => {
				if ( !victim.startsWith("https://www.mtxserv.fr/forums/members/") )
					console.log("Merci d'être intelligent");
				else {
					readline.question("Like (Y) Dislike (N) Angry (G) Disagree (X) Agree (A) or a number\n", (answer) => {
						if ( isNaN(answer) ) {
							switch (answer) {
								case 'Y':
									type = 2;
									break;
								case 'N':
									type = 3;
									break;
								case 'G':
									type = 8;
									break;
								case 'X':
									type = 6;
									break;
								case 'A':
									type = 4;
									break;
							}
						} else if ( answer = parseInt(answer) && answer > 0 && answer < 18 ) {
							type = answer;
						}
						listPost(victim);
						readline.close();
					});
				}
			});
		});
	});
});