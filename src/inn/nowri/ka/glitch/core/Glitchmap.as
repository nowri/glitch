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
 *	uk.co.soulwire.display.Glitchmap
 *	
 *	@version 1.00 | Feb 2, 2010
 *	@author Justin Windle
 *	@see http://blog.soulwire.co.uk
 *  
 **/
package inn.nowri.ka.glitch.core 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.FileFilter;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	/**
	 * Glitchmap
	 */
	public class Glitchmap extends Sprite 
	{

		//	----------------------------------------------------------------
		//	CONSTANTS
		//	----------------------------------------------------------------

		public static const FILE_FILTER : FileFilter = new FileFilter("Images", "*.jpg;*.jpeg;");
		public static const NULL_BYTE : int = 0;

		//	----------------------------------------------------------------
		//	PRIVATE MEMBERS
		//	----------------------------------------------------------------

		protected var _bytesSource : ByteArray;
		protected var _bytesGlitch : ByteArray;
		protected var _imageLoader : URLLoader;
		protected var _bytesLoader : Loader = new Loader();
		protected var _headerSize : int = 417;
		protected var _seed : Number = 1.0;
		protected var _maxIterations : int = 512;
		protected var _glitchiness : Number = 0.01;

		private var _output : Bitmap;

		//	----------------------------------------------------------------
		//	CONSTRUCTOR
		//	----------------------------------------------------------------

		public function Glitchmap(path : String = null)
		{
			_imageLoader = new URLLoader();
			_bytesGlitch = new ByteArray();
			if(path) loadImage(path);
		}

		//	----------------------------------------------------------------
		//	PUBLIC METHODS
		//	----------------------------------------------------------------

		public function loadImage(path : String, ignoreType : Boolean = false) : void
		{
			if(!ignoreType)
			{
				var filetype : String = path.match(/\.([^\.]+)$/)[1].replace(/\?.*/, '').toLowerCase();
			
				if(FILE_FILTER.extension.indexOf(filetype) == -1)
				{
					throw new Error("Glitchmap only accepts these image types: " + FILE_FILTER.extension);
					return;
				}
			}
			
			_imageLoader.addEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
			_imageLoader.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			_imageLoader.addEventListener(Event.COMPLETE, onLoadComplete);
			
			_imageLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_imageLoader.load(new URLRequest(path));
		}
		

		//	----------------------------------------------------------------
		//	EVENT HANDLERS
		//	----------------------------------------------------------------

		final protected function onBytesLoadError(event : IOErrorEvent) : void
		{
			trace("Error loading bytes");
		}

		final protected function onLoadIOError(event : IOErrorEvent) : void
		{
			trace("Error");
			dispatchEvent(event);
		}

		final protected function onLoadProgress(event : ProgressEvent) : void
		{
			dispatchEvent(event);
		}
		
		protected function onBytesLoaded(event : Event) : void
		{
			if(!_output)
			{
				_output = _bytesLoader.content as Bitmap;
				addChild(_output);
			}
			else
			{
				_output.bitmapData.dispose();
				_output.bitmapData = _bytesLoader.content['bitmapData'];
			}
			
			_bytesLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onBytesLoadError);
			_bytesLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onBytesLoadError);
			dispatchEvent(new Event(Event.CHANGE));
		}
		

		protected function onLoadComplete(event : Event) : void
		{
			_imageLoader.removeEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
			_imageLoader.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			_imageLoader.removeEventListener(Event.COMPLETE, onLoadComplete);
			
			bytesSource = _imageLoader.data as ByteArray;
			
			dispatchEvent(event);
		}

		//	----------------------------------------------------------------
		//	PUBLIC ACCESSORS
		//	----------------------------------------------------------------

		public function get glitchiness() : Number
		{
			return _glitchiness;
		}

		public function set glitchiness(value : Number) : void
		{
			_glitchiness = value < 0.0 ? 0.0 : value > 1.0 ? 1.0 : value;
			draw();
		}

		public function get maxIterations() : int
		{
			return _maxIterations;
		}

		public function set maxIterations(value : int) : void
		{
			_maxIterations = value;
			draw();
		}

		public function get seed() : Number
		{
			return _seed;
		}

		public function set seed(value : Number) : void
		{
			_seed = value;
			draw();
		}
		
		public function get bitmapData() : BitmapData
		{
			return _output.bitmapData;
		}
		
		//	----------------------------------------------------------------
		//	PRIVATE MESODS
		//	----------------------------------------------------------------
		
		final protected function draw() : void
		{
			if(!_bytesSource) return;

			_bytesLoader.unload();
			_bytesSource.position = 0;
			
			_bytesGlitch.length = 0;
			_bytesGlitch.writeBytes(_bytesSource, 0, _bytesSource.bytesAvailable);
			
			if(_glitchiness > 0.0)
			{
				var length : int = _bytesGlitch.length - _headerSize - 2;
				var amount : int = int(_glitchiness * _maxIterations);
				var random : Number = _seed;
				
				for (var i : int = 0;i < amount;i++)
				{
					random = ( random * 16807 ) % 2147483647;
					
					_bytesGlitch.position = _headerSize + int(length * random * 4.656612875245797e-10);
					_bytesGlitch.writeByte(NULL_BYTE);
				}
			}
			
			_bytesLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onBytesLoadError);
			_bytesLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBytesLoaded);
			_bytesLoader.loadBytes(_bytesGlitch);
		}
		
		//	----------------------------------------------------------------
		//	PRIVATE ACCESSORS
		//	----------------------------------------------------------------

//		private function get bytesSource() : ByteArray
//		{
//			return _bytesSource;
//		}

		final protected function set bytesSource(value : ByteArray) : void
		{
			_bytesSource = value;
			_bytesSource.position = 0;
			_headerSize = 417;

			var byte : uint;
			
			while(_bytesSource.bytesAvailable)
			{
				byte = _bytesSource.readUnsignedByte();
				
				if(byte == 0xFF)
				{
					byte = _bytesSource.readUnsignedByte();
					
					if(byte == 0xDA)
					{
						_headerSize = _bytesSource.position + _bytesSource.readShort();
						break;
					}
					
					_bytesSource.position--;
				}
			}
			draw();
		}

//		public function get bytesGlitch() : ByteArray
//		{
//			return _bytesGlitch;
//		}


	}
}
