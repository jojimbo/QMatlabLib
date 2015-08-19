classdef ScenarioType < int32
    %% SCENARIOTYPE 
    %% Enumeration for the scenario_type_key for the ModelFile object.    
    %
    %  A list of the valid values that can be set in the input xml control 
    %  file for the element
    %  <scenario_set_type><scenario_type_key>
    %  from <PruRSG><run_parameters>
    %     
    %%
    enumeration
        Base                (1) % t=0 base simulation
        WhatIfBase          (2) % t=0 what-if
        WhatIfProjection    (3) % t>0 what-if
        BigBang             (4) % Big bang
        PnL                 (5) % Pnl
        StandardFormula     (6) % Standard formula
        LM_Calibration      (7) % Lite model calibration
        BaseProjection      (8) % t>0 base simulation
        CriticalScenario    (9) % Critical scenario 2.6.0 and older code.
       
        Undefined_10        (10)
        Undefined_11        (11)
        Undefined_12        (12)
        Undefined_13        (13)
        Undefined_14        (14)
        Undefined_15        (15)
        Undefined_16        (16)
        Undefined_17        (17)
        Undefined_18        (18)
        Undefined_19        (19)
        
        AllCalibrations         (20)
        RiskModelCalibration         (21)
        DependencyModelCalibration         (22)
        
        Reserved_23         (23)
        Reserved_24         (24)
        Reserved_25         (25)
        Reserved_26         (26)
        Reserved_27         (27)
        Reserved_28         (28)
        Reserved_29         (29)
        Reserved_30         (30)
        Reserved_31         (31)
        Reserved_32         (32)
        Reserved_33         (33)
        Reserved_34         (34)
        Reserved_35         (35)
        Reserved_36         (36)
        Reserved_37         (37)
        Reserved_38         (38)
        Reserved_39         (39)
        
        
    end
    
end

