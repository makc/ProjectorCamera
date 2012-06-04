package {
	import com.ideaskill.projector.ProjectorCamera;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.filters.ConvolutionFilter;
	import flash.geom.Matrix;
	import flash.ui.Keyboard;
	
	[SWF(backgroundColor="0")]
	public class Test extends Sprite {
		public var pcam:ProjectorCamera;
		public function Test () {
			// add ProjectorCamera to display list and init webcam
			addChild (pcam = new ProjectorCamera);
			pcam.requestCamera ();
			
			// in this simple test, we're going to wait for ENTER key
			stage.addEventListener (KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		public function onKeyDown(e:KeyboardEvent):void {
			// and when ENTER is pressed, we:
			if (e.keyCode == Keyboard.ENTER) {
				stage.removeEventListener (KeyboardEvent.KEY_DOWN, onKeyDown);
				
				// create BitmapData of any size
				var s:Number = 5;
				var bd:BitmapData = new BitmapData (stage.stageWidth / s, stage.stageHeight / s);
				
				// get projector perspective drawn into it
				pcam.drawTo (bd);
				
				// apply simple convolution filter to highlight edges
				bd.applyFilter (bd, bd.rect, bd.rect.topLeft, new ConvolutionFilter (3, 3, [
					-1, -1, -1,
					-1, +8, -1,
					-1, -1, -1
				]));
				
				// project the result
				graphics.clear ();
				graphics.beginBitmapFill (bd, new Matrix (s, 0, 0, s), false, true);
				graphics.drawRect (0, 0, stage.stageWidth, stage.stageHeight);
				graphics.endFill ();
			}
		}
	}
}