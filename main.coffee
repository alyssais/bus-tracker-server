app = require("express.io")()

fs = require "fs"
async = require "async"
request = require "request"

services = fs.readFileSync("services.txt").toString().trim().split("\n")

app.http().io()
app.listen(process.env.PORT or 4567)

updateVehicles = (done) ->
  async.eachLimit services, 5, (service, done) ->
    request "http://tfeapp.com/3.3/vehicle_positions_by_service?service_name=#{service}", (error, request, body) ->
      return if error
      for vehicle in JSON.parse body
        console.log(service)
        app.io.broadcast("bus", vehicle)
      done()
  , -> setTimeout updateVehicles, 10e3

updateVehicles()
