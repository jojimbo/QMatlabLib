function varargout = Demo_GUI_01(varargin)
% DEMO_GUI_01 MATLAB code for Demo_GUI_01.fig
%      DEMO_GUI_01, by itself, creates a new DEMO_GUI_01 or raises the existing
%      singleton*.
%
%      H = DEMO_GUI_01 returns the handle to a new DEMO_GUI_01 or the handle to
%      the existing singleton*.
%
%      DEMO_GUI_01('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DEMO_GUI_01.M with the given input arguments.
%
%      DEMO_GUI_01('Property','Value',...) creates a new DEMO_GUI_01 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Demo_GUI_01_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Demo_GUI_01_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Demo_GUI_01

% Last Modified by GUIDE v2.5 19-May-2015 11:44:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Demo_GUI_01_OpeningFcn, ...
    'gui_OutputFcn',  @Demo_GUI_01_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end


% --- Executes just before Demo_GUI_01 is made visible.
function Demo_GUI_01_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Demo_GUI_01 (see VARARGIN)

% Choose default command line output for Demo_GUI_01
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
end


% UIWAIT makes Demo_GUI_01 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Demo_GUI_01_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


% --- Executes on selection change in CalculationChoice.
function CalculationChoice_Callback(hObject, eventdata, handles)
% hObject    handle to CalculationChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns CalculationChoice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CalculationChoice
end


% --- Executes during object creation, after setting all properties.
function CalculationChoice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CalculationChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes when Model Choice changes
function selectedModel = uibuttongroupModelChoice_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1
% eventdata  structure with the following fields
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

ModelButtonActive = strtrim(get(eventdata.NewValue, 'Tag')); % Get Tag of selected object.
if strcmpi(ModelButtonActive, 'GBMbutton')
    selectedModel = 'Gbm';
    set(handles.TableGBMModelProperties, 'Visible','on')
    set(handles.TableHestonModelProperties, 'Visible','off')
elseif strcmpi(ModelButtonActive, 'Hestonbutton')
    selectedModel = 'Heston';
    set(handles.TableGBMModelProperties, 'Visible','off')
    set(handles.TableHestonModelProperties, 'Visible','on')
else
    error('Model not implemented yet')
end

end


% --- Returns selected Model
function selectedModel = uibuttongroupModelChoice_Callback(hObject, eventdata, handles)
% hObject    handle to InstrumentChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns InstrumentChoice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from InstrumentChoice

ModelButtonActive = handles.uibuttongroupModelChoice.SelectedObject.Tag;
if strcmpi(ModelButtonActive, 'GBMbutton')
    selectedModel = 'Gbm';
elseif strcmpi(ModelButtonActive, 'Hestonbutton')
    selectedModel = 'Heston';
else
    error('Model not implemented yet')
end
end


% --- Executes on button press in GBMbutton.
function GBMbutton_Callback(hObject, eventdata, handles)
% hObject    handle to GBMbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end


% --- Executes on button press in Hestonbutton.
function Hestonbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Hestonbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end


% --- Executes on selection change in InstrumentChoice.
function InstrumentToPrice = InstrumentChoice_Callback(hObject, eventdata, handles)
% hObject    handle to InstrumentChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns InstrumentChoice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from InstrumentChoice

% Determine selected InstrumentChoice
str = cellstr(get(hObject, 'String'));
val = get(hObject,'Value');

handles.InstrumentToPrice = str{val};
guidata(hObject, handles);
InstrumentToPrice = strtrim(str{val});
end


% --- Executes during object creation, after setting all properties.
function InstrumentChoice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InstrumentChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
instfact = engine.factories.InstrumentFactory;
set(hObject,'String',instfact.list);

end


% --- Executes on button press in RunSimbutton.
function RunSimbutton_Callback(hObject, eventdata, handles)
% hObject    handle to RunSimbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Today = datestr(today, 'dd-mmm-yyyy');
Maturity = handles.TableInstrProperties.Data{2};
        
n_steps = daysdif(Today, Maturity, 0); % 0 for Act/Act
T = yearfrac(Today, Maturity, 0); % 0 for Act/Act
        
n_sim = str2double(get(handles.NumSimsInput, 'String'));

ModelToUse = uibuttongroupModelChoice_Callback(handles.uibuttongroupModelChoice, eventdata, handles);
switch ModelToUse
    case 'Gbm'
        drift = handles.TableGBMModelProperties.Data{1};
        sigma0 = handles.TableGBMModelProperties.Data{2}; %Initial Volatility
        S0 = handles.TableGBMModelProperties.Data{3}; %Initial price for the Stock
        riskcare_gbm = quant.models.Gbm_RC_01(drift, sigma0);

        tStart = tic;
        [Paths2, Times2, Z2] = Simulate(riskcare_gbm, n_steps, 'DeltaTime', T/n_steps, 'NTRIALS', n_sim, ...
            'Method', 'Riskcare', 'StartState', S0);
        timeSimGBM_RCwithRNG = toc(tStart)
        
        stockprices = quant.TimeSeries(squeeze(Paths2), 'days', datenum(Maturity)-n_steps, 'Name', 'stockprices');
        stockvols = sigma0;
    case 'Heston'
        % TODO -- Configure Heston
        r = handles.TableHestonModelProperties.Data{1};
        kappa = handles.TableHestonModelProperties.Data{2}; % Speed of reversion
        eta = handles.TableHestonModelProperties.Data{3}; % Long run variance
        theta = handles.TableHestonModelProperties.Data{4}; % Vol of Variance (lambda in Heston Little Trap)
        rho = handles.TableHestonModelProperties.Data{5}; % Correlation
        
        sigma0 = handles.TableHestonModelProperties.Data{6}; % Initial Volatility
        S0 = handles.TableHestonModelProperties.Data{7}; % Initial price for the Stock
        
        riskcare_heston = quant.models.Heston_RC_01(rho, theta, kappa, eta, r);
        tStart = tic;
        [Paths3, Times3, Z3] = Simulate(riskcare_heston, n_steps, 'DeltaTime', T/n_steps, 'NTRIALS', n_sim, ...
            'Method', 'Riskcare', 'StartState', [S0; sigma0]);
        timeSimHeston_RCwithRNG = toc(tStart)
        
        stockprices = quant.TimeSeries(squeeze(Paths3(:,1,:)), 'days', datenum(Maturity)-n_steps, 'Name', 'stockprices');
        stockvols = quant.TimeSeries(squeeze(Paths3(:,2,:)), 'days', datenum(Maturity)-n_steps, 'Name', 'stockvols');
    otherwise
        error('Model '&ModelToUse&' not implemented')
end

handles.stockprices     = stockprices;
handles.stockvols       = stockvols;

% Calls to update simulation paths plot everytime a new simulation is performed
% if the togglebutton for automated updates of the plots is active
if UpdatePlotsActive_Callback(handles.UpdatePlotsActive, eventdata, handles)
    UpdatePlots_Callback(hObject, eventdata, handles)
end

% TODO - Include automatic re-pricing of instrument??

guidata(hObject, handles);
end


% --- Executes on button press in UpdatePlots.
function UpdatePlots_Callback(hObject, eventdata, handles)
% hObject    handle to UpdatePlots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.SimPathsPlot);
cla(handles.SimPathsPlot);
plot(handles.stockprices);

axes(handles.PricesDistributionPlot);
cla(handles.PricesDistributionPlot);
[pd1,pd2,pd3,pd4] = createFit(handles.stockprices.Data(end,:));
end


% --- Executes on button press in PriceInstrButton.
function PriceInstrButton_Callback(hObject, eventdata, handles)
% hObject    handle to PriceInstrButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
TEF = quant.riskFactors.EquityStock('TEF'); %Underlying of the Option

Today = datestr(today, 'dd-mmm-yyyy');

if isnumeric(handles.TableInstrProperties.Data{1})
    Strike = handles.TableInstrProperties.Data{1};
elseif ischar(handles.TableInstrProperties.Data{1})
    Strike = str2double(handles.TableInstrProperties.Data{1});
else
    % TODO - Able to digest other formats
    Strike = str2double(handles.TableInstrProperties.Data{1});
end
Maturity = handles.TableInstrProperties.Data{2};
Call_Put_Flag = handles.TableInstrProperties.Data{3};

InstrumentType = InstrumentChoice_Callback(handles.InstrumentChoice, eventdata, handles);
if strcmpi(InstrumentType, 'Euro_Option')
    OptionToPrice = quant.instruments.Euro_Option(Call_Put_Flag, TEF, Maturity, Strike)
    % For Euro Option simply MC:
    [priceOption, stdError, finalPayments] = quant.methods.MCPrice(OptionToPrice, handles.stockprices, Today);
elseif strcmpi(InstrumentType, 'Asian_Option')
    OptionToPrice = quant.instruments.Asian_Option(Call_Put_Flag, TEF, Maturity, Strike)
    % For Asian Option simply MC:
    [priceOption, stdError, finalPayments] = quant.methods.MCPrice(OptionToPrice, handles.stockprices, Today);
elseif strcmpi(InstrumentType, 'Amer_Option')
    OptionToPrice = quant.instruments.Amer_Option(Call_Put_Flag, TEF, Maturity, Strike)
    % For American Option use LSMC:
    [priceOption, stdError, finalPayments] = quant.methods.LSMCPrice(OptionToPrice, handles.stockprices, Today);
elseif strcmpi(InstrumentType, 'Hold_Underlying')
    OptionToPrice = quant.instruments.Hold_Underlying(TEF, Maturity)
    [priceOption, stdError, finalPayments] = quant.methods.MCPrice(OptionToPrice, handles.stockprices, Today);
else
    error('Not implemented Instrument yet')
end

handles.InstrumentPrice.Price = priceOption;
handles.InstrumentPrice.stdError = stdError;
handles.InstrumentPrice.finalPayments = finalPayments;

set( handles.displayPrice, 'String', num2str(priceOption) );

guidata(hObject, handles);
end


function displayPrice_Callback(hObject, eventdata, handles)
% hObject    handle to displayPrice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of displayPrice as text
%        str2double(get(hObject,'String')) returns contents of displayPrice as a double
end


% --- Executes during object creation, after setting all properties.
function displayPrice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displayPrice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes during object creation, after setting all properties.
function TableInstrProperties_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displayPrice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

% Set default values
Maturity = datestr(daysadd(today,360, 1), 'dd-mmm-yyyy');
hObject.Data{1} = 100;
hObject.Data{2} = Maturity;
hObject.Data{3} = 'Put';
%set(hObject.Data{1}, 'String', '100');
%set(hObject.Data{2}, 'String', Maturity);
%set(hObject.Data{3}, 'String', 'Put');
guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function TableGBMModelProperties_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displayPrice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

% Set default values
hObject.Data{1} = 0.04; % Drift
hObject.Data{2} = 0.4; % Initial Volatility (constant for GBM)
hObject.Data{3} = 80.0; % Initial value of the Underlying stock

guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function TableHestonModelProperties_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displayPrice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

% Set default values
hObject.Data{1}     = 0.04;             % Risk free rate
hObject.Data{2}     = 1.5768;           % Speed of reversion
hObject.Data{3}     = 0.0398;           % Long run variance
hObject.Data{4}     = 0.5751;           % Vol of Variance (lambda in Heston Little Trap)
hObject.Data{5}     = -0.5711;          % Correlation

hObject.Data{6}     = sqrt(0.0175);     % Initial Volatility
hObject.Data{7}     = 80;               % Initial price for the Stock
 
guidata(hObject, handles);
end


% --- Executes on button press in UpdatePlotsActive.
function active = UpdatePlotsActive_Callback(hObject, eventdata, handles)
% hObject    handle to UpdatePlotsActive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of UpdatePlotsActive
active = get(hObject,'Value');
end


% --- Executes on button press in CalculateVaRbutton.
function CalculateVaRbutton_Callback(hObject, eventdata, handles)
% hObject    handle to CalculateVaRbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
varLevel = str2double(get(handles.VaRLevelInput, 'String'));

handles.Var = quantile(handles.InstrumentPrice.finalPayments, varLevel);
set( handles.displayVaR, 'String', num2str(handles.Var) );

axes(handles.VaRPlot);
cla(handles.VaRPlot);
[pd1,pd2,pd3,pd4,pd5,pd6] = createVaRFit(handles.InstrumentPrice.finalPayments, varLevel);

guidata(hObject, handles);

end


function VaRLevelInput_Callback(hObject, eventdata, handles)
% hObject    handle to VaRLevelInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VaRLevelInput as text
%        str2double(get(hObject,'String')) returns contents of VaRLevelInput as a double
end

% --- Executes during object creation, after setting all properties.
function VaRLevelInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VaRLevelInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
