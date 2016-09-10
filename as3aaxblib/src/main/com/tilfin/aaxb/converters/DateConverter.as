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


package com.tilfin.aaxb.converters
{
	/**
	 * Date Converter.
	 *  
	 * @author tilfin
	 * @author Last Modified: $Author: tilfin $
	 * @version $Revision:  $ $Date:  $
	 */
	public class DateConverter implements IConverter
	{
		private static const DATEPARSE_EXP:RegExp = /(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})\.(\d{3})Z/;
		
		private static const DATEPARSE_EXP_2:RegExp = /(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})Z/;
		
		/**
		 * @inheritDoc
		 */
		public function fromXML(value:XML):* {
			if (value == null) return null;
			var datestr:String = String(value);
			var results:Array = DATEPARSE_EXP.exec(datestr);
			if (results == null) {
				results = DATEPARSE_EXP_2.exec(datestr);
			}
			var date:Date = new Date();
			date.setUTCFullYear(parseInt(results[1], 10), parseInt(results[2], 10) - 1, parseInt(results[3], 10));
			date.setUTCHours(parseInt(results[4], 10), parseInt(results[5], 10), parseInt(results[6], 10), parseInt(results[7], 10));
			return date;
		}
		
		/**
		 * @inheritDoc
		 */
		public function toXML(name:String, value:*):XML {
			var date:Date = value as Date;
			if (date == null) return null;
			
			var datestr:String = date.fullYearUTC.toString();
			datestr += "-" + fillZeroStr(date.monthUTC + 1, 2);
			datestr += "-" + fillZeroStr(date.dateUTC, 2);
			datestr += "T" + fillZeroStr(date.hoursUTC, 2);
			datestr += ":" + fillZeroStr(date.minutesUTC, 2);
			datestr += ":" + fillZeroStr(date.secondsUTC, 2);
			datestr += "." + fillZeroStr(date.millisecondsUTC, 3);
			datestr += "Z";
			
			var xml:XML = <{name}></{name}>;
			xml.appendChild(datestr);
			return xml;
		}
		
		private static function fillZeroStr(value:Number, len:int):String {
			var str:String = value.toString();
			for (var i:int = str.length; i < len; i++) {
				str = "0" + str;
			}
			return str;
		}
	}
}