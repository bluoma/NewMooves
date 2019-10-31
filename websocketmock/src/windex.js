const WebSocket = require('ws')
const term = require('terminal-kit').terminal
const merge = require('deepmerge')
const utils = require('./utils')
const stdinParse = require('./stdin').stdinParse

function WSS (db, port) {
  this.run = function () {
    // start server
    
    let httpListener = function() {
    	console.log(`\nListening on localhost:${port}`)
    	console.log(`Press ctrl-c to exit`)
    	console.log('server Adddress: %o', wss.address())
    }
    
    const wss = new WebSocket.Server({ port: port }, httpListener)
    

    // send data through socket
    let sendConnectData = function (ws, req) {
      let res
      
			// clear cache, require should always run again to detect file changes
				// or random stuff
			delete require.cache[require.resolve(db)]
			res = require(db)
			// input file response
			req.url.split('/').forEach(p => { 
				if (p) { 
					res = res[p] 
				} 
			})
			

      console.log('\n\nSending:\n')
      term.green(JSON.stringify(res, 4, 2))
      ws.send(JSON.stringify(res))
      
    }
    
    // send data through socket
    let sendMessageData = function (ws, path, message) {
      let res
      
			// clear cache, require should always run again to detect file changes
				// or random stuff
			delete require.cache[require.resolve(db)]
			res = require(db)
			// input file response
			path.split('/').forEach(p => { 
				if (p) { 
					res = res[p] 
				} 
			})
			//let stringified = JSON.stringify(res)
			//let base64 = Buffer.from(stringified, 'base64').toString()
			message.body = res
			
      console.log('\n\nSending:\n')
      term.green(JSON.stringify(message, 4, 2))
      ws.send(JSON.stringify(message))
      console.log('\n')

    }

		wss.on('close', function closed() {
			console.log("onClose")
		})
		wss.on('error', function err(error) {
			console.log("onError")
			console.log(error)
		})
		wss.on('headers', function connectionResponseHeaders(headers, req) {
			console.log("onHeaders")
			console.log(headers)
		})
    wss.on('connection', function connection (ws, req) {
      term.brightCyan('\nonConnection: ', req.url)
			console.log('\n')
			console.log('onConnection Method:', req.method)
    	console.log('onConnection Headers: %o', req.headers)
			
			let data = [];   

			req.on('error', (err) => {
        // This prints the error message and stack trace to `stderr`.
      	console.error(err.stack)
    	})

    	req.on('data', (chunk) => {
        data.push(chunk)
    	})
    
    	req.on('end', () => {
        data = Buffer.concat(data).toString()
        // at this point, `data` has the entire request body stored in it as a string
        console.log("\nonConnection reqBody: %s\n", data)
    	});
			
			/*
			 	let messageId: String
    		let messageTimeStamp: Date
    		let messageResource: String
    		let messageBody: Data?
			*/
			
      ws.on('message', function incoming (jmessage) {
        term.brightCyan('\nonMessage: ', jmessage)
        console.log('\n')
        try {
        	const message = JSON.parse(jmessage)
        	console.log('id: %s, timestamp: %s, resource: %s', message.id, message.timeStamp, message.resource)
        	const resourceURL = new URL(message.resource) 
        	const path = resourceURL.pathname
        	
        	sendMessageData(ws, path, message)
        }
        catch (err) {
        	console.error(err)
        }
        
        
      })
      
      ws.on('ping', function inping (message) {
        console.log('ws received ping: %s', message)
      })
      
      ws.on('pong', function inpong (message) {
        console.log('ws received pong: %s', message)
      })
      
      //console.log(ws)


      // send data on connection
      //sendConnectData(ws, req)

      // read from stdin
      /*
      var stdin = process.openStdin()
      stdin.addListener('data', function (d) {
        let data = stdinParse(d)
        sendData(ws, req, data)
      })
      */
    })
  }
}

module.exports = WSS
