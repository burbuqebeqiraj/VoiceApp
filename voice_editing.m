function varargout = voice_editing(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @voice_editing_OpeningFcn, ...
                   'gui_OutputFcn',  @voice_editing_OutputFcn, ...
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


% --- Executes just before voice_editing is made visible.
function voice_editing_OpeningFcn(hObject, eventdata, handles, varargin)
% %disable button
set(handles.btnSave,'enable','on');

set(handles.btnPause,'enable','off');
set(handles.btnResume,'enable','off');
set(handles.btnStop,'enable','off');
set(handles.btn_play,'enable','off');
% 
set(handles.btnHighpass,'enable','off');
set(handles.btnLowpass,'enable','off');
set(handles.btnBandpass,'enable','off');
set(handles.btnStoppass,'enable','off');
set(handles.cut_off_freq,'enable','off');
set(handles.cut_off_freq_1,'enable','off');
set(handles.radiobuttonIIR,'enable','off');
set(handles.radiobuttonFIR,'enable','off');
set(handles.btnEcho,'enable','off');
set(handles.delay_txt,'enable','off');
set(handles.alfa_txt,'enable','off');
set(handles.amplification, 'enable', 'off')
set(handles.btnPlaybackFilterSound, 'enable', 'off');
set(handles.radiobuttonIIR, 'Value', 0);
set(handles.radiobuttonFIR, 'Value', 0);
set(handles.notify,'Visible','off');
 
handles.output = hObject;

handles.state = 0;
handles.Fs = 8000;
global nBits;
nBits = 16;
global recObj;
recObj = audiorecorder(handles.Fs,nBits,1);
set(recObj,'TimerPeriod',0.05,'TimerFcn',{@audioTimerCallback,handles});

xlabel(handles.axeTimeDomain,'Time');
ylabel(handles.axeTimeDomain, 'Amplitude');
xlabel(handles.axesFrequency,'Frequency(Hz)');
ylabel(handles.axesFrequency,'|Y(f)|');
xlabel(handles.axesFrequencyFilter,'Frequency(Hz)');
ylabel(handles.axesFrequencyFilter,'|Y(f)|');

% Update handles structure
guidata(hObject, handles);


function audioTimerCallback(hObject,event,handles)
if(isempty(hObject))
    return;
end

global signal;
signal = getaudiodata(hObject);
plot(handles.axeTimeDomain, signal);
xlabel(handles.axeTimeDomain,'Time');
ylabel(handles.axeTimeDomain, 'Amplitude');

%fft
nfft = length(signal);
fftRecord = fft(signal,nfft);
X = abs(fftRecord);
fa = (0:nfft/2-1)*handles.Fs/nfft;
M = X(1:nfft/2);
plot(handles.axesFrequency, fa,M);
xlabel(handles.axesFrequency,'Frequency(Hz)');
ylabel(handles.axesFrequency,'|Y(f)|')

% --- Outputs from this function are returned to the command line.
function varargout = voice_editing_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnRecord.
function btnRecord_Callback(hObject, eventdata, handles)
%prepare parameter

global recObj;
global player;
global readvoice;

if handles.state == 0 
    set(hObject,'String','Stop Rec');
    
    player='';
    readvoice = '';
    record(recObj);
    handles.state =1 ;
    
    set(handles.btnImport,'enable','off');
    set(handles.btnStop,'enable','off');
    set(handles.btnResume,'enable','off');
    set(handles.btnPause,'enable','off');
    set(handles.btnSave,'enable','off');
    set(handles.btn_play,'enable','off');
    set(handles.radiobuttonIIR,'enable','off');
    set(handles.radiobuttonFIR,'enable','off');
    set(handles.btnEcho,'enable','off');
    set(handles.delay_txt,'enable','off');
    set(handles.alfa_txt,'enable','off');
    xlabel(handles.axeTimeDomain,'Time');
    ylabel(handles.axeTimeDomain, 'Amplitude');
    xlabel(handles.axesFrequency,'Frequency(Hz)');
    ylabel(handles.axesFrequency,'|Y(f)|')
    set(handles.btnSave,'String','Done');
    set(handles.amplification, 'enable', 'off');
else
    set(hObject,'String','Continue Rec');
    pause(recObj);
    handles.state = 0;
    set(handles.amplification, 'enable', 'on');
    set(handles.btnImport,'enable','off');
    set(handles.btnStop,'enable','off');
    set(handles.btn_play,'enable','on');
    set(handles.btnPause,'enable','off');
    set(handles.btnSave,'enable','on');
    set(handles.radiobuttonIIR,'enable','on');
    set(handles.radiobuttonFIR,'enable','on');
    set(handles.btnEcho,'enable','on');
    set(handles.delay_txt,'enable','on');
    set(handles.alfa_txt,'enable','on');
    set(handles.radiobuttonFIR, 'Value', 0);
    xlabel(handles.axeTimeDomain,'Time');
    ylabel(handles.axeTimeDomain, 'Amplitude');
    xlabel(handles.axesFrequency,'Frequency(Hz)');
    ylabel(handles.axesFrequency,'|Y(f)|');
end

guidata(hObject,handles)



% --- Executes on button press in btnImport.
function btnImport_Callback(hObject, eventdata, handles)
% hObject    handle to btnImport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%global Fs;
global player;
global readvoice;
global filename;
global fOut;

set(handles.btnSave,'String','Done');
filename = uigetfile('*.wav','Select data set');

if isequal(filename, 0)
    msgbox('User selected ''Cancel'''); 
else
    fOut = '';
    readvoice = audioread(filename);
    player = audioplayer(readvoice, handles.Fs);
    cla(handles.axesFrequencyFilter, 'reset');
    set(handles.btnSave,'enable','off');
    set(handles.btnRecord,'enable','on');
    set(handles.btn_play,'enable','off');
    set(handles.radiobuttonIIR,'enable','on');
    set(handles.radiobuttonFIR,'enable','on');
    set(handles.btnPause,'enable','on');
    set(handles.btnResume,'enable','off');
    set(handles.btnStop,'enable','on');
    set(hObject,'String','Change File');
    set(handles.amplification, 'enable', 'off');
    set(handles.radiobuttonFIR, 'enable', 'off');
    set(handles.radiobuttonIIR, 'enable', 'off');
    set(handles.btnHighpass,'enable','off');
    set(handles.btnLowpass,'enable','off');
    set(handles.btnBandpass,'enable','off');
    set(handles.btnStoppass,'enable','off');
    set(handles.cut_off_freq,'enable','off');
    set(handles.cut_off_freq_1,'enable','off');
    set(handles.btnRecord,'enable','off');
    set(handles.cut_off_freq,'String','');
    set(handles.cut_off_freq_1,'String','');
    set(handles.radiobuttonFIR, 'Value', 0);
    set(handles.radiobuttonIIR, 'Value', 0);
    set(handles.btn_play,'String','Playing');
    set(handles.notify,'Visible','on');
    set(handles.notify,'String','Click Stop to start using Tools');
    
    play(player);
    if isempty(player)
        set(handles.btnRecord,'enable','on');
    end
  
    plot(handles.axeTimeDomain, readvoice);
    
    %fft
    plot(handles.axeTimeDomain, readvoice);
    nfft = length(readvoice);
    fftRecord = fft(readvoice,nfft);
    fft_abs = abs(fftRecord);
    fa = (0:nfft/2-1)*handles.Fs/nfft;
    fft_Record = fft_abs(1:nfft/2);

    plot(handles.axesFrequency, fa,fft_Record);
    
    xlabel(handles.axeTimeDomain,'Time');
    ylabel(handles.axeTimeDomain, 'Amplitude');
    xlabel(handles.axesFrequency,'Frequency(Hz)');
    ylabel(handles.axesFrequency,'|Y(f)|');


end


% --- Executes on button press in btnSave.
function btnSave_Callback(hObject, eventdata, handles)
% hObject    handle to btnSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global recObj;
global signal; 
global sig;
global fOut;
global filename;
global readvoice;
global player;
global tryFilter;

pause(recObj);

if isempty(signal) && isempty(readvoice) 
   
    cl = questdlg('Do you want to EXIT?','EXIT',...
            'Yes','No','No');
    switch cl
        case 'Yes'
            close();
            return;
        case 'No'
            quit cancel;
            player='';
    end 
else
    if ~isempty(signal)
        question = questdlg('Do you want to Save?','',...
                   'Save','Save & Close', 'Trash', 'Trash');
        switch question
            case 'Save'
                filename = uiputfile('*.wav','Save as...');
                if isequal(filename, 0)
                    msgbox('User selected ''Cancel''');
                else
                    audiowrite(filename, signal, handles.Fs);
                    set(handles.btnSave,'enable','off');
                    msgbox('Recording Save Successfully')
                    set(handles.btnSave,'String','Done');
                    
                end
                
            case 'Save & Close'
                filename = uiputfile('*.wav','Save as...');     
                if isequal(filename, 0)
                    msgbox('User selected ''Cancel''');
                else
                    stop(recObj);
                    audiowrite(filename, signal, handles.Fs);
                    set(handles.btnImport,'enable','on');
                    set(handles.btnImport,'String','New Import');
                    set(handles.btn_play,'enable','off');
                    set(handles.btnRecord,'String','New Rec');
                    cla(handles.axeTimeDomain,'reset');
                    cla(handles.axesFrequency,'reset'); 
                    cla(handles.axesFrequencyFilter, 'reset');
                    msgbox('Recording Save Successfully')
                    set(handles.btnSave,'enable','on');
                    sig = '';
                    signal = '';
                    set(handles.btnSave,'String','Exit');
                    set(handles.radiobuttonIIR,'enable','off');
                    set(handles.radiobuttonFIR,'enable','off');
                    set(handles.amplification, 'enable', 'off');
                    set(handles.btnEcho,'enable','off');
                    set(handles.delay_txt,'enable','off');
                    set(handles.alfa_txt,'enable','off');
                    set(handles.btnRecord, 'enable', 'on');
                    set(handles.btnImport,'String','New Import');
                    set(handles.btnHighpass,'enable','off');
                    set(handles.btnLowpass,'enable','off');
                    set(handles.btnBandpass,'enable','off');
                    set(handles.btnStoppass,'enable','off');
                    set(handles.cut_off_freq,'String','');
                    set(handles.cut_off_freq_1,'String','');
                    set(handles.radiobuttonFIR, 'Value', 0);
                    set(handles.radiobuttonIIR, 'Value', 0);
                    set(handles.btnPlaybackFilterSound, 'enable', 'off');
                end

            case 'Trash'
                stop(recObj);
                set(handles.btnRecord,'String','New Rec');
                set(handles.btnImport,'String','New Import');
                set(handles.btnSave,'enable','on');
                set(handles.btn_play,'enable','off');
                set(handles.btnImport,'enable','on');
                set(handles.btnResume,'enable','off');
                cla(handles.axeTimeDomain,'reset');
                cla(handles.axesFrequency,'reset');
                set(handles.btnSave,'String','Exit');
                set(handles.radiobuttonIIR,'enable','off');
                set(handles.radiobuttonFIR,'enable','off');
                set(handles.btnHighpass,'enable','off');
                set(handles.btnLowpass,'enable','off');
                set(handles.btnBandpass,'enable','off');
                set(handles.btnStoppass,'enable','off');
                set(handles.btnEcho,'enable','off');
                set(handles.cut_off_freq,'enable','off');
                set(handles.cut_off_freq_1,'enable','off');
                set(handles.amplification, 'enable', 'off');
                set(handles.btnEcho,'enable','off');
                set(handles.delay_txt,'enable','off');
                set(handles.alfa_txt,'enable','off');
                set(handles.btnRecord, 'enable', 'on');
                set(handles.btnImport,'String','New Import');
                set(handles.cut_off_freq,'String','');
                set(handles.cut_off_freq_1,'String','');
                set(handles.radiobuttonFIR, 'Value', 0);
                set(handles.radiobuttonIIR, 'Value', 0);
                set(handles.btnPlaybackFilterSound, 'enable', 'off');
                sig = '';
                signal = '';
%                 stop(sig);
        end
    elseif ~isempty(fOut)
        question = questdlg('Do you want to Save?','',...
                   'Save & Close','Trash', 'Cancel', 'Cancel');
        switch question
            case 'Save & Close'
                filename = uiputfile('*.wav','Save as...');
                if isequal(filename, 0)
                    msgbox('User selected ''Cancel''');
                else 
                    audiowrite(filename, fOut, handles.Fs);
                    msgbox('Recording Save Successfully');
                    set(handles.btnSave,'String','Exit');
                    set(handles.radiobuttonIIR,'enable','off');
                    set(handles.radiobuttonFIR,'enable','off');
                    set(handles.amplification, 'enable', 'off')
                    set(handles.btn_play, 'enable', 'off');
                    set(handles.btnEcho,'enable','off');
                    set(handles.delay_txt,'enable','off');
                    set(handles.alfa_txt,'enable','off');
                    set(handles.btnRecord, 'enable', 'on');
                    set(handles.btnImport,'String','New Import');
                    cla(handles.axeTimeDomain,'reset');
                    cla(handles.axesFrequency,'reset'); 
                    cla(handles.axesFrequencyFilter, 'reset');
                    set(handles.btnHighpass,'enable','off');
                    set(handles.btnLowpass,'enable','off');
                    set(handles.btnBandpass,'enable','off');
                    set(handles.btnStoppass,'enable','off');
                    set(handles.cut_off_freq,'String','');
                    set(handles.cut_off_freq_1,'String','');
                    set(handles.radiobuttonFIR, 'Value', 0);
                    set(handles.radiobuttonIIR, 'Value', 0);
                    set(handles.btnPlaybackFilterSound, 'enable', 'off');
                end
                readvoice = '';
                
            case 'Trash'
                cla(handles.axeTimeDomain,'reset');
                cla(handles.axesFrequency,'reset');
                cla(handles.axesFrequencyFilter, 'reset'); 
                stop(player);
                filename = '';
                readvoice = '';
                set(handles.btnRecord,'enable','on');
                set(handles.btnSave,'String','Exit');
                set(handles.btn_play,'enable','off');
                set(handles.radiobuttonIIR,'enable','off');
                set(handles.radiobuttonFIR,'enable','off');
                set(handles.btnHighpass,'enable','off');
                set(handles.btnLowpass,'enable','off');
                set(handles.btnBandpass,'enable','off');
                set(handles.btnStoppass,'enable','off');
                set(handles.btnEcho,'enable','off');
                set(handles.cut_off_freq,'enable','off');
                set(handles.cut_off_freq_1,'enable','off');
                set(handles.amplification, 'enable', 'off');
                set(handles.btnEcho,'enable','off');
                set(handles.delay_txt,'enable','off');
                set(handles.alfa_txt,'enable','off');
                set(handles.btnRecord, 'enable', 'on');
                set(handles.btnImport,'String','New Import');
                set(handles.cut_off_freq,'String','');
                set(handles.cut_off_freq_1,'String','');
                set(handles.radiobuttonFIR, 'Value', 0);
                set(handles.radiobuttonIIR, 'Value', 0);
                set(handles.btnPlaybackFilterSound, 'enable', 'off');
            case 'Cancel'
                return;
        end
        elseif ~isempty(tryFilter)
        question = questdlg('Do you want to Save?','',...
                   'Save & Close','Trash', 'Cancel', 'Cancel');
        switch question
            case 'Save & Close'
                filename = uiputfile('*.wav','Save as...');
                if isequal(filename, 0)
                    msgbox('User selected ''Cancel''');
                else 
                    audiowrite(filename, tryFilter, handles.Fs);
                    msgbox('Recording Save Successfully');
                    set(handles.btnSave,'String','Exit');
                    set(handles.radiobuttonIIR,'enable','off');
                    set(handles.radiobuttonFIR,'enable','off');
                    set(handles.amplification, 'enable', 'off')
                    set(handles.btn_play, 'enable', 'off');
                    set(handles.btnEcho,'enable','off');
                    set(handles.delay_txt,'enable','off');
                    set(handles.alfa_txt,'enable','off');
                    set(handles.btnRecord, 'enable', 'on');
                    set(handles.btnImport,'String','New Import');
                    cla(handles.axeTimeDomain,'reset');
                    cla(handles.axesFrequency,'reset'); 
                    cla(handles.axesFrequencyFilter, 'reset');
                    set(handles.btnHighpass,'enable','off');
                    set(handles.btnLowpass,'enable','off');
                    set(handles.btnBandpass,'enable','off');
                    set(handles.btnStoppass,'enable','off');
                    set(handles.cut_off_freq,'String','');
                    set(handles.cut_off_freq_1,'String','');
                    set(handles.radiobuttonFIR, 'Value', 0);
                    set(handles.radiobuttonIIR, 'Value', 0);
                    set(handles.btnPlaybackFilterSound, 'enable', 'off');
                    set(handles.alfa_txt,'String','');
                    set(handles.delay_txt,'String','');
                end
                tryFilter = '';
                
            case 'Trash'
                cla(handles.axeTimeDomain,'reset');
                cla(handles.axesFrequency,'reset');
                cla(handles.axesFrequencyFilter, 'reset'); 
                stop(player);
                filename = '';
                tryFilter = '';
                set(handles.btnRecord,'enable','on');
                set(handles.btnSave,'String','Exit');
                set(handles.btn_play,'enable','off');
                set(handles.radiobuttonIIR,'enable','off');
                set(handles.radiobuttonFIR,'enable','off');
                set(handles.btnHighpass,'enable','off');
                set(handles.btnLowpass,'enable','off');
                set(handles.btnBandpass,'enable','off');
                set(handles.btnStoppass,'enable','off');
                set(handles.btnEcho,'enable','off');
                set(handles.cut_off_freq,'enable','off');
                set(handles.cut_off_freq_1,'enable','off');
                set(handles.amplification, 'enable', 'off');
                set(handles.btnEcho,'enable','off');
                set(handles.delay_txt,'enable','off');
                set(handles.alfa_txt,'enable','off');
                set(handles.btnRecord, 'enable', 'on');
                set(handles.btnImport,'String','New Import');
                set(handles.cut_off_freq,'String','');
                set(handles.cut_off_freq_1,'String','');
                set(handles.radiobuttonFIR, 'Value', 0);
                set(handles.radiobuttonIIR, 'Value', 0);
                set(handles.btnPlaybackFilterSound, 'enable', 'off');
                set(handles.alfa_txt,'String','');
                set(handles.delay_txt,'String','');
            case 'Cancel'
                return;
        end
    else
        question = questdlg('You should apply Filters first or Trash to reset','',...
                   'Trash', 'Apply Filter', 'Apply Filter');
        switch question
            case 'Trash'
                cla(handles.axeTimeDomain,'reset');
                cla(handles.axesFrequency,'reset');
                cla(handles.axesFrequencyFilter, 'reset'); 
                set(handles.btnSave,'String','Exit');
                set(handles.btnImport, 'String', 'New Import');
                set(handles.btnRecord, 'enable', 'on');
                readvoice = '';
            case 'Apply Filter'
                return;
        end
    end
end


function amplification_Callback(hObject, eventdata, handles)
% hObject    handle to amplification (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of amplification as text
%        str2double(get(hObject,'String')) returns contents of amplification as a double


% --- Executes during object creation, after setting all properties.
function amplification_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amplification (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_play.
function btn_play_Callback(hObject, eventdata, handles)

global recObj;
%global nBits;
global sig;
global signal;
global readvoice;
global player;
global player1;
global i;

i = str2num(get(handles.amplification, 'String'));

if ~isempty(readvoice)
    signal='';
    sig='';
    player = audioplayer(readvoice, handles.Fs);
    play(player);
    set(handles.btnImport,'enable','on');
    set(handles.btnResume,'enable','off');
    set(handles.btnPause,'enable','on');
    set(handles.btn_play,'enable','off');
    set(handles.btnStop,'enable','on');
    set(handles.btnSave,'enable','off');
    set(handles.amplification, 'enable', 'off')
    set(handles.radiobuttonIIR,'enable','off');
    set(handles.radiobuttonFIR,'enable','off');
    
    if isempty(i) || i == 0
        signal = '';
        play(player);
        
    else

        signal = '';
        if i <= -1 && i >= -10
            abs(i);
            player = audioplayer(readvoice/i, handles.Fs);
            play(player);
        elseif i >= 1 && i <=10
            player = audioplayer(readvoice*i, handles.Fs);
            play(player);
        else
            msgbox('Choose value in interval -1 to -10 to attenuation and 1 to 10 to amplification');
        end
    end
else
    readvoice='';
    sig = getaudiodata(recObj);
    player1 = audioplayer(sig, handles.Fs);
%     play(player1);
    set(handles.btnPause,'enable','on')
    set(handles.btnStop,'enable','on')
    set(handles.btn_play,'enable','off');
    set(handles.btnSave,'enable','off');
    set(handles.amplification, 'enable', 'off');
    set(handles.radiobuttonIIR,'enable','off');
    set(handles.radiobuttonFIR,'enable','off');
   
    if isempty(i) || i ==0
        play(player1);
    else
        if i <= -1 && i >= -10
            abs(i);
            player = audioplayer(signal/i, handles.Fs);
            play(player);
       elseif i >= 1 && i <= 10
            player = audioplayer(signal*i, handles.Fs);
            play(player);
        else
            msgbox('Choose value in interval -1 to -10 to attenuation and 1 to 10 to amplification');
        end

    end
end


% --- Executes on button press in btnPause.
function btnPause_Callback(hObject, eventdata, handles)
% hObject    handle to btnPause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global player;
global sig;
global player1;

if ~isempty(player)
    sig = '';
    pause(player);
    set(handles.btnResume,'enable','on');
    set(handles.btn_play,'enable','off');
    set(handles.btnPause,'enable','off');
    set(handles.amplification, 'enable', 'off');
    set(handles.amplification, 'enable', 'off');
else
    player = '';
    pause(player1);
    set(handles.btnResume,'enable','on');
    set(handles.btn_play,'enable','off');
    set(handles.btnPause,'enable','off');
    set(handles.amplification, 'enable', 'off')
end


% --- Executes on button press in btnResume.
function btnResume_Callback(hObject, eventdata, handles)

global player;
global sig;
global player1;

if ~isempty(player)
    sig = '';
    resume(player);
    set(handles.btn_play,'enable','off');
    set(handles.btnPause,'enable','on');
    set(handles.btnResume,'enable','off');
    set(handles.amplification, 'enable', 'off')
else
    player = '';
    resume(player1);
    set(handles.btn_play,'enable','off');
    set(handles.btnPause,'enable','on');
    set(handles.btnResume,'enable','off');
    set(handles.amplification, 'enable', 'off')
end


% --- Executes on button press in btnStop.
function btnStop_Callback(hObject, eventdata, handles)
% hObject    handle to btnStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global player;
global readvoice;
global player1;

if ~isempty(readvoice)
%     readvoice='';
    stop(player);
    set(handles.btnRecord,'enable','off');
    set(handles.btnImport,'enable','on');
    set(handles.btnResume,'enable','off');
    set(handles.btn_play,'enable','on');
    set(handles.btnPause,'enable','off');
    set(handles.btnStop,'enable','off');
    set(handles.btnSave,'enable','on');
    set(handles.amplification, 'enable', 'on');
    set(handles.radiobuttonFIR, 'Value', 0);
    set(handles.radiobuttonIIR, 'Value', 0);
    set(handles.radiobuttonFIR, 'enable', 'on');
    set(handles.radiobuttonIIR, 'enable', 'on');
    set(handles.btnEcho,'enable','on');
    set(handles.delay_txt,'enable','on');
    set(handles.alfa_txt,'enable','on');
    set(handles.btn_play,'String','Play');
    set(handles.notify,'Visible','off');
else
%     sig = '';
    stop(player1);
    set(handles.btnResume,'enable','off');
    set(handles.btn_play,'enable','on');
    set(handles.btnPause,'enable','off');
    set(handles.btnStop,'enable','off');
    set(handles.btnSave,'enable','on');
    set(handles.amplification, 'enable', 'on');
    set(handles.radiobuttonFIR, 'Value', 0);
    set(handles.radiobuttonIIR, 'Value', 0);
    set(handles.radiobuttonFIR, 'enable', 'on');
    set(handles.radiobuttonIIR, 'enable', 'on');
    set(handles.btnEcho,'enable','on');
    set(handles.delay_txt,'enable','on');
    set(handles.alfa_txt,'enable','on');
end


% --- Executes on button press in radiobuttonFIR.
function radiobuttonFIR_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonFIR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonFIR
set(handles.btnHighpass,'enable','off');
set(handles.btnLowpass,'enable','off');
set(handles.btnBandpass,'enable','on');
set(handles.btnStoppass,'enable','on');
set(handles.cut_off_freq,'enable','on');
set(handles.cut_off_freq_1,'enable','on');
set(handles.cut_off_freq, 'String','');
set(handles.cut_off_freq_1,'String','');


% --- Executes on button press in radiobuttonIIR.
function radiobuttonIIR_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonIIR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonIIR

set(handles.btnHighpass,'enable','off');
set(handles.btnLowpass,'enable','off');
set(handles.btnBandpass,'enable','on');
set(handles.btnStoppass,'enable','on');
set(handles.cut_off_freq,'enable','on');
set(handles.cut_off_freq_1,'enable','on');
set(handles.cut_off_freq, 'String','');
set(handles.cut_off_freq_1,'String','');


function cut_off_freq_Callback(hObject, eventdata, handles)
% hObject    handle to cut_off_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cut_off_freq as text
%        str2double(get(hObject,'String')) returns contents of cut_off_freq as a double
set(handles.btnHighpass,'enable','on');
set(handles.btnLowpass,'enable','on');
set(handles.btnBandpass,'enable','off');
set(handles.btnStoppass,'enable','off');


% --- Executes during object creation, after setting all properties.
function cut_off_freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cut_off_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function cut_off_freq_1_Callback(hObject, eventdata, handles)
% hObject    handle to cut_off_freq_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cut_off_freq_1 as text
%        str2double(get(hObject,'String')) returns contents of cut_off_freq_1 as a double
set(handles.btnHighpass,'enable','off');
set(handles.btnLowpass,'enable','off');
set(handles.btnBandpass,'enable','on');
set(handles.btnStoppass,'enable','on');


% --- Executes during object creation, after setting all properties.
function cut_off_freq_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cut_off_freq_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%FIR FILTER

% --- Executes on button press in btnHighpass.
function btnHighpass_Callback(hObject, eventdata, handles)

global fOut;
global readvoice;
global signal;
 
   
ii = str2num(get(handles.cut_off_freq, 'String'));
set(handles.btnPlaybackFilterSound, 'enable', 'on');

if isempty(ii)
    msgbox('Choose your cut off frequency');
else
    if ii<=0
        msgbox('Cut off frequency should be positive number');
    else
        if ~isempty(readvoice)
            signal = '';
            cut_off_freq = 2*(ii)/handles.Fs;
            n = 10;
            if handles.radiobuttonFIR.Value == 1
                win = fir1(n, cut_off_freq, 'high');
                fOut = filter(win,1,readvoice);
            else
                [wn,win] = butter(n, cut_off_freq, 'high');
                fOut = filter(wn,win,readvoice);
            end
            %fft
            nfft = length(fOut);
            filterSignal1 = fft(fOut,nfft);
            filterSignal_abs1 = abs(filterSignal1);
            fa = (0:nfft/2-1)*handles.Fs/nfft;
            fftSignal1 = filterSignal_abs1(1:nfft/2);

            plot(handles.axesFrequencyFilter, fa,fftSignal1);
            xlabel(handles.axesFrequencyFilter,'Frequency(Hz)');
            ylabel(handles.axesFrequencyFilter,'|Y(f)|');
        
            
        else
            readvoice = '';
            cut_off_freq = 2*(ii)/handles.Fs;
            n = 10;
            
            if handles.radiobuttonFIR.Value == 1
                win = fir1(n, cut_off_freq, 'high');
                fOut = filter(win,1,signal);
            else
                [wn,win] = butter(n, cut_off_freq, 'high');
                fOut = filter(wn,win,signal);
            end

            %fft
            nfft = length(fOut);
            filterSignal = fft(fOut,nfft);
            filterSignal_abs = abs(filterSignal);
            fa = (0:nfft/2-1)*handles.Fs/nfft;
            fftSignal = filterSignal_abs(1:nfft/2);

            plot(handles.axesFrequencyFilter, fa,fftSignal);
            xlabel(handles.axesFrequencyFilter,'Frequency(Hz)');
            ylabel(handles.axesFrequencyFilter,'|Y(f)|');
        end
    end
end


% --- Executes on button press in btnLowpass.
function btnLowpass_Callback(hObject, eventdata, handles)
% hObject    handle to btnLowpass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%global recObj;
global fOut;
global readvoice;
global signal;

set(handles.btnPlaybackFilterSound, 'enable', 'on');
ii = str2num(get(handles.cut_off_freq, 'String'));

if isempty(ii)
    msgbox('Choose your cut off frequency');
else
    if ii<=0
        msgbox('Cut off frequency should be positive number');
    else
        if ~isempty(readvoice)
            signal = '';
            cut_off_freq = 2*(ii)/handles.Fs;
            n = 10;
           if handles.radiobuttonFIR.Value == 1
                win = fir1(n, cut_off_freq, 'low');
                fOut = filter(win,1,readvoice);
            else
                [wn,win] = butter(n, cut_off_freq, 'low');
                fOut = filter(wn,win,readvoice);
            end

            %fft
            nfft = length(fOut);
            filterSignal = fft(fOut,nfft);
            filterSignal_abs = abs(filterSignal);
            fa = (0:nfft/2-1)*handles.Fs/nfft;
            fftSignal = filterSignal_abs(1:nfft/2);

            plot(handles.axesFrequencyFilter, fa,fftSignal);
            xlabel(handles.axesFrequencyFilter,'Frequency(Hz)');
            ylabel(handles.axesFrequencyFilter,'|Y(f)|');

        else
            readvoice = '';
            cut_off_freq = 2*(ii)/handles.Fs;
            n = 10;
            
            if handles.radiobuttonFIR.Value == 1
                win = fir1(n, cut_off_freq, 'low');
                fOut = filter(win,1,signal);
            else
                [wn,win] = butter(n, cut_off_freq, 'low');
                fOut = filter(wn,win,signal);
            end

            %fft
            nfft = length(fOut);
            filterSignal = fft(fOut,nfft);
            filterSignal_abs = abs(filterSignal);
            fa = (0:nfft/2-1)*handles.Fs/nfft;
            fftSignal = filterSignal_abs(1:nfft/2);

            plot(handles.axesFrequencyFilter, fa,fftSignal);
            xlabel(handles.axesFrequencyFilter,'Frequency(Hz)');
            ylabel(handles.axesFrequencyFilter,'|Y(f)|');
        end
    end
end


% --- Executes on button press in btnBandpass.
function btnBandpass_Callback(hObject, eventdata, handles)
% hObject    handle to btnBandpass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%global recObj;
global fOut;
global readvoice;
global signal;

set(handles.btnPlaybackFilterSound, 'enable', 'on');
lowBound = str2num(get(handles.cut_off_freq, 'String'));
highBound = str2num(get(handles.cut_off_freq_1, 'String'));

if isempty(lowBound) || isempty(highBound)
    msgbox('Choose interval of filtering');
else
    if lowBound<=0 || highBound<=0
        msgbox('Interval of filtering should be positive number');
    else
        if ~isempty(readvoice)
            signal = '';    
            lowFreq = 2*lowBound/handles.Fs;
            highFreq = 2*(highBound)/ handles.Fs;
            n = 10;
            
            if handles.radiobuttonFIR.Value == 1
                win = fir1(n, [lowFreq highFreq], 'band');
                fOut = filter(win,1,readvoice);
            else
                [wn,win] = butter(n,[lowFreq highFreq], 'bandpass');
                fOut = filter(wn,win,readvoice);
            end
            

            nfft = length(fOut);
            filterSignal = fft(fOut,nfft);
            filterSignal_abs = abs(filterSignal);
            fa = (0:nfft/2-1)*handles.Fs/nfft;
            fftSignal = filterSignal_abs(1:nfft/2);

            plot(handles.axesFrequencyFilter, fa,fftSignal);
            xlabel(handles.axesFrequencyFilter,'Frequency(Hz)');
            ylabel(handles.axesFrequencyFilter,'|Y(f)|');
        else
            readvoice = '';
            lowFreq = 2*lowBound/handles.Fs;
            highFreq = 2*(highBound)/ handles.Fs;
            n = 10;
            
            if handles.radiobuttonFIR.Value == 1
                win = fir1(n, [lowFreq highFreq], 'band');
                fOut = filter(win,1,signal);
            else
               [wn,win] = butter(n,[lowFreq highFreq], 'bandpass');
               fOut = filter(wn,win,signal);
            end

            nfft = length(fOut);
            filterSignal = fft(fOut,nfft);
            filterSignal_abs = abs(filterSignal);
            fa = (0:nfft/2-1)*handles.Fs/nfft;
            fftSignal = filterSignal_abs(1:nfft/2);

            plot(handles.axesFrequencyFilter, fa,fftSignal);
            xlabel(handles.axesFrequencyFilter,'Frequency(Hz)');
            ylabel(handles.axesFrequencyFilter,'|Y(f)|');
        end
    end
end


% --- Executes on button press in btnStoppass.
function btnStoppass_Callback(hObject, eventdata, handles)
% hObject    handle to btnStoppass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global fOut;
global readvoice;
global signal;

set(handles.btnPlaybackFilterSound, 'enable', 'on');
lowBound = str2num(get(handles.cut_off_freq, 'String'));
highBound = str2num(get(handles.cut_off_freq_1, 'String'));

if isempty(lowBound) || isempty(highBound)
    msgbox('Choose interval of filtering');
else
    if lowBound<=0 || highBound<=0
        msgbox('Interval of filtering should be positive number');
    else
        if ~isempty(readvoice)
            signal = '';   
            lowFreq = 2*lowBound/handles.Fs;
            highFreq = 2*(highBound)/ handles.Fs;
            n = 10;
            
            if handles.radiobuttonFIR.Value == 1
                win = fir1(n, [lowFreq highFreq], 'stop');
                fOut = filter(win,1,readvoice);
            else
                [wn,win] = butter(n, [lowFreq highFreq], 'stop');
                fOut = filter(wn,win,readvoice);
            end

            nfft = length(fOut);
            filterSignal = fft(fOut,nfft);
            filterSignal_abs = abs(filterSignal);
            fa = (0:nfft/2-1)*handles.Fs/nfft;
            fftSignal = filterSignal_abs(1:nfft/2);
            plot(handles.axesFrequencyFilter, fa,fftSignal);
            xlabel(handles.axesFrequencyFilter,'Frequency(Hz)');
            ylabel(handles.axesFrequencyFilter,'|Y(f)|');
            
        else
            
            readvoice = '';
            lowFreq = 2*lowBound/handles.Fs;
            highFreq = 2*(highBound)/ handles.Fs;
            n = 10;
            
            if handles.radiobuttonFIR.Value == 1
                win = fir1(n, [lowFreq highFreq], 'stop');
                fOut = filter(win,1,signal);
            else
                [wn,win] = butter(n, [lowFreq highFreq], 'stop');
                fOut = filter(wn,win,signal);
            end

            nfft = length(fOut);
            filterSignal = fft(fOut,nfft);
            filterSignal_abs = abs(filterSignal);
            fa = (0:nfft/2-1)*handles.Fs/nfft;
            fftSignal = filterSignal_abs(1:nfft/2);
            plot(handles.axesFrequencyFilter, fa,fftSignal);
            xlabel(handles.axesFrequencyFilter,'Frequency(Hz)');
            ylabel(handles.axesFrequencyFilter,'|Y(f)|');
        end
    end
end


% --- Executes on button press in btnPlaybackFilterSound.
function btnPlaybackFilterSound_Callback(hObject, eventdata, handles)

global fOut
global statetry;
global playFilter;

if statetry == 1
    playFilter = audioplayer(fOut,handles.Fs);
    play(playFilter);
    set(handles.btnPlaybackFilterSound,'String','Stop');
    statetry = 0;

else 
    set(handles.btnPlaybackFilterSound,'String','Try Filter');
    statetry = 1;
    stop(playFilter);
end


function alfa_txt_Callback(hObject, eventdata, handles)
% hObject    handle to alfa_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of alfa_txt as text
%        str2double(get(hObject,'String')) returns contents of alfa_txt as a double


% --- Executes during object creation, after setting all properties.
function alfa_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alfa_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function delay_txt_Callback(hObject, eventdata, handles)
% hObject    handle to delay_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of delay_txt as text
%        str2double(get(hObject,'String')) returns contents of delay_txt as a double


% --- Executes during object creation, after setting all properties.
function delay_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delay_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in btnEcho.
function btnEcho_Callback(hObject, eventdata, handles)
% hObject    handle to btnEcho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global filename;
global stateEcho;
global tryFilter;
global tryEcho;

[Y, handles.Fs] = audioread(filename);

alfa = str2num(get(handles.alfa_txt, 'String'));
D = str2num(get(handles.delay_txt, 'String'));

if isempty(alfa)
    msgbox('Attenuation is empty');
elseif isempty(D)
    msgbox('Delay is empty');
else
    if alfa > 0 && alfa < 1
        if D > 0
            b = [1, zeros(1, D-2), alfa];
            tryFilter = filter(b, 1, Y); 
            
            if stateEcho == 1
                tryEcho = audioplayer(tryFilter, handles.Fs);
                play(tryEcho);
                plot(handles.axesFrequencyFilter, tryFilter);
                stateEcho = 0;
                set(handles.btnEcho,'String','Stop');
            else
                set(handles.btnEcho,'String','Try Echo');
                stateEcho = 1;
                stop(tryEcho);
            end
        end
    else
        msgbox('Choose value 0.1 to 0.9 for Attenuation and 1000 to 3000 for Delay');
    end
end



function btnConv_Callback(hObject, eventdata, handles)
% hObject    handle to btnConv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%global Fs;

[Y, Fs] = audioread('musical109.wav');
[Y1, Fs] = audioread('musical112.wav');
Y2 = Y(:,1);
z = conv(Y1, Y2);
figure;
subplot(3,1,1);
plot(Y);
title('Impulse response 1');
subplot(3,1,2);
plot(Y1);
title('Impulse response 2');
subplot(3,1,3);
plot(z);
sound(z, Fs);
title('Convolution');



function notify_Callback(hObject, eventdata, handles)
% hObject    handle to notify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of notify as text
%        str2double(get(hObject,'String')) returns contents of notify as a double


% --- Executes during object creation, after setting all properties.
function notify_CreateFcn(hObject, eventdata, handles)
% hObject    handle to notify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


