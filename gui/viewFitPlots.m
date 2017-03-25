function varargout = viewFitPlots(varargin)
% VIEWFITPLOTS MATLAB code for viewFitPlots.fig
%      VIEWFITPLOTS, by itself, creates a new VIEWFITPLOTS or raises the existing
%      singleton*.
%
%      H = VIEWFITPLOTS returns the handle to a new VIEWFITPLOTS or the handle to
%      the existing singleton*.
%
%      VIEWFITPLOTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEWFITPLOTS.M with the given input arguments.
%
%      VIEWFITPLOTS('Property','Value',...) creates a new VIEWFITPLOTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before viewFitPlots_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to viewFitPlots_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help viewFitPlots

% Last Modified by GUIDE v2.5 29-Jun-2012 17:17:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @viewFitPlots_OpeningFcn, ...
                   'gui_OutputFcn',  @viewFitPlots_OutputFcn, ...
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


% --- Executes just before viewFitPlots is made visible.
function viewFitPlots_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to viewFitPlots (see VARARGIN)

% Choose default command line output for viewFitPlots
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes viewFitPlots wait for user response (see UIRESUME)
% uiwait(handles.figViewFitPlots);


% --- Outputs from this function are returned to the command line.
function varargout = viewFitPlots_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in chkOverlayDS.
function chkOverlayDS_Callback(hObject, eventdata, handles)
% hObject    handle to chkOverlayDS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkOverlayDS


% --- Executes on button press in btnView.
function btnView_Callback(hObject, eventdata, handles)
% hObject    handle to btnView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
