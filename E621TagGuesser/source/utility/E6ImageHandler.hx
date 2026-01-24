package utility;

import lime.app.Future;
import monosodiumplusplus.MonoSodiumPlusPlus;


typedef E6Image = {
	var ?url:String;
    var tags:Array<String>;  
}

class E6ImageHandler {
    public static function getRandomImage(onSuccess:(E6Image)->Void) {
        var future = new Future(() ->
		{
			var api:MonoSodiumPlusPlus = new MonoSodiumPlusPlus();

			api.verboseMode = true;

			api.randomPost.setTag("-animated").setTag("pawbert_lynxley").setTag("solo").setTag("rating:safe");

			api.randomPost.search(postData ->
			{
				trace(postData.post.id);
				var e6data:E6Image = {
					tags: postData.post.tags.general
				}
				e6data.url = postData.post.sample.url ?? postData.post.file.url;

				trace("API response completed for:", e6data.url);
				onSuccess(e6data);

				
			}, err -> trace("Error: " + err));
		}, true);

		future.onError((err:Dynamic) ->
		{
			trace("Error", err);
		});
    }
}