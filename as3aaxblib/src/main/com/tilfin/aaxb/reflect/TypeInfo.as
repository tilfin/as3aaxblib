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


package com.tilfin.aaxb.reflect
{
	import com.tilfin.aaxb.annotations.XmlAttribute;
	import com.tilfin.aaxb.annotations.XmlElement;
	import com.tilfin.aaxb.annotations.XmlElementWrapper;
	import com.tilfin.aaxb.annotations.XmlValue;

	/**
	 * TypeInfo
	 * 
	 * @author tilfin
	 * @author Last Modified: $Author: tilfin $
	 * @version $Revision:  $ $Date:  $
	 */
	public class TypeInfo
	{
		private var _fullType:String;
		
		private var _type:String;
		
		private var _elType:String;
		
		private var _metaData:Object;
		
		public function TypeInfo(fullType:String) {
			_fullType = fullType;
			
			var pos:int = _fullType.indexOf("<");
			if (pos > -1) {
				// Vector
				var endpos:int = _fullType.indexOf(">");
				_type = _fullType.substr(0, pos - 1);
				_elType = _fullType.substring(pos + 1, endpos);
			} else {
				// 
				_type = _fullType;
				var pc:int = _fullType.lastIndexOf("::");
				if (pc > -1) {
					_elType = _fullType.substr(pc + 2);
				}
			}
			
			_metaData = new Object();
		}
		
		public function get type():String {
			return _type;
		}
		
		public function get elementType():String {
			return _elType;
		}
		
		public function get fullType():String {
			return _fullType;
		}
		
		public function get isXmlValue():Boolean {
			return _metaData.hasOwnProperty(XmlValue.META_NAME);
		}
		
		public function get xmlAttribute():XmlAttribute {
			return _metaData[XmlAttribute.META_NAME] as XmlAttribute;
		}
		
		public function get xmlElement():XmlElement {
			return _metaData[XmlElement.META_NAME] as XmlElement;
		}
		
		public function get xmlElementWrapper():XmlElementWrapper {
			return _metaData[XmlElementWrapper.META_NAME] as XmlElementWrapper;
		}
		
		public function addMetadata(name:String, value:*):void {
			_metaData[name] = value;
		}
	}
}