const http = require('https');
const { exec } = require('child_process');

const checks = {
	'76561198053559858': 'Yoh Sambre',
	
};

const data = '?key=APIKEY&include_appinfo=1&include_played_free_games=1';

var http_options = {
	host: 'api.steampowered.com',
	headers: {
		'User-Agent': 'DOKI-DOKI CHECKER',
		'Connection': 'keep-alive',
		'Cookie': ''
	}
};

// <url> [data] <callback>
function http_request(urlPath, callback, data="") {
	if (typeof callback === 'string') {
		let transition = callback;
		callback = data;
		data = transition;
	}
	http_options['path'] = urlPath;
	if (data == '') {
		http_options['method'] = 'GET';
		http_options['headers']['Content-Type'] = 'text/html; charset=UTF-8';
		if ( http_options['headers']['Content-Length'] )
			delete http_options['headers']['Content-Length'];
	} else {
		http_options['method'] = 'POST';
		http_options['headers']['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8';
		http_options['headers']['Content-Length'] = data.length;
	}
	let request = http.request(http_options, (res) => {
		res.setEncoding('utf8');

		var body = '';

		res.on('data', (chunk) => {
			body += chunk;
		});

		res.on('end', () => {
			if (typeof callback === 'function')
				callback(res, body);
		});
	});
	if (data != '') {
		request.write(data);
	}
	request.end();
}

function checkGames(gamelist) {
	for (let i = 0; i < gamelist.length; ++i) {
		if (gamelist[i].appid == 698780) {
			return true;
		}
	}

	return false;
}

setInterval(() => {

	for (let steamid in checks) {
		http_request('/IPlayerService/GetOwnedGames/v1' + data + '&steamid=' + steamid, (_, body) => {
			body = JSON.parse(body);

			if (checkGames(body['response']['games'])) {
				console.log('OMAGAD ' + checks[steamid] + ' IS ONE OF US');
				exec('C:\\Users\\Maks\\Games\\MusicBee\\MusicBee.exe /Play "C:\\Users\\Maks\\dokidoki_checker\\sound\\lucky.mp3"',
					(error, stdout, stderr) => {

					if (error)
						throw error;
				});
			} else
				console.log('Umf, ' + checks[steamid] + ' is a moron');
		});
	}

}, 600000); // every 10m
