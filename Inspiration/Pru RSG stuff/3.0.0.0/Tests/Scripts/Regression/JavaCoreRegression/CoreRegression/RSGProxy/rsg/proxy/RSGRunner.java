package rsg.proxy;

import RSGSimulate.RSGSimulate;

import com.mathworks.toolbox.javabuilder.MWException;

// This class exists merely as an alias - to hide the 
// inappropriately named RSGSimulate class
public class RSGRunner extends RSGSimulate {
	public RSGRunner() throws MWException {		
		System.out.println("Constructing an RSG instance...");
	}		
}
