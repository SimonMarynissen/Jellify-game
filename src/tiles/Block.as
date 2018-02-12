package tiles {
	
	import caurina.transitions.Tweener;
	import caurina.transitions.properties.ColorShortcuts;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import gui.BlockFragment;
	import states.GameState;
	import tiles.Tile;
	import tiles.blockContainers.Jelly;
	import tiles.wallAttachments.*;

	public class Block extends Tile {
		
		[Embed(source = "../../assets/img/blocks.png")] private static const MOBILE_BLOCK:Class;
		[Embed(source = "../../assets/img/immobileBlocks.png")] private static const IMMOBILE_BLOCK:Class;
		[Embed(source = "../../assets/img/blockTransitions.png")] private static const BLOCK_TRANSITION:Class;
		[Embed(source = "../../assets/img/locked.png")] private static const LOCKED:Class;
		[Embed(source = "../../assets/img/blocksFrozen.png")] private static const FROZEN:Class;
		[Embed(source = "../../assets/img/blockSelection.png")] private static const SELECTION:Class;
		[Embed(source = "../../assets/img/moveCount.png")] private static const MOVE_COUNT:Class;
		
		private static const
			MOBILE_FRAMES:Array = [],
			MOBILE_CORNERS:Array = [],
			IMMOBILE_FRAMES:Array = [],
			IMMOBILE_CORNERS:Array = [],
			TRANSITIONS:Array = [],
			FROZEN_FRAMES:Array = [],
			FROZEN_CORNERS:Array = [],
			MOVE_COUNT_BITMAPDATA:Array = [];
			
		private static var
			LOCKED_BITMAPDATA:BitmapData,
			SELECTION_BITMAPDATA:BitmapData;
			
		public var
			wallBlockSeparation:int = 0;
		
		private var
			colour:uint,
			locked:Boolean,
			mobile:Boolean,
			movesLeft:int = -1,
			frozen:Boolean,
			jelly:Jelly,
			readyToMove:Boolean,
			readyToFall:Boolean,
			readyToExplode:Boolean = false,
			wallAttachments:Array = [],
			paints:Array = [], // makes sure that multiple colour changers won't paint the block
			overImage:Bitmap,
			selectionImage:Bitmap,
			frame:int,
			corners:int,
			transitions:int,
			transitionCorners:int,
			gameState:GameState,
			animations:Array = [],
			movements:Array = [],
			bitmapData:BitmapData,
			sliced:/*Boolean*/Array = [false, false, false, false],
			connections:/*Block*/Array,
			connectionCoordinates:Array,
			connectionSprites:/*BlockConnection*/Array;
			
		public static function initBitmapData():void {
			ColorShortcuts.init();
			var mobileBits:BitmapData = new MOBILE_BLOCK().bitmapData;
			var immobileBits:BitmapData = new IMMOBILE_BLOCK().bitmapData;
			var transitionBits:BitmapData = new BLOCK_TRANSITION().bitmapData;
			var frozenBits:BitmapData = new FROZEN().bitmapData;
			var moveCountBits:BitmapData = new MOVE_COUNT().bitmapData;
			for (var i:int = 0; i <= 11; i++) {
				MOBILE_FRAMES[i] = [];
				MOBILE_CORNERS[i] = [];
				IMMOBILE_FRAMES[i] = [];
				IMMOBILE_CORNERS[i] = [];
				TRANSITIONS[i] = [];
				MOVE_COUNT_BITMAPDATA[i] = [];
				for (var j:int = 0; j < 16; j++) {
					(MOBILE_FRAMES[i][j] = new BitmapData(32, 32, true, 0)).copyPixels(
						mobileBits, new Rectangle(32 * i, 32 * j, 32, 32),
						new Point(0, 0), null, null, true);
					(IMMOBILE_FRAMES[i][j] = new BitmapData(32, 32, true, 0)).copyPixels(
						immobileBits, new Rectangle(32 * i, 32 * j, 32, 32),
						new Point(0, 0), null, null, true);
				}
				for (j = 0; j < 9; j++) {
					(MOVE_COUNT_BITMAPDATA[i][j] = new BitmapData(32, 32, true, 0)).copyPixels(
						moveCountBits, new Rectangle((8 - j) * 8, 12 * i, 8, 12),
						new Point(12, 10), null, null, true);
				}
				for (j = 0; j < 4; j++) {
					(MOBILE_CORNERS[i][j] = new BitmapData(32, 32, true, 0)).copyPixels(
						mobileBits, new Rectangle(32 * i + (j % 2) * 16, 512 + Math.floor(j / 2) * 16, 16, 16),
						new Point((j % 2) * 16, Math.floor(j / 2) * 16), null, null, true);
					(IMMOBILE_CORNERS[i][j] = new BitmapData(32, 32, true, 0)).copyPixels(
						immobileBits, new Rectangle(32 * i + (j % 2) * 16, 512 + Math.floor(j / 2) * 16, 16, 16),
						new Point((j % 2) * 16, Math.floor(j / 2) * 16), null, null, true);
					var bitX:int = 6 + 10 * (j % 2);
					var bitY:int = 6 + 10 * Math.floor(j / 2);
					(TRANSITIONS[i][4 + j] = new BitmapData(32, 32, true, 0)).copyPixels(
						transitionBits, new Rectangle(32 * i + bitX, bitY, 10, 10),
						new Point(bitX, bitY), null, null, true);
				}
				for (j = 0; j < 2; j++) {
					(TRANSITIONS[i][j+1] = new BitmapData(32, 32, true, 0)).copyPixels(
						transitionBits, new Rectangle(32 * i + 20 * j, 40, 12, 16), new Point(20 * j, 8), null, null, true);
					(TRANSITIONS[i][3 * j] = new BitmapData(32, 32, true, 0)).copyPixels(
						transitionBits, new Rectangle(32 * i + 8, 64 + 20 * j, 16, 12), new Point(8, 20 * j), null, null, true);
				}
			}
			for (i = 0; i < 16; i++) {
				(FROZEN_FRAMES[i] = new BitmapData(32, 32, true, 0)).copyPixels(
						frozenBits, new Rectangle(0, 32 * i, 32, 32),
						new Point(), null, null, true);
			}
			for (i = 0; i < 4; i++) {
				(FROZEN_CORNERS[i] = new BitmapData(32, 32, true, 0)).copyPixels(
						frozenBits, new Rectangle((i % 2) * 16, 512 + Math.floor(i / 2) * 16, 16, 16),
						new Point((i % 2) * 16, Math.floor(i / 2) * 16), null, null, true);
			}
			LOCKED_BITMAPDATA = new LOCKED().bitmapData;
			SELECTION_BITMAPDATA = new SELECTION().bitmapData;
			mobileBits.dispose();
			immobileBits.dispose();
			transitionBits.dispose();
			frozenBits.dispose();
			moveCountBits.dispose();
		}
		
		public function Block(data:Array, gameState:GameState, info:Array = null) {
			super((info == null) ? data[1] : info[0], (info == null) ? data[2] : info[1]);
			if (info == null) {
				this.colour = data[3];
				setJelly(new Jelly(this));
				if (data[4] == 2)
					locked = true;
				if (data[4] >= 3)
					movesLeft = data[4] - 2;
				else if (data[4] == 1 || data[4] == 2)
					movesLeft = 0;
				if (data[4] != 1 && data[4] != 2)
					mobile = true;
				if (colour == J.WALL_BLOCK_COLOUR) { // moving wall
					for (var i:int = 4; i < data.length; i++) {
						if (data[i] is Array && data[i][0] == 0)
							wallAttachments = J.getWallAttachments(data[i])
					}
				}
				selectionImage = new Bitmap(SELECTION_BITMAPDATA);
				selectionImage.x = -8;
				selectionImage.y = -8;
				selectionImage.alpha = 0;
				connections = [];
				connectionSprites = [];
				changeImage(0, 0, 0, 0);
			} else {
				//return [X, Y, colour, frame, corners, transitions, transitionCorners, locked, mobile, frozen, attachments, movesLeft];
				this.colour = info[2];
				this.frame = info[3];
				this.corners = info[4];
				this.transitions = info[5];
				this.transitionCorners = info[6];
				this.locked = info[7];
				this.mobile = info[8];
				this.frozen = info[9];
				for (i = 0; i < info[10].length; i++)
					wallAttachments.push(info[10][i].clone());
				this.movesLeft = info[11];
				this.connectionCoordinates = info[12];
				(info[info.length - 1] as Jelly).cloneAdd(this);
				selectionImage = new Bitmap(SELECTION_BITMAPDATA);
				selectionImage.x = -8;
				selectionImage.y = -8;
				selectionImage.alpha = 0;
				connections = [];
				connectionSprites = [];
				changeImage(frame, corners, transitions, transitionCorners);
			}
			this.gameState = gameState;
			buttonMode = (isMobile() && !isLocked());
			addListeners();
		}
		
		private function mouseOver(e:MouseEvent):void {
			if (isMobile() && !jelly.getJellyShape().hasLockedBlocks()) {
				for each (var jel:Jelly in jelly.getJellyShape().getJellies()) {
					for each (var block:Block in jel.getBlocks())
						block.tintChangeWhenOver();
				}
			}
		}
		
		public function tintChangeWhenOver():void {
			Tweener.addTween(this, {_tintBrightness:0.3, time:1, transition:J.easeFast});
		}
		
		private function mouseOut(e:MouseEvent):void {
			for each (var jel:Jelly in jelly.getJellyShape().getJellies()) {
				for each (var block:Block in jel.getBlocks())
					block.tintChangeWhenOut();
			}
		}
		
		private function tintChangeWhenOut():void {
			Tweener.addTween(this, {_tintBrightness:0, time:1, transition:"easeOutExpo"});
		}
		
		private var selectionIsAnimating:Boolean = false;
		private var targetAlpha:Number = 0;
		public function startSelectionAnimation():void {
			if (!isMobile() || isLocked())
				return;
			addChild(selectionImage);
			selectionIsAnimating = true;
			selectionImage.alpha = 1;
			targetAlpha = 1;
			onCompleteSelectionAnimation();
		}
		
		public function stopSelectionAnimation():void {
			selectionIsAnimating = false;
			selectionImage.alpha = 0;
			if (contains(selectionImage))
				removeChild(selectionImage);
			targetAlpha = 0;
		}
		
		private function onCompleteSelectionAnimation(e:Event = null):void {
			targetAlpha = 1.25 - targetAlpha;
			if (selectionIsAnimating)
				Tweener.addTween(selectionImage, { alpha:targetAlpha, time:0.5, transition:"easeInOutSine", onComplete:onCompleteSelectionAnimation});
			else {
				Tweener.removeTweens(selectionImage, "alpha");
				selectionImage.alpha = 0;
				if (contains(selectionImage))
					removeChild(selectionImage);
				//Tweener.addTween(selectionImage, { alpha:0, time:0.01, transition:"easeOutExpo", onComplete:function():void {
					//if (contains(selectionImage))
						//removeChild(selectionImage);
				//}});
			}
		}
		
		public function changeImage(frame:int, corners:int, transitions:int, transitionCorners:int):void {
			if (bitmapData != null)
				bitmapData.dispose();
			bitmapData = new BitmapData(32, 32, true, 0);
			this.frame = frame;
			this.corners = corners;
			this.transitions = transitions;
			this.transitionCorners = transitionCorners;
			if (mobile || locked) 
				addToBitmapData(MOBILE_FRAMES[colour][frame]);
			else
				addToBitmapData(IMMOBILE_FRAMES[colour][frame]);
			for (var i:int = 0; i < 4; i++) {
				if (corners & (1 << i)) {
					if (mobile || locked)
						addToBitmapData(MOBILE_CORNERS[colour][i]);
					else
						addToBitmapData(IMMOBILE_CORNERS[colour][i]);
				}
			}
			for (i = 0; i < 4; i++) {
				if (transitions & (1 << i))
					addToBitmapData(TRANSITIONS[colour][i]);
			}
			for (i = 0; i < 4; i++) {
				if (transitionCorners & (1 << i))
					addToBitmapData(TRANSITIONS[colour][i + 4]);
			}
			if (locked)
				addToBitmapData(LOCKED_BITMAPDATA);
			if (frozen) {
				addToBitmapData(FROZEN_FRAMES[frame])
				for (i = 0; i < 4; i++) {
					if (corners & (1 << i))
						addToBitmapData(FROZEN_CORNERS[i]);
				}
			}
			if (!locked && mobile && movesLeft >= 1)
				addToBitmapData(MOVE_COUNT_BITMAPDATA[colour][movesLeft - 1]);
			if (overImage != null) {
				if (contains(overImage))
					removeChild(overImage);
				overImage.bitmapData.dispose();
			}
			addChild(overImage = new Bitmap(bitmapData));
			if (colour == J.WALL_BLOCK_COLOUR) {
				for each (var attachment:WallAttachment in wallAttachments) {
					attachment.changeImage(true);
					attachment.x = x;
					attachment.y = y;
				}
			}
			for (i = 0; i < connectionSprites.length; i++) {
				if (connectionSprites[i].isFirst(this)) {
					connectionSprites[i].x = x;
					connectionSprites[i].y = y;
				}
			}
		}
		
		private function addToBitmapData(bits:BitmapData):void {
			bitmapData.copyPixels(bits, new Rectangle(0, 0, 32, 32), new Point(0, 0), null, null, true);
		}
		
		public function changeBlockNextTo(block:Block, start:Boolean, afterJellify:Boolean, spiking:Boolean):Boolean {
			var action:Boolean = false;
			if (colour != J.WALL_BLOCK_COLOUR)
				return action;
			var xDir:int = block.getX() - this.getX();
			var yDir:int = block.getY() - this.getY();
			if (Math.abs(xDir) + Math.abs(yDir) == 2)
				return action;
			for each (var attachment:WallAttachment in wallAttachments) {
				if (attachment.getX() == xDir && attachment.getY() == yDir) {
					var isAfterJellify:Boolean = J.isAttachmentAfterJellify(attachment);
					if (afterJellify != isAfterJellify)
						continue;
					var a:Boolean = false;
					if (spiking) {
						if (!start && (attachment is Spike))
							a = attachment.changeBlock(block, true, this, gameState);
					} else {
						if ((!start || (attachment is Hinge)) && !(attachment is Spike))
							a = attachment.changeBlock(block, true, this, gameState);
					}
					action ||= a;
				}
			}
			return action;
		}
		
		public function addAnimation(typeAndOptions:Array):void {
			//animations.push(typeAndOptions);
		}
		
		public function addMovement(xdir:int, ydir:int, gameStarted:Boolean = true):void {
			for (var i:int = 0; i < connectionSprites.length; i++) {
				if (connectionSprites[i].isFirst(this))
					connectionSprites[i].move(xdir, ydir);
			}
			X += xdir;
			Y += ydir;
			if (!gameStarted) {
				x += GameState.cellWidth * xdir;
				y += GameState.cellWidth * ydir;
				for each (var attachment:WallAttachment in wallAttachments) {
					attachment.x = x;
					attachment.y = y;
				}
				for (i = 0; i < connectionSprites.length; i++) {
					if (connectionSprites[i].isFirst(this)) {
						connectionSprites[i].x = x;
						connectionSprites[i].y = y;
					}
				}
			} else
				movements.push([xdir, ydir]);
		}
		
		public function move(gravityX:int, gravityY:int):void {
			if (movements.length == 0)
				return;
			var startIndex:int = 0;
			for (var i:int = 1; i < movements.length; i++) {
				if (movements[i][0] != movements[startIndex][0] || movements[i][1] != movements[startIndex][1]) {
					if (movements[startIndex][0] != 0)
						animations.push([0, movements[startIndex][0] * (i - startIndex)]);
					else if (movements[startIndex][1] != 0)
						animations.push([1, movements[startIndex][1] * (i - startIndex)]);
					startIndex = i;
				}
			}
			if (startIndex != movements.length - 1) {
				if (movements[startIndex][0] != 0)
					animations.push([0, movements[startIndex][0] * (movements.length - startIndex)]);
				else if (movements[startIndex][1] != 0)
					animations.push([1, movements[startIndex][1] * (movements.length - startIndex)]);
			} else if (startIndex == 0) {
				if (movements[startIndex][0] != 0)
					animations.push([0, movements[startIndex][0]]);
				else if (movements[startIndex][1] != 0)
					animations.push([1, movements[startIndex][1]]);
			}
			movements = [];
		}
		
		public function hasAnimations():Boolean {
			return animations.length != 0;
		}
		
		public function mergeWith(block:Block):void {
			if (jelly == block.getJelly())
				return;
			if (colour == J.WALL_BLOCK_COLOUR && block.colour == J.WALL_BLOCK_COLOUR) {
				if (wallBlockSeparation != block.wallBlockSeparation)
					return;
			}
			jelly.add(block);
		}
		
		public function mergeJellyShapes(block:Block):void {
			if (block.getJelly().getJellyShape() != jelly.getJellyShape())
				jelly.getJellyShape().mergeWith(block.getJelly().getJellyShape());
		}
		
		public function hasLockedBlocksInShape():Boolean {
			return getJelly().getJellyShape().hasLockedBlocks();
		}
		
		public function changeWallAttachments(screen:Sprite):void {
			for (var i:int = wallAttachments.length - 1; i >= 0; i--) {
				if (wallAttachments[i] is Bomb && (wallAttachments[i] as Bomb).isReadyToExplode())
					wallAttachments[i].alpha = 0;
			}
		}
		
		public function hasHinge(xdir:int, ydir:int):Boolean {
			if (colour != J.WALL_BLOCK_COLOUR)
				return false;
			for each (var attachment:WallAttachment in wallAttachments) {
				if (attachment is Hinge) {
					if (attachment.getX() == xdir && attachment.getY() == ydir)
						return true;
				}
			}
			return false;
		}
		
		public function removeHinge(xdir:int, ydir:int, screen:Sprite):void {
			if (colour != J.WALL_BLOCK_COLOUR)
				return;
			for (var i:int = 0; i < wallAttachments.length; i++) {
				if (wallAttachments[i] is Hinge) {
					if (wallAttachments[i].getX() == xdir && wallAttachments[i].getY() == ydir) {
						if (screen.contains(wallAttachments[i]))
							screen.removeChild(wallAttachments[i]);
						wallAttachments[i] = null;
						wallAttachments.splice(i, 1);
						return;
					}
				}
			}
		}
		
		public function addWallAttachmentsTo(screen:Sprite):void {
			for each (var attachment:WallAttachment in wallAttachments)
				screen.addChild(attachment);
		}
		
		public function removeWallAttachmentsFrom(screen:Sprite):void {
			for each (var attachment:WallAttachment in wallAttachments)
				screen.removeChild(attachment);
		}
		
		public function addListeners():void {
			if (!hasEventListener(MouseEvent.ROLL_OVER))
				addEventListener(MouseEvent.ROLL_OVER, mouseOver);
			if (!hasEventListener(MouseEvent.ROLL_OUT))
				addEventListener(MouseEvent.ROLL_OUT, mouseOut);
		}
		
		public function removeListeners():void {
			if (hasEventListener(MouseEvent.ROLL_OVER))
				removeEventListener(MouseEvent.ROLL_OVER, mouseOver);
			if (hasEventListener(MouseEvent.ROLL_OUT))
				removeEventListener(MouseEvent.ROLL_OUT, mouseOut);
		}
		
		public function clone():Block {
			var clone:Block = new Block([1, X, Y, colour], gameState);
			clone.removeListeners();
			clone.readyToMove = readyToMove;
			clone.readyToFall = readyToFall;
			clone.mobile = mobile;
			clone.frozen = frozen;
			clone.locked = locked;
			clone.wallAttachments = [];
			clone.buttonMode = buttonMode;
			for (var i:int = 0; i < wallAttachments.length; i++)
				clone.wallAttachments.push(wallAttachments[i].clone());
			clone.changeImage(frame, corners, transitions, transitionCorners);
			return clone;
		}
		
		public function getFragments():Array {
			var fragments:Array = [];
			var bat:BitmapData = overImage.bitmapData;
			for (var X:int = 0; X < 8; X++) {
				for (var Y:int = 0; Y < 8; Y++) {
					var bit:BitmapData = new BitmapData(4, 4, true, 0);
					bit.copyPixels(bat, new Rectangle(4 * X, 4 * Y, 4, 4), new Point(0, 0), null, null, true);
					fragments.push(new BlockFragment(x + 4 * X, y + 4 * Y, bit));
				}
			}
			return fragments;
		}
		
		private var
			movingX:Boolean = false,
			targetX:int,
			left:Boolean,
			movingY:Boolean = false,
			targetY:int,
			up:Boolean;
		private function doFirstAnimationInRow():void {
			if (animations[0][0] == 0) {
				movingX = true;
				targetX = x + animations[0][1] * GameState.cellWidth;
				left = (targetX <= x) ? true : false;
				Tweener.addTween(this, { x:targetX,
					time:0.1 * Math.abs(animations[0][1]), transition:J.easeFast/*"easeOutExpo"*/,
					onComplete:onEndAnimation, onUpdate:updateAttachmentsOnAnimation
				});
			} else if (animations[0][0] == 1) {
				movingY = true;
				targetY = y + animations[0][1] * GameState.cellWidth;
				up = (targetY <= y) ? true : false;
				Tweener.addTween(this, { y:targetY,
					time:0.1 * Math.abs(animations[0][1]), transition:J.easeFast/*"easeOutExpo"*/,
					onComplete:onEndAnimation, onUpdate:updateAttachmentsOnAnimation
				});
			}
		}
		
		private function updateAttachmentsOnAnimation():void {
			if (colour == J.WALL_BLOCK_COLOUR) {
				for each (var attachment:WallAttachment in wallAttachments) {
					attachment.changeImage(true);
					attachment.x = x;
					attachment.y = y;
				}
			}
			for (var i:int = 0; i < connectionSprites.length; i++) {
				if (connectionSprites[i].isFirst(this)) {
					connectionSprites[i].x = x;
					connectionSprites[i].y = y;
				}
			}
			if (movingX) {
				if ((left && x < targetX) || (!left && targetX < x)) {
					Tweener.removeTweens(this, "x");
					Tweener.addTween(this, {x:targetX, onComplete:onEndAnimation, onUpdate:updateAttachmentsOnAnimation});
				}
			}
			if (movingY) {
				if ((up && y < targetY) || (!up && targetY < y)) {
					Tweener.removeTweens(this, "y");
					Tweener.addTween(this, {y:targetY, onComplete:onEndAnimation, onUpdate:updateAttachmentsOnAnimation});
				}
			}
		}
		
		private function onEndAnimation(e:Event = null):void {
			movingX = false;
			movingY = false;
			animations.shift();
			startAnimating();
		}
		
		public function startAnimating():void {
			if (animations.length > 0)
				doFirstAnimationInRow();
		}
		
		public function getInfo():Array {
			var attachments:Array = [];
			for (var i:int = 0; i < wallAttachments.length; i++) {
				if (wallAttachments[i] is Bomb) {
					var bomb:Bomb = wallAttachments[i] as Bomb;
					if (bomb.isReadyToExplode())
						continue;
				}
				attachments.push(wallAttachments[i].clone());
			}
			var connectionCoordinates:Array = [];
			for (var j:int = 0; j < connections.length; j++)
				connectionCoordinates.push([connections[j].getX(), connections[j].getY()]);
			return [X, Y, colour, frame, corners, transitions, transitionCorners, locked, mobile, frozen, attachments, movesLeft, connectionCoordinates];
		}
		
		public function getColour():uint { return this.colour; }
		public function setColour(colour:uint):void { this.colour = colour; }
		public function isLocked():Boolean { return this.locked; }
		public function setLocked(locked:Boolean):void {
			this.locked = locked;
			buttonMode = (isMobile() && !isLocked());
		}
		public function isMobile():Boolean { return this.mobile; }
		public function decrementMovesLeft():void {
			if (movesLeft != -1) {
				this.movesLeft--;
				if (movesLeft < 1)
					mobile = false;
				buttonMode = (isMobile() && !isLocked());
				changeImage(frame, corners, transitions, transitionCorners);
			}
		}
		public function slice(xdir:int, ydir:int):void {
			sliced[J.getIndexFrom(xdir, ydir)] = true;
		}
		
		public function getSlice(xdir:int, ydir:int):Boolean {
			return sliced[J.getIndexFrom(xdir, ydir)];
		}
		
		public function resetSlices():void {
			sliced = [false, false, false, false];
		}
		
		public function addConnection(block:Block, connection:BlockConnection):void {
			if (connections.indexOf(block) == -1) {
				connections.push(block);
				block.connections.push(this);
				mergeJellyShapes(block);
				connection.addFirstBlock(this);
				connection.addSecondBlock(block);
			}
		}
		
		public function addConnectionSprite(connection:BlockConnection):void {
			connectionSprites.push(connection);
			if (connection.isFirst(this)) {
				connection.x = x;
				connection.y = x;
			}
		}
		
		public function removeAllConnections(screen:Sprite):void {
			for (var i:int = 0; i < connections.length; i++) {
				var index:int = connections[i].connections.indexOf(this);
				if (index != -1)
					connections[i].connections.splice(index, 1);
			}
			connections = [];
			if (connectionSprites != null) {
				for (i = 0; i < connectionSprites.length; i++) {
					if (screen.contains(connectionSprites[i]))
						screen.removeChild(connectionSprites[i]);
						
				}
			}
			connectionSprites = [];
		}
		
		public function getConnections():Array { return this.connections; }
		public function getConnectionCoordinates():Array { return this.connectionCoordinates; }
		public function getMovesLeft():int { return this.movesLeft; }
		public function setFrozen(frozen:Boolean):void { this.frozen = frozen; }
		public function isFrozen():Boolean { return this.frozen; }
		public function setJelly(jelly:Jelly):void { this.jelly = jelly; }
		public function getJelly():Jelly { return this.jelly; }
		public function isReadyToMove():Boolean { return this.readyToMove; }
		public function setReadyToMove(ready:Boolean):void { readyToMove = ready; }
		public function isReadyToFall():Boolean { return this.readyToFall; }
		public function setReadyToFall(falling:Boolean):void { readyToFall = falling; }
		private var explosionDirections:Array = [];
		public function addExplosionDirection(direction:Array):void { explosionDirections.push(direction); }
		public function getExplosionDirections():Array { return explosionDirections; }
		public function resetExplosionDirections():void { explosionDirections = []; }
		public function setReadyToExplode():void { this.readyToExplode = true; }
		public function isReadyToExplode():Boolean { return this.readyToExplode; }
		public function setPaints(paints:Array):void { this.paints = paints; }
		public function getPaints():Array { return this.paints; }
		public function addPaint(paint:int):void { paints.push(paint); }
		public function isInSameShapeWith(block:Block):Boolean { return getJelly().getJellyShape() == block.getJelly().getJellyShape(); }
	}
}