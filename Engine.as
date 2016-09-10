package  {
	
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	public class Engine extends Sprite
	{
		/// Constants
		private const STATE_PAUSE = "pause";
		private const STATE_RUN = "run";
		
		private const KEY_PAUSE:Number = 81;
		private const KEY_TRACE:Number = 69;
		
		private const KEY_LEFT:Number = 65;
		private const KEY_RIGHT:Number = 68;
		private const KEY_JUMP:Number = 32;
		
		private const ACCEL_GRAVITY:int = 4;
		private const ACCEL_RUN:int = 1;
		
		// 
		private var currentState:String;
		
		// 
		private var camera:View;
		
		// Controls
		private var keyLeft:Boolean;
		private var keyRight:Boolean;
		private var keyJump:Boolean;
	
		// View displays & focus
		private var display:Sprite;
		private var pauseDisplay:Sprite;
		
		private var currentFocus:DisplayObject;
		
		private var areas:Array;
		private var currentArea:Area;
		
		private var currentTestArea:MovieClip;
		
		private var actives:Array;
		
		private var currentPC:Active;
		
		private var ground:Boolean;
		private var jumpCount:uint;
		private var jumpKeyUp:Boolean = true;
		
		private var wall:int;
		
		//
		//// Constructor
		public function Engine (defaultArea:Area) : void
		{
			/// Testing -  build test area & actives
			
			// Set default display area
			addArea (defaultArea, true);
			
			currentPC = new Active ("test");
			addActive (currentPC, 200, -100, true);
			//addActive (new Active ("test"), 100, -200);
			
			/// Events
			addEventListener (Event.ENTER_FRAME, update);
			addEventListener (Event.ADDED_TO_STAGE, config);
		}
		
		//
		//// EVENT - ADDED_TO_STAGE
		private function config (Event) : void
		{
			// Draw pause display
			pauseDisplay = new Sprite ();
			pauseDisplay.graphics.lineStyle (0);
			pauseDisplay.graphics.beginFill (0x000000, .2);
			pauseDisplay.graphics.lineTo (stage.stageWidth, 0);
			pauseDisplay.graphics.lineTo (stage.stageWidth, stage.stageHeight);
			pauseDisplay.graphics.lineTo (0, stage.stageHeight);
			pauseDisplay.graphics.lineTo (0, 0);
			
			// Setup the display & add to screen
			display = new Sprite ();
			addChild (display);
			
			// Update display
			update (Event);
			
			// Create camera and set display
			camera = new View (display);
			if (currentFocus) camera.setFocus (currentFocus);
			
			// Set engine state
			setState (STATE_RUN);
			
			// KeyUp & KeyDown Events
			stage.addEventListener (KeyboardEvent.KEY_DOWN, keyDownEvent);
			stage.addEventListener (KeyboardEvent.KEY_UP, keyUpEvent);
		}
		
		//
		//// EVENT - ENTER_FRAME
		private function update (Event) : void
		{
			// Check all actives are added to display
			if (!currentTestArea) {
				currentTestArea = currentArea.getTestLayer ();
				display.addChild (currentTestArea);
			}
			for (var i in actives) {
				if (!actives[i].parent) {
					display.addChild (actives[i]);
				}
			}
			
			// 
			if (currentState == STATE_RUN) {
				
				// Loop vars
				var testVel:int;
				var curCoords:Point;
				var curVel:Array;
				var curStance:int;
				var curHalfWidth:Number;
				
				//
				for (i in actives) {
					
					/// Key Input
					
					// Left & Right keys
					if (keyLeft && keyRight) {
						currentPC.accelerate (-3);
						
					// Left key
					} else if (keyLeft) {
						currentPC.setStance (-1);
						currentPC.accelerate (1);
						
					// Right key
					} else if (keyRight) {
						currentPC.setStance (1);
						currentPC.accelerate (1);
						
					// Neither left or right
					} else {
						currentPC.accelerate (-2);
					}
					
					// Jump key
					if (keyJump && ((ground && jumpKeyUp) || jumpCount >= 1 && jumpCount < 5)) {
						// Settings
						jumpKeyUp = false;
						ground = false;
						
						// Accelerate active upward
						jumpCount++;
						currentPC.accelerate (0, -12 + jumpCount * 2);
					}
					
					
					// Get active's properties
					curCoords = actives[i].localToGlobal (new Point (0, 0));
					curVel = actives[i].getVel ();
					curStance = actives[i].getStance ();
					curHalfWidth = actives[i].width / 2;
					
					/// Horizontal movement
					
					// Reset horizontal test velocity
					testVel = 0;
					
					// Right test
					if (curVel[0] > 0) {
						while (testVel < curVel[0] && !currentTestArea.hitTestPoint (curCoords.x + curHalfWidth + testVel + 2, curCoords.y - 10, true)) {
							testVel++;
						}
						
					// Left test
					} else if (curVel[0] < 0) {
						while (testVel > curVel[0] && !currentTestArea.hitTestPoint (curCoords.x - curHalfWidth + testVel - 1, curCoords.y - 10, true)) {
							testVel--;
						}
					}
					
					// Horizontal collision
					if (testVel != curVel[0]) {
						wall = curStance;
						actives[i].x += testVel;
						actives[i].setVelX (0);
						
					// You're fine
					} else {
						wall = 0;
						actives[i].x += curVel[0];
					}
					
					
					/// Vertical movement
					curCoords = actives[i].localToGlobal (new Point (0, 0));
					
					// Ground Pre-test & Gravity!
					if (!currentTestArea.hitTestPoint (curCoords.x + curHalfWidth + 1, curCoords.y + 2, true) &&
						!currentTestArea.hitTestPoint (curCoords.x - curHalfWidth, curCoords.y + 2, true)) {
						ground = false;
						actives[i].accelerate (0, 4);
					} else if (curVel[1] >= 0) {
						// Quick-fix for upward upward slopes
						while (currentTestArea.hitTestPoint (curCoords.x, curCoords.y, true)) {
							actives[i].y -= 1;
							curCoords = actives[i].localToGlobal (new Point (0, 0));
						};
					}
					
					// Fall collision
					if (curVel[1] > 0) {
						// Test all velocities from 1 to active's current velocity
						testVel = 0;
						while (testVel < curVel[1] &&
							   !currentTestArea.hitTestPoint (curCoords.x + curHalfWidth + 1, curCoords.y + testVel + 1, true) &&
							   !currentTestArea.hitTestPoint (curCoords.x - curHalfWidth , curCoords.y + testVel + 1, true)) {
							testVel++;
						}
						
						// Ground Post-test
						if (testVel != curVel[1]) {
							ground = true;
							jumpCount = 0; 
							actives[i].setVelY (0);
						}
						
						actives[i].y += testVel;
					} else {
						actives[i].y += curVel[1];
					}
					
				}
				
				// Update display position
				camera.update ();
			}
		}
		
		private function keyDownEvent (e:KeyboardEvent) : void
		{
			// Key 'Q' - PAUSE
			if (e.keyCode == KEY_PAUSE) {
				if (currentState == STATE_RUN) {
					setState (STATE_PAUSE);
				} else if (currentState == STATE_PAUSE) {
					setState (STATE_RUN);
				}
			}
			
			if (e.keyCode == KEY_LEFT) {
				keyLeft = true;
			}
			if (e.keyCode == KEY_RIGHT) {
				keyRight = true;
			}
			if (e.keyCode == KEY_JUMP) {
				keyJump = true;
			}
			
			// Key 'F'
			if (e.keyCode == 70) {
				update (Event);
			}
		}
		
		private function keyUpEvent (e:KeyboardEvent) : void
		{
			if (e.keyCode == KEY_LEFT) {
				keyLeft = false;
			}
			if (e.keyCode == KEY_RIGHT) {
				keyRight = false;
			}
			if (e.keyCode == KEY_JUMP) {
				keyJump = false;
				jumpKeyUp = true;
			}
		}
		
		private function addActive (newActive:Active, defaultX:Number = 0, defaultY:Number = 0, setFocus:Boolean = false) : void
		{
			// Create actives array, if needed
			if (!actives) actives = new Array ();
			actives.push (newActive);
			
			// Position & add new active
			newActive.x = defaultX;
			newActive.y = defaultY;
			
			// Set view focus
			if (setFocus) currentFocus = newActive;
			
		}

		private function addArea (newArea:Area, setCurrent:Boolean = false) : void
		{	
			if (!areas) areas = new Array ();
			areas.push (newArea);
			
			if (setCurrent) setArea (areas[areas.length - 1]);
		}
		
		private function setArea (newArea:Area) : void
		{
			if (currentArea) display.removeChild (currentArea);
			
			currentArea = newArea;
		}
		
		
		
		public function setState (newState:String) : void
		{
			if (newState == STATE_RUN) {
				currentState = STATE_RUN;
				if (pauseDisplay.parent) removeChild (pauseDisplay);
			}
			
			if (newState == STATE_PAUSE) {
				currentState = STATE_PAUSE;
				if (!pauseDisplay.parent) addChild (pauseDisplay);
			}
		}
		
	}
	
}
