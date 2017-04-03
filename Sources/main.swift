//
//  main.swift
//  HTTPSTest
//
//  Created by Jonathan Guthrie on 2017-04-03.
//	Copyright (C) 2017 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2017 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

// This 'handler' function serves port 80.
func handler80(data: [String:Any]) throws -> RequestHandler {
	return {
		request, response in
		response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world! Port 80</body></html>")
		// Ensure that response.completed() is called when your processing is done.
		response.completed()
	}
}

// This 'handler' function serves port 443.
func handler443(data: [String:Any]) throws -> RequestHandler {
	return {
		request, response in
		response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world! Port 443</body></html>")
		response.completed()
	}
}



let confData = [
	"servers": [
		// Serves Port 80
		[
			"name":"localhost",
			"port":80,
			"routes":[
				["method":"get", "uri":"/", "handler":handler80],
				["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.staticFiles,
				 "documentRoot":"./webroot",
				 "allowResponseFilters":true]
			],
			"filters":[
				[
				"type":"response",
				"priority":"high",
				"name":PerfectHTTPServer.HTTPFilter.contentCompression,
				]
			]
		],
		// Serves Port 443.
		[
			"name":"localhost",
			"port":443,
			"routes":[
				["method":"get", "uri":"/", "handler":handler443],
				["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.staticFiles,
				 "documentRoot":"./webroot",
				 "allowResponseFilters":true]
			],
			"filters":[
				[
					"type":"response",
					"priority":"high",
					"name":PerfectHTTPServer.HTTPFilter.contentCompression,
					]
			],
			"tlsConfig":[
				"certPath": "/etc/letsencrypt/live/test1.iamjono.io/fullchain.pem",
				"verifyMode": "peer",
				"keyPath": "/etc/letsencrypt/keys/0000_key-certbot.pem"
			]
		]
	]
]


do {
	// Launch the servers based on the configuration data.
	try HTTPServer.launch(configurationData: confData)
} catch {
	fatalError("\(error)") // fatal error launching one of the servers
}

