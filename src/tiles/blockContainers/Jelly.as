package tiles.blockContainers {
	
	import tiles.Block;

	public class Jelly {
		
		private var
			blocks:/*Block*/Array = [],
			colour:uint,
			freezeIt:Boolean,
			defrostIt:Boolean,
			jellyShape:JellyShape;
		
		public function Jelly(block:Block = null) {
			if (block != null) {
				blocks.push(block);
				colour = block.getColour();
			}
			jellyShape = new JellyShape(this);
		}
		
		public function setReadyToMove(ready:Boolean):void {
			jellyShape.setReadyToMove(ready);
		}
		
		public function setReadyToFall(falling:Boolean):void {
			for each (var block:Block in blocks)
				block.setReadyToFall(falling);
		}
		
		public function add(block:Block):void {
			var jelly:Jelly = block.getJelly();
			var otherBlocks:Array = jelly.getBlocks();
			for each (var jellyBlock:Block in otherBlocks) {
				blocks.push(jellyBlock);
				jellyBlock.setJelly(this);
			}
			jelly.getJellyShape().remove(jelly);
			getJellyShape().mergeWith(jelly.getJellyShape());
		}
		
		public function hasLocked():Boolean {
			for each (var block:Block in blocks) {
				if (block.isLocked())
					return true;
			}
			return false;
		}
		
		public function freeze():void {
			for each (var block:Block in blocks)
				block.setFrozen(true);
		}
		
		public function clone():Jelly {
			var clone:Jelly = new Jelly();
			clone.blocks = [];
			clone.colour = colour;
			clone.freezeIt = freezeIt;
			clone.defrostIt = defrostIt;
			return clone;
		}
		
		public function cloneAdd(block:Block):void {
			if (blocks.length == 0)
				colour = block.getColour();
			blocks.push(block);
			block.setJelly(this);
		}
		
		public function getCoordinatesFromBlocks():Array {
			var coordinates:Array = [];
			for each (var block:Block in blocks)
				coordinates.push([block.getX(), block.getY()]);
			return coordinates;
		}
		
		public function removeBlock(block:Block):void {
			var index:int = blocks.indexOf(block);
			if (index != -1)
				blocks.splice(index, 1);
			block.setJelly(new Jelly(block));
		}
		
		public function removeBlocksInNewShape(blocksToRemove:Array):Jelly {
			if (blocksToRemove.length == 0)
				return null;
			var jelly:Jelly = new Jelly();
			for (var i:int = 0; i < blocksToRemove.length; i++) {
				removeBlock(blocksToRemove[i]);
				jelly.cloneAdd(blocksToRemove[i]);
			}
			return jelly;
		}
		
		public function disband():void {
			for (var i:int = blocks.length - 1; i >= 0; i--) {
				var block:Block = blocks.pop();
				block.setJelly(new Jelly(block));
				var connections:Array = block.getConnections();
				if (connections != null && connections.length > 0)
					block.mergeJellyShapes(connections[0]);
			}
			jellyShape.remove(this);
		}
		
		public function shallowCopyBlocks():Array {
			var result:Array = [];
			for each (var block:Block in blocks)
				result.push(block);
			return result;
		}
		
		public function findBlock(X:int, Y:int):Block {
			for each (var block:Block in blocks) {
				if (block.getX() == X && block.getY() == Y)
					return block;
			}
			return null;
		}
		
		public function isMultiColoured():Boolean {
			if (isEmpty())
				return false;
			var colour:uint = blocks[0].getColour();
			for each (var block:Block in blocks) {
				if (block.getColour() != colour)
					return true;
			}
			return false;
		}
		
		public function isEmpty():Boolean { return blocks.length == 0; }
		public function getBlocks():Array { return this.blocks; }
		public function setJellyShape(shape:JellyShape):void { jellyShape = shape; }
		public function getJellyShape():JellyShape { return this.jellyShape; }
		public function getColour():uint { return this.colour; }
		public function needsToFreeze():void { freezeIt = true; }
		public function needsToDefrost():void { defrostIt = true; }
		public function resetFreezeOptions():void { freezeIt = false; defrostIt = false; }
		public function shouldBeFrozen():Boolean { return freezeIt && !defrostIt; }
		public function shouldBeDefrosted():Boolean { return !freezeIt && defrostIt; }
	}
}