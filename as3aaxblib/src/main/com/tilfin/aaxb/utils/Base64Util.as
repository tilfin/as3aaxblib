/*
Copyright (c) 2011, Tilfin Limited
All rights reserved.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are
met:

* Redistributions of source code must retain the above copyright notice, 
this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the 
documentation and/or other materials provided with the distribution.

* Neither the name of Adobe Systems Incorporated nor the names of its 
contributors may be used to endorse or promote products derived from 
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


package com.tilfin.aaxb.utils
{
	import flash.utils.ByteArray;
	
	/**
	 * Base64 Encode/Decode Utility.
	 * 
	 * @author tilfin
	 * @author Last Modified: $Author: tilfin $
	 * @version $Revision:  $ $Date:  $
	 */
	public class Base64Util
	{
		private static const NN:uint = uint.MAX_VALUE;
		private static const SN:uint = uint.MAX_VALUE - 1;
		
		private static const INVERSE:Vector.<uint> = new Vector.<uint>([
				SN, SN, SN, SN, SN, SN, SN, SN, SN, SN, SN, 62, SN, SN, SN, 63,
				52, 53, 54, 55, 56, 57, 58, 59, 60, 61, SN, SN, SN, NN, SN, SN,
				SN, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
				15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, SN, SN, SN, SN, SN,
				SN, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
				41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51
			]);
		
		private static const B64_CHARCODES:Vector.<uint> = new Vector.<uint>([
				65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78,
				79, 80,	81, 82, 83, 84, 85, 86, 87, 88, 89, 90,
				97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110,
				111, 112, 113, 114, 115, 116, 117, 118,	119, 120, 121, 122,
				48, 49, 50, 51,	52, 53, 54, 55, 56, 57,
				43, 47
			]);
		
		/**
		 * Decodes a Base64 encoded String.
		 * 
		 * @param encoded The Base64 encoded String to decode.
		 * @return decoded ByteArray.
		 */
		public static function decode(encoded:String):ByteArray {
			const INVERSE_LENGTH:Number = INVERSE.length;
			var w:Vector.<uint> = new Vector.<uint>([0, 0, 0, 0]);
			var data:ByteArray = new ByteArray();
			var count:int = 0;
			for (var i:uint = 0, len:uint = encoded.length; i < len; i++) {
				var c:Number = encoded.charCodeAt(i) - 32;
				if (c < INVERSE_LENGTH && INVERSE[c] != SN) {
					w[count++] = INVERSE[c];
			    } else {
					continue;
				}
				
				if (count == 4) {
					count = 0;
					data.writeByte((w[0] << 2) | ((w[1] & 0xFF) >> 4));
					
					if (w[2] == NN)
						break;
					
					data.writeByte((w[1] << 4) | ((w[2] & 0xFF) >> 2));
					
					if (w[3] == NN)
						break;
					
					data.writeByte((w[2] << 6) | w[3]);
				}
			}
			
			data.position = 0;
			return data;
		}

		/** @private '=' */
		private static const ESCAPE_CHARCODE:uint = 61;
		
		private static const MAX_BUFFER_SIZE:uint = 32767;

		/**
		 * Encodes a ByteArray to Base64 String.
		 * 
		 * @param data ByteArray to encode.
		 * @return encoded String.
		 */
		public static function encode(data:ByteArray):String {
			var w:Vector.<uint> = new Vector.<uint>([ 0, 0, 0 ]);
			var str:String = "";
			var cblock:Array = new Array();3
			
			var oldPosition:uint = data.position;
			data.position = 0;
			
			var count:uint = 0;
			var i:uint = 0;
			var preLastIndex:uint = data.length - 2;
			while (i <= preLastIndex) {
				w[count++] = data[i];
				
				if (count == 3) {
					if (cblock.length >= MAX_BUFFER_SIZE) {
						str += String.fromCharCode.apply(null, cblock);
						cblock = [];
					}
					encodeBlock(cblock, count, w);
					count = 0;
					w[0] = w[1] = w[2] = 0;
				}
				
				i++;
			}
			w[count++] = data[i];
			encodeBlock(cblock, count, w);
			str += String.fromCharCode.apply(null, cblock);
			
			data.position = oldPosition;
			
			return str;
		}
		
		/**
		 * @private
		 */
		private static function encodeBlock(block:Array, count:uint, w:Vector.<uint>):void {
			block.push(B64_CHARCODES[(w[0] & 0xFF) >> 2]);
			block.push(B64_CHARCODES[((w[0] & 0x03) << 4) | ((w[1] & 0xF0) >> 4)]);
			
			if (count > 1) {
				block.push(B64_CHARCODES[((w[1] & 0x0F) << 2) | ((w[2] & 0xC0) >> 6) ]);
			} else {
				block.push(ESCAPE_CHARCODE);
			}
			
			if (count > 2) {
				block.push(B64_CHARCODES[w[2] & 0x3F]);
			} else {
				block.push(ESCAPE_CHARCODE);
			}
		}
		
	}
}