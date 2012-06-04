package {
	import com.ideaskill.projector.ProjectorCamera;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	
	[SWF(backgroundColor="0")]
	public class TestPaint extends Sprite {
		public var pcam:ProjectorCamera;
		public var canvas:BitmapData, frame:BitmapData, pixel:BitmapData;
		
		// http://www.youtube.com/watch?v=HSos8cGSVlg 
		public function TestPaint () {
			
			// add ProjectorCamera to display list and init webcam
			addChild (pcam = new ProjectorCamera);
			pcam.requestCamera ();
			
			// create bitmaps
			canvas = new BitmapData (stage.stageWidth, stage.stageHeight);
			frame = canvas.clone ();
			pixel = new BitmapData (1, 1);

			graphics.clear ();
			graphics.beginBitmapFill (canvas, null, false, true);
			graphics.drawRect (0, 0, stage.stageWidth, stage.stageHeight);
			graphics.endFill ();
			
			// go
			addEventListener (Event.ENTER_FRAME, loop);
		}
		
		// color transforms are simple, though not the best, way to do things below
		public var ct1:ColorTransform = new ColorTransform (1, 1, 1, 1, -210, -210, -210);
		public var ct2:ColorTransform = new ColorTransform (0.9, 0.9, 0.9);
		
		public function loop(e:Event):void {
			
			// draw projector perspective into frame
			pcam.drawTo (frame);
			
			// get average color (cheap alternative to histogram)
			pcam.drawTo (pixel);
			
			// apply simple ColorTransform to threshold the frame
			var c:uint = pixel.getPixel (0, 0);
			var s:Number = 2.0;
			ct1.redOffset   = -(((c & 0xff0000) >> 16) + s * 255) / (s + 1);
			ct1.greenOffset = -(((c & 0x00ff00) >> 8)  + s * 255) / (s + 1);
			ct1.blueOffset  = -( (c & 0x0000ff)        + s * 255) / (s + 1);
			frame.colorTransform (frame.rect, ct1);
			
			// add to canvas
			canvas.draw (frame, null, null, BlendMode.ADD);
			
			// fade canvas to prevent saturation (still needs low light environment)
			canvas.colorTransform (canvas.rect, ct2);
		}
	}
}