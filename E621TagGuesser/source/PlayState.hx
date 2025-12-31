package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxe.io.Bytes;
import monosodiumplusplus.MonoSodiumPlusPlus;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.net.FileReference;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.net.URLRequestHeader;
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
			getUrl(_url ->
			{
				imageUrl = _url;
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

		getUrl(_url ->
		{
			imageUrl = _url;
		});
	}

	function getUrl(onSuccess:String->Void):Void
	{
		sys.thread.Thread.create(() ->
		{
			var api:MonoSodiumPlusPlus = new MonoSodiumPlusPlus();

			api.verboseMode = true;
			var url:String;
			var id:Int;
			var tag:String;

			api.randomPost.setTag("-animated").setTag("pokemon").setTag("solo").setTag("-ralsei");

			api.randomPost.search(postData ->
			{
				url = postData.file_url;
				id = postData.id;
				tag = postData.tag_string;
			}, err -> trace("Error: " + err));

			onSuccess(url);
			trace(url);
		});
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (imageUrl != "")
		{
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.dataFormat = "binary";
			var request:URLRequest = new URLRequest(imageUrl);
			imageUrl = "";
			request.requestHeaders = [
				new URLRequestHeader("User-Agent", "MonoSodiumPlusPlus/1.0 (by MonekyTheShep on github)")
			];
			loader.load(request);
			
		}
	}

	function onComplete(e:Event):Void
	{
		var bytes:ByteArray = loader.data;

		spr.loadGraphic(BitmapData.fromBytes(bytes));
		final factor:Float = Math.min(FlxG.width / spr.width, FlxG.height / spr.height);
		spr.scale.set(factor, factor);
		spr.screenCenter();
		spr.antialiasing = true;
	}
}
