package;

/**
 * Simple API for searching Rule34, doesn't need much explanation
 * 
 * @author Alejo GD Official (@alejogdofficial)
 * 
 * Keep the credits and search for your porn :wink:
 * 
 * @see https://api.rule34.xxx/
 */

import openfl.net.URLLoader;
import openfl.net.URLRequest;

import openfl.display.BitmapData;

import haxe.Json;

class Rule34API
{
    public var key:String;
    public var user_id:String;

    /**
     * Self-Explanatory
     * @param key Your API Key
     * @param id Your User ID
     */
    public function new(key:String, id:String)
    {
        key = key;

        user_id = id;
    }

    public final BASE_URL:String = 'https://api.rule34.xxx/index.php?page=dapi&s=post&q=index&json=1';

    /**
     * Searches for an image and returns the information obtained in JSON
     * @param tags Search tags (For example: `[‘girlfriend_(friday_night_funkin)’, ‘big_ass’]`)
     * @param total Number of images to search for
     */
    public function search(tags:Array<String>, ?total:Int)
    {
        total ??= 1;

        loadRequest(getUrl(tags, total), (data) -> {
            if (onSearchComplete != null)
                onSearchComplete(Json.parse(data));
        });
    }

    /**
     * Searches for an image and returns a BitmapData
     * @param tags Search tags (For example: `[‘girlfriend_(friday_night_funkin)’, ‘big_ass’]`)
     * @param total Number of images to search for
     * @param pos Position of the image in the array of searched objects
     */
    public function searchGraphic(tags:Array<String>, ?total:Int, ?pos:Int):BitmapData
    {
        total ??= 1;

        pos = Math.max(Math.min(pos ?? 0, total), 0);

        loadRequest(getUrl(tags, total), (data) -> {
            loadRequest(Json.parse(data)[pos].file_url, (bytes) -> {
                if (onSearchGraphicComplete != null)
                    onSearchGraphicComplete(BitmapData.fromBytes(bytes));
            }, 0);
        });
    }

    /**
     * Helps create a URL for requests
     * @param tags Search tags (For example: `[‘girlfriend_(friday_night_funkin)’, ‘big_ass’]`)
     * @param total Number of images to search for
     */
    public function getUrl(tags:Array<String>, ?total:Int)
    {
        total ??= 1;

        return BASE_URL +
            '&tags=' + tags.join('%20') +
            '&limit=' + total +
            '&user_id=' + user_id +
            '&api_key=' + key;
    }

    /**
     * Set of Optional Callbacks for Each Function
     */
    
    public var onSearchComplete:Dynamic -> Void;

    public var onSearchGraphicComplete:FlxGraphic -> Void;

    public var onError:String -> Void;

    /**
     * A little help to create requests faster
     * @param url URL for the request
     * @param onComplete Callback for when the request is loaded
     * @param format Callback Format
     */
    private function loadRequest(url:String, onComplete:Dynamic -> Void, ?format:URLLoaderDataFormat)
    {
        final loader:URLLoader = new URLLoader();
        loader.dataFormat = format ?? 1;

        loader.addEventListener('complete', (e) -> {
            try
            {
                onComplete(loader.data);
            } catch(e:Dynamic) {
                if (onError != null)
                    onError(e);
            }
        });

        loader.addEventListener('ioError', (e) -> {
            if (onError != null) 
                onError(e);
        });

        loader.load(new URLRequest(url));
    }
}