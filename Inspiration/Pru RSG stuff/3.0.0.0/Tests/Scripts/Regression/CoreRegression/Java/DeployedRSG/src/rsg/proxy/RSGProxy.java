package rsg.proxy;

import com.mathworks.toolbox.javabuilder.*;

import java.util.*;

public class RSGProxy {

	public static String[] RSGCalibrate(String controlFilePath)
			throws MWException {
		// [UserMsg XMLFilePathOut] = RSGCalibrate(XMLFilePath)

		RSGRunner runner = null;
		try {
			List in = RSGHelper.ins(controlFilePath);
			List out = RSGHelper.outs(2);
			runner = new RSGRunner();

			System.out.println("Calling RSGCalibrate...");
			runner.RSGCalibrate(out, in);
			return RSGHelper.processReturnedArgs(out);
		} finally {
			RSGProxy.cleanup(runner);
		}
	}

	public static void RSGBootstrap(String controlFilePath) throws MWException {
		// RSGBootstrap(inputXmlFilePath)			

		RSGRunner runner = null;
		try {
			List in = RSGHelper.ins(controlFilePath);
			List out = RSGHelper.outs(0);
			runner = new RSGRunner();

			System.out.println("Calling RSGBootstrap...");
			runner.RSGBootstrap(out, in);
		} finally {
			RSGProxy.cleanup(runner);
		}
	}

	public static String[] RSGSimulate(String controlFilePath)
			throws MWException {
		// [UserMsg ScenSetID] = RSGSimulate(XMLFilePath, nBatch)
		RSGRunner runner = null;
		try {
			List in = RSGHelper.ins(controlFilePath, "");
			List out = RSGHelper.outs(2);

			runner = new RSGRunner();

			System.out.println("Calling RSGSimulate...");
			runner.RSGSimulate(out, in);

			return RSGHelper.processReturnedArgs(out);
		} finally {
			RSGProxy.cleanup(runner);
		}
	}

	public static String[] RSGValidate(String scenarioID) throws MWException {
		// [UserMsg valReportPath] = RSGValidate(scenSetName)
		RSGRunner runner = null;
		try {
			List in = RSGHelper.ins(scenarioID);
			List out = RSGHelper.outs(2);

			runner = new RSGRunner();

			System.out.println("Calling RSGValidate...");
			runner.RSGValidate(out, in);

			return RSGHelper.processReturnedArgs(out);
		} finally {
			RSGProxy.cleanup(runner);
		}
	}

	public static String[] RSGMakePruFiles(String scenarioID)
			throws MWException {
		// [UserMsg pruFilesPath] = RSGMakePruFiles(scenSetName, scenDates)	
		RSGRunner runner = null;
		try {
			List in = RSGHelper.ins(scenarioID, "");
			List out = RSGHelper.outs(2);

			runner = new RSGRunner();

			System.out.println("Calling RSGMakePruFiles...");
			runner.RSGMakePruFiles(out, in);

			return RSGHelper.processReturnedArgs(out);
		} finally {
			RSGProxy.cleanup(runner);
		}
	}

	public static String[] RSGMakeAlgoFiles(String scenarioID)
			throws MWException {
		// [UserMsg algoFilesPath] = RSGMakeAlgoFiles(scenSetName, scenDates)
		RSGRunner runner = null;
		try {
			List in = RSGHelper.ins(scenarioID, "");
			List out = RSGHelper.outs(2);

			runner = new RSGRunner();

			System.out.println("Calling RSGMakeAlgoFiles...");
			runner.RSGMakeAlgoFiles(out, in);

			return RSGHelper.processReturnedArgs(out);
		} finally {
			RSGProxy.cleanup(runner);
		}
	}

	public static String RSGBootstrapValidate(String controlFilePath)
			throws MWException {
		// OutputFilesPath = RSGBootstrapValidate(xmlFilePath)

		RSGRunner runner = null;
		try {
			List in = RSGHelper.ins(controlFilePath);
			List out = RSGHelper.outs(1);

			runner = new RSGRunner();

			System.out.println("Calling RSGBootstrapValidate...");
			runner.RSGBootstrapValidate(out, in);

			return RSGHelper.processReturnedArgs(out)[0];
		} finally {
			RSGProxy.cleanup(runner);
		}
	}

	public static String RSGBootstrapCalibrate(String controlFilePath)
			throws MWException {
		// outputXmlPath = RSGBootstrapCalibrate(inputXmlPath)

		RSGRunner runner = null;
		try {
			List in = RSGHelper.ins(controlFilePath);
			List out = RSGHelper.outs(1);

			runner = new RSGRunner();

			System.out.println("Calling RSGBootstrapCalibrate...");
			runner.RSGBootstrapCalibrate(out, in);

			return RSGHelper.processReturnedArgs(out)[0];
		} finally {
			RSGProxy.cleanup(runner);
		}
	}

	public static String[] RSGRunCS(String controlFilePath,
			String araReportFileNme, int windowSize, String windowShape,
			String shapeParameter) throws MWException {
		// [UserMsg ScenSetID] = RSGRunCS(xmlFilePath, araReportFileName, windowSize, windowShape, shapeParameter) 

		RSGRunner runner = null;
		try {
			List in = RSGHelper.ins(controlFilePath, araReportFileNme,
					windowSize, windowShape, shapeParameter);
			List out = RSGHelper.outs(2);

			runner = new RSGRunner();

			System.out.println("Calling RSGBootstrapCalibrate...");
			runner.RSGRunCS(out, in);
			return RSGHelper.processReturnedArgs(out);
		} finally {
			RSGProxy.cleanup(runner);
		}
	}

	private static void cleanup(RSGRunner runner) {
		if (runner != null) {
//			com.mathworks.toolbox.javabuilder.MWApplication.terminate();
			runner.dispose();
//			Runtime.getRuntime().halt(1);
		}
	}
}
