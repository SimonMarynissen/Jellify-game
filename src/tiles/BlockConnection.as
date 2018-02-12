package tiles {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class BlockConnection extends Sprite {
		
		[Embed(source = "../../assets/img/chains.png")] private static const CHAINS:Class;
		
		private static const
			CHAIN_ENDS_BITMAPDATA:Array = [],
			CHAIN_BITMAPDATA:Array = [];
		
		public static function initBitmapData():void {
			var bit:BitmapData = new CHAINS().bitmapData;
			for (var i:int = 0; i < 4; i++) {
				var rectX:int = 32 - 16 * int(i == 2) - 32 * int(i == 1);
				var rectY:int = 16 * int(i == 3);
				var rectW:int = 32 - 16 * int(i == 1 || i == 2);
				var rectH:int = 32 - 16 * int(i == 0 || i == 3);
				var X:int = 16 * int(i == 2);
				var Y:int = 16 * int(i == 3);
				(CHAIN_ENDS_BITMAPDATA[i] = new BitmapData(32, 32, true, 0)).copyPixels(bit,
						new Rectangle(rectX, rectY, rectW, rectH), new Point(X, Y), null, null, true);
			}
			for (i = 0; i < 6; i++) {
				(CHAIN_BITMAPDATA[i] = new BitmapData(32, 32, true, 0)).copyPixels(bit,
						new Rectangle(((i + 2) % 4) * 32, Math.floor((i + 2) / 4) * 32, 32, 32),
						new Point(0, 0), null, null, true);
			}
			bit.dispose();
			bit = null;
		}
		
		private var
			first:Point,
			second:Point,
			firstDir:Point,
			secondDir:Point,
			block1:Point,
			block2:Point,
			firstBlock:Block;
		
		public function BlockConnection(arr:Array) {
			super();
			first = new Point(arr[0], arr[1]);
			second = new Point(arr[2], arr[3]);
			firstDir = new Point(J.getXDir(arr[4]), J.getYDir(arr[4]));
			secondDir = new Point(J.getXDir(arr[5]), J.getYDir(arr[5]));
			draw();
		}
		
		public function addFirstBlock(block:Block):void {
			block1 = new Point(block.getX(), block.getY());
			block.addConnectionSprite(this);
			this.x = block.x;
			this.y = block.y;
		}
		
		public function addSecondBlock(block:Block):void {
			block2 = new Point(block.getX(), block.getY());
			block.addConnectionSprite(this);
		}
		
		public function addActualFirstBlock(block:Block):void {
			firstBlock = block;
		}
		
		public function isFirst(block:Block):Boolean {
			return firstBlock == block;//block1.x == block.getX() && block1.y == block.getY();
		}
		
		public function isConnection(x1:int, y1:int, x2:int, y2:int):Boolean {
			return x1 == first.x && y1 == first.y && x2 == second.x && y2 == second.y;
		}
		
		public function getData():Array {
			return [block1.x, block1.y, block2.x, block2.y];
		}
		
		public function move(xdir:int, ydir:int):void {
			block1.x += xdir;
			block1.y += ydir;
			block2.x += xdir;
			block2.y += ydir;
		}
		
		private function draw():void {
			addEnds();
			var xDir:int = firstDir.x;
			var yDir:int = firstDir.y;
			var startX:int = first.x + xDir;
			var startY:int = first.y + yDir;
			var X:int = startX;
			var Y:int = startY;
			var endX:int = second.x + secondDir.x;
			var endY:int = second.y + secondDir.y;
			if (startX == second.x && startY == second.y && endX == first.x && endY == first.y)
				return;
			if (startX == second.x && startY == second.y) {
				addTilesInSpecialCase(startX, startY, firstDir, secondDir);
				return;
			} else if (endX == first.x && endY == first.y) {
				addTilesInSpecialCase(endX, endY, secondDir, firstDir);
				return;
			}
			while (X != endX || Y != endY) {
				var dist:int = Math.abs(X - endX) + Math.abs(Y - endY);
				var newDist:int = Math.abs(X + xDir - endX) + Math.abs(Y + yDir - endY);
				var wrongDirection:Boolean = (newDist > dist) ||
					((xDir != 0) && X + xDir == endX && ((endY < Y && secondDir.y == -1) || (endY > Y && secondDir.y == 1))) ||
					((yDir != 0) && Y + yDir == endY && ((endX < X && secondDir.x == -1) || (endX > X && secondDir.x == 1))) ||
					((X + xDir) == second.x && (Y + yDir) == second.y);
				if (wrongDirection) {
					var newX:int = X;
					var newY:int = Y;
					if (xDir != 0) {
						var d1:int = Math.abs(Y + 1 - endY);
						var d2:int = Math.abs(Y - 1 - endY);
						if (d1 < d2)
							newY += 1;
						else if (d1 > d2)
							newY -= 1;
						else
							newY += (xDir > 0) ? 1 : -1;
					} else if (yDir != 0) {
						d1 = Math.abs(X + 1 - endX);
						d2 = Math.abs(X - 1 - endX);
						if (d1 < d2)
							newX += 1;
						else if (d1 > d2)
							newX -= 1;
						else
							newX += (yDir > 0) ? -1 : 1;
					}
					if (newX == second.x && newY == second.y)
						addTile(X, Y, (xDir != 0) ? 0 : 1);
					else {
						if (xDir != 0) {
							d1 = Math.abs(Y + 1 - endY);
							d2 = Math.abs(Y - 1 - endY);
							if (d1 < d2) {
								addTile(X, Y, (xDir > 0) ? 5 : 4);
								yDir = 1;
							} else if (d1 > d2) {
								addTile(X, Y, (xDir > 0) ? 2 : 3);
								yDir = -1;
							} else {
								addTile(X, Y, (xDir > 0) ? 5 : 3);
								yDir = (xDir > 0) ? 1 : -1;
							}
							xDir = 0;
						} else if (yDir != 0) {
							d1 = Math.abs(X + 1 - endX);
							d2 = Math.abs(X - 1 - endX);
							if (d1 < d2) {
								addTile(X, Y, (yDir > 0) ? 3 : 4);
								xDir = 1;
							} else if (d1 > d2) {
								addTile(X, Y, (yDir > 0) ? 2 : 5);
								xDir = -1;
							} else {
								addTile(X, Y, (yDir > 0) ? 2 : 4);
								xDir = (yDir > 0) ? -1 : 1;
							}
							yDir = 0;
						}
					}
				} else
					addTile(X, Y, (xDir != 0) ? 0 : 1);
				X += xDir;
				Y += yDir;
			}
			if (xDir == -secondDir.x && yDir == -secondDir.y) {
				addTile(X, Y, (xDir != 0) ? 0 : 1);
			} else {
				if (xDir == 1 && yDir == 0)
					addTile(X, Y, (secondDir.y == 1) ? 2 : 5);
				else if (xDir == -1 && yDir == 0)
					addTile(X, Y, (secondDir.y == 1) ? 3 : 4);
				else if (xDir == 0 && yDir == 1)
					addTile(X, Y, (secondDir.x == 1) ? 2 : 3);
				else if (xDir == 0 && yDir == -1)
					addTile(X, Y, (secondDir.x == 1) ? 5 : 4);
			}
		}
		
		private function addTilesInSpecialCase(X:int, Y:int, dir1:Point, dir2:Point):void {
			if (dir1.x != 0) {
				if (dir2.x == 1) {
					addTile(X, Y, 5);
					addTile(X, Y + 1, 3);
					addTile(X + 1, Y + 1, 2);
					addTile(X + 1, Y, 5);
				} else if (dir2.x == -1) {
					addTile(X, Y, 3);
					addTile(X, Y - 1, 5);
					addTile(X - 1, Y - 1, 4);
					addTile(X - 1, Y, 3);
				}
				if (dir2.y == 1) {
					addTile(X, Y, 0);
					addTile(X + dir1.x, Y, (dir1.x == 1) ? 5 : 4);
					addTile(X + dir1.x, Y + 1, (dir1.x == 1) ? 2 : 3);
					addTile(X, Y + 1, (dir1.x == 1) ? 3 : 2);
				} else if (dir2.y == -1) {
					addTile(X, Y, 0);
					addTile(X + dir1.x, Y, (dir1.x == 1) ? 2 : 3);
					addTile(X + dir1.x, Y - 1, (dir1.x == 1) ? 5 : 4);
					addTile(X, Y - 1, (dir1.x == 1) ? 4 : 5);
				}
			} else {
				if (dir2.y == 1) {
					addTile(X, Y, 2);
					addTile(X - 1, Y, 4);
					addTile(X - 1, Y + 1, 3);
					addTile(X, Y + 1, 2);
				} else if (dir2.y == -1) {
					addTile(X, Y, 4);
					addTile(X + 1, Y, 2);
					addTile(X + 1, Y - 1, 5);
					addTile(X, Y - 1, 4);
				}
				if (dir2.x == 1) {
					addTile(X, Y, 1);
					addTile(X, Y + dir1.y, (dir1.y == 1) ? 3 : 4);
					addTile(X + 1, Y + dir1.y, (dir1.y == 1) ? 2 : 5);
					addTile(X + 1, Y, (dir1.y == 1) ? 5 : 2);
				} else if (dir2.x == -1) {
					addTile(X, Y, 1);
					addTile(X, Y + dir1.y, (dir1.y == 1) ? 2 : 5);
					addTile(X - 1, Y + dir1.y, (dir1.y == 1) ? 3 : 4);
					addTile(X - 1, Y, (dir1.y == 1) ? 4 : 3);
				}
			}
		}
		
		private function addTile(X:int, Y:int, tileId:int):void {
			var bit:Bitmap = new Bitmap(CHAIN_BITMAPDATA[tileId]);
			bit.x = 32 * (X - first.x);
			bit.y = 32 * (Y - first.y);
			addChild(bit);
		}
		
		private function addEnds():void {
			var start:Bitmap = new Bitmap(CHAIN_ENDS_BITMAPDATA[J.getIndexFrom(firstDir.x, firstDir.y)]);
			addChild(start);
			var end:Bitmap = new Bitmap(CHAIN_ENDS_BITMAPDATA[J.getIndexFrom(secondDir.x, secondDir.y)]);
			end.x = 32 * (second.x - first.x);
			end.y = 32 * (second.y - first.y);
			addChild(end);
		}
	}
}