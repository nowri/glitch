//--------------------------------------------------------------------------
//	
//	
//  @author : nowri.ka
//  @date : 2012/06/18
//
//--------------------------------------------------------------------------


//original copyrights
/**		
 * 
 *	Glitchmap
 *	
 *	@version 1.00 | Feb 2, 2010
 *	@author Justin Windle
 *	@see http://blog.soulwire.co.uk
 *  
 **/

package inn.nowri.ka.glitch.timerglitch 
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import inn.nowri.ka.glitch.timerglitch.vo.UpdateObj;
	
	/**
	 * Glitchmap
	 */
	[Event(name="change", type="flash.events.Event")]
	[Event(name="complete", type="flash.events.Event")]
	public class RayGlitch extends TimerGlitch 
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		public function RayGlitch(path : String = null, amount:int=50, limit:int=50)
		{
			super(path, amount, limit);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		private var glitchWidth:int;
		private var baseX:int;
		private var topOrBottom:String;

		//--------------------------------------------------------------------------
		//
		//  Override methods
		//
		//--------------------------------------------------------------------------
		override public function next():Boolean
		{
			if(++_count<_limit)
			{
				var nums:int = int(Math.random()*16);
				var timer:Timer = new Timer(100, nums);
				
				glitchWidth = int(Math.random()*50)+10;
				baseX = int((_bitmapDataOrigin.width-glitchWidth)*Math.random());
				topOrBottom = (Math.random()>=0.5)? "top":"bottom";
				timer.addEventListener(TimerEvent.TIMER, timerGlitchEventHandler);
				timer.start();
				timerGlitchEventHandler();
				return true;
			}
			return false;
		}
		
		protected function timerGlitchEventHandler(e:TimerEvent=null):void
		{
			paramRandomize();
			updateRectObj = getUpdateObj();
			bytesSource = encoder.encode(updateRectObj.bmd);
		}
		
		override protected function getUpdateObj():UpdateObj
		{
			var w:int =	1;
			var h:int =	int(_bitmapDataOrigin.height*Math.random()*2/3)+1;
			var x:int = int(Math.random()*glitchWidth-glitchWidth/2+baseX);
			var y:int =(topOrBottom=="top")? 0:_bitmapDataOrigin.height-h;

			var bmd:BitmapData = new BitmapData(w, h, true, 0x00);
			bmd.copyPixels(_bitmapData, new Rectangle(x,y,w,h), drawPt);
			return new UpdateObj(bmd, x, y);
		}
	}
}
