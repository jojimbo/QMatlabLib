package rsg.coreregression;

import junit.framework.TestCase;
import com.mathworks.toolbox.javabuilder.MWException;
import java.io.*;
import rsg.proxy.*;

// Encapsulate all Non Grid, Persistence tests
public class PersistenceGrid extends TestCase {
	public void setUp() throws IOException, MWException {
		System.out.println("Setup " + getName());
		RSGHelper.configure("app_grid.config", getName());
		RSGHelper.RebuildScenarioDB();
	}
	
	public void tearDown() {
		System.out.println("Teardown");
	}
	/*
	public void testWhatIf_BigBang_tgt0() throws MWException {
		//RSGProxy.RSGSimulate("Test28.xml");
		//RSGHelper.runSimulation("Test32.xml");
	}
	*/
	public void xtestWhatIf_tgt0() throws MWException {
		RSGProxy.RSGSimulate("Test19.xml");
		RSGHelper.runSimulation("Test24.xml");
	}
	/*
	public void testUDS_tgt0() throws MWException {
		//RSGHelper.runSimulation("Test30.xml");
	}
	
	public void testBigBang_tgt0() throws MWException {
		//RSGHelper.runSimulation("Test28.xml");
	}
*/
	public void testBaseSimulation_tgt0() throws MWException {		
		RSGHelper.runSimulation("Test19.xml");
	}	
	/*
	public void testCS_WhatIf_tgt0() throws MWException {
		
		String araReportPath = RSGHelper.GetConfigValue("ARAReportPath");
		File araReport = new File(araReportPath + File.separatorChar + "Test29", "ST_Critical_Scenarios_IDs_100sims.csv");
		RSGProxy.RSGSimulate("Test27.xml");
		RSGProxy.RSGSimulate("Test31.xml");
		String[] values = RSGProxy.RSGRunCS("Test31.xml", araReport.toString(), 5, "Exponential", "");
		
		System.out.println("Simulation completed");
		
		String scenarioID = RSGHelper.getArg(values);
		RSGHelper.generateFiles(scenarioID);
	
	    // Compare the generated files to a baseline
	    // Provide the scenario set ID and the path to the baseline files
	    String pathToBaseline = RSGHelper.GetConfigValue("BaselineFolder");
	    String pathToOutput = RSGHelper.GetConfigValue("OutputFolderPath");
	    RSGHelper.CompareFiles(pathToOutput, scenarioID, pathToBaseline);
	    
	}
*/
}
