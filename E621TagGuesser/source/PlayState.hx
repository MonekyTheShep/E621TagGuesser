package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxe.io.Bytes;
import monosodiumplusplus.MonoSodiumPlusPlus;
import monosodiumplusplus.RateLimiter;
import openfl.display.BitmapData;
import openfl.utils.ByteArray;

class PlayState extends FlxState
{
	var spr:FlxSprite;
	var uiCamera:FlxCamera;

	override public function create()
	{
		super.create();
		var button = new FlxButton(0, 0, "Reload", () -> {
			#if js
			// worker for js
			#else
			getImage();
			#end
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

		#if js
		#else
		getImage();
		#end
	}

	function getImage()
	{
		getImageData(data ->
		{
			spr.loadGraphic(BitmapData.fromBytes(data));
			final factor:Float = Math.min(FlxG.width / spr.width, FlxG.height / spr.height);
			spr.scale.set(factor, factor);
			spr.screenCenter();
			spr.antialiasing = true;
		});
	}

	function getImageData(onSuccess:Bytes->Void):Void
	{
		var api:MonoSodiumPlusPlus = new MonoSodiumPlusPlus();

		api.verboseMode = true;
		var url:String;
		var id:Int;
		var tag:String;

		api.randomPost.setTag("-animated").setTag("femboy").setTag("solo").setTag("-ralsei");

		// api.posts.setTag("solo").setTag("femboy").setTag("rating:safe").setLimit(5).setPage(1);

		// api.posts.search(postData ->
		// {
		// 	for (post in postData.posts)
		// 	{
		// 		trace("Post url", post.file.url);
		// 	}
		// }, err -> trace("Error: " + err));

		api.randomPost.search(postData ->
		{
			url = postData.file_url;
			id = postData.id;
			tag = postData.tag_string;
		}, err -> trace("Error: " + err));
		trace(url, id, tag);

		var httpBuilder:HttpBuilder = new HttpBuilder(url);

		httpBuilder.setHeader("User-Agent", "E621TagGuesser/1.0 (by MonekyTheShep on github)");

		try
		{
			httpBuilder.getHttpData(data ->
			{
				onSuccess(data);
			});
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
