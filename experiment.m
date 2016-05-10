function varargout = experiment(varargin)
% experiment M-file for experiment.fig
%      experiment, by itself, creates a new experiment or raises the existing
%      singleton*.
%
%      H = experiment returns the handle to a new experiment or the handle to
%      the existing singleton*.
%
%      experiment('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in experiment.M with the given input arguments.
%
%      experiment('Property','Value',...) creates a new experiment or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before experiment_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to experiment_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help experiment

% Last Modified by GUIDE v2.5 23-Oct-2014 15:46:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @experiment_OpeningFcn, ...
                   'gui_OutputFcn',  @experiment_OutputFcn, ...
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

function setBoundField(h, field, value)
    handles = guidata(h);
    handles.(field) = value;
    guidata(h, handles);
    
    boundFns = handles.boundFns;
    if isfield(boundFns, field)
        fnsForField = boundFns.(field);
        for i = 1: size(fnsForField, 2)
            fn = fnsForField{i};
            fn(value);
        end
    end
end

function bind(h, field, fn)
    handles = guidata(h);
    if ~isfield(handles, 'boundFns')
        handles.boundFns = {};
    end
    origFns = {};
    if isfield(handles.boundFns, field)
        origFns = handles.boundFns.(field);
    end
    handles.boundFns.(field) = [origFns {fn}];
    guidata(h, handles);
end

% --- Executes just before experiment is made visible.
function experiment_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to experiment (see VARARGIN)

% Choose default command line output for experiment
handles.output = hObject;
guidata(hObject, handles);

    function setFontSize(fontSize)
        set(handles.fontSizeText, 'String', ...
            sprintf('Font Size: %.0f', fontSize));
        set(handles.displayText, 'FontSize', fontSize);
    end

bind(hObject, 'fontSize', @setFontSize);

    function setConfigPath(configPath)
        handlesC = guidata(hObject);
        set(handlesC.startButton,'Enable','On');
        set(handlesC.configFilePathText,'String',configPath);
        handlesC.config = picShower.fileUtils.loadConfig(configPath);
        guidata(hObject, handlesC);
    end
bind(hObject, 'configPath', @setConfigPath);

% UIWAIT makes experiment wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = experiment_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in startButton.
function startButton_Callback(~, ~, handles)
% hObject    handle to startButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.cancelButton, 'Enable', 'On');

    function cancel = cancelNotifyFn
        ptr = handles.output;
        currState = guidata(ptr);
        cancel = currState.cancel;
    end

handles.cancel = false;
guidata(handles.output, handles);

picShower.controllers.runExperiment(...
    handles.flashShower, handles.displayText, ...
    handles.config, ...
    @cancelNotifyFn);

end

function cancelButton_Callback(~, ~, handles)
    handles.cancel = true;
    guidata(handles.output, handles);
    set(handles.cancelButton, 'Enable', 'Off');
end

function prepTextBoxForWindowsOs(hObject)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function fontSizeSlider_Callback(slider, ~, handles)
    setBoundField(handles.output, 'fontSize', slider.Value);
end

function fullpath = selectFileSub()
    [data_filename, data_pathname] = uigetfile( ...
                    {'*.m;', 'Matlab files (*.m)';...
                    '*.*',       'All Files (*.*)'},...
                    sprintf('Select a %s file','Config'));
    if isequal(data_filename,0)
        fullpath = '';
        return;
    else
        fullpath = [data_pathname data_filename];
    end
end

function loadConfigFileButton_Callback(~, ~, handles)
    configFilePath = selectFileSub();
    if configFilePath
        setBoundField(handles.output, 'configPath', configFilePath);
    end
end
