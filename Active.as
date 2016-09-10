package  {
	
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.utils.getDefinitionByName;
	
	public class Active extends Sprite
	{
		private const VELOCITY_X_MAX:Number = 10;
		private const VELOCITY_Y_MAX:Number = 100;
		
		private var type:String;
		
		private var actions:Array;
		private var actionMCs:Array;
		
		private var currentAction:String;
		private var currentMC:MovieClip;
		
		private var stance:int;
		private var velocity:Array;

		public function Active (defaultType:String, defaultAction:String = "still") : void
		
		{
			// Pass parameters
			type = defaultType;
			
			addAction (defaultAction, true);
			
			// Initialize
			setStance (1);
			velocity = new Array (0, 0);
		}
		
		private function addAction (newAction:String, setBoolean:Boolean = false) : void
		{
			if (!actions) actions = new Array ();
			if (!actionMCs) actionMCs = new Array ();
			
			actions.push (newAction);
			
			var actionClass:Class = getDefinitionByName(type + "_" + newAction) as Class;
			actionMCs.push (new actionClass ());
			
			if (setBoolean) setAction (newAction);
		}
		
		public function setStance (newStance:int) : void
		{
			if (Math.abs (newStance) == 1) {
				stance = newStance;
				scaleX = stance;
			}
		}
		
		public function setAction (newAction:String) : void
		{
			if (currentMC) removeChild (currentMC);
			
			var id = actions.indexOf (newAction);
			
			currentAction = actions[id];
			currentMC = actionMCs[id];
			
			addChild (currentMC);
			
		}
		
		public function setVelX (newVelX:Number) : void
		{
			velocity[0] = newVelX;
		}
		public function setVelY (newVelY:Number) : void
		{
			velocity[1] = newVelY;
		}
		
		public function accelerate (accelX:Number = 0, accelY:Number = 0) : void
		{
			// Accelerate X velocity in the direction of stance
			if (accelX > 0) {
				if ((stance == 1 && velocity[0] + stance * accelX > VELOCITY_X_MAX) || (stance == -1 && velocity[0] + stance * accelX < -VELOCITY_X_MAX)) {
					velocity[0] = stance * VELOCITY_X_MAX;
				} else {
					velocity[0] += stance * accelX;
				}
			} else if (accelX < 0) {
				if ((stance == 1 && velocity[0] + stance * accelX < 0) || (stance == -1 && velocity[0] + stance * accelX > 0)) {
					velocity[0] = 0;
				} else {
					velocity [0] += stance * accelX;
				}
			}
			
			if ((accelY > 0 && velocity[1] + accelY < VELOCITY_Y_MAX) || (accelY < 0 && velocity[1] + accelY > -VELOCITY_Y_MAX)) {
				velocity[1] += accelY;
			}
		}
		
		
		
		public function getVel () : Array
		{
			return velocity;
		}
		
		public function getStance () : int
		{
			return stance;
		}

	}
	
}
