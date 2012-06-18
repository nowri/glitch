package inn.nowri.ka.glitch.timerglitch.vo
{
	import flash.display.BitmapData;

	public class UpdateObj
	{
		public var bmd:BitmapData;
		public var x:int;
		public var y:int;
		public function UpdateObj(bmd:BitmapData, x:int, y:int)
		{
			this.bmd = bmd;
			this.x = x;
			this.y = y;
		}
		
		public function destroy():void
		{
			if(bmd)bmd.dispose();
		}
	}
}