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


package com.tilfin.aaxb
{
	import com.tilfin.aaxb.converters.BooleanConverter;
	import com.tilfin.aaxb.converters.ByteArrayConverter;
	import com.tilfin.aaxb.converters.DateConverter;
	import com.tilfin.aaxb.converters.NumberConverter;
	import com.tilfin.aaxb.converters.StringConverter;
	import com.tilfin.aaxb.reflect.ClassStructureProvider;
	import com.tilfin.aaxb.reflect.TypeDescriptor;
	import com.tilfin.aaxb.marshallers.IMarshaller;
	import com.tilfin.aaxb.marshallers.PrimitiveMarshaller;
	import com.tilfin.aaxb.marshallers.StructureMarshaller;
	import com.tilfin.aaxb.marshallers.VectorMarshaller;
	
	import flash.utils.getQualifiedClassName;

	/**
	 * <p>XmlSerializer supplies the function how objects are encoded into XML or
	 * are decoded from XML.</p>
	 *
	 * <p>Integer, Float are applied to AS Number. String, Date are applied to AS String.</p>
	 * 
     * <pre><code>
	 * var instance:Hoge = new Hoge();
	 * var serializer:XmlSerializer = new XmlSerializer(Hoge, Foo);
	 * var xml:XML = serializer.serialize(instance);
	 * var instance2:Hoge = seriailzer.deserialize(xml);
	 * </code></pre>
	 *
	 * @author tilfin
	 * @author Last Modified: $Author: tilfin $
	 * @version $Revision:  $ $Date:  $
	 */
	public class XmlSerializer 
	{
		private var _structureMarshaller:IMarshaller;

		/**
		 * Contructor.
		 * 
		 * @param classes XML Binding Classes 
		 */
		public function XmlSerializer(... classes) {
			if (classes == null || classes.length == 0) {
				throw new ArgumentError("'classes' argument is required.");
			}

			var msmap:Object = new Object();
			var csp:ClassStructureProvider = new ClassStructureProvider(classes);
			_structureMarshaller = new StructureMarshaller(msmap, csp);
			
			for each (var cname:String in csp.classNames) {
				msmap[cname] = _structureMarshaller;
			}
			
			msmap[TypeDescriptor.TYPE_STRING] = new PrimitiveMarshaller(new StringConverter());
			msmap[TypeDescriptor.TYPE_BOOLEAN] = new PrimitiveMarshaller(new BooleanConverter());
			msmap[TypeDescriptor.TYPE_NUMBER] = new PrimitiveMarshaller(new NumberConverter());
			msmap[TypeDescriptor.TYPE_DATE] = new PrimitiveMarshaller(new DateConverter());
			msmap[TypeDescriptor.TYPE_BYTEARRAY] = new PrimitiveMarshaller(new ByteArrayConverter());
			msmap[TypeDescriptor.TYPE_VECTOR] = new VectorMarshaller(msmap, csp);
		}
		
		/**
		 * encodes Instance to XML.
		 * 
		 * @param rootElementName XML root element name
		 * @param rootInstance root instance
		 * @return XML
		 */
		public function serialize(rootInstance:*, rootElementName:String=null):XML {
			return _structureMarshaller.mashall(rootInstance, rootElementName);
		}
		
		/**
		 * decodes XML to Instance.
		 * 
		 * @param xml XML Root Node
		 * @return instance
		 */
		public function deserialize(xml:XML):* {
			var xmlList:XMLList = new XMLList();
			xmlList[0] = xml;
			return _structureMarshaller.unmashall(xmlList);
		}
	}
}