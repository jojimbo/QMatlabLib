% These tests cover QC1873 (Adding and removing dynamic properties).

function test_suite = Test_QC1873_AddRemoveDynamicProperties()
    disp('Initialising Test_QC1873_AddRemoveDynamicProperties')
 
    initTestSuite;        
end

function Test_AddRemoveDynamicProperties()
    % Test that properties can be added and removed
    disp('Executing test Test_AddRemoveDynamicProperties')
    ds = prursg.Engine.DataSeries();

    name = 'dynProp1'; type = 'number'; value = 42;
    AddRemove(ds, name, type, value)

    % Do it twice to ensure object is still usable
    name = 'dynProp1'; type = 'string'; value = 'forty two';
    AddRemove(ds, name, type, value)
end

function Test_AddRemoveUseDynamicProperties()
    % Test that properties behave as expected
    disp('Executing test Test_AddRemoveUseDynamicProperties')
    ds = prursg.Engine.DataSeries();

    AddRemoveHelper(ds);
end

function Test_AddRemoveOnClone()
    % Test that properties behave as expected on a clone
    disp('Executing test Test_AddRemoveOnClone')
    ds = prursg.Engine.DataSeries();

    AddRemoveHelper(ds.Clone);
end

function Test_AddDynamicPropertiesTwice()
    % Check that an exception is thrown if the same proprty is re-added 
    disp('Executing test Test_AddDynamicPropertiesTwice')
    ds = prursg.Engine.DataSeries();

    name = 'dynProp1'; type = 'string'; value = 'forty two';
    
    assertFalse(ds.HasDynamicProperty(name))
    assertTrue(isempty(ds.findprop(name)))
    Add(ds, name, type, value)
    
    assertExceptionThrown(@() Add(ds, name, type, value),  'DataSeries:AddDynamicProperty', ... 
        'We expect an exception as the dynamic property has already been added')
end

function Test_AddDynamicPropertiesAndClone()
    % Check that added dynamic properties persist across clones
    disp('Executing test Test_AddDynamicPropertiesAndClone')
    ds = prursg.Engine.DataSeries();

    name = 'dynProp1'; type = 'string'; value = 'forty two';
    
    assertFalse(ds.HasDynamicProperty(name))
    assertTrue(isempty(ds.findprop(name)))
    Add(ds, name, type, value)

    clone = ds.Clone;

    assertTrue(clone.HasDynamicProperty(name))
    assertFalse(isempty(ds.findprop(name)))

    assertEqual(ds.dynProp1, clone.dynProp1)

    clone.dynProp1 = 'forty three';

    assertEqual(ds.dynProp1,'forty two') 
    assertEqual(clone.dynProp1, 'forty three')
end

function Test_AddDynamicPropertyWithUnsupportedType()
    disp('Executing test Test_AddDynamicPropertyWithUnsupportedType')
    ds = prursg.Engine.DataSeries();

    name = 'dynProp1'; type = 'double'; value = 42;
    
    assertFalse(ds.HasDynamicProperty(name))
    assertTrue(isempty(ds.findprop(name)))
    assertExceptionThrown(@() Add(ds, name, type, value),  'DynamicProperty:DynamicProperty', ... 
        'We expect an exception as the dynamic property supports types ''string'' and ''number'' only')
end

function Test_ConstructDynamicPropertyWithUnsupportedArguments()
    disp('Executing test Test_ConstructDynamicPropertyWithUnsupportedArguments')
    ds = prursg.Engine.DataSeries();

    name = 'dynProp1'; type = 'number'; value = 42;
     
    assertFalse(ds.HasDynamicProperty(name))
    assertTrue(isempty(ds.findprop(name)))
    
    assertExceptionThrown(@() prursg.Engine.DynamicProperty(name, value, type, 42),...
		'DynamicProperty:DynamicProperty', ... 
        ['We expect an exception as the dynamic property expects no arguments, or, '...
		'''name'', ''value'', or, ''name'', ''value'', ''type'' only'])
    
    assertExceptionThrown(@() prursg.Engine.DynamicProperty(name, value, type, ''),...
		'DynamicProperty:DynamicProperty', ... 
        ['We expect an exception as the dynamic property expects no arguments, or, '...
		'''name'', ''value'', or, ''name'', ''value'', ''type'' only'])
    
    
    assertExceptionThrown(@() prursg.Engine.DynamicProperty(name),...
		'DynamicProperty:DynamicProperty', ... 
        ['We expect an exception as the dynamic property expects no arguments, or, '...
		'''name'', ''value'', or, ''name'', ''value'', ''type'' only'])
end

% Helper functions
function AddRemove(ds, name, type, value)
    assertFalse(ds.HasDynamicProperty(name))
    assertTrue(isempty(ds.findprop(name)))
    Add(ds, name, type, value)
    
    Remove(ds, name)    
end

function Add(ds, name, type, value)
    ds.AddDynamicProperty(name, value, type)
    
    assertTrue(ds.HasDynamicProperty(name))
    assertFalse(isempty(ds.findprop(name)))    
end

function Remove(ds, name)
    assertTrue(ds.RemoveDynamicProperty(name))
    
    assertFalse(ds.HasDynamicProperty(name))
    assertTrue(isempty(ds.findprop(name)))
end


function AddRemoveHelper(ds)
    name1 = 'dynProp1'; type1 = 'number'; value1 = 42;
    Add(ds, name1, type1, value1)

    assertEqual(ds.dynProp1, value1);
    
    % Test that multiple dyn props can be added and used
    
    name2 = 'dynProp2'; type2 = 'string'; value2 = '42';
    Add(ds, name2, type2, value2)

    assertEqual(ds.dynProp2, value2);
    
    % Now re-add the first property with a different type
    Remove(ds, name1);
    
    % Change its type
    Add(ds, name1, type2, value2)

    assertEqual(ds.dynProp1, value2);

end

