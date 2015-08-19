function TestXmlModelImport()
    %TESTXMLMODELIMPORT test the general model xml import function    
    clear;
    clc;
    
    import prursg.Model.*;
    
    dom = xmlread(fullfile('+prursg','+Test', '+Xml', 'fx-model.xml'));
    checkCalibrationSources(dom);
    checkCalibrationTargets(dom);
    checkModel(dom);
end

function checkModel(dom)
    import prursg.Model.*;
    
    model = FXLognormal();    
    model.fromXml(dom.getFirstChild());
    assertCalibrationSource(model.calibrationSource);
    assertCalibrationTargets(model.calibrationTargets);
end

function checkCalibrationSources(dom)
    import prursg.Xml.*;
    source = prursg.Engine.CalibrationSource();
    assert(source.fromXml(XmlTool.getNode(dom, 'risk_calibration_set')));
    assertCalibrationSource(source);
end

function assertCalibrationSource(source)
    assert(strcmp(source.ids{1}, 'TEST_FX'));
    assert(strcmp(prursg.Xml.XmlTool.dateToString(source.from), '31/10/2008'));
    assert(strcmp(prursg.Xml.XmlTool.dateToString(source.to), '30/09/2009'));
end

function assertCalibrationTargets(targets)
    assert(strcmp(targets(1).percentile, '95%'));
    assert(strcmp(targets(2).percentile, 'mean'));
    assert(targets(1).value == 0.01);
    assert(targets(2).value == 1);
end

function checkCalibrationTargets(dom)
    import prursg.Xml.*;
    %
    targets = prursg.Engine.CalibrationTarget.fromXml(XmlTool.getNode(dom, 'calibration_targets'));    
    assert(numel(targets) == 2);
    assertCalibrationTargets(targets);
end

