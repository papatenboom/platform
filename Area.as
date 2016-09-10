package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.utils.getDefinitionByName;
	
	public class Area extends Sprite
	{
		
		private var areaTitle:String;
		
		// Position
		private var offsetX:Number;
		private var offsetY:Number;
		
		// Layers
		private var testLayer:MovieClip;
		
		private var topLayer:MovieClip;
		private var bottomLayer:MovieClip;
		
		
		//
		//// Constructor
		public function Area (defaultTitle:String) : void
		{
			// Pass parameters
			areaTitle = defaultTitle;
			
			// Test layer
			var testLayerClass:Class = getDefinitionByName(areaTitle + "_test") as Class;
     		testLayer = new testLayerClass ();
			
			// Top layer
			var topLayerClass:Class = getDefinitionByName(areaTitle + "_top") as Class;
     		topLayer = new topLayerClass ();
			
		}
		
		public function getTestLayer () : MovieClip
		{
			return testLayer;
		}

	}
	
}
