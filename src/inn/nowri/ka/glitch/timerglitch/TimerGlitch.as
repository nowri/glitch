////////////////////////////////////////////////////////////////////////////////
//
//  nowri
//  Copyright 2012 http://nowei.in
//  All Rights Reserved.
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @author nowri.ka
 * @update Apr 14, 2012
 */


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
	import com.adobe.images.JPGEncoder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import inn.nowri.ka.glitch.core.Glitchmap;
	import inn.nowri.ka.glitch.timerglitch.vo.UpdateObj;

	/**
	 * Glitchmap
	 */
	[Event(name="change", type="flash.events.Event")]
	[Event(name="complete", type="flash.events.Event")]
	public class TimerGlitch extends Glitchmap 
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		public function TimerGlitch(path : String = null, amount:int=50, limit:int=50)
		{
			_bytesGlitch = new ByteArray();
			_amount = amount;
			_limit = limit;
			if(path) loadImage(path);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		protected var _amount : int;
		
		protected var _bitmapData : BitmapData;
		protected var _bitmapDataOrigin : BitmapData;
		protected var updateRectObj : UpdateObj;
		protected var _limit : int;
		protected var _count : int=0;
		protected var encoder:JPGEncoder = new JPGEncoder();
		protected var drawPt : Point = new Point(0, 0);
		private var imageLoader : Loader = new Loader();
		
		//--------------------------------------------------------------------------
		//
		//  Override Accessors(a-z, getter -> setter)
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  bitmapData
		//----------------------------------
		override public function get bitmapData() : BitmapData
		{
			return _bitmapData;
		}
		
		
		//----------------------------------
		//  glitchiness
		//----------------------------------
		override public function set glitchiness(value : Number) : void
		{
			//can't set
		}
		
		//----------------------------------
		//  maxIterations
		//----------------------------------
		override public function set maxIterations(value : int) : void
		{
			//can't set
		}
		
		//----------------------------------
		//  seed
		//----------------------------------
		override public function set seed(value : Number) : void
		{
			//can't set
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Accessors(a-z, getter -> setter)
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  amount
		//----------------------------------
		public function set amount(amount : int) : void
		{
			_amount = amount;
		}
		
		//----------------------------------
		//  limit
		//----------------------------------
		public function set limit(limit : int) : void
		{
			_limit = limit;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Override methods
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  API
		//----------------------------------
		override public function loadImage(path : String, ignoreType : Boolean = false) : void
		{
			var loaderInfo:LoaderInfo = imageLoader.contentLoaderInfo;
			loaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			imageLoader.load(new URLRequest(path));
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  API
		//----------------------------------
		public function loadImageByBmd(bmd : BitmapData) : void
		{
			setBmd(bmd);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function next():Boolean
		{
			if(++_count<_limit)
			{
				paramRandomize();
				updateRectObj = getUpdateObj();
				bytesSource = encoder.encode(updateRectObj.bmd);
				return true;
			}
			return false;
		}
		
		public function reset():void
		{
			_count = 0;
			if(updateRectObj)
			{
				updateRectObj.destroy();
				updateRectObj=null;
			}
			if(_bytesLoader.contentLoaderInfo.hasEventListener(IOErrorEvent.IO_ERROR))
			{
				_bytesLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onBytesLoadError);
			}
			if(_bytesLoader.contentLoaderInfo.hasEventListener(Event.COMPLETE))
			{
				_bytesLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onBytesLoaded);
			}
			_bitmapData.copyPixels(_bitmapDataOrigin, new Rectangle(0,0,_bitmapDataOrigin.width,_bitmapDataOrigin.height), drawPt);
		}
		
		//----------------------------------
		//  Internal methods
		//----------------------------------
		protected function getUpdateObj():UpdateObj
		{
			var w:int =	int(_bitmapDataOrigin.width*Math.random())+1;
			var h:int =	int(_bitmapDataOrigin.height*Math.random()/5)+1;
			var x:int = int(Math.random()*(_bitmapDataOrigin.width-w));
			var y:int = int(Math.random()*(_bitmapDataOrigin.height-h));
			var bmd:BitmapData = new BitmapData(w, h, true, 0x00);
			bmd.copyPixels(_bitmapData, new Rectangle(x,y,w,h), drawPt);
			return new UpdateObj(bmd, x, y);
		}
		
		protected function paramRandomize() : void
		{
			var per:Number = _amount/50;
			_seed = 1+int(Math.random()*1000);
			_maxIterations = 64*per;
			_glitchiness = 0.1*per;
		}
		
		private function setBmd(bmd:BitmapData) : void
		{
			_bitmapData = bmd;
			_bitmapDataOrigin = _bitmapData.clone();
			
		}
		

		//--------------------------------------------------------------------------
		//
		//  Override Event Handler
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  Internal methods
		//----------------------------------
		override protected function onBytesLoaded(event : Event) : void
		{
			if(!updateRectObj)return;
			var bmd:BitmapData = _bytesLoader.content['bitmapData'];
			_bitmapData.copyPixels(bmd, new Rectangle(0, 0, bmd.width, bmd.height), new Point(updateRectObj.x,updateRectObj.y));
			updateRectObj.destroy();
			updateRectObj=null;
			_bytesLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onBytesLoadError);
			_bytesLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onBytesLoaded);
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		override protected function onLoadComplete(event : Event) : void
		{
			imageLoader.removeEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
			imageLoader.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			imageLoader.removeEventListener(Event.COMPLETE, onLoadComplete);
			
			setBmd((imageLoader.content as Bitmap).bitmapData);
			imageLoader.unload();
			
			
			dispatchEvent(event);
		}
		
	}
}
