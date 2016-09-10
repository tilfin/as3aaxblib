package entity
{
	import com.tilfin.aaxb.annotations.XmlValue;

	[XmlRootElement(name="plain")]
	public class PlainText
	{
		[XmlValue]
		public var text:String;
	}
}