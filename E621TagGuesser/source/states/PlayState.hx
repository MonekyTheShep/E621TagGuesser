package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxInputText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import lime.app.Future;
import monosodiumplusplus.MonoSodiumPlusPlus;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.net.URLRequestHeader;
import openfl.utils.ByteArray;
import utility.E6ImageHandler;

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
			E6ImageHandler.getRandomImage(e6image ->
			{
				imageUrl = e6image.url;
			});
		});

		uiCamera = new FlxCamera();
		uiCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(uiCamera, false);
		FlxG.camera.pixelPerfectRender = FlxG.camera.pixelPerfectShake = true;

		// button
		button.screenCenter();
		button.cameras = [uiCamera];
		spr = new FlxSprite();
		// Input field
		var inputField = new FlxInputText(0, 0, 100, "", 10);
		inputField.screenCenter();
		inputField.y = button.y - 30;

		inputField.cameras = [uiCamera];
		inputField.antialiasing = true;

		inputField.callback = function(text, action)
		{
			if (action == "enter")
			{
				trace("Input changed with enter: " + inputField.text);
			}
		};
		add(button);
		add(inputField);
		add(spr);

		E6ImageHandler.getRandomImage(e6image ->
		{
			imageUrl = e6image.url;
		});

	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (imageUrl != "")
		{
			getImageByteData();
		}
	}

	function getImageByteData():Void
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
