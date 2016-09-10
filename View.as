package  {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class View {
		
		/// Constants
		static const MODE_CENTER:String = "center";
		static const MODE_FOLLOW:String = "follow";
		
		// Current focus mode
		private var currentMode:String = MODE_FOLLOW;
		
		// 
		private var currentDisplay:Sprite;
		private var currentFocus:DisplayObject;

		// Display position
		private var displayX:Number;
		private var displayY:Number;
		
		
		//
		//// Constructor
		public function View (defaultDisplay:Sprite, defaultFocus:DisplayObject = null)
		{
			
			// Pass parameters
			setDisplay (defaultDisplay, defaultFocus);
		}
		
		public function setDisplay (newDisplay:Sprite, newFocus:DisplayObject = null) : void
		{
			currentDisplay = newDisplay;
			setFocus (newFocus);
			
			currentDisplay.addEventListener (Event.ADDED_TO_STAGE, initCenter);
		}
		
		public function setFocus (newFocus:DisplayObject) : void
		{
			currentFocus = newFocus;
		}
		
		public function update () : void
		{
			// Current the focus position is set to the center of the Stage
			var centerX:Number = currentDisplay.stage.stageWidth / 2;
			var centerY:Number = currentDisplay.stage.stageHeight / 2;
			
			// Focus position
			var focusX:Number, focusY:Number;
			
			// Viscocity for follow mode
			var visc:Number = 10;
			
			
			// Determine focus position
			if (!currentFocus) {
				focusX = currentDisplay.width / 2 + currentDisplay.getBounds (currentDisplay).x;
				focusY = currentDisplay.height / 2 + currentDisplay.getBounds (currentDisplay).y;
			} else {
				focusX = currentFocus.x
				focusY = currentFocus.y - currentFocus.height / 2;
			}
			
			// Update display's position
			if (currentMode == MODE_CENTER) {
				currentDisplay.x = centerX - focusX;
				currentDisplay.y = centerY - focusY;
				
			} else if (currentMode == MODE_FOLLOW) {
				currentDisplay.x += int ((centerX - (currentDisplay.x + focusX)) / visc);
				currentDisplay.y += int ((centerY - (currentDisplay.y + focusY)) / visc);  
			
			}
		}
		
		private function initCenter (Event) : void
		{
			var defMode = currentMode;
			
			currentMode = MODE_CENTER;
			
			update ();
			
			currentMode = defMode;
		}

	}
	
}
