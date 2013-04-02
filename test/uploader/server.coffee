#!/usr/bin/env coffee

#Err... sorry for the monkey patching ;-)
String.prototype.repeat = String.prototype.repeat or (times) ->
  (@ for n in [1..times]).join('')

   
###
try
  Router = require 'node-simple-router'
catch e
  Router = require '../lib/router'
###

Router = require '../../src/router'

http = require 'http'
router = Router(list_dir: true)
#
#Example routes
#

router.post "/upload", (req, res) ->
  res.writeHead(200, {'Content-type': 'text/html'})
  res.end """
	  <script type="text/javascript">
	    alert("Upload successful!");
	    history.back();
	  </script>'
	  """ 
  ###
  router.log "Someone is trying to upload something"
  
  for key, val of req.post
    console.log "@#{key.toUpperCase().replace('\n', '#')}@ === #{val.replace('\n','|')}"
    console.log "\n\n\n"
  ###
  router.log "Request IP: #{req.connection.remoteAddress}"
  router.log "Request URL: #{req.url}"
  router.log "Request headers:\n#{JSON.stringify req.headers}\n\n"
  router.log "Request content-type: #{req.headers['content-type']  or 'content-type not found'}"
  router.log "#".repeat 20
  router.log "Raw Request data:"
  router.log "=".repeat 100
  router.log JSON.stringify req.post
  router.log "=".repeat 100
  router.log "Request data:"
  router.log "=".repeat 100
  body = ""
  for key, val of req.post
    body += val
  for line in body.split('\r\n')
    router.log line
    router.log "#".repeat 20
  router.log "=".repeat 100
    
#
#End of example routes
#



#Ok, just start the server!

argv = process.argv.slice 2

server = http.createServer router

server.on 'listening', ->
  addr = server.address() or {address: '0.0.0.0', port: argv[0] or 8000}
  router.log "Serving web content at " + addr.address + ":" + addr.port  

process.on "SIGINT", ->
  server.close()
  router.log ' '
  router.log "Server shutting up..."
  router.log ' '
  process.exit 0

server.listen if argv[0]? and not isNaN(parseInt(argv[0])) then parseInt(argv[0]) else 8000
