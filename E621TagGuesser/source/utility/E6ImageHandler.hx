package utility;

import lime.app.Future;
import monosodiumplusplus.MonoSodiumPlusPlus;


typedef E6Image = {
    var url:String;
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
				if (postData.post.sample.url != null)
				{
					trace("API response completed for:", postData.post.sample.url);
                    var e6data:E6Image = 
                    {
                        url: postData.post.sample.url, 
                        tags: postData.post.tags.general
                    }
					onSuccess(e6data);
				}
				else
				{
					trace("API response completed for:", postData.post.file.url);
					var e6data:E6Image = 
                    {
                        url: postData.post.file.url,
                        tags: postData.post.tags.general
                    }
					onSuccess(e6data);
				}

				
			}, err -> trace("Error: " + err));
		}, true);

		future.onError((err:Dynamic) ->
		{
			trace("Error", err);
		});
    }
}