import com.mathworks.toolbox.javabuilder.*;
import RSGSimulate.*;
import java.util.*;

class RSGSimulateRunner
{
	enum Func
	{
		RSGCalibrate, RSGBootstrap, RSGSimulate, RSGValidate, RSGMakePruFiles, RSGMakeAlgoFiles, RSGRunCS, RSGBootstrapValidate, RSGBootstrapCalibrate
	}
	public static void main(String[] args)
	{
		RSGSimulate theRSGRunner = null;
		
		try
		{
			theRSGRunner = new RSGSimulate();
			List lhs = new ArrayList(), rhs = new ArrayList();
			Func fu = Func.RSGSimulate;
			for (String arg : args) {
				boolean fuFound = false;
				for (Func f : Func.values()) {
					if (arg.equals(f.toString())) {
						fu = f;
						fuFound = true;
						break;
					}
				}	
				if (!fuFound)
					rhs.add(arg);
			}
			switch (fu) {
            case RSGBootstrapCalibrate:
				lhs.add(null);
				theRSGRunner.RSGBootstrapCalibrate(lhs, rhs);
				break;
            case RSGBootstrapValidate:
				lhs.add(null);
				theRSGRunner.RSGBootstrapValidate(lhs, rhs);
				break;
			case RSGBootstrap:
				theRSGRunner.RSGBootstrap(lhs, rhs);
				break;
			case RSGCalibrate:
				lhs.add(null);
				lhs.add(null);
				theRSGRunner.RSGCalibrate(lhs, rhs);
				break;
			case RSGSimulate:
				lhs.add(null);
				lhs.add(null);
				theRSGRunner.RSGSimulate(lhs, rhs);
				break;
			case RSGValidate:
				lhs.add(null);
				lhs.add(null);
				theRSGRunner.RSGValidate(lhs, rhs);
				break;
			case RSGMakePruFiles:
				lhs.add(null);
				lhs.add(null);
				theRSGRunner.RSGMakePruFiles(lhs, rhs);
				break;
			case RSGMakeAlgoFiles:
				lhs.add(null);
				lhs.add(null);
				theRSGRunner.RSGMakeAlgoFiles(lhs, rhs);
				break;
            case RSGRunCS:
				lhs.add(null);
                lhs.add(null);
                theRSGRunner.RSGRunCS(lhs, rhs);
                break;
			default:
				throw new Exception("Unknown function " + fu.toString());
			}

			System.out.println("\nRSG returned " + lhs.size() + " elements.\n");

			for (Object o : lhs)
			{
				if (o != null)
				{
					System.out.println("Class: " + o.getClass().toString());
					if (o instanceof MWArray)
					{
						MWArray a = (MWArray)o;
						System.out.println("MWArray: " + a.numberOfDimensions() + " dimensions " + 
											toString(a.getDimensions()) + ", " + a.numberOfElements() + " elements");
					}

					if (o instanceof MWCellArray)
					{
						MWCellArray ca = (MWCellArray)o;
						List<MWArray> al = ca.asList();
						for (MWArray ar : al)
						{
							System.out.println("Cell: " + ar.getClass().toString());
							if (ar instanceof MWNumericArray)
								printArray((MWNumericArray)ar);
							else if (ar instanceof MWCharArray)
								printArray((MWCharArray)ar);
						}
					}
					else if (o instanceof MWNumericArray)
					{
						MWNumericArray na = (MWNumericArray)o;
						printArray(na);
					}
					else if (o instanceof MWCharArray)
					{
						MWCharArray ca = (MWCharArray)o;
						printArray(ca);
					}
				}
				else
				{
					// Seems not to happen. Instead, system sigfaults if an output variable is unset.
					System.out.println("Output variable unset");
				}
				System.out.println("\n-----------------");
			}
		}
		catch (Exception e)
		{
			System.out.println("Exception: " + e.toString());
			
		}
		finally
		{			
			if (theRSGRunner != null)
			{				
                com.mathworks.toolbox.javabuilder.MWApplication.terminate();
				theRSGRunner.dispose();			
				Runtime.getRuntime().halt(1);
			}		
		}
	}
	
	private static String toString(int[] arr)
	{
		if (arr.length == 0)
			return "[]";
		StringBuffer sb = new StringBuffer("[");
		sb.append(Integer.toString(arr[0]));
		for (int i = 1; i < arr.length; ++i)
		{
			sb.append(",");
			sb.append(Integer.toString(arr[i]));
		}
		sb.append("]");
		return sb.toString();
	}

	private static String toString(double[] arr)
	{
		if (arr.length == 0)
			return "[]";
		StringBuffer sb = new StringBuffer("[");
		sb.append(Double.toString(arr[0]));
		for (int i = 1; i < arr.length; ++i)
		{
			sb.append(",");
			sb.append(Double.toString(arr[i]));
		}
		sb.append("]");
		return sb.toString();
	}

	private static void printArray(MWNumericArray ar)
	{
		if (ar.numberOfDimensions() == 2)
		{
			StringBuffer buf = new StringBuffer();
			Object[] arr = ar.toArray();
			for (Object o : arr)
			{
				if (o instanceof double[])
					buf.append(toString((double[])o));
				else
					System.out.println(o.getClass().toString());
				buf.append("\n");
			}
			System.out.println(buf.toString());
		}
	}

	private static void printArray(MWCharArray ca)
	{
		System.out.println(ca.toString());
	}
}

