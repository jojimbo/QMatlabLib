function TestXmlModelImport()
    %TESTXMLMODELIMPORT test the general model xml import function    
    clear;
    clc;
    
    testYieldCurve();
    testFxRate();
    testVolaSurface();
end

function testVolaSurface()
    import prursg.Model.*;
    
    model = VolNormal();    
    dom = xmlread(fullfile('+prursg','+Test', '+Xml', 'vola-surface-model.xml'));
    model.fromXml(dom.getFirstChild());
    checkImportedVolaSurface(model);
    checkExportedVolaSurface(dom, model);
end

function checkImportedVolaSurface(model)
    sigma = zeros(3, 3);
    sigma(1, 1) = 1.99415652617254E-02;
    sigma(2, 1) = 1.47480374380712E-02;
    sigma(3, 1) = 1.35246554971043E-02;
    sigma(1, 2) = 1.99415652617254E-02;
    sigma(2, 2) = 1.47480374380712E-02;
    sigma(3, 2) = 1.35246554971043E-02;
    sigma(1, 3) = 1.99415652617254E-02;
    sigma(2, 3) = 1.47480374380712E-02;
    sigma(3, 3) = 1.35246554971043E-02;   
    assert(isequal(model.sigma, sigma));
end

function checkExportedVolaSurface(dom, model)
    import prursg.Model.*;

    model.sigma = magic(4);
    model.toXml(dom.getFirstChild());
    %str = xmlwrite(dom);
    
    surface = VolNormal();
    surface.fromXml(dom.getFirstChild());
    
    assert(isequal(model.sigma, surface.sigma));
    assert(isequal(model, surface));
end

function testYieldCurve()
    import prursg.Model.*;
    
    risk = prursg.Engine.Risk([] , []);
    dom = xmlread(fullfile('+prursg','+Test', '+Xml', 'yc-model.xml'));
    prursg.Xml.RiskDao.fromXml(risk, dom.getFirstChild());
    
    assert(risk.random_seed == 1);
    assert(strcmp(risk.name, 'TST_nyc'));
    assert(strcmp(risk.risk_family, 'nyc'));
    assert(strcmp(risk.currency, 'TST'));
    
    model = YC3factorPCA(); 
    model.fromXml(dom.getFirstChild());
    
    checkYieldCurveImport(model);
    checkYieldCurveExport(dom, model);
end

function checkYieldCurveImport(model)
    coord = [ 1 12 90];
    pc1 = [0.757250452204615 0.181625167980594 3.07020013000342E-06];
    pc2 = [-0.457675264723907 0.337742841173688 2.57213749992792E-09];
    pc3 = [-0.194448882706178 -0.31037294681053 -7.2018076384558E-09];    
    assertPCValues(coord, pc1, model.PC1);
    assertPCValues(coord, pc2, model.PC2);
    assertPCValues(coord, pc3, model.PC3);    
    %
    assert(model.sigma1 == 0.1667);
    assert(model.sigma2 == 0.0978);
    assert(model.sigma3 == 0.06828);    
end

function assertPCValues(coord, pc, modelPc)
    for i = 1:numel(coord)
        assert(pc(i) == modelPc(coord(i)));
    end
end

function checkYieldCurveExport(dom, model)
    import prursg.Model.*;

    model.PC1 = [ 1 2.2 3 4 5]';
    model.sigma3 = 4;
    model.toXml(dom.getFirstChild());
    str = xmlwrite(dom);
    
    yc = YC3factorPCA();
    yc.fromXml(dom.getFirstChild());
    assert(model.sigma1 == yc.sigma1);
    assert(model.sigma2 == yc.sigma2);
    assert(model.sigma3 == yc.sigma3);
    assert(isequal(model.PC1, yc.PC1));    
    assert(isequal(model.PC2, yc.PC2));    
    assert(isequal(model.PC3, yc.PC3));    
end



%fx rate
function testFxRate()
    import prursg.Model.*;
    
    model = FXLognormal();    
    dom = xmlread(fullfile('+prursg','+Test', '+Xml', 'fx-model.xml'));
    model.fromXml(dom.getFirstChild());
    checkImportedFxRate(model);
    checkExportXml(dom, model);
end

function checkImportedFxRate(fx)
    assert(fx.sigma == 0.05);    
end

function checkExportXml(dom, model)
    import prursg.Model.*;

    xml = dom.getFirstChild();
    model.sigma = 0.08;
    model.toXml(xml);
    str = xmlwrite(dom);
    
    fx = FXLognormal();
    fx.fromXml(dom.getFirstChild());
    assert(fx.sigma == model.sigma);
    assert(isequal(model, fx));
end

