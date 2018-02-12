package bl {
	
	import flash.display.LoaderInfo;
	import flash.errors.IOError;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;
	import flash.utils.ByteArray; 
	
	/**
	 * BL manager files rewritten to properly work with FlashDevelop.
	 * @author Jean-Philippe Sarda
	 * @edited Simon Marynissen
	 */

	public class GameManager extends EventDispatcher {
		
		public static var MAX_DATA_SIZE:Number = 40000;
		public var theroot:Main;
		
		private var
			sendconn:LocalConnection,
			rcvconn:LocalConnection,
			connectString:String = "BLConnectionRcv",
			cursoroverbl:Boolean = false,
			paused:Boolean = false,
			plcmd:*,
			blRc:Number;
			
		/**
		 * Constructor.
		 * @param	main	Your main class, must be named Main.
		 */
		public function GameManager(main:Main) {
			theroot = main;
			try {
			    var keyStr:String;
			    var valueStr:String;
			    var paramObj:Object = LoaderInfo(theroot.root.loaderInfo).parameters;
			    for (keyStr in paramObj) {
					if (keyStr == "blRc") blRc = Number(paramObj[keyStr]);
			    }
			} catch (error:Error) {}
			connectString += blRc;
			sendconn = new LocalConnection();
            sendconn.addEventListener(StatusEvent.STATUS, onstatus);
			rcvconn = new LocalConnection();
			rcvconn.allowDomain("http://www.bonuslevel.org", "http://bonuslevel.org", "http://localhost");
			rcvconn.client = this;
			try {
                rcvconn.connect("BLPlayerConnectionSnd" + blRc);
            } catch (error:ArgumentError) {
                trace("GameManager Can't connect... The connection name is already being used by another SWF");
            }
        }
		
		/**
		 * Is called by the level manager, when your game is loaded and the BL API is ready.
		 */
		public function blInit():void {
			// You may implement this function.
		}
		
		/**
		 * Is called by the level manager, when your game is paused (put in background).
		 */
		public function blPause():void {
			// You may implement this function.
    		paused = true;
		}
		
		/**
		 * Is called by the level manager, when your game is resumed (put in foreground).
		 */
		public function blResume():void {
			// You may implement this function.
    		paused = false;
		}
		
		/**
		 * Is called by the level manager when the stop button is pressed. It's a request to show the welcome screen of your game.
		 */
		public function blWelcome():void {
			// You may implement this function.
		}
		
		/**
		 * Is called by the level manager when the player has just completed all the levels of a category.
		 */
		public function blCatWin():void {
			// You may implement this function, for example a winning animation.
		}
		
		/**
		 * Is called by the level manager when the player has just completed all the levels of the game.
		 */
		public function blWin():void {
			// You may implement this function, for example a winning animation.
		}
		
		/*******************************************
		 *  GAME BASIC API
		 * *****************************************/
		
		/**
		 * This function is called by the level manager, not by you.
		 * @param	data		A ByteArray containing the level data to be unserialized.
		 * @param	official	-1 for an unevaluated or to be edited level. 0 for an accepted level. 1 for an official that never has been completed. 2 for an offical that already has been completed.
		 */
		public function blPlayLvl(data:ByteArray, official:Number):void {
			// You must implement this function.
			// Always include the sendPlayResult method at the end of the function.
			sendPlayResult(false, "You must implement the blPlayLvl function of the game manager.");
		}
		
		/**
		 * You must call this when the player has completed a level.
		 * @param	completed	Wether the level is completed. If it's false the level is not completed, but the player will go to the next level if the levels aren't locked.
		 * @param	score		The score the player gained on the level.
		 */
		public function lvlCompleted(completed:Boolean, score:Number):void {
			// Don't modify this function.
			sendconn.send(connectString, "lvlCompleted", completed, score);
		}
		
		/*******************************************
		 *  USER DATA API
		 * *****************************************/
		
		/**
		 * This function is called by the level manager after you have requested for the user data.
		 * @param	result	A Boolean wether it worked or not. If it's false data is a string containing an error message.
		 * @param	data	A ByteArray containing the user data. User data can be a list of items, power ups, coins, etc..
		 */
		public function blNewUserData(result:Boolean, data:ByteArray):void {
			// You may implement this function.
			if (result) {
				if (data.length == 0) {
					Main.userData = [];
					Main.userData[0] = [];
					Main.userData[1] = true;
				} else {
					data.position = 0;
					Main.userData = data.readObject();
					data.position = 0;
					if (Main.userData[1] == undefined)
						Main.userData[1] = true;
				}
				if (Main.userData[1])
					Main.BLManager.theroot.changeMusic(null);
			} else
				showInfo(String(data.readObject));
		}
		
		/**
		 * If you game implements the user data, you must call this function, usually at the beginning of the game. The BL API will reply by calling the blNewUserData function.
		 */
		public function requestUserData():void {
			// Don't modify this function.
			sendconn.send(connectString, "requestUserData");
		}
		
		/**
		 * You must call it to store the user data. The BL API will reply by calling userDataUpdatedCbk();
		 * @param	data	A ByteArray containing the user data.
		 */
		public function updateUserData(data:ByteArray):void {
			// Don't modify this function.
			// MAX_DATA_SIZE, split in small blocks of data if necessary.
			var packet_nb:Number = Math.ceil(data.length / MAX_DATA_SIZE);
			if (packet_nb <= 0) packet_nb = 1;
			for (var i:Number = 0; i < packet_nb; i++) {
				var packet:ByteArray = new ByteArray();
				var startRead:Number = i * MAX_DATA_SIZE;
				var readLength:Number = MAX_DATA_SIZE;
				if (startRead + readLength >= data.length) readLength = data.length - startRead;
				packet.writeBytes(data, startRead, readLength);
				sendconn.send(connectString, "updateUserDataByte", packet, i, packet_nb);
			}
		}
		
		/**
		 * This function is called by the BL API after you call updateUserData.
		 * @param	result	A Boolean wether the user data has been stored succesfully.
		 * @param	data	If result is false, data will contain the error message.
		 */
		public function userDataUpdatedCbk(result:Boolean, data:String):void {
			// You may implement this function.
			if (!result)
				showInfo(data);
		}
		
		/*******************************************
		 *  BEST PLAYER DATA API (since v2 only)
		 * *****************************************/
		
		/**
		 * This function is called by the level manager after you've requested for the best player data.
		 * @param	result		A Boolean wether if the function succeeded. If it's false data will contain an error message.
		 * @param	username	The username of the best player.
		 * @param	score		The score of the best player result.
		 * @param	data		A ByteArray containing the best player data, for example a description of a replay of the best player in a racing game.
		 */
		public function blBestPlayerData(result:Boolean, username:String, score:Number, data:ByteArray):void {
			// You may implement this function.
			// uncompress data with possible try catch for IOError
			log("Retreiving best player data", 1);
			if (data.length > 0) {
				try {
					data.position = 0;
					data.uncompress();
					Main.bestPlayerData = data.readObject();
				} catch (e:Error) {
					try {
						data.position = 0;
						Main.bestPlayerData = data.readObject();
					} catch (e:Error) {
						
					}
				}
			}
		}
		
		/**
		 * If your game implements the best player data, you must call this function, usually at the beginning of the game. The BL API will reply by calling the blBestPlayerData function.
		 */
		public function requestBestPlayerData():void {
			// Don't modify this function.
			sendconn.send(connectString, "requestBestPlayerData");
		}
		
		/**
		 * You must call it to store the best player data, when the BL manager calls the method blNeedBestPlayerData();
		 * @param	data	A ByteArray containing the best player data.
		 */
		public function sendBestPlayerData(data:ByteArray):void {
			log("Sending best player data", 0);
			// Don't modify this function.
			// MAX_DATA_SIZE, split in small blocks of data if necessary.
			var packet_nb:Number = Math.ceil(data.length / MAX_DATA_SIZE);
			if (packet_nb <= 0) packet_nb = 1;
			for (var i:Number = 0; i < packet_nb; i++) {
				var packet:ByteArray = new ByteArray();
				var startRead:Number = i * MAX_DATA_SIZE;
				var readLength:Number = MAX_DATA_SIZE;
				if (startRead + readLength >= data.length) readLength = data.length - startRead;
				packet.writeBytes(data, startRead, readLength);
				sendconn.send(connectString, "sendBestPlayerDataByte", packet, i, packet_nb);
			}
		}
		
		/**
		 * This function is called by the level manager after you've completed a level and if you have achieved the best score. If your game implements the best player data, then you have to serialize the best player data and send it to the BL manager by calling the method sendBestPlayerData.
		 */
		public function blNeedBestPlayerData():void {
			// You may implement this function if you wish to use the BEST PLAYER DATA API.
			//sendconn.send(connectString, "sendBestPlayerDataByte", null, 0, 0);
			var byte:ByteArray = new ByteArray();
			byte.position = 0;
			byte.writeObject(Main.playerData);
			byte.position = 0;
			byte.compress();
			sendBestPlayerData(byte);
		}
		
		/*******************************************
		 *  HIDDEN API (not to be used)
		 * *****************************************/
		
		private var dataStack:ByteArray;
		public function playLvl(cmd:*, data:ByteArray, official:Number, packet_id:Number = 0, packet_nb:Number = 1):void {
			// Don't modify this function.
			if (packet_id == 0) dataStack = new ByteArray();
			dataStack.writeBytes(data);
			if (packet_id == packet_nb - 1) {
				plcmd = cmd;
				var bytes:ByteArray = new ByteArray();
				bytes.writeBytes(dataStack);
				blPlayLvl(bytes, official);
				dataStack = new ByteArray();
			}
		}
		
		/**
		 * Call this function at the end of the blPlayLvl function.
		 * @param	result	A Boolean wether it succeeded to unserialize and play the level.
		 * @param	data	A string containing an error message if result is false.
		 */
		public function sendPlayResult(result:Boolean, data:String):void {
			// Don't modify this function.
			sendconn.send(connectString, "playLvlCbk", plcmd, result, data);
		}
		
		private var userDataStack:ByteArray;
		public function newUserData(result:Boolean, data:ByteArray, packet_id:Number = 0, packet_nb:Number = 1):void {
			// Don't modify this function.
			if (packet_id == 0) userDataStack = new ByteArray();
			userDataStack.writeBytes(data);
			if (packet_id == packet_nb - 1) {
				var bytes:ByteArray = new ByteArray();
				bytes.writeBytes(userDataStack);
				blNewUserData(result, bytes);
				userDataStack = new ByteArray();
			}
		}
		
		private var bestPlayerDataStack:ByteArray;
		public function bestPlayerData(result:Boolean, username:String, score:Number, data:ByteArray, packet_id:Number = 0, packet_nb:Number = 1):void {
			// Don't modify this function.
			if (packet_id == 0) bestPlayerDataStack = new ByteArray();
			bestPlayerDataStack.writeBytes(data);
			if (packet_id == packet_nb - 1) {
				var bytes:ByteArray = new ByteArray();
				bytes.writeBytes(bestPlayerDataStack);
				blBestPlayerData(result, username, score, bytes);
				bestPlayerDataStack = new ByteArray();
			}
		}
		
		/*******************************************
		 *  UTILS/MISC API 
		 * *****************************************/
		
		/**
		 * You can call this method to display a trace in the debug console.
		 * @param	text	Contains the String you want to trace.
		 * @param	level	0 for important, 1 for medium, 2 for info.
		 */
		public function log(text:String, level:Number):void {
			// Don't modify this function.
			sendconn.send(connectString, "debug", text, level);
		}
		
		/**
		 * You can call this method to display the main menu.
		 * @param	command		-1 turns on the menu as it is. Other values are for specific screens, but are not yet defined.
		 */
		public function showMenu(command:Number):void {
			// Don't modify this function.
			sendconn.send(connectString, "cmdShowMenu", command);
		}
		
		/**
		 * You can call this method to display a popup with an info text.
		 * @param	text	The String you want to display.
		 */ 
		public function showInfo(text:String):void {
			// Don't modify this function.
			sendconn.send(connectString, "cmdShowInfo", text);
		}
		
		public function getMgrVersion():void {
			// Don't modify this function.
			sendconn.send(connectString, "setPlayerManagerVersion", 3, 2);
		}
		
		/**
		 * You can call this method to know if the game is paused (in background).
		 * @return	A Boolean wether the game is paused.
		 */
		public function isPaused():Boolean {
			// Don't modify this function.
			return paused;
		}
		
		/**
		 * You must call this method when a mouse click is triggered in your swf to know if your mouse is over a Bonuslevel menu or popup.
		 * @return	A Boolean wether the mouse cursor is over a Bonuslevel menu or popup. If it's true you can't use the mouse click for your swf.
		 */
		public function cursorOverBLGUI():Boolean {
			// Don't modify this function.
			return cursoroverbl;
		}
		
		public function setCursorOverBLGUI(b:Boolean):void {
			// Don't modify this function.
			cursoroverbl = b;
			if (!paused) dispatchEvent(new BLEvent("GUI", b)); //dont dispatch if the app is paused
		}
		
		private function onstatus(event:StatusEvent):void {
			// Don't modify this function.
            switch (event.level) {
                case "status":
                    //trace("GameManager LocalConnection.send() succeeded");
                    break;
                case "error":
                    //trace("GameManager LocalConnection.send() failed");
                    break;
            }
        }
		
		public var gid:Number = -1; // game id
		public var path:String = "";
		public function initialize(g:Number, p:String):void {
			// Don't modify this function.
			gid = g;
			path = p;
			blInit();
		}
		
		/**
		 * Call this method to get the path to the extra resources (extra swf, images, etc.) you have uploaded to the BL servsers, you may want to load into you main swf.
		 * @return	A string containing the extra path.
		 */
		public function getExtraPath():String {
			// Don't modify this function.
			return path;
		}
	}
}