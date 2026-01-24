package;

import haxe.Http;
import haxe.io.Bytes;

class HttpBuilder {
    
    var url:String;

    var params = new Map<String, String>();
    var header = new Map<String, String>();

    public function new(url:String) {
        this.url = url;
    }

    public function getHttpData(onResult:Bytes->Void):Void {

        var haxeHTTP:Http = new Http(url);

        for (name => value in params) {
            haxeHTTP.setParameter(name, value);
        }

        for (headerName => value in header) {
            haxeHTTP.setHeader(headerName, value);
        }


        haxeHTTP.onBytes = function(data:Bytes) {
            onResult(data);
        }

		haxeHTTP.onError = function(err:Dynamic)
		{

            trace("Error: " + err);
            
        };

        haxeHTTP.onStatus = function(status:Int) {

            trace("Status Code: " + status);
            
        };

        haxeHTTP.request(false);
        
    }

    public function setParam(name:String, value:String):HttpBuilder {
        this.params[name] = value;
        return this;
    }

    public function setHeader(header:String, value:String):HttpBuilder {
        this.header[header] = value;
        return this;
    }
}