package  {
	
	import flash.display.Sprite;
	
	public class Main extends Sprite
	{
		
		//
		//// Constructor
		public function Main()
		{
			// constructor code
			var testArea = new Area ("test");
			
			var testEngine = new Engine (testArea);
			
			addChild (testEngine);
		}

	}
	
}
