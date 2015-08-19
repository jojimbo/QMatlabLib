package xml;

import java.util.LinkedHashSet;
import java.util.Set;

import org.w3c.dom.Node;
import org.w3c.dom.Text;


public class XmlParser {
	
	public static class Axis {			
		Set<Double> uniqueValues = new LinkedHashSet<Double>();
							
		public double[] getValues() {
			double[] out = new double[uniqueValues.size()];
			int i = 0;
			for(Double d : uniqueValues) {
				out[i++] = d;				
			}
			return out;
		}		
	}
	
	
	static public double[][] parseCorrelationMatrix(Node xmlCorrs) {
		final int size = xmlCorrs.getChildNodes().getLength();	
		double[][] corrs = new double[size][size];		
		for(int i = 0; i < size; ++i) {
			for(int j = 0; j < size; ++j) {				
				Text value = (Text)xmlCorrs.getChildNodes().item(i).getChildNodes().item(j).getFirstChild();
				String s = value.getData();
				assert(s.length() > 0);				
				try {
					double d = Double.parseDouble(s);
					corrs[i][j] = d;
				} catch (NumberFormatException nfe) {
					System.err.println(nfe + " " + i + " " + j);					
				}
			}
		}
		return corrs;
	}
	
	
	static public double[][] parseSerialisedCubeValues2(String[] axesNames, Node xmlValues) {
        int nValues = xmlValues.getChildNodes().getLength();
        double[][] out = new double[nValues][axesNames.length + 1];
        Node valueTag = xmlValues.getFirstChild();
        for(int i = 0; i < nValues; ++i) {
                for(int j = 0; j < axesNames.length; ++j) {
                        String attributeValue = valueTag.getAttributes().getNamedItem(axesNames[j]).getNodeValue();
                        out[i][j] = Double.parseDouble(attributeValue);
                }
                Text nodeValue = (Text)valueTag.getFirstChild();
                out[i][axesNames.length] = Double.parseDouble(nodeValue.getData());
                valueTag = valueTag.getNextSibling();
        }
        return out;
}
	
	
	
	static public Object[] parseSerialisedCubeValues(String[] axesNames, Node xmlValues) {
		
		Axis[] axes = new Axis[axesNames.length];
		final int nValues = xmlValues.getChildNodes().getLength();
		for(int i = 0; i < axes.length; ++i) {
			axes[i] = new Axis();
		}		
		double[][] values = new double[nValues][axesNames.length + 1];
		//
		Node valueTag = xmlValues.getFirstChild();
		for(int i = 0; i < nValues; ++i) {
			for(int j = 0; j < axesNames.length; ++j) {				
				String attributeValue = valueTag.getAttributes().getNamedItem(axesNames[j]).getNodeValue();
				final double axisValue = Double.parseDouble(attributeValue);
				values[i][j] = axisValue;
				axes[j].uniqueValues.add(axisValue);
				
			}
			Text nodeValue = (Text)valueTag.getFirstChild();
			values[i][axesNames.length] = Double.parseDouble(nodeValue.getData());
			valueTag = valueTag.getNextSibling();
		}
		//
		return new Object[] { axes, values };
	}
	
	
	static void out(Object o) {
		System.out.println(o);
	}
}
