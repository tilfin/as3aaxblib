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


package com.tilfin.aaxb.marshallers
{
	import com.tilfin.aaxb.converters.IConverter;

	/**
	 * Primitive Marshaller.
	 * 
	 * @author tilfin
	 * @author Last Modified: $Author: tilfin $
	 * @version $Revision:  $ $Date:  $
	 */
	public class PrimitiveMarshaller implements IMarshaller
	{
		private var _converter:IConverter;
		
		public function PrimitiveMarshaller(converter:IConverter) {
			_converter = converter;
		}
		
		/**
		 * @inheritDoc
		 */
		public function mashall(element:*, field:String=null):* {
			if (element == null) return null;
			return _converter.toXML(field, element);
		}
		
		/**
		 * @inheritDoc
		 */
		public function unmashall(node:XMLList, elementType:String=null):*
		{
			if (node == null || node.length() == 0) return null;
			return _converter.fromXML(node[0]);
		}
	}
}