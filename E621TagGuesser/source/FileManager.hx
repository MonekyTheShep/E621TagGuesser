package;

import flixel.graphics.FlxGraphic;
import haxe.io.Bytes;
import sys.io.File;

class FileManager {
    
    public var data:Bytes;
    public var path:String;
    public var filename:String;

    public function new(data:Bytes, path:String, filename:String) {
        this.data = data;
        this.path = path;
        this.filename = filename;
    }

	public function write()
	{    
        try {
			File.saveBytes(this.path + '/$filename', this.data);
        } 
        catch (e:Dynamic) {
            trace("Error: " + e);
        }
        
    }

}