package tiles {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import states.GameState;
	import tiles.Block;
	import tiles.Tile;
	import tiles.wallAttachments.*;
	
	public class Wall extends Tile {
		
		[Embed(source = "../../assets/img/walls.png")] private static const WALL:Class;
		
		private static const
			WALL_BITMAPDATA:Array = [];
		
		private var
			image:Bitmap,
			wallAttachments:Array = [],
			frame:int,
			gameState:GameState;
		
		public static function initBitmapData():void {
			var bit:BitmapData = new WALL().bitmapData;
			for (var i:int = 0; i < 16; i++)
				(WALL_BITMAPDATA[i] = new BitmapData(32, 32, true, 0)).copyPixels(
					bit, new Rectangle(0, i * 32, 32, 32), new Point(0, 0), null, null, true);
		}
		
		public function Wall(data:Array, gameState:GameState) {
			super(data[1], data[2]);
			this.gameState = gameState;
			addChild(image = new Bitmap(WALL_BITMAPDATA[0]));
			for (var i:int = 3; i < data.length; i++) {
				if (data[i] is Array && data[i][0] == 0)
					wallAttachments = J.getWallAttachments(data[i])
			}
		}
		
		public function changeImage(frame:int):void {
			this.frame = frame;
			removeChild(image);
			addChild(image = new Bitmap(WALL_BITMAPDATA[frame]));
			for each (var attachment:WallAttachment in wallAttachments) {
				attachment.changeImage(false);
				attachment.x = x;
				attachment.y = y;
			}
		}
		
		public function changeBlockNextTo(block:Block, start:Boolean, afterJellify:Boolean, spiking:Boolean):Boolean {
			var action:Boolean = false;
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
							a = attachment.changeBlock(block, false, this, gameState);
					} else {
						if ((!start || (attachment is Hinge)) && !(attachment is Spike))
							a = attachment.changeBlock(block, false, this, gameState);
					}
					action ||= a;
				}
			}
			return action;
		}
		
		public function changeWallAttachments(screen:Sprite):void {
			for (var i:int = wallAttachments.length - 1; i >= 0; i--) {
				if (wallAttachments[i] is Bomb && (wallAttachments[i] as Bomb).isReadyToExplode())
					wallAttachments[i].alpha = 0;
			}
		}
		
		public function hasHinge(xdir:int, ydir:int):Boolean {
			for each (var attachment:WallAttachment in wallAttachments) {
				if (attachment is Hinge) {
					if (attachment.getX() == xdir && attachment.getY() == ydir)
						return true;
				}
			}
			return false;
		}
		
		public function removeHinge(xdir:int, ydir:int, screen:Sprite):void {
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
		
		public function clone():Wall {
			var clone:Wall = new Wall([2, X, Y], gameState);
			clone.wallAttachments = [];
			for (var i:int = 0; i < wallAttachments.length; i++)
				clone.wallAttachments.push(wallAttachments[i].clone());
			clone.changeImage(frame);
			return clone;
		}
		
		public function getChangableData():Array {
			var arr:Array = [];
			for (var i:int = 0; i < wallAttachments.length; i++) {
				if (wallAttachments[i] is Bomb)
					arr.push((wallAttachments[i] as Bomb).getInfo());
				else if (wallAttachments[i] is Hinge)
					arr.push((wallAttachments[i] as Hinge).getInfo());
			}
			if (arr.length == 0)
				arr = null;
			return arr;
		}
		
		public function updateChangableData(data:Array, screen:Sprite):void {
			for (var j:int = 0; j < wallAttachments.length; j++) {
				if (wallAttachments[j] is Bomb)
					wallAttachments[j].makeInactive();
			}
			for (var i:int = 2; i < data.length; i++) {
				var type:int = data[i][0];
				var xDir:int = data[i][1];
				var yDir:int = data[i][2];
				if (type == 0) {
					for (j = 0; j < wallAttachments.length; j++) {
						if (wallAttachments[j] is Bomb) {
							var b:Bomb = (wallAttachments[j] as Bomb);
							if (b.getX() == xDir && b.getY() == yDir) {
								if (!data[i][3])
									wallAttachments[j].makeActive();
							}
						}
					}
				} else if (type == 1) {
					var found:Boolean = false;
					for (j = 0; j < wallAttachments.length; j++) {
						if (wallAttachments[j] is Hinge) {
							var h:Hinge = (wallAttachments[j] as Hinge);
							if (h.getX() == xDir && h.getY() == yDir) {
								found = true;
								break;
							}
						}
					}
					if (!found) {
						var hinge:Hinge = new Hinge(xDir, yDir);
						hinge.x = x;
						hinge.y = y;
						hinge.changeImage(false);
						wallAttachments.push(hinge);
						screen.addChild(hinge);
					}
				}
			}
		}
	}
}