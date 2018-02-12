package states {

	import caurina.transitions.Tweener;
	import com.Base64;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import gui.Animator;
	import gui.BGParticles;
	import gui.Button;
	import gui.ShapePanel;
	import gui.virtualMouse.MyVirtualMouse;
	import tiles.*;
	import tiles.blockContainers.*;
	import tiles.wallAttachments.*;
	
	public class GameState extends State {
		
		[Embed(source = "../../assets/img/bg.jpg")] public static const BG:Class;
		[Embed(source = "../../assets/img/playground.png")] private static const PLAYGROUND:Class;
		/*[Embed(source = "../../assets/font/Bender_Inline.ttf", fontName = "bender_inline",
			mimeType = "application/x-font", advancedAntiAliasing = "true",
			embedAsCFF = "false")] private static const BENDER_INLINE:Class;
		[Embed(source = "../../assets/font/Bender_Thin.ttf", fontName = "bender_thin",
			mimeType = "application/x-font", advancedAntiAliasing = "true",
			embedAsCFF = "false")] private static const BENDER_THIN:Class;*/
		[Embed(source = "../../assets/font/Bender_Solid.ttf", fontName = "bender_solid",
			mimeType = "application/x-font", advancedAntiAliasing = "true",
			embedAsCFF = "false")] private static const BENDER_SOLID:Class;
		[Embed(source = "../../assets/img/undoButton.png")] private static const UNDO:Class;
		[Embed(source = "../../assets/img/gravityButtonUp.png")] private static const UP_GRAVITY:Class;
		[Embed(source = "../../assets/img/gravityButtonLeft.png")] private static const LEFT_GRAVITY:Class;
		[Embed(source = "../../assets/img/gravityButtonRight.png")] private static const RIGHT_GRAVITY:Class;
		[Embed(source = "../../assets/img/gravityButtonDown.png")] private static const DOWN_GRAVITY:Class;
		[Embed(source = "../../assets/img/gravityDirectionBorder.png")] private static const GRAVITY_BORDER:Class;
		[Embed(source = "../../assets/img/directions.png")] private static const DIRECTIONS:Class;
		
		public static const
			cellWidth:int = 32;
			
		public var
			gravityX:int = 0,
			gravityY:int = 1,
			walls:Array = [],
			gridWidth:int,
			gridHeight:int;
			
		private static const
			UNDO_BITMAPDATA:Array = [],
			UP_G_BITMAPDATA:Array = [],
			LEFT_G_BITMAPDATA:Array = [],
			RIGHT_G_BITMAPDATA:Array = [],
			DOWN_G_BITMAPDATA:Array = [],
			GRAVITY_BORDER_BITMAPDATA:Array = [],
			DIRECTIONS_BITMAPDATA:Array = [];
			
		private static var
			gridYOffset:int,
			gridXOffset:int,
			animator:Animator;
		
		private var
			downKeys:Array = [],
			official:int,
			virtualMouse:Boolean,
			mouse:MyVirtualMouse,
			mX:int, // mouse X
			mY:int, // mouse Y
			playStates:Array = [],
			blocks:/*Block*/Array = [],
			forceFields:Array = [],
			processing:Boolean,
			directionX:int,
			directionY:int,
			amountGoalShapes:Array,
			blockConnections:Array,
			connectionSprites:/*BlockConnection*/Array,
			coloursInGame:Array = [],
			wallBlockSeparations:Array = [],
			moves:int,
			movesButton:Sprite = new Sprite(),
			movesTextField:TextField = new TextField(),
			undoButton:Button,
			upGravityButton:Button,
			leftGravityButton:Button,
			rightGravityButton:Button,
			downGravityButton:Button,
			//gravityParticleEmitter:GravityParticles = new GravityParticles(),
			//gravityParticleRenderer:DisplayObjectRenderer = new DisplayObjectRenderer(),
			bgParticles:BGParticles,
			gravityDirectionBorders:Array = [],
			gameStarted:Boolean,
			shapePanel:ShapePanel,
			wallLayer:Sprite = new Sprite(),
			blockLayer:Sprite = new Sprite(),
			blockConnectionLayer:Sprite = new Sprite(),
			blockAnimationLayer:Sprite = new Sprite(),
			wallAttachmentLayer:Sprite = new Sprite(),
			forceFieldLayer:Sprite = new Sprite(),
			//waterLayer:Sprite = new Sprite(),
			topLayer:Sprite = new Sprite(),
			data:ByteArray,
			finished:Boolean,
			blockClickedOn:Block,
			fragments:/*BlockFragment*/Array = [],
			special:Boolean = false;
			//water:Water;
		
		public static function initBitmapData():void {
			for (var i:int = 0; i < 4; i++) {
				(UNDO_BITMAPDATA[i] = new BitmapData(144, 48, true, 0)).copyPixels(
					new UNDO().bitmapData, new Rectangle(0, 48 * i, 144, 48),
					new Point(0, 0), null, null, true);
				(UP_G_BITMAPDATA[i] = new BitmapData(64, 32, true, 0)).copyPixels(
					new UP_GRAVITY().bitmapData, new Rectangle(0, 32 * i, 64, 32),
					new Point(0, 0), null, null, true);
				(LEFT_G_BITMAPDATA[i] = new BitmapData(32, 64, true, 0)).copyPixels(
					new LEFT_GRAVITY().bitmapData, new Rectangle(0, 64 * i, 32, 64),
					new Point(0, 0), null, null, true);
				(RIGHT_G_BITMAPDATA[i] = new BitmapData(32, 64, true, 0)).copyPixels(
					new RIGHT_GRAVITY().bitmapData, new Rectangle(0, 64 * i, 32, 64),
					new Point(0, 0), null, null, true);
				(DOWN_G_BITMAPDATA[i] = new BitmapData(64, 32, true, 0)).copyPixels(
					new DOWN_GRAVITY().bitmapData, new Rectangle(0, 32 * i, 64, 32),
					new Point(0, 0), null, null, true);
				var w:int = 32 + 32 * Math.abs(J.getXDir(i));
				var h:int = 32 + 32 * Math.abs(J.getYDir(i));
				(DIRECTIONS_BITMAPDATA[i] = new BitmapData(w, h, true, 0)).copyPixels(
					new DIRECTIONS().bitmapData, new Rectangle(64 * int(i == 0) + 96 * int(i == 3), 32 * int(i == 2), w, h), new Point(), null, null, true);
				GRAVITY_BORDER_BITMAPDATA[i] = [];
				for (var j:int = 0; j < 3; j++) {
					(GRAVITY_BORDER_BITMAPDATA[i][j] = new BitmapData(32, 32, true, 0)).copyPixels(
						new GRAVITY_BORDER().bitmapData, new Rectangle(32 * j, 32 * i, 32, 32),
						new Point(0, 0), null, null, true);
				}
			}
		}
		
		public static function getGridXOffset():int { return gridXOffset; }
		
		public static function getGridYOffset():int { return gridYOffset; }
		
		public function GameState(data:ByteArray, official:Number, mouse:MyVirtualMouse = null) {
			super();
			this.data = data;
			this.official = official;
			this.virtualMouse = (mouse != null);
			this.mouse = mouse;
			if (mouse != null)
				mouse.game = this;
			animator = new Animator(blockAnimationLayer, this);
			blockConnectionLayer.mouseEnabled = false;
			blockConnectionLayer.mouseChildren = false;
			blockAnimationLayer.mouseEnabled = false;
			blockAnimationLayer.mouseChildren = false;
			wallAttachmentLayer.mouseEnabled = false;
			wallAttachmentLayer.mouseChildren = false;
			forceFieldLayer.mouseEnabled = false;
			forceFieldLayer.mouseChildren = false;
			//waterLayer.mouseEnabled = false;
			//waterLayer.mouseChildren = false;
			topLayer.mouseEnabled = false;
			topLayer.mouseChildren = false;
			var myGlow:GlowFilter = new GlowFilter(); 
			myGlow.alpha = 0.5;
			myGlow.color = 0xffffff; 
			myGlow.blurX = 10; 
			myGlow.blurY = 10; 
			myGlow.strength = 5;
			horizontalDirection.filters = [myGlow];
			verticalDirection.filters = [myGlow];
			horizontalBitmap = new Bitmap();
			horizontalBitmap.visible = false;
			horizontalDirection.addChild(horizontalBitmap);
			verticalBitmap = new Bitmap();
			verticalBitmap.visible = false;
			verticalDirection.addChild(verticalBitmap);
			initLevel();
		}
		
		override public function startUp(e:Event):void {
			super.startUp(e);
			if (!special) {
				addEventListener(MouseEvent.MOUSE_DOWN, clickedDown);
				addEventListener(MouseEvent.MOUSE_UP, clickedUp);
			}
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			//initLevel();
			gameStarted = true;
		}
		
		private var action:Boolean = false;
		private var movingState:int = 0;
		override public function everyFrame(e:Event):void {
			updateMouseCoordinates();
			if (special && gameStarted && !finished) {
				finished = true;
				data.position = 0;
				var objs:Array = data.readObject();
				data.position = 0;
				if (objs[1] == 0) { // complete x accepted/official levels made by yourself
					if (Main.userData == null)
						Main.BLManager.showInfo("The user data is null: reloading the game may fix this.");
					else {
						var awardScreen:AwardScreen = new AwardScreen(0, objs);
						addChild(awardScreen);
					}
				}
				removeEventListener(Event.ENTER_FRAME, everyFrame);
				return;
			}
			if (fragments.length > 0) {
				for (var i:int = fragments.length - 1; i >= 0; i--) {
					fragments[i].update();
					if (fragments[i].time > 15) {
						blockAnimationLayer.removeChild(fragments[i]);
						fragments[i].bitmapData.dispose();
						fragments[i] = null;
						fragments.splice(i, 1);
					}
				}
			}
			if (finished)
				return;
			if (processing && !finished) {
				if (!hasAnimationsGoing()) {
					if (movingState == 0) {
						movingState = 1;
						action = fallBlocks();
						if (action)
							autoTileBlocks();
					} else if (movingState == 1) {
						movingState = 2;
						attachmentAction();
						autoTileBlocks();
					} else if (movingState == 2) {
						movingState = 3;
						var a:Boolean = action;
						action ||= fallBlocks();
						if (a != action)
							autoTileBlocks();
					} else if (movingState == 3) {
						movingState = 0;
						if (!action) {
							processing = false;
							afterMove();
						}
					}
				}
			} else if (showDirection && blockClickedOn != null) {
				directionFrame--;
				if (directionFrame < 0)
					directionFrame += 6;
				directionFrame %= 6;
				if (blockClickedOn.x > mX || blockClickedOn.x + 32 <= mX || blockClickedOn.y > mY || blockClickedOn.y + 32 <= mY) {
					var directions:Array = findDirections();
					var index:int = J.getIndexFrom(directions[0], directions[1]);
					if (directions[0] != 0) {
						horizontalBitmap.visible = false;
						var bits:BitmapData = new BitmapData(64, 32, true, 0);
						var w:int = directionSize2, h:int = directionSize1;
						var x:int = directionFrame, y:int = (32 - h) / 2;
						var destX:int = blockClickedOn.x + 32;
						if (directions[0] == -1) {
							x = 64 - w - directionFrame;
							destX = blockClickedOn.x - w;
						}
						bits.copyPixels(DIRECTIONS_BITMAPDATA[index], new Rectangle(x, y, w, h), new Point(0, y), null, null, true);
						horizontalDirection.x = destX;
						horizontalBitmap.bitmapData = bits;
						horizontalBitmap.visible = true;
					}
					if (directions[1] != 0) {
						verticalBitmap.visible = false;
						bits = new BitmapData(32, 64, true, 0);
						w = directionSize1, h = directionSize2;
						x = (32 - w) / 2, y = directionFrame;
						var destY:int = blockClickedOn.y + 32;
						if (directions[1] == -1) {
							y = 64 - h - directionFrame;
							destY = blockClickedOn.y - h;
						}
						bits.copyPixels(DIRECTIONS_BITMAPDATA[index], new Rectangle(x, y, w, h), new Point(x, 0), null, null, true);
						verticalDirection.y = destY;
						verticalBitmap.bitmapData = bits;
						verticalBitmap.visible = true;
					}
				} else {
					horizontalBitmap.visible = false;
					verticalBitmap.visible = false;
				}
			} else if (!showDirection) {
				horizontalBitmap.visible = false;
				verticalBitmap.visible = false;
			}
		}
		
		private function hasAnimationsGoing():Boolean {
			for each (var block:Block in blocks) {
				if (block.hasAnimations())
					return true;
			}
			return false;
		}
		
		override public function terminate():void {
			super.terminate();
			//gravityParticleEmitter.stop();
			if (bgParticles != null)
				bgParticles.stop();
			if (hasEventListener(MouseEvent.MOUSE_DOWN))
				removeEventListener(MouseEvent.MOUSE_DOWN, clickedDown);
			if (hasEventListener(MouseEvent.MOUSE_UP))
				removeEventListener(MouseEvent.MOUSE_UP, clickedUp);
			if (hasEventListener(KeyboardEvent.KEY_DOWN))
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			if (hasEventListener(KeyboardEvent.KEY_UP))
				stage.removeEventListener(KeyboardEvent.KEY_UP, keyUp);
			if (upGravityButton != null) {
				if (upGravityButton.hasEventListener(MouseEvent.CLICK))
					upGravityButton.removeEventListener(MouseEvent.CLICK, gravityUp);
			}
			if (leftGravityButton != null) {
				if (leftGravityButton.hasEventListener(MouseEvent.CLICK))
					leftGravityButton.removeEventListener(MouseEvent.CLICK, gravityLeft);
			}
			if (rightGravityButton != null) {
				if (rightGravityButton.hasEventListener(MouseEvent.CLICK))
					rightGravityButton.removeEventListener(MouseEvent.CLICK, gravityRight);
			}
			if (downGravityButton != null) {
				if (downGravityButton.hasEventListener(MouseEvent.CLICK))
					downGravityButton.removeEventListener(MouseEvent.CLICK, gravityDown);
			}
			if (undoButton != null) {
				if (undoButton.hasEventListener(MouseEvent.CLICK))
					undoButton.removeEventListener(MouseEvent.CLICK, undo);
			}
		}
		
		public function jellify(wallBlocks:Boolean = false, blocksToUse:Array = null, addWallsToBlocks:Boolean = false):void {
			var ignoreFrozen:Boolean = false;
			if (blocksToUse == null)
				blocksToUse = blocks;
			else
				ignoreFrozen = true;
			for each (var block:Block in blocksToUse) {
				for each (var bluck:Block in block.getConnections())
					block.mergeJellyShapes(bluck);
				if (block.isFrozen() && !ignoreFrozen)
					continue;
				if (block.getColour() == 11 && !wallBlocks && !addWallsToBlocks)
					continue;
				if (block.isReadyToExplode())
					continue;
				var X:int = block.getX();
				var Y:int = block.getY();
				var colour:uint = block.getColour();
				var right:Block = findBlock(X + 1, Y);
				var down:Block = findBlock(X, Y + 1);
				if (blocksToUse.indexOf(right) == -1)
					right = null;
				if (blocksToUse.indexOf(down) == -1)
					down = null;
				var ff:ForceField = findForceField(X, Y);
				var rightff:ForceField = findForceField(X + 1, Y);
				var downff:ForceField = findForceField(X, Y + 1);
				var forceRightColour1:int = ((ff == null) ? -1 : ff.getColour(1, 0));
				var forceRightColour2:int = ((rightff == null) ? -1 : rightff.getColour(-1, 0));
				var forceDownColour1:int = ((ff == null) ? -1 : ff.getColour(0, 1));
				var forceDownColour2:int = ((downff == null) ? -1 : downff.getColour(0, -1));
				if (right != null && !right.isReadyToExplode() && (!right.isFrozen() || ignoreFrozen) && (!block.getSlice(1, 0) && !right.getSlice(-1, 0))) {
					if (right.getColour() == colour) {
						if (forceRightColour1 != colour && forceRightColour2 != colour)
							block.mergeWith(right);
						else {
							block.slice(1, 0);
							right.slice(-1, 0);
						}
					}
				}
				if (down != null && !down.isReadyToExplode() && (!down.isFrozen() || ignoreFrozen) && (!block.getSlice(0, 1) && !down.getSlice(0, -1))) {
					if (down.getColour() == colour) {
						if (forceDownColour1 != colour && forceDownColour2 != colour)
							block.mergeWith(down);
						else {
							block.slice(0, 1);
							down.slice(0, -1);
						}
					}
				}
				if (addWallsToBlocks) {
					var blocksAround:Array = findBlocksAround(X, Y);
					for (var i:int = 0; i < 4; i++) {
						if (blocksAround[i] == null)
							continue;
						if (block.hasHinge(J.getXDir(i), J.getYDir(i)) ||
							blocksAround[i].hasHinge(-J.getXDir(i), -J.getYDir(i))) {
							block.mergeJellyShapes(blocksAround[i]);
						}
					}
				}
			}
		}
		
		private function initLevel():void {
			addChild(new Bitmap(new BG().bitmapData));
			bgParticles = new BGParticles();
			addChild(bgParticles);
			data.position = 0;
			if (data.length == 0) {
				Main.BLManager.showInfo("Failed to init level: empty data. Reloading the page may help.");
				return;
			}
			
			//var str:String = "eNptjlEOgDAIQ4crA2KMJ/D+x9SiIfNjLGFvbZo1LokQtNgFG4AOhYUKNA6BU3EY1ZbaCBOy5QVk6sz3QPDcnLk+x5heO75yWISfpFNohf7HPhFEy+rOxi9YwSjQAkAfri8oAQ==";
			//data = Base64.decodeToByteArray(str);
			//data.uncompress();
			data.position = 0;
			var objs:Array = data.readObject();//[[0, [1, 8, 15], [2, 0, 0, 5, 6], [3, [0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0]], /*[4, [[1,1], [2,1]]],*/ [5, [1, 3, 1, 5, 3, 0]]], [1, 0, 4, 2], [1, 1, 3, 2], [1, 1, 5, 2], [2, 0, 5], [2, 0, 2], [2, 1, 2]/*[1, 2, 0, 11], [1, 1, 1, 11], [1, 2, 1, 11], [2, 0, 2, [0, [3, 0, 1]]], [2, 1, 2], [2, 2, 2], [2, 3, 2], [2, 4, 2], [1, 0, 3, 7], [1, 2, 3, 7], [1, 4, 3, 7, 1], [2, 4, 4], [2, 4, 5]*/];
			//
			data.position = 0;
			special = false;
			if (objs != null) {
				special = (objs[0] == "special");
			}
			if (special) {
				return;
			}
			
			var minX:int = 13;
			var maxX:int = 0;
			var minY:int = 13;
			var maxY:int = 0;
			
			for (var i:int = 1; i < objs.length; i++) {
				if (objs[i][1] < minX)
					minX = objs[i][1];
				if (objs[i][1] > maxX)
					maxX = objs[i][1];
				if (objs[i][2] < minY)
					minY = objs[i][2];
				if (objs[i][2] > maxY)
					maxY = objs[i][2];
			}
			gridWidth = maxX - minX + 1;
			gridHeight = maxY - minY + 1;
			
			upGravityButton = new Button(UP_G_BITMAPDATA);
			leftGravityButton = new Button(LEFT_G_BITMAPDATA);
			rightGravityButton = new Button(RIGHT_G_BITMAPDATA);
			downGravityButton = new Button(DOWN_G_BITMAPDATA);
			
			var boundaryAttachments:Array = null;
			
			// options
			for (i = 1; i < objs[0].length; i++) {
				if (objs[0][i][0] == 1) { // gravity related
					var startGravity:int = objs[0][i][1];
					if (startGravity & 1) {
						gravityX = 0, gravityY = -1;
					} else if (startGravity & 2) {
						gravityX = -1, gravityY = 0;
					} else if (startGravity & 4) {
						gravityX = 1, gravityY = 0;
					} else if (startGravity & 8) {
						gravityX = 0, gravityY = 1;
					}
					var gravitySwitches:int = objs[0][i][2];
					var amountOfSwitches:int = 0;
					for (var k:int = 0; k < 4; k++) {
						if (gravitySwitches & (1 << k))
							amountOfSwitches++;
					}
					if (amountOfSwitches > 1 || (amountOfSwitches == 1 && !(startGravity & gravitySwitches))) {
						if (gravitySwitches & 1)
							addChild(upGravityButton);
						if (gravitySwitches & 2)
							addChild(leftGravityButton);
						if (gravitySwitches & 4)
							addChild(rightGravityButton);
						if (gravitySwitches & 8)
							addChild(downGravityButton);
					}
					activateGravityButton(!(startGravity & 1), !(startGravity & 2), !(startGravity & 4), !(startGravity & 8));
				} else if (objs[0][i][0] == 2) { // game size related
					minX = objs[0][i][1];
					minY = objs[0][i][2];
					gridWidth = objs[0][i][3];
					gridHeight = objs[0][i][4];
				} else if (objs[0][i][0] == 3) // amount of shapes to win
					amountGoalShapes = objs[0][i][1];
				else if (objs[0][i][0] == 5) // block connections
					blockConnections = objs[0][i];
				else if (objs[0][i][0] == 6) // boundary wall attachments
					boundaryAttachments = objs[0][i];
			}
			
			if (boundaryAttachments != null) {
				for (i = 1; i < boundaryAttachments.length; i++) {
					boundaryAttachments[i][0] -= minX;
					boundaryAttachments[i][1] -= minY;
				}
			}
			
			wallBlockSeparations = [];
			for (i = 1; i < objs[0].length; i++) {
				if (objs[0][i][0] == 4) { // wall block separations
					for (var g:int = 1; g < objs[0][i].length; g++) {
						for each (var arr:Array in objs[0][i][g])
							wallBlockSeparations.push([arr[0] - minX, arr[1] - minY, g]);
					}
				}
			}
			if (blockConnections != null) {
				for (i = 1; i < blockConnections.length; i++) {
					blockConnections[i][0] -= minX;
					blockConnections[i][1] -= minY;
					blockConnections[i][2] -= minX;
					blockConnections[i][3] -= minY;
				}
			}
			for (i = 1; i < objs.length; i++) {
				objs[i][1] -= minX;
				objs[i][2] -= minY;
			}
			gridXOffset = (640 - cellWidth * gridWidth) / 2;
			gridYOffset = (640 - cellWidth * gridHeight) / 2;
			
			bgParticles.changeDirection(gravityX, gravityY);
			bgParticles.start();
			
			upGravityButton.addEventListener(MouseEvent.CLICK, gravityUp);
			upGravityButton.x = gridXOffset + (gridWidth * cellWidth - 64) / 2;
			upGravityButton.y = gridYOffset - 72;
			leftGravityButton.addEventListener(MouseEvent.CLICK, gravityLeft);
			leftGravityButton.x = gridXOffset - 72;
			leftGravityButton.y = gridYOffset + (gridHeight * cellWidth - 64) / 2;
			rightGravityButton.addEventListener(MouseEvent.CLICK, gravityRight);
			rightGravityButton.x = gridXOffset + cellWidth * gridWidth + 40;
			rightGravityButton.y = gridYOffset + (gridHeight * cellWidth - 64) / 2;
			downGravityButton.addEventListener(MouseEvent.CLICK, gravityDown);
			downGravityButton.x = gridXOffset + (gridWidth * cellWidth - 64) / 2;
			downGravityButton.y = gridYOffset + cellWidth * gridHeight + 40;
			
			var playground:BitmapData = new BitmapData((gridWidth + 2) * 32, (gridHeight + 2) * 32, true, 0);
			playground.copyPixels(new PLAYGROUND().bitmapData, new Rectangle(0, 0, 32, 32), new Point(0, 0), null, null, true);
			playground.copyPixels(new PLAYGROUND().bitmapData, new Rectangle(576 - playground.width + 32, 0, playground.width - 32, 32), new Point(32, 0), null, null, true);
			playground.copyPixels(new PLAYGROUND().bitmapData, new Rectangle(0, 576 - playground.height + 32, 32, playground.height - 32), new Point(0, 32), null, null, true);
			playground.copyPixels(new PLAYGROUND().bitmapData, new Rectangle(576 - playground.width + 32, 576 - playground.height + 32, playground.width - 32, playground.height - 32), new Point(32, 32), null, null, true);
			var playgroundImage:Bitmap = new Bitmap(playground);
			playgroundImage.x = gridXOffset - 32;
			playgroundImage.y = gridYOffset - 32;
			addChild(playgroundImage);
			
			movesTextField.defaultTextFormat = new TextFormat("bender_solid", 40, 0xffffff);
			movesTextField.embedFonts = true;
			movesTextField.text = "moves: 0";
			movesTextField.selectable = false;
			movesTextField.x = 8;
			movesTextField.y = 584;
			movesTextField.width = 300;
			addChild(movesTextField);
			undoButton = new Button(UNDO_BITMAPDATA);
			undoButton.x = 400;
			undoButton.y = 584;
			undoButton.addEventListener(MouseEvent.CLICK, undo);
			undoButton.deactivate();
			addChild(undoButton);
			
			
			addChild(wallLayer);
			addChild(blockLayer);
			addChild(blockConnectionLayer);
			addChild(blockAnimationLayer);
			addChild(wallAttachmentLayer);
			addChild(forceFieldLayer);
			//addChild(waterLayer);
			addChild(topLayer);
			
			for (var X:int = 0; X < gridWidth+2; X++)
				walls[X] = [];
			for (X = -1; X < gridWidth+1; X++) { // border walls
				for (var Y:int = -1; Y < gridHeight+1; Y++) {
					if (X == -1 || X == gridWidth || Y == -1 || Y == gridHeight) {
						var attachment:Array = null;
						if (boundaryAttachments != null) {
							for (var h:int = 1; h < boundaryAttachments.length; h++) {
								if (boundaryAttachments[h][0] == X && boundaryAttachments[h][1] == Y) {
									attachment = boundaryAttachments[h][2];
									break;
								}
							}
						}
						if (attachment == null)
							wallLayer.addChild(walls[X + 1][Y + 1] = new Wall([2, X, Y], this));
						else
							wallLayer.addChild(walls[X + 1][Y + 1] = new Wall([2, X, Y, [0, attachment]], this));
					}
				}
			}
			for (X = 0; X < gridWidth; X++)
				forceFields[X] = [];
			
			for (i = 0; i <= 11; i++)
				coloursInGame[i] = false;
			for (i = 1; i < objs.length; i++) {
				var obj:Array = objs[i];
				if (obj[0] == 1) {
					blocks.push(new Block(obj, this));
					coloursInGame[obj[3]] = true;
					if (obj[3] == J.WALL_BLOCK_COLOUR) {
						for each (var array:Array in wallBlockSeparations) {
							if (array[0] == obj[1] && array[1] == obj[2]) {
								blocks[blocks.length - 1].wallBlockSeparation = array[2];
								break;
							}
						}
						for (var j:int = 4; j < obj.length; j++) {
							if (obj[j] is Array && obj[j][0] == 0) {
								for (k = 1; k < obj[j].length; k++) {
									if (obj[j][k][0] == 1)
										coloursInGame[obj[j][k][3]] = true;
								}
							}
						}
					}
				} else if (obj[0] == 2) {
					wallLayer.addChild(walls[obj[1] + 1][obj[2] + 1] = new Wall(obj, this));
					for (j = 3; j < obj.length; j++) {
						if (obj[j] is Array && obj[j][0] == 0) {
							for (k = 1; k < obj[j].length; k++) {
								if (obj[j][k][0] == 1)
									coloursInGame[obj[j][k][3]] = true;
							}
						}
					}
				} else if (obj[0] == 3)
					forceFieldLayer.addChild(forceFields[obj[1]][obj[2]] = new ForceField(obj));
			}
			makeShapePanel();
			changeGravityDirectionBorders();
			for each (var block:Block in blocks)
				blockLayer.addChild(block);
			
			connectionSprites = [];
			if (blockConnections != null) {
				for (i = 1; i < blockConnections.length; i++) {
					var b1:Block = findBlock(blockConnections[i][0], blockConnections[i][1]);
					var b2:Block = findBlock(blockConnections[i][2], blockConnections[i][3]);
					if (b1 != null && b2 != null) {
						var connect:BlockConnection = new BlockConnection(blockConnections[i]);
						connect.addActualFirstBlock(b1);
						blockConnectionLayer.addChild(connect);
						connectionSprites.push(connect);
						b1.addConnection(b2, connect);
					}
				}
			}
			
			Main.playerData = [[]];
			jellify(true);
			autoTileBlocks(true);
			attachmentAction(true);
			fallBlocks();
			jellify();
			autoTileBlocks(false);
			autoTileWalls();
			autoTileForceFields();
			//var waterLevels:Array = [];
			//for (X = 0; X < gridWidth; X++) {
				//waterLevels[X] = [];
				//for (Y = 0; Y < gridHeight; Y++) {
					//waterLevels[X][Y] = (walls[X + 1][Y + 1] == null) ? Math.round(Math.random()) : 0;
				//}
			//}
			//water = new Water(waterLevels, this, 0x123456);
			//water.x = getGridXOffset();
			//water.y = getGridYOffset();
			//water.settle();
			//waterLayer.addChild(water);
			playStates.push(currentState());
			addWallAttachmentsToScreen(true);
		}
		
		private function addWallAttachmentsToScreen(start:Boolean = false):void {
			for each (var block:Block in blocks)
				block.addWallAttachmentsTo(wallAttachmentLayer);
			if (!start)
				return;
			for (var X:int = 0; X < gridWidth + 2; X++) {
				for (var Y:int = 0; Y < gridHeight + 2; Y++) {
					if (walls[X][Y] != null)
						walls[X][Y].addWallAttachmentsTo(wallAttachmentLayer);
				}
			}
		}
		
		private function removeWallAttachmentsFromScreen():void {
			for each (var block:Block in blocks)
				block.removeWallAttachmentsFrom(wallAttachmentLayer);
			/*for (var X:int = 0; X < gridWidth + 2; X++) {
				for (var Y:int = 0; Y < gridHeight + 2; Y++) {
					if (walls[X][Y] != null)
						walls[X][Y].removeWallAttachmentsFrom(wallAttachmentLayer);
				}
			}*/
		}
		
		private function keyDown(e:KeyboardEvent):void {
			if (mouse)
				return;
			var index:int = downKeys.indexOf(e.keyCode);
			if (index == -1) {
				downKeys.push(e.keyCode);
				fireKeyAction(e.keyCode);
			}
		}
		
		private function fireKeyAction(code:uint):void {
			switch (code) {
				case Keyboard.UP :
					if (contains(upGravityButton))
						gravityUp(null);
					break;
				case Keyboard.LEFT : 
					if (contains(leftGravityButton))
						gravityLeft(null);
					break;
				case Keyboard.DOWN :
					if (contains(downGravityButton))
						gravityDown(null);
					break;
				case Keyboard.RIGHT :
					if (contains(rightGravityButton))
						gravityRight(null);
					break;
				case Keyboard.J :
					jAction();
					break;
				case Keyboard.E :
					eAction();
					break;
				default :
					updateTooltips = false;
					break;
			}
		}
		
		private var updateTooltips:Boolean = false;
		private function jAction():void {
			updateTooltips = true;
		}
		
		private function eAction():void {
			if (updateTooltips) {
				updateTooltips = false;
				Main.changeToolTips();
			}
		}
		
		private function keyUp(e:KeyboardEvent):void {
			if (mouse)
				return;
			var index:int = downKeys.indexOf(e.keyCode);
			if (index != -1)
				downKeys.splice(index, 1);
		}
		
		private function gravityUp(e:MouseEvent):void {
			if (processing || finished)
				return;
			if (gravityX == 0 && gravityY == -1)
				return;
			gravityX = 0;
			gravityY = -1;
			activateGravityButton(false, true, true, true);
			gravityChanged();
		}
		
		private function gravityLeft(e:MouseEvent):void {
			if (processing || finished)
				return;
			if (gravityX == -1 && gravityY == 0)
				return;
			gravityX = -1;
			gravityY = 0;
			activateGravityButton(true, false, true, true);
			gravityChanged();
		}
		
		private function gravityRight(e:MouseEvent):void {
			if (processing || finished)
				return;
			if (gravityX == 1 && gravityY == 0)
				return;
			gravityX = 1;
			gravityY = 0;
			activateGravityButton(true, true, false, true);
			gravityChanged();
		}
		
		private function gravityDown(e:MouseEvent):void {
			if (processing || finished)
				return;
			if (gravityX == 0 && gravityY == 1)
				return;
			gravityX = 0;
			gravityY = 1;
			activateGravityButton(true, true, true, false);
			gravityChanged();
		}
		
		private function gravityChanged():void {
			bgParticles.changeDirection(gravityX, gravityY);
			//gravityParticleEmitter.changeGravity(gravityX, gravityY);
			changeGravityDirectionBorders();
			if (Main.playerData && mouse == null)
				Main.playerData[0].push([ -1, -1, gravityX, gravityY]);
			processing = true;
			//water.settle();
			//afterMove();
		}
		
		private function afterMove():void {
			/*var action:Boolean = true;
			while (action) {
				action = fallBlocks();
				attachmentAction();
				action ||= fallBlocks();
			}*/
			jellify();
			autoTileBlocks();
			moves++;
			movesTextField.text = "moves: " + moves;
			undoButton.activate();
			if (undoAllowed)
				playStates.push(currentState());
			if (hasWon())
				finishLevel();
		}
		
		private function attachmentAction(start:Boolean = false):void {
			blocksNextToWallAttachments(start, false);
			jellify();
			blocksNextToWallAttachments(start, true, false);
			blocksNextToWallAttachments(start, true, true);
		}
		
		private function blocksNextToWallAttachments(start:Boolean = false, afterJellify:Boolean = false, spiking:Boolean = false):Boolean {
			var action:Boolean = false;
			for each (var block:Block in blocks) {
				block.setPaints([]);
				var wallsAround:Array = findWallsAround(block.getX(), block.getY());
				for (var i:int = 0; i < wallsAround.length; i++) {
					if (wallsAround[i] != null) {
						var a:Boolean = wallsAround[i].changeBlockNextTo(block, start, afterJellify, spiking);
						action ||= a;
					}	
				}
				var movingWallsAround:Array = findBlocksAroundSameColour(block.getX(), block.getY(), 11);
				for (i = 0; i < movingWallsAround.length; i++) {
					if (movingWallsAround[i] != null) {
						a = movingWallsAround[i].changeBlockNextTo(block, start, afterJellify, spiking);
						action ||= a;
					}
				}
				var paints:Array = block.getPaints();
				var paintBlock:Boolean = true;
				if (paints.length > 1) {
					var paint:int = paints[0];
					for (i = 1; i < paints.length; i++) {
						if (paints[i] != paint)
							paintBlock = false;
					}
				}
				if (paintBlock && paints.length > 0) {
					ColourChanger.colourBlock(block, paints[0], this);
					action = true;
				}
			}
			if (afterJellify) {
				var jelliesDone:Array = [];
				for each (block in blocks) {
					var jelly:Jelly = block.getJelly();
					if (jelliesDone.indexOf(jelly) == -1) {
						jelliesDone.push(jelly);
						if (jelly.shouldBeFrozen())
							Freezer.freezeJelly(jelly);
						else if (jelly.shouldBeDefrosted())
							Defroster.defrostJelly(jelly);
						jelly.resetFreezeOptions();
					}
				}
				jelliesDone = null;
			}
			for (var k:int = blocks.length - 1; k >= 0; k--) {
				if (blocks[k].isReadyToExplode()) {
					animator.addBlockExplosion(blocks[k]);
					var neighbours:Array = findBlocksAroundSameColour(blocks[k].getX(), blocks[k].getY(), J.WALL_BLOCK_COLOUR);
					wallsAround = findWallsAround(blocks[k].getX(), blocks[k].getY());
					for (i = 0; i < 4; i++) {
						var index:int = 3 - i;
						var xdir:int = -J.getXDir(index);
						var ydir:int = -J.getYDir(index);
						if (neighbours[i] != null) {
							if (neighbours[i].hasHinge(xdir, ydir))
								neighbours[i].removeHinge(xdir, ydir, wallAttachmentLayer);
						}
						if (wallsAround[i] != null) {
							if (wallsAround[i].hasHinge(xdir, ydir))
								wallsAround[i].removeHinge(xdir, ydir, wallAttachmentLayer);
						}
					}
					blockLayer.removeChild(blocks[k]);
					blocks[k].removeListeners();
					blocks[k].removeAllConnections(blockConnectionLayer);
					var jolly:Jelly = blocks[k].getJelly();
					jolly.removeBlock(blocks[k]);
					if (jolly.isEmpty())
						jolly.getJellyShape().remove(jolly);
					blocks[k] = null;
					blocks.splice(k, 1);
				}
			}
			animator.startAnimating();
			changeWallAttachments();
			return action;
		}
		
		private function changeWallAttachments():void {
			for (var X:int = 0; X < gridWidth + 2; X++) {
				for (var Y:int = 0; Y < gridHeight + 2; Y++) {
					if (walls[X][Y] != null)
						walls[X][Y].changeWallAttachments(wallAttachmentLayer);
				}
			}
			for each (var block:Block in blocks) {
				if (block.getColour() == 11)
					block.changeWallAttachments(wallAttachmentLayer);
			}
		}
		
		private var
			showDirection:Boolean = false,
			horizontalDirection:Sprite = new Sprite(),
			verticalDirection:Sprite = new Sprite(),
			horizontalBitmap:Bitmap,
			verticalBitmap:Bitmap,
			directionFrame:int = 0;
		private function clickedDown(e:MouseEvent):void {
			updateMouseCoordinates();
			if (processing)
				return;
			if (Main.BLManager.cursorOverBLGUI())
				return;
			blockClickedOn = findBlock((mX - gridXOffset) / cellWidth, (mY - gridYOffset) / cellWidth);
			if (blockClickedOn != null && blockClickedOn.isMobile() && !blockClickedOn.isLocked()) {
				directionFrame = 0;
				directionSize1 = 20;
				directionSize2 = 20;
				willChangeSize = true;
				onCompleteDirection1Change();
				onCompleteDirection2Change();
				blockClickedOn.startSelectionAnimation();
				horizontalDirection.y = blockClickedOn.y;
				verticalDirection.x = blockClickedOn.x;
				showDirection = true;
				if (!topLayer.contains(horizontalDirection))
					topLayer.addChild(horizontalDirection);
				if (!topLayer.contains(verticalDirection))
					topLayer.addChild(verticalDirection);
			}
		}
		
		public var directionSize1:int;
		private var willChangeSize:Boolean = false;
		private function onCompleteDirection1Change(e:Event = null):void {
			if (willChangeSize) {
				var targetSize1:int = 32 - directionSize1;
				Tweener.addTween(this, { directionSize1:targetSize1, time:0.5, transition:"easeOutBack", onComplete:onCompleteDirection1Change } );
			}
		}
		
		public var directionSize2:int;
		private function onCompleteDirection2Change(e:Event = null):void {
			if (willChangeSize) {
				var targetSize2:int = 64 - directionSize2;
				Tweener.addTween(this, { directionSize2:targetSize2, time:0.5, transition:"easeOutBack", onComplete:onCompleteDirection2Change });
			}
		}
		
		private function clickedUp(e:MouseEvent):void {
			updateMouseCoordinates();
			showDirection = false;
			willChangeSize = false;
			var continueGameLogic:Boolean = true;
			if (topLayer.contains(horizontalDirection))
				topLayer.removeChild(horizontalDirection);
			if (topLayer.contains(verticalDirection))
				topLayer.removeChild(verticalDirection);
			if (blockClickedOn != null)
				blockClickedOn.stopSelectionAnimation();
			if (processing || finished || blockClickedOn == null)
				continueGameLogic = false;
			else if (Main.BLManager.cursorOverBLGUI())
				continueGameLogic = false;
			else if (!blockClickedOn.isMobile())
				continueGameLogic = false;
			else if (blockClickedOn.x <= mX && blockClickedOn.x + 32 > mX && blockClickedOn.y <= mY && blockClickedOn.y + 32 > mY)
				continueGameLogic = false;
			else if (blockClickedOn.hasLockedBlocksInShape())
				continueGameLogic = false;
			if (continueGameLogic) {
				blockClickedOn.getJelly().getJellyShape().setReadyToMove(true);
				blockClickedOn.decrementMovesLeft();
				var directions:Array = findDirections();
				directionX = directions[0];
				directionY = directions[1];
				
				if (Main.playerData && mouse == null) {
					var tileX:int = blockClickedOn == null ? -1 : blockClickedOn.getX();
					var tileY:int = blockClickedOn == null ? -1 : blockClickedOn.getY();
					if (tileX != -1 && tileY != -1) {
						var dirX:int = (gravityY != 0) ? directionX : 0;
						var dirY:int = (gravityX != 0) ? directionY : 0;
						Main.playerData[0].push([tileX, tileY, dirX, dirY]);
					}
				}
				
				moveBlocks();
				processing = true;
				//afterMove();
			}
			blockClickedOn = null;
		}
		
		private function findDirections():Array {
			updateMouseCoordinates();
			if (blockClickedOn == null)
				return null;
			var directions:Array = [0, 0];
			if (gravityY != 0) {
				if (mX < blockClickedOn.x + 16)
					directions[0] = -1;
				else
					directions[0] = 1;
			}
			if (gravityX != 0) {
				if (mY < blockClickedOn.y + 16)
					directions[1] = -1;
				else
					directions[1] = 1;
			}
			return directions;
		}
		
		private function moveBlocks():void {
			var checkingBlocks:Array = [];
			var newCheckingBlocks:Array = [];
			for each (var block:Block in blocks) {
				if (block.isReadyToMove())
					checkingBlocks.push(block);
			}
			var stopped:Boolean = false;
			while (checkingBlocks.length > 0) {
				for each (block in checkingBlocks) {
					var X:int = block.getX();
					var Y:int = block.getY();
					var wall:Wall = findWall(X  + directionX, Y + directionY);
					if (wall != null) {
						stopped = true;
						break;
					}
					if (blockedByForceField(X, Y, directionX, directionY, block.getColour()) ||
						blockedByForceField(X + directionX, Y + directionY, -directionX, -directionY, block.getColour())) {
						stopped = true;
						break;
					}
					var newBlock:Block = findBlock(X + directionX, Y + directionY);
					if (newBlock != null && !newBlock.isReadyToMove() && !newBlock.hasLockedBlocksInShape()) {
						var jellyShape:JellyShape = newBlock.getJelly().getJellyShape();
						jellyShape.setReadyToMove(true);
						for each (var jelly:Jelly in jellyShape.getJellies()) {
							for each (var jellyBlock:Block in jelly.getBlocks())
								newCheckingBlocks.push(jellyBlock);
						}
					} else if (newBlock != null && newBlock.hasLockedBlocksInShape()) {
						stopped = true;
						break;
					}
				}
				if (stopped)
					break;
				checkingBlocks = newCheckingBlocks;
				newCheckingBlocks = [];
			}
			if (!stopped) {
				for each (block in blocks) {
					if (block.isReadyToMove())
						block.addMovement(directionX, directionY, gameStarted);
				}
			}
			for each (block in blocks)
				block.setReadyToMove(false);
			for each (block in blocks)
				block.move(gravityX, gravityY);
			for each (block in blocks)
				block.startAnimating();
			slicify();
		}
		
		private function fallBlocks():Boolean {
			var jellyShapes:Array = [];
			var fallableBlocks:Array = [];
			for each (var block:Block in blocks) {
				var jellyShape:JellyShape = block.getJelly().getJellyShape();
				if (jellyShapes.indexOf(jellyShape) == -1) {
					jellyShapes.push(jellyShape);
					if (!jellyShape.hasLockedBlocks()) {
						var hasForceFieldsInside:Boolean = false;
						for each (var jelly:Jelly in jellyShape.getJellies()) {
							for each (var jellyBlock:Block in jelly.getBlocks()) {
								var X:int = jellyBlock.getX();
								var Y:int = jellyBlock.getY();
								var col:uint = jellyBlock.getColour();
								if (blockedByForceField(X, Y, gravityX, gravityY, col) ||
										blockedByForceField(X + gravityX, Y + gravityY, -gravityX, -gravityY, col)) {
									jellyShape.setReadyToFall(false);
									hasForceFieldsInside = true;
									break;
								}		
							}
							if (hasForceFieldsInside)
								break;
						}
						if (hasForceFieldsInside)
							continue;
						for each (jelly in jellyShape.getJellies()) {
							for each (jellyBlock in jelly.getBlocks())
								fallableBlocks.push(jellyBlock);
						}
					} else
						jellyShape.setReadyToFall(false);
				}
			}
			var action:Boolean = false;
			var checkWhenFallingBlocks:Array = [];
			for each (block in fallableBlocks) {
				X = block.getX() + gravityX;
				Y = block.getY() + gravityY;
				var blockUnder:Block = findBlock(X, Y);
				if (blockUnder == null || !(block.isInSameShapeWith(blockUnder)))
					checkWhenFallingBlocks.push(block);
			}
			for each (block in checkWhenFallingBlocks)
				block.getJelly().getJellyShape().setReadyToFall(true);
			var stillFalling:Boolean = true;
			while (stillFalling) {
				for each (block in checkWhenFallingBlocks) {
					if (!block.isReadyToFall())
						continue;
					X = block.getX();
					Y = block.getY();
					blockUnder = findBlock(X + gravityX, Y + gravityY);
					var wall:Wall = findWall(X + gravityX, Y + gravityY);
					var stoppedFalling:Boolean = (wall != null) ||
							(blockUnder != null && (!blockUnder.isReadyToFall() || blockUnder.hasLockedBlocksInShape())) ||
							blockedByForceField(X, Y, gravityX, gravityY, block.getColour()) ||
							blockedByForceField(X + gravityX, Y + gravityY, -gravityX, -gravityY, block.getColour());
					if (stoppedFalling)
						stopFalling(block);
				}
				stillFalling = false;
				for each (block in blocks) {
					if (block.isReadyToFall()) {
						stillFalling = true;
						action = true;
						block.addMovement(gravityX, gravityY, gameStarted);
					}
				}
				slicify();
			}
			for each (block in blocks)
				block.move(gravityX, gravityY);
			for each (block in blocks) {
				block.startAnimating();
				block.resetSlices();
			}
			return action;
		}
		
		private function stopFalling(block:Block):void {
			var jellyShapesToStop:/*JellyShape*/Array = [block.getJelly().getJellyShape()];
			var index:int = 0;
			while (index < jellyShapesToStop.length) {
				jellyShapesToStop[index].setReadyToFall(false);
				for each (var jelly:Jelly in jellyShapesToStop[index].getJellies()) {
					for each (var jellyBlock:Block in jelly.getBlocks()) {
						var blockOn:Block = findBlock(jellyBlock.getX() - gravityX, jellyBlock.getY() - gravityY);
						if (blockOn != null && jellyShapesToStop.indexOf(blockOn.getJelly().getJellyShape()) == -1)
							jellyShapesToStop.push(blockOn.getJelly().getJellyShape());
					}
				}
				index++;
			}
		}
		
		public function hingeBlocks(blocksToUse:Array = null):void {
			if (blocksToUse == null)
				blocksToUse = blocks;
			for each (var block:Block in blocksToUse) {
				var neighbours:Array = findBlocksAroundSameColour(block.getX(), block.getY(), 11);
				for (var i:int = 0; i < 4; i++) {
					if (neighbours[i] != null && (neighbours[i].hasHinge(J.getXDir(i), J.getYDir(i)) ||
							block.hasHinge(J.getXDir(3 - i), J.getYDir(3 - i))))
						block.mergeJellyShapes(neighbours[i]);
				}
			}
		}
		
		private function slicify():void {
			var jellyShapes:Array = [];
			for each (var block:Block in blocks) {
				var jellyShape:JellyShape = block.getJelly().getJellyShape();
				if (jellyShapes.indexOf(jellyShape) == -1)
					jellyShapes.push(jellyShape);
			}
			for each (jellyShape in jellyShapes) {
				for each (var jelly:Jelly in jellyShape.getJellies()) {
					var jellyBlocks:Array = jelly.shallowCopyBlocks();
					jelly.disband();
					jellify(false, jellyBlocks, true);
				}
			}
		}
		
		private function hasWon():Boolean {
			var jellyShapes:Array = [];
			var colours:Array = [];
			for each (var block:Block in blocks) {
				var jellyShape:JellyShape = block.getJelly().getJellyShape();
				if (jellyShapes.indexOf(jellyShape) == -1) {
					jellyShapes.push(jellyShape);
					var jellyShapeColours:Array = jellyShape.getColours();
					for (var c:int = 0; c < jellyShapeColours.length; c++)
						colours.push(jellyShapeColours[c]);
				}
			}
			var colourCount:Array = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
			for each (var i:int in colours)
				colourCount[i]++;
			if (amountGoalShapes == null) {
				for (i = 1; i < 11; i++) {
					if (colourCount[i] > 1)
						return false;
				}
			} else {
				for (i = 1; i < 11; i++) {
					if (colourCount[i] != amountGoalShapes[i] && amountGoalShapes[i] != 10)
						return false;
				}
			}
			return true;
		}
		
		private function undo(e:MouseEvent):void {
			if (processing)
				return;
			if (moves <= 0)
				return;
			if (finished) {
				finished = false;
				if (winScreen)
					winScreen.stop();
			}
			revertState();
			//gravityParticleEmitter.changeGravity(gravityX, gravityY);
			bgParticles.changeDirection(gravityX, gravityY);
			changeGravityDirectionBorders();
			moves--;
			if (moves == 0)
				undoButton.deactivate();
			if (Main.playerData && mouse == null) {
				if (Main.playerData[0].length > 0)
					Main.playerData[0].pop();
			}
			movesTextField.text = "moves: " + moves;
		}
		
		private function changeGravityDirectionBorders():void {
			for (var i:int = 0; i < gravityDirectionBorders.length; i++) {
				if (gravityDirectionBorders[i] != null && contains(gravityDirectionBorders[i]))
					removeChild(gravityDirectionBorders[i]);
			}
			gravityDirectionBorders = [];
			if (gravityX != 0) {
				for (var Y:int = -1; Y <= gridHeight; Y++) {
					var tileIndex:int = 1;
					if (Y == -1)
						tileIndex = 0;
					else if (Y == gridHeight)
						tileIndex = 2;
					var bitmap:Bitmap = new Bitmap(GRAVITY_BORDER_BITMAPDATA[(gravityX == 1) ? 2 : 1][tileIndex]);
					bitmap.x = gridXOffset - 32 + ((gravityX == 1) ? 32 * (gridWidth + 1) : 0);
					bitmap.y = gridYOffset + 32 * Y;
					gravityDirectionBorders.push(bitmap);
					addChild(bitmap);
				}
			} else if (gravityY != 0) {
				for (var X:int = -1; X <= gridWidth; X++) {
					tileIndex = 1;
					if (X == -1)
						tileIndex = 0;
					else if (X == gridWidth)
						tileIndex = 2;
					bitmap = new Bitmap(GRAVITY_BORDER_BITMAPDATA[(gravityY == 1) ? 3 : 0][tileIndex]);
					bitmap.x = gridXOffset + 32 * X;
					bitmap.y = gridYOffset - 32 + ((gravityY == 1) ? 32 * (gridHeight + 1) : 0);
					gravityDirectionBorders.push(bitmap);
					addChild(bitmap);
				}
			}
		}
		
		private function currentState():Array {
			//return [cloneBlocks(), [gravityX, gravityY], cloneWalls()];
			return [cloneBlocks2(), [gravityX, gravityY], getChangableWallData(), getConnectionCoordinates()];
		}
		
		private function cloneBlocks():Array {
			var clonedBlocks:Array = [];
			for each (block in blocks)
				clonedBlocks.push(block.clone());
			var jellyShapes:Array = [];
			for each (var block:Block in blocks) {
				if (jellyShapes.indexOf(block.getJelly().getJellyShape()) == -1)
					jellyShapes.push(block.getJelly().getJellyShape());
			}
			for each (var jellyShape:JellyShape in jellyShapes) {
				var jellies:Array = jellyShape.getJellies();
				var coordinates:Array = [];
				for (var i:int = 0; i < jellies.length; i++)
					coordinates[i] = jellies[i].getCoordinatesFromBlocks();
				var clonedJellyShape:JellyShape = new JellyShape();
				var clonedJellies:Array = [];
				for (i = 0; i < jellies.length; i++) {
					clonedJellies[i] = jellies[i].clone();
					clonedJellyShape.cloneAdd(clonedJellies[i]);
				}
				var found:Boolean = false;
				for (i = 0; i < clonedBlocks.length; i++) {
					for (var j:int = 0; j < clonedJellies.length; j++) {
						for (var k:int = 0; k < coordinates[j].length; k++) {
							if (coordinates[j][k][0] == clonedBlocks[i].getX() && coordinates[j][k][1] == clonedBlocks[i].getY()) {
								clonedJellies[j].cloneAdd(clonedBlocks[i]);
								found = true;
								break;
							}
						}
						if (found)
							break;
					}
					found = false;
				}
			}
			return clonedBlocks;
		}
		
		private function cloneBlocks2(arr:Array = null):Array {
			var clonedBlocks:Array = [];
			if (arr == null)
				arr = blocks;
			for (var i:int = 0; i < blocks.length; i++)
				clonedBlocks[i] = blocks[i].getInfo();
			var jellyShapes:Array = [];
			for each (var block:Block in arr) {
				if (jellyShapes.indexOf(block.getJelly().getJellyShape()) == -1)
					jellyShapes.push(block.getJelly().getJellyShape());
			}
			for each (var jellyShape:JellyShape in jellyShapes) {
				var jellies:Array = jellyShape.getJellies();
				var coordinates:Array = [];
				for (i = 0; i < jellies.length; i++)
					coordinates[i] = jellies[i].getCoordinatesFromBlocks();
				var clonedJellyShape:JellyShape = new JellyShape();
				var clonedJellies:Array = [];
				for (i = 0; i < jellies.length; i++) {
					clonedJellies[i] = jellies[i].clone();
					clonedJellyShape.cloneAdd(clonedJellies[i]);
				}
				for (i = 0; i < clonedJellies.length; i++) {
					for (var j:int = 0; j < coordinates[i].length; j++) {
						var X:int = coordinates[i][j][0];
						var Y:int = coordinates[i][j][1];
						for each (var blockData:Array in clonedBlocks) {
							if (blockData[0] == X && blockData[1] == Y) {
								blockData.push(clonedJellies[i]);
								break;
							}
						}
					}
				}
			}
			return clonedBlocks;
		}
		
		private function cloneWalls():Array {
			var clonedWalls:Array = [];
			for (var X:int = 0; X < gridWidth + 2; X++) {
				clonedWalls[X] = [];
				for (var Y:int = 0; Y < gridHeight + 2; Y++) {
					if (walls[X][Y] != null)
						clonedWalls[X][Y] = walls[X][Y].clone();
				}
			}
			return clonedWalls;
		}
		
		private function getChangableWallData():Array {
			var data:Array = [];
			for (var X:int = 0; X < gridWidth + 2; X++) {
				for (var Y:int = 0; Y < gridHeight + 2; Y++) {
					if (walls[X][Y] != null) {
						var arr:Array = walls[X][Y].getChangableData();
						if (arr != null) {
							arr.unshift(X, Y);
							data.push(arr);
						}
					}
				}
			}
			return data;
		}
		
		private function getConnectionCoordinates():Array {
			var data:Array = [];
			for (var i:int = 0; i < connectionSprites.length; i++)
				data.push(connectionSprites[i].getData());
			return data;
		}
		
		private function revertState(complete:Boolean = false):void {
			if (!undoAllowed && !complete)
				return;
			removeWallAttachmentsFromScreen();
			for (var k:int = blocks.length - 1; k >= 0; k--) {
				blockLayer.removeChild(blocks[k]);
				blocks[k].removeListeners();
				blocks[k] = null;
			}
			blocks = [];
			if (complete) {
				while (playStates.length > 1)
					playStates.pop();
			} else
				playStates.pop();

			var jellies:Array = [];
			var clonedBlocksData:Array = [];
			for each (var blockData:Array in playStates[playStates.length - 1][0]) {
				var arr:Array = [];
				for (var l:int = 0; l < blockData.length - 1; l++)
					arr[l] = blockData[l];
				var index:int = jellies.indexOf(blockData[blockData.length - 1]);
				if (index == -1) {
					jellies.push(blockData[blockData.length - 1]);
					arr[blockData.length - 1] = jellies.length - 1;
				} else
					arr[blockData.length - 1] = index;
				clonedBlocksData.push(arr);
			}
			var jellyShapes:Array = [];
			for each (var jelly:Jelly in jellies) {
				if (jellyShapes.indexOf(jelly.getJellyShape()) == -1)
					jellyShapes.push(jelly.getJellyShape());
			}
			var clonedJellies:Array = [];
			for (var i:int = 0; i < jellies.length; i++)
				clonedJellies[i] = jellies[i].clone();
			for each (var jellyShape:JellyShape in jellyShapes) {
				var clonedJellyShape:JellyShape = new JellyShape();
				for each (var jell:Jelly in jellyShape.getJellies()) {
					index = jellies.indexOf(jell);
					clonedJellyShape.cloneAdd(clonedJellies[index]);
				}
			}
			for each (var clonedBlockData:Array in clonedBlocksData)
				clonedBlockData[clonedBlockData.length - 1] = clonedJellies[clonedBlockData[clonedBlockData.length - 1]];
			
			var blocksData:Array = clonedBlocksData;
			for each (blockData in blocksData)
				blocks.push(new Block(null, this, blockData));
				
			var connectionCoordinates:Array = playStates[playStates.length - 1][3];
			for (var d:int = 0; d < connectionCoordinates.length; d++) {
				var b1:Block = findBlock(connectionCoordinates[d][0], connectionCoordinates[d][1]);
				var b2:Block = findBlock(connectionCoordinates[d][2], connectionCoordinates[d][3]);
				if (b1 != null && b2 != null) {
					var c:BlockConnection = connectionSprites[d];
					c.addActualFirstBlock(b1);
					blockConnectionLayer.addChild(c);
					b1.addConnection(b2, c);
				}
			}
			
			for each (var block:Block in blocks)
				blockLayer.addChild(block);
				
			gravityX = playStates[playStates.length - 1][1][0];
			gravityY = playStates[playStates.length - 1][1][1];
			//water.changeWaterLevels(playStates[playStates.length - 1][3]);
			activateGravityButton(!isGravityUp(), !isGravityLeft(), !isGravityRight(), !isGravityDown());
			for (i = 0; i < playStates[playStates.length - 1][2].length; i++) {
				var X:int = playStates[playStates.length - 1][2][i][0];
				var Y:int = playStates[playStates.length - 1][2][i][1];
				walls[X][Y].updateChangableData(playStates[playStates.length - 1][2][i], wallAttachmentLayer);
			}
			addWallAttachmentsToScreen();
		}
		
		/*private function revertState2():void {
			removeWallAttachmentsFromScreen();
			for each (var block:Block in blocks) {
				blockLayer.removeChild(block);
				block.removeListeners();
			}
			blocks = [];
			playStates.pop();
			blocks = cloneBlocks(playStates[playStates.length - 1][0]);
			for each (block in blocks) {
				block.addListeners();
				blockLayer.addChild(block);
			}
			gravityX = playStates[playStates.length - 1][1][0];
			gravityY = playStates[playStates.length - 1][1][1];
			//water.changeWaterLevels(playStates[playStates.length - 1][3]);
			activateGravityButton(!isGravityUp(), !isGravityLeft(), !isGravityRight(), !isGravityDown());
			
			/*for (var X:int = 0; X < gridWidth; X++) {
				for (var Y:int = 9; Y < gridHeight; Y++) {
					if (walls[X][Y] != null) {
						wallLayer.removeChild(walls[X][Y]);
						walls[X][Y] = null;
					}
				}
			}
			for (X = 0; X < gridWidth + 2; X++) {
				for (Y = 0; Y < gridHeight + 2; Y++) {
					if (playStates[playStates.length - 1][2][X][Y] != null) {
						walls[X][Y] = playStates[playStates.length - 1][2][X][Y].clone();
						wallLayer.addChild(walls[X][Y]);
					}
				}
			}*/
		/*	for (var i:int = 0; i < playStates[playStates.length - 1][2].length; i++) {
				var X:int = playStates[playStates.length - 1][2][i][0];
				var Y:int = playStates[playStates.length - 1][2][i][1];
				walls[X][Y].updateChangableData(playStates[playStates.length - 1][2][i]);
			}
			
			addWallAttachmentsToScreen();
		}*/
		
		private function isGravityUp():Boolean {
			return gravityX == 0 && gravityY == -1;
		}
		
		private function isGravityLeft():Boolean {
			return gravityX == -1 && gravityY == 0;
		}
		
		private function isGravityRight():Boolean {
			return gravityX == 1 && gravityY == 0;
		}
		
		private function isGravityDown():Boolean {
			return gravityX == 0 && gravityY == 1;
		}
		
		private function activateGravityButton(up:Boolean, left:Boolean, right:Boolean, down:Boolean):void {
			if (up)
				upGravityButton.activate();
			else
				upGravityButton.deactivate();
			if (left)
				leftGravityButton.activate();
			else
				leftGravityButton.deactivate();
			if (right)
				rightGravityButton.activate();
			else
				rightGravityButton.deactivate();
			if (down)
				downGravityButton.activate();
			else
				downGravityButton.deactivate();
		}
		
		private function blockedByForceField(X:int, Y:int, xdir:int, ydir:int, colour:uint):Boolean {
			return findForceField(X, Y) != null && (forceFields[X][Y].getColour(xdir, ydir) == colour);
		}
		
		private function findBlock(X:int, Y:int):Block {
			for each (var block:Block in blocks) {
				if (block.getX() == X && block.getY() == Y)
					return block;
			}
			return null;
		}
		
		private function findBlockInJelly(X:int, Y:int, jelly:Jelly):Block {
			if (jelly == null)
				return null;
			return jelly.findBlock(X, Y);
		}
		
		private function findBlocksAround(X:int, Y:int):Array {
			var left:Block = null, up:Block = null, right:Block = null, down:Block = null;
			for each (var block:Block in blocks) {
				if (left == null && block.getX() == X - 1 && block.getY() == Y)
					left = block;
				else if (up == null && block.getX() == X && block.getY() == Y - 1)
					up = block;
				else if (right == null && block.getX() == X + 1 && block.getY() == Y)
					right = block;
				else if (down == null && block.getX() == X && block.getY() == Y + 1)
					down = block;
				else if (left != null && up != null && right != null && down != null)
					break;
			}
			return [up, left, right, down];
		}
		
		private function findBlocksAroundSameColour(X:int, Y:int, colour:uint):Array {
			var left:Block = null, up:Block = null, right:Block = null, down:Block = null;
			var upleft:Block = null, upright:Block = null, downleft:Block = null, downright:Block = null;
			for each (var block:Block in blocks) {
				if (block.getColour() != colour)
					continue;
				if (left == null && block.getX() == X - 1 && block.getY() == Y)
					left = block;
				else if (up == null && block.getX() == X && block.getY() == Y - 1)
					up = block;
				else if (right == null && block.getX() == X + 1 && block.getY() == Y)
					right = block;
				else if (down == null && block.getX() == X && block.getY() == Y + 1)
					down = block;
				else if (upleft == null && block.getX() == X - 1 && block.getY() == Y - 1)
					upleft = block;
				else if (upright == null && block.getX() == X + 1 && block.getY() == Y - 1)
					upright = block;
				else if (downleft == null && block.getX() == X - 1 && block.getY() == Y + 1)
					downleft = block;
				else if (downright == null && block.getX() == X + 1 && block.getY() == Y + 1)
					downright = block;
				else if (left != null && up != null && right != null && down != null &&
						upleft != null && upright != null && downleft != null && downright != null)
							break;
			}
			return [down, right, left, up, upleft, upright, downleft, downright];
		}
		
		private function findBlocksAroundSameColourInJelly(X:int, Y:int, colour:uint, jelly:Jelly):Array {
			var left:Block = null, up:Block = null, right:Block = null, down:Block = null;
			var upleft:Block = null, upright:Block = null, downleft:Block = null, downright:Block = null;
			for each (var block:Block in jelly.getBlocks()) {
				if (block.getColour() != colour)
					continue;
				if (left == null && block.getX() == X - 1 && block.getY() == Y)
					left = block;
				else if (up == null && block.getX() == X && block.getY() == Y - 1)
					up = block;
				else if (right == null && block.getX() == X + 1 && block.getY() == Y)
					right = block;
				else if (down == null && block.getX() == X && block.getY() == Y + 1)
					down = block;
				else if (upleft == null && block.getX() == X - 1 && block.getY() == Y - 1)
					upleft = block;
				else if (upright == null && block.getX() == X + 1 && block.getY() == Y - 1)
					upright = block;
				else if (downleft == null && block.getX() == X - 1 && block.getY() == Y + 1)
					downleft = block;
				else if (downright == null && block.getX() == X + 1 && block.getY() == Y + 1)
					downright = block;
				else if (left != null && up != null && right != null && down != null &&
						upleft != null && upright != null && downleft != null && downright != null)
							break;
			}
			return [down, right, left, up, upleft, upright, downleft, downright];
		}
		
		private function findBlocksAroundSameColourOrMovingWallsInJelly(X:int, Y:int, colour:uint, jelly:Jelly):Array {
			var up:Block = null, left:Block = null, right:Block = null, down:Block = null;
			var jellyBlocks:Array = jelly.getBlocks();
			for each (var block:Block in jellyBlocks) {
				if (block.getColour() != colour && block.getColour() != 11)
					continue;
				if (up == null && block.getX() == X && block.getY() == Y - 1)
					up = block;
				else if (left == null && block.getX() == X - 1 && block.getY() == Y)
					left = block;
				else if (right == null && block.getX() == X + 1 && block.getY() == Y)
					right = block;
				else if (down == null && block.getX() == X && block.getY() == Y + 1)
					down = block;
				else if (up != null && left != null && right != null && down != null)
					break;
			}
			return [up, left, right, down];
		}
		
		private function autoTileBlocks(wallBlocks:Boolean = false):void {
			for each (var block:Block in blocks) {
				var colour:int = block.getColour();
				if (colour == 11 && !wallBlocks)
					continue;
				var X:int = block.getX();
				var Y:int = block.getY();
				var neighbours:Array = findBlocksAroundSameColourInJelly(X, Y, colour, block.getJelly());
				var frame:int = 0;
				var corners:int = 0;
				var transitions:int = 0;
				var transitionCorners:int = 0;
				var interrupted:Array = [];
				for (var i:int = 0; i < 4; i++) {
					var xdir:int = J.getXDir(3 - i);
					var ydir:int = J.getYDir(3 - i);
					interrupted[i] = blockedByForceField(X, Y, xdir, ydir, colour) ||
							blockedByForceField(X + xdir, Y + ydir, -xdir, -ydir, colour);
				}
				for (i = 0; i < 4; i++) {
					if (neighbours[i] != null && !interrupted[i])
						frame += (1 << i);
					if (!block.isMobile() && !block.isLocked() && neighbours[i] != null && (neighbours[i].isMobile() || neighbours[i].isLocked()) && !interrupted[i])
						transitions += (1 << (3-i));
				}
				var cornerInterrupted:Array = [
					blockedByForceField(X - 1, Y, 0, -1, colour) || blockedByForceField(X - 1, Y - 1, 0, 1, colour),
					blockedByForceField(X - 1, Y - 1, 1, 0, colour) || blockedByForceField(X, Y - 1, -1, 0, colour)];
				if (isCorner(neighbours, cornerInterrupted, 4, 2, 3))
					corners += 1;
				cornerInterrupted = [
					blockedByForceField(X + 1, Y, 0, -1, colour) || blockedByForceField(X + 1, Y - 1, 0, 1, colour),
					blockedByForceField(X, Y - 1, 1, 0, colour) || blockedByForceField(X + 1, Y - 1, -1, 0, colour)];
				if (isCorner(neighbours, cornerInterrupted, 5, 1, 3))
					corners += 2;
				cornerInterrupted = [
					blockedByForceField(X - 1, Y + 1, 1, 0, colour) || blockedByForceField(X, Y + 1, -1, 0, colour),
					blockedByForceField(X - 1, Y, 0, 1, colour) || blockedByForceField(X - 1, Y + 1, 0, -1, colour)];
				if (isCorner(neighbours, cornerInterrupted, 6, 0, 2))
					corners += 4;
				cornerInterrupted = [
					blockedByForceField(X, Y + 1, 1, 0, colour) || blockedByForceField(X + 1, Y + 1, -1, 0, colour),
					blockedByForceField(X + 1, Y, 0, 1, colour) || blockedByForceField(X + 1, Y + 1, 0, -1, colour)];
				if (isCorner(neighbours, cornerInterrupted, 7, 0, 1))
					corners += 8;
					
				if (!block.isMobile() && !block.isLocked()) {
					if (isTransitionCorner(neighbours, transitions, 0, 1))
						transitionCorners += 1;
					if (isTransitionCorner(neighbours, transitions, 0, 2))
						transitionCorners += 2;
					if (isTransitionCorner(neighbours, transitions, 1, 3))
						transitionCorners += 4;
					if (isTransitionCorner(neighbours, transitions, 2, 3))
						transitionCorners += 8;
				}
				block.changeImage(frame, corners, transitions, transitionCorners);
			}
		}
		
		private function isMobile(block:Block):Boolean { // help method for autotiling
			if (block == null)
				return true;
			return (block.isMobile() || block.isLocked());
		}
		
		private function isTransitionCorner(neighbours:Array, transitions:int, index1:int, index2:int):Boolean { // help method for autotiling
			var trans1:Boolean = Boolean(transitions & (1 << index1));
			var trans2:Boolean = Boolean(transitions & (1 << index2));
			return ((trans1 && trans2) ||
					(trans1 && isMobile(neighbours[3 - index2])) ||
					(trans2 && isMobile(neighbours[3 - index1])));
		}
		
		private function isCorner(neighbours:Array, interrupted:Array, index1:int, index2:int, index3:int):Boolean { // help method for autotiling
			if (neighbours[index2] != null && neighbours[index3] != null) {
				if ((neighbours[index1] == null && !interrupted[0] && !interrupted[1]) ||
						(neighbours[index1] != null && (interrupted[0] || interrupted[1])))
					return true;
			}
			return false;
		}
		
		private function findWall(X:int, Y:int):Wall {
			if (X >= -1 && X < gridWidth + 1 && Y >= -1 && Y < gridHeight + 1)
				return walls[X+1][Y+1];
			else
				return null;
		}
		
		private function findWallsAround(X:int, Y:int):Array {
			var left:Wall = findWall(X - 1, Y);
			var up:Wall = findWall(X, Y - 1);
			var right:Wall = findWall(X + 1, Y);
			var down:Wall = findWall(X, Y + 1);;
			return [down, right, left, up];
		}
		
		private function autoTileWalls():void {
			for (var X:int = 0; X < gridWidth + 2; X++) {
				for (var Y:int = 0; Y < gridHeight + 2; Y++) {
					if (walls[X][Y] != null) {
						var neighbours:Array = findWallsAround(X-1, Y-1);
						var frame:int = 0;
						for (var i:int = 0; i < 4; i++)
							frame += (1 << i) * int(neighbours[i] != null);
						walls[X][Y].changeImage(frame);
					}
				}
			}
		}
		
		private function findForceField(X:int, Y:int):ForceField {
			if (X >= 0 && X < gridWidth && Y >= 0 && Y < gridHeight)
				return forceFields[X][Y];
			else
				return null;
		}
		
		private function findForceFieldsAround(X:int, Y:int):Array {
			var left:ForceField = findForceField(X - 1, Y);
			var up:ForceField = findForceField(X, Y - 1);
			var right:ForceField = findForceField(X + 1, Y);
			var down:ForceField = findForceField(X, Y + 1);;
			return [up, left, right, down];
		}
		
		private function autoTileForceFields():void {
			for (var X:int = 0; X < gridWidth; X++) {
				for (var Y:int = 0; Y < gridHeight; Y++) {
					if (forceFields[X][Y] != null) {
						var neighbours:Array = findForceFieldsAround(X, Y);
						var transitions:Array = [0, 0, 0, 0];
						for (var xdir:int = -1; xdir <= 1; xdir++) {
							for (var ydir:int = -1; ydir <= 1; ydir++) {
								if (Math.abs(xdir) + Math.abs(ydir) != 1)
									continue;
								var colour:int = forceFields[X][Y].getColour(xdir, ydir);
								if (colour == -1)
									continue;
								var index:int = J.getIndexFrom(xdir, ydir);
								var otherIndices:Array = J.getOppossiteIndices(index);
								var otherDirections:Array = J.getOppositeDirections(index);
								var internalTransitions:Array = [0, 0];
								for (var j:int = 0; j < 2; j++) {
									if (colour == forceFields[X][Y].getColour(otherDirections[j][0], otherDirections[j][1]))
										internalTransitions[j] = 2;
									else if (neighbours[otherIndices[j]] == null || neighbours[otherIndices[j]].getColour(xdir, ydir) != colour)
										internalTransitions[j] = 0;
									else if (neighbours[otherIndices[j]].getColour(
											otherDirections[(j + 1) % 2][0], otherDirections[(j + 1) % 2][1]) != colour)
										internalTransitions[j] = 1;
								}
								transitions[index] = 3 * internalTransitions[0] + internalTransitions[1];
							}
							
						}
						forceFields[X][Y].changeImage(transitions);
					}
				}
			}
		}
		
		private function makeShapePanel():void {
			if (amountGoalShapes == null)
				return;
			shapePanel = new ShapePanel(amountGoalShapes, coloursInGame,
				gridHeight >= 12 && contains(upGravityButton), 
				gridWidth >= 12 && contains(rightGravityButton));
			addChild(shapePanel);
		}
		
		public function addFragments(arr:Array):void {
			fragments = fragments.concat(arr);
		}
		
		private var winScreen:WinScreen;
		private function finishLevel():void {
			finished = true;
			//undoButton.deactivate();
			winScreen = new WinScreen(moves, this, official != 0);
			addChild(winScreen);
			winScreen.start();
		}
		
		public function replayLevel(tutorial:Boolean = false):void {
			if (tutorial) {
				revertState(true);
				bgParticles.changeDirection(gravityX, gravityY);
				changeGravityDirectionBorders();
			} else
				Main.BLManager.theroot.switchState(new GameState(data, official, mouse));
		}
		
		public function saveScoreAndNext():void {
			if (mouse != null)
				return;
			if (Main.isGreyOrRed()) {
				Main.BLManager.showInfo("You cannot score on a to be evaluated or rejected level.");
				return;
			}
			Main.BLManager.lvlCompleted(true, moves);
			if (Main.isYourLevel()) {
				if (Main.isAcceptedOrOfficial()) {
					try {
						if (Main.userData == null)
							throw new Error("The user data is null");
						var lvlid:int = Main.getLvlid();
						var uname:String = Main.Global.gamevars.uname;
						Main.addLvlidToUserData(lvlid);
						Main.sendUserData();
					} catch (e:Error) {
						Main.BLManager.showInfo("Error saving user data: " + e.message);
					}
				}
			}
			//if (Main.userData != null)
				//Main.BLManager.log("You scored on " + Main.userData[0].length + " accepted levels of yourself.", 2);
		}
		
		private function updateMouseCoordinates():void {
			if (virtualMouse) {
				mX = mouse.location.x;
				mY = mouse.location.y;
			} else {
				mX = mouseX;
				mY = mouseY;
			}
		}
		
		public function removeMouse():void {
			virtualMouse = false;
			if (mouse)
				mouse.game = null;
			mouse = null;
		}
		
		private var undoAllowed:Boolean = true;
		public function allowUndo():void {
			undoAllowed = true;
		}
		
		public function disableUndo():void {
			undoAllowed = false;
		}
		
		public function virtualMouseDown():void {
			clickedDown(null);
		}
		
		public function virtualMouseUp():void {
			clickedUp(null);
		}
		
		public function virtualMouseClick():void {
			updateMouseCoordinates();
			var mousePoint:Point = new Point(mX, mY)
			if (upGravityButton.getRect(this).containsPoint(mousePoint))
				gravityUp(null);
			if (leftGravityButton.getRect(this).containsPoint(mousePoint))
				gravityLeft(null);
			if (rightGravityButton.getRect(this).containsPoint(mousePoint))
				gravityRight(null);
			if (downGravityButton.getRect(this).containsPoint(mousePoint))
				gravityDown(null);
		}
	}
}