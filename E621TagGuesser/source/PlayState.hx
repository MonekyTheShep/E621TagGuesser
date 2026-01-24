package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import lime.app.Future;
import monosodiumplusplus.MonoSodiumPlusPlus;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.utils.ByteArray;

class PlayState extends FlxState
{
	var spr:FlxSprite;
	var uiCamera:FlxCamera;
	var loader:URLLoader = new URLLoader();
	var imageUrl:String = "";

	override public function create()
	{
		super.create();
		var button = new FlxButton(0, 0, "Reload", () ->
		{
			getUrl(url ->
			{
				imageUrl = url;
			});
		});

		uiCamera = new FlxCamera();
		uiCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(uiCamera, false);
		FlxG.camera.pixelPerfectRender = FlxG.camera.pixelPerfectShake = true;

		button.screenCenter();
		button.cameras = [uiCamera];
		spr = new FlxSprite();
		add(button);
		add(spr);

		getUrl(url ->
		{
			imageUrl = url;
		});
	}

	function getUrl(onSuccess:String->Void):Void
	{
		var future = new Future(() ->
		{
			var api:MonoSodiumPlusPlus = new MonoSodiumPlusPlus();

			api.verboseMode = true;
			var url:String;

			api.randomPost.setTag("-animated").setTag("pawbert_lynxley").setTag("solo").setTag("rating:safe");

			api.randomPost.search(postData ->
			{
				trace(postData.post.id);
				if (postData.post.sample.url != null)
				{
					trace("API response completed for:", postData.post.sample.url);
					onSuccess(postData.post.sample.url);
				}
				else
				{
					trace("API response completed for:", postData.post.file.url);
					onSuccess(postData.post.file.url);
				}

				
			}, err -> trace("Error: " + err));

			// return url;
		}, true);

		// future.onComplete((url) ->
		// {

		// });
		future.onError((err:Dynamic) ->
		{
			trace("Error", err);
		});
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (imageUrl != "")
		{
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			var request:URLRequest = new URLRequest(imageUrl);
			imageUrl = "";
			// cant set user agent on js platform
			#if !js
			request.requestHeaders = [
				new URLRequestHeader("User-Agent", "MonoSodiumPlusPlus/1.0 (by MonekyTheShep on github)")
			];
			#end
			loader.load(request);
			
		}
	}

	function onComplete(e:Event):Void
	{

		var bytes:ByteArray = loader.data;

		var bitmapData = BitmapData.loadFromBytes(bytes);
		bitmapData.onComplete((image) ->
		{
			spr.loadGraphic(image);
			final factor:Float = Math.min(FlxG.width / spr.width, FlxG.height / spr.height);
			spr.scale.set(factor, factor);
			spr.screenCenter();
			spr.antialiasing = true;
		});
		

	}
}
