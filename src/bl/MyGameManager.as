package bl {
	
	import flash.utils.ByteArray;
	import states.GameState;
	import states.TitleState;
	
	/**
	 * BL manager files rewritten to properly work with FlashDevelop.
	 * @author Jean-Philippe Sarda
	 * @edited Simon Marynissen
	 */
	
	public class MyGameManager extends GameManager {
		
		private static var theOne:MyGameManager = null;
		
		/**
		 * Constructor.
		 * @param	main	Your main class, must be named Main.
		 */
		public function MyGameManager(main:Main) {
			super(main);
			theOne = this;
		}
		
		/**
		 * Returns the BLManager, once it's instantiated.
		 */
		public static function getInstance():MyGameManager {
			return theOne;
		}
		
		/**
		 * The BL API will call this function when the player wants to play a level.
		 * @param	data		A ByteArray containing the level data to be unserialized.
		 * @param	official	0 for a non official level. 1 for an official, but not yet completed. 2 for an offical that already has been completed.
		 */
		override public function blPlayLvl(data:ByteArray, official:Number):void {
			sendPlayResult(true, "");
			theroot.switchState(new GameState(data, official));
		}
		
		/**
		 * Is called by the level manager, when your game is loaded and the BL API is ready
		 */
		override public function blInit():void {
			theroot.initSounds();
			theroot.initGlobal();
			requestUserData();
			requestBestPlayerData();
		}
		
		/**
		 * Is called by the level manager when the stop button is pressed. It's a request to show the welcome screen of your game.
		 */
		override public function blWelcome():void {
			theroot.switchState(new TitleState());
		}
		
		/**
		 * Is called by the level manager, when your game is paused (put in background).
		 */
		override public function blPause():void {
			// You may implement this.
			// Don't forget to call super.blPause();
		}
		
		/**
		 * Is called by the level manager, when your game is resumed (put in foreground).
		 */
		override public function blResume():void {
			// You may implement this.
			// Don't forget to call super.blResume();
		}
	}
}