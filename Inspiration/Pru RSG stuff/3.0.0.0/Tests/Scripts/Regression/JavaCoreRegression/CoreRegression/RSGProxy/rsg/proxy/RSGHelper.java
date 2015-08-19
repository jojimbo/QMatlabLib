package rsg.proxy;

import java.io.File;
import java.io.FileNotFoundException;

import JTestUtility.JTestUtility;

import com.mathworks.toolbox.javabuilder.MWArray;
import com.mathworks.toolbox.javabuilder.MWCellArray;
import com.mathworks.toolbox.javabuilder.MWCharArray;
import com.mathworks.toolbox.javabuilder.MWException;
import com.mathworks.toolbox.javabuilder.MWNumericArray;

import java.util.*;
import java.io.*;
import java.nio.channels.*;

public class RSGHelper {

	public static String configSource = "./configs"; //System.getProperty("user.dir"); // "../../CoreRegression";
	
	public static void configure(String configName) throws IOException {
		// Copy the config file from the CoreRegression folder and rename it to app.config in the root
		// Retain the original in the root for later inspection
		String workingDir = System.getProperty("user.dir");
		
		File source = new File(RSGHelper.configSource, configName);
		File dest = new File(workingDir, "app.config");
		
		RSGHelper.copyFile(source, dest);
	}
	
	public static void copyFile(File sourceFile, File destFile) throws IOException {
		System.out.println("Attempting to copy '" + sourceFile.toString() + "' to '" + 
				destFile.toString() + "'...");
		if (!sourceFile.exists()) {
			System.out.println("The source file does not exist!");
			throw new IOException("RSG application configuration file not found!");
		}
			
		if (!destFile.exists())
			destFile.createNewFile();
	
		FileChannel source = null;
		FileChannel dest = null;
		
		try {
			source = new FileInputStream(sourceFile).getChannel();
			dest = new FileOutputStream(destFile).getChannel();
			dest.transferFrom(source, 0, source.size());
			System.out.println("Copy complete.");
		} catch (IOException io) {
			System.out.println("Copy failed!");
			throw io;
		}
		finally {
			if (source != null) 
				source.close();
			if (dest != null)
				dest.close();
		}		
	}	
	
	public static void runSimulation(String controlFile)  throws MWException {	
		System.out.println("Running persistence mode simulation with '" + controlFile + "'");
		RSGHelper.Simulate(controlFile, false);
	}
	
	public static void runInMemSimulation(String controlFile)  throws MWException {
		System.out.println("Running in memory simulation with '" + controlFile + "'");
		RSGHelper.Simulate(controlFile, true);
	}
	
	private static void Simulate(String controlFile, boolean inmem)  throws MWException {
		System.out.println("Testing RSGSimulate with '" + controlFile + "'");
		
		String[] values = RSGProxy.RSGSimulate(controlFile);
		
		System.out.println("Simulation completed");
		
		String scenarioID = RSGHelper.getArg(values);
		if (!inmem)
			RSGHelper.generateFiles(scenarioID);
	
	    // Compare the generated files to a baseline
	    // Provide the scenario set ID and the path to the baseline files
	    String pathToBaseline = RSGHelper.GetConfigValue("BaselineFolder");
	    String pathToOutput = RSGHelper.GetConfigValue("OutputFolderPath");
	    RSGHelper.CompareFiles(pathToOutput, scenarioID, pathToBaseline);
	}
	
	public static void generateFiles(String scenarioID) throws MWException {
		// This method MUST use the RSGProxy mthods and NOT the TestUtil generateFiles method
		System.out.println("Generating Algo, Pru and Validation report files " + 
				"for scenario ID : '" + scenarioID + "'");
		
		String[] values = RSGProxy.RSGMakeAlgoFiles(scenarioID);	
		String filePath = RSGHelper.getArg(values);
		System.out.println("Files can be found here: '" + filePath + "'");	

		values = RSGProxy.RSGMakePruFiles(scenarioID);
		filePath = RSGHelper.getArg(values);
		System.out.println("Files can be found here: '" + filePath + "'");	
		
		values = RSGProxy.RSGValidate(scenarioID);
		filePath = RSGHelper.getArg(values);
		System.out.println("Files can be found here: '" + filePath + "'");	
	}

	public static void exists(File path) throws FileNotFoundException {
		if (path == null || !path.exists())
			throw new FileNotFoundException("Could not find '"
					+ path.toString() + "'");
	}

	public static String getArg(String[] args) throws IllegalArgumentException {
		if (args == null)
			throw new IllegalArgumentException("The input array cannot be null");

		if (args.length == 0)
			return null;
		else if (args.length == 1)
			return args[1];
		else if (args.length == 2) {
			// Print the first and return the second
			System.out.println(args[0]);
			return args[1];
		} else {
			throw new IllegalArgumentException(
					"The input array cannot have more than two elements");
		}

		// [UserMsg XMLFilePathOut] = RSGCalibrate(XMLFilePath)
		// [UserMsg valReportPath] = RSGValidate(scenSetName)
		// [UserMsg pruFilesPath] = RSGMakePruFiles(scenSetName, scenDates)
		// [UserMsg algoFilesPath] = RSGMakeAlgoFiles(scenSetName, scenDates)

		// [UserMsg ScenSetID] = RSGSimulate(XMLFilePath, nBatch)
		// [UserMsg ScenSetID] = RSGRunCS(xmlFilePath, araReportFileName, windowSize, windowShape, shapeParameter) 

		// OutputFilesPath = RSGBootstrapValidate(xmlFilePath)
		// outputXmlPath = RSGBootstrapCalibrate(inputXmlPath)
		// RSGBootstrap(inputXmlFilePath)

	}

	public static void CompareDirs(String basePath, String baseScenId,
			String testPath, String testScenId) throws MWException {
		// CompareDirs(basePath, baseScenId, testPath, testScenId)			

		JTestUtility util = null;
		try {
			List in = RSGHelper.ins(basePath, baseScenId, testPath, testScenId);
			List out = RSGHelper.outs(0);

			util = new JTestUtility();

			System.out.println("Calling CompareDirs...");
			util.CompareDirs(out, in);
		} finally {
			RSGHelper.cleanup(util);
		}
	}

	public static void CompareFiles(String pathToOutput, String scenarioSetId,
			String pathToBaseline) throws MWException {
		// CompareFiles(pathToOutput, scenarioSetId, pathToBaseline)

		JTestUtility util = null;
		try {
			List in = RSGHelper
					.ins(pathToOutput, scenarioSetId, pathToBaseline);
			List out = RSGHelper.outs(0);

			util = new JTestUtility();

			System.out.println("Calling CompareFiles...");
			util.CompareFiles(out, in);
		} finally {
			RSGHelper.cleanup(util);
		}
	}

	public static String GetConfigValue(String key) throws MWException {
		// value = GetConfigValue(key)

		JTestUtility util = null;
		try {
			List in = RSGHelper.ins(key);
			List out = RSGHelper.outs(1);

			util = new JTestUtility();

			System.out.println("Calling GetConfigValue...");
			util.GetConfigValue(out, in);

			return RSGHelper.processReturnedArgs(out)[0];
		} finally {
			RSGHelper.cleanup(util);
		}
	}

	public static void RebuildScenarioDB() throws MWException {
		// RebuildScenarioDB()

		JTestUtility util = null;
		try {
			List in = RSGHelper.ins();
			List out = RSGHelper.outs(0);

			util = new JTestUtility();

			System.out.println("Calling RebuildScenarioDB...");
			util.RebuildScenarioDB(out, in);
		} finally {
			RSGHelper.cleanup(util);
		}
	}

	// Convert an elipsis into a List
	public static List<Object> ins(Object... args) {
		return Arrays.asList(args);
	}

	// Create a List with a place for each output argument
	public static List<?> outs(int argc) {
		List<?> outputSpec = new ArrayList(argc);
		for (int i = 0; i < argc; i++)
			outputSpec.add(null);
		return outputSpec;
	}

	public static String[] processReturnedArgs(List<?> args) {
		int numArgs = args.size();
		System.out.println("\nProcessing " + numArgs + " returned elements.\n");
		String[] out = new String[numArgs];

		try {
			for (int i = 0; i < numArgs; i++) {
				Object arg = args.get(i);
				if (arg != null) {
					System.out.println("Class: " + arg.getClass().toString());
					if (arg instanceof MWArray) {
						MWArray a = (MWArray) arg;
						System.out.println("MWArray: " + a.numberOfDimensions()
								+ " dimensions " + toString(a.getDimensions())
								+ ", " + a.numberOfElements() + " elements");
								// prints e.g. MWArray: 2 dimensions [1,25], 25 elements
					} 
					
					if (arg instanceof MWCellArray) {
						MWCellArray ca = (MWCellArray) arg;
						List<MWArray> al = ca.asList();
						for (MWArray ar : al) {
							System.out.println("Cell: "
									+ ar.getClass().toString());
							if (ar instanceof MWNumericArray)
								out[i] = printArray((MWNumericArray) ar);
							else if (ar instanceof MWCharArray)
								out[i] = printArray((MWCharArray) ar);
						}
					} else if (arg instanceof MWNumericArray) {
						MWNumericArray na = (MWNumericArray) arg;
						out[i] = printArray(na);
					} else if (arg instanceof MWCharArray) {
						MWCharArray ca = (MWCharArray) arg;
						out[i] = printArray(ca);
					}
				} else {
					// Seems not to happen. Instead, system sigfaults if an output variable is unset.
					System.out.println("Output variables unset");
				}

				System.out.println("\n-----------------");
			}
		} catch (Exception e) {
			System.out.println("Exception: " + e.toString());

		}

		return out;
	}

	private static String toString(int[] arr) {
		if (arr.length == 0)
			return "[]";
		StringBuffer sb = new StringBuffer("[");
		sb.append(Integer.toString(arr[0]));
		for (int i = 1; i < arr.length; ++i) {
			sb.append(",");
			sb.append(Integer.toString(arr[i]));
		}
		sb.append("]");
		return sb.toString();
	}

	private static String toString(double[] arr) {
		if (arr.length == 0)
			return "[]";
		StringBuffer sb = new StringBuffer("[");
		sb.append(Double.toString(arr[0]));
		for (int i = 1; i < arr.length; ++i) {
			sb.append(",");
			sb.append(Double.toString(arr[i]));
		}
		sb.append("]");
		return sb.toString();
	}

	private static String printArray(MWNumericArray ar) {
		if (ar.numberOfDimensions() == 2) {
			StringBuffer buf = new StringBuffer();
			Object[] arr = ar.toArray();
			for (Object o : arr) {
				if (o instanceof double[])
					buf.append(toString((double[]) o));
				else
					System.out.println(o.getClass().toString());
				buf.append("\n");
			}
			System.out.println(buf.toString());
			return buf.toString();
		}
		System.out.println("Returning null as not 2 domensional data");
		return null;
	}

	private static String printArray(MWCharArray ca) {
		System.out.println(ca.toString());
		return ca.toString();
	}

	private static void cleanup(JTestUtility runner) {
		if (runner != null) {
	//		com.mathworks.toolbox.javabuilder.MWApplication.terminate();
			runner.dispose();
	//		Runtime.getRuntime().halt(1);
		}
	}
}
