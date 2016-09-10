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


package com.tilfin.aaxb.reflect {
	
	import com.tilfin.aaxb.annotations.XmlElement;
	import com.tilfin.aaxb.annotations.XmlElementWrapper;
	import com.tilfin.aaxb.annotations.XmlRootElement;
	
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import org.hamcrest.mxml.core.Not;
	
	/**
	 * Class Structure Provider.
	 * 
	 * @author tilfin
	 * @author Last Modified: $Author: tilfin $
	 * @version $Revision:  $ $Date:  $
	 */
	public class ClassStructureProvider {

		private var _cache:Object;
		private var _classMap:Object;
		private var _classNames:Array;

		public function ClassStructureProvider(classes:Array) {
			_cache = new Object();
			_classMap = new Object();
			_classNames = new Array();
			
			for each (var klass:Class in classes) {
				var qcn:String = getQualifiedClassName(klass);
				var cs:ClassStructure = getClassStructure(klass);
				_cache[qcn] = cs;
				_classMap[cs.tagName] = klass;
				_classNames.push(qcn);
			}
		}
		
		public function get classNames():Array {
			return _classNames;
		}
		
		public function get classMap():Object {
			return _classMap;
		}
		
		public function getStructure(instance:*):ClassStructure {
			var qcn:String = getQualifiedClassName(instance);
			if (_cache.hasOwnProperty(qcn)) {
				return _cache[qcn];
			} else {
				var struct:ClassStructure = getClassStructure(instance);
				_cache[qcn] = struct;
				return struct;
			}
		}
		
		private static const METADATA:String = "metadata";
		
		private function getClassStructure(instance:*):ClassStructure {
			var klass:Class;
			if (instance is Class) {
				klass = instance;
			} else {
				klass = getDefinitionByName(getQualifiedClassName(instance)) as Class;
			}
			
			var xmltype:XMLList = describeType(klass).factory;
			var struct:ClassStructure = new ClassStructure();
			struct.typeInfo = new TypeInfo(xmltype.@type);

			var props:Object = new Object();
			for each (var child:XML in xmltype.children()) {
				if (child.localName() == "variable") {
					var type:String = String(child.@type);
					var typeInfo:TypeInfo = new TypeInfo(type);
					
					// Set Property MetaData
					for each (var attr:XML in child.child(METADATA)) {
						var attrName:String = String(attr.@name);
						if (attrName == XmlElement.META_NAME) {
							typeInfo.addMetadata(attrName, getXmlElement(attr, XmlElement));
						} else if (attrName == XmlElementWrapper.META_NAME) {
							typeInfo.addMetadata(attrName, getXmlElement(attr, XmlElementWrapper));
						} else if (attrName.substr(0, 1) != "_") {
							typeInfo.addMetadata(attrName, true);
						}
					}
					
					props[String(child.@name)] = typeInfo;
				} else if (child.localName() == METADATA) {
					// Set Class MetaData
					var aname:String = String(child.@name);
					if (aname == XmlRootElement.META_NAME) {
						struct.typeInfo.addMetadata(XmlElement.META_NAME, getXmlElement(child, XmlElement));
					}
				}
			}
			
			struct.properties = props;
			return struct;
		}
		
		private function getXmlElement(xml:XML, klass:Class):* {
			var xmlel:* = new klass();
			var xmllist:XMLList = xml.child("arg");
			for each (var arg:XML in xmllist) {
				var key:String = String(arg.@key);
				xmlel[key] = String(arg.@value);
			}
			return xmlel;
		}
		
		private function getClassName(qcn:String):String {
			return qcn.substr(qcn.lastIndexOf("::") + 2);
		}
	}
}