function graphite()
% GRAPHITE Main interface for GRAPHical Insect Tracking Environment
%   Allows the manipulation of bee tag annotation files. The GUI provides
%   access to the istag, trackid, and digits fields. The GUI has options to
%   update the tag_annotations.mat file, export a data file, and export a
%   summary video.
%
%   SYNTAX
%   graphite()
%
%   DESCRIPTION
%   tageditor() opens the main graphical interface for GRAPHITE
%
%   DEPENDENCIES
%   main.m
%
%   AUTHOR
%   Blair J. Rossetti
%
%   DATE LAST MODIFIED
%   2016-08-25

% set figure dimensions
set(0,'units','pixels');
ss = get(0,'screensize');   % screen size
sar = ss(4)/ss(3);          % screen aspect ratio
far = 1/2;                  % figure aspect ratio
fds = 2/3;                  % figure downscale

if far > sar
    % set dimensions based on screen width
    w = fds*ss(3);
    h = w*far;
else
    % set dimensions based on screen height
    h = fds*ss(4);
    w = h/far;    
end

fdims = [floor(ss(3)/2-w/2), floor(ss(4)/2-h/2), w, h];

f = figure('Visible','off','Position', fdims, 'Name', 'GRAPHITE',...
    'NumberTitle','off', 'Toolbar', 'none');

% set figure panels
pfiles = uipanel(f, 'Position', [0.005, 0.005, 0.5-0.0075, 1-0.0075], 'BorderType', 'none');
psettings = uipanel(f, 'Position', [0.5+0.0025, 0.005, 0.3-0.005, 1-0.0075]);
pbuttons = uipanel(f, 'Position', [0.8+0.0025, 0.005, 0.2-0.0075, 1-0.0075], 'BorderType', 'none');

% add file buttons
hadddir = uicontrol(pfiles, 'Style', 'pushbutton', 'String', 'Add Directory', ...
          'Units', 'normalized', 'Position', [0.01, 0.905, 1/3-0.0125, 0.1-0.015], ...
          'Callback', @adddir_Callback);
haddfile = uicontrol(pfiles, 'Style', 'pushbutton', 'String', 'Add File', ...
           'Units', 'normalized', 'Position', [1/3+0.0025, 0.905, 1/3-0.005, 0.1-0.015], ...
          'Callback', @addfile_Callback);
hremove = uicontrol(pfiles, 'Style', 'pushbutton', 'String', 'Remove', ...
          'Units', 'normalized', 'Position', [2/3+0.0025, 0.905, 1/3-0.0125, 0.1-0.015], ...
          'Callback', @remove_Callback);

% add files table
hfiles = uitable(pfiles, ...
         'Units', 'normalized', 'Position', [0.01, 0.01, .98, .9-0.015], ...
         'RowName', [], ...
         'ColumnName', {'File', 'Start', 'End', 'ARC', 'Output'}, ...
         'ColumnFormat', {'char', 'numeric', 'numeric', 'logical', 'char'}, ...
         'ColumnEditable', logical([0 1 1 1 1]), ...
         'CellSelectionCallback', @files_SelectionCallback, ...
         'CellEditCallback', @files_EditCallback);

wtable = (pfiles.Position(3)-hfiles.Position(1)*2)*f.Position(3); 
hfiles.ColumnWidth = {floor(wtable/5)};

% add run buttons
hppvid = uicontrol(pbuttons, 'Style', 'pushbutton', 'String', 'Preprocess Video(s)', ...
         'Units', 'normalized', 'Position', [0.01, 5/6+0.005, 0.98, 1/6-0.015], ...
          'Tag', 'ppvid', 'Callback', @run_Callback);
hdetecttags = uicontrol(pbuttons, 'Style', 'pushbutton', 'String', 'Detect Tags', ...
              'Units', 'normalized', 'Position', [0.01, 4/6+0.005, 0.98, 1/6-0.01], ...
              'Tag', 'detect', 'Callback', @run_Callback);
hreadtags = uicontrol(pbuttons, 'Style', 'pushbutton', 'String', 'Read Tags', ...
            'Units', 'normalized', 'Position', [0.01, 3/6+0.005, 0.98, 1/6-0.01], ...
            'Tag', 'read', 'Callback', @run_Callback);
htracks = uicontrol(pbuttons, 'Style', 'pushbutton', 'String', 'Assemble Tracks', ...
          'Units', 'normalized', 'Position', [0.01, 2/6+0.005, 0.98, 1/6-0.01], ...
          'Tag', 'assemble', 'Callback', @run_Callback);
hedit = uicontrol(pbuttons, 'Style', 'pushbutton', 'String', 'Edit', ...
        'Units', 'normalized', 'Position', [0.01, 1/6+0.005, 0.98, 1/6-0.01], ...
        'Tag', 'edit', 'Callback', @run_Callback);
hrunall = uicontrol(pbuttons, 'Style', 'pushbutton', 'String', 'Run All', ...
          'Units', 'normalized', 'Position', [0.01, 0.01, 0.98, 1/6-0.015], ...
          'Tag', 'runall', 'Callback', @run_Callback);
     
% add settings panels
poutdir = uipanel(psettings, 'Title', 'Output Directory', ...
          'Position', [0.01, 7/8+0.005, 0.98, 1/8-0.01], 'BorderType', 'none');
ptrim = uipanel(psettings, 'Title', 'Trim Times', ...
        'Position', [0.01, 6/8+0.005, 0.98, 1/8-0.005], 'BorderType', 'none');
parc = uipanel(psettings, 'Title', 'Active Region Cropping (ARC)', ...
       'Position', [0.01, 5/8+0.005, 0.98, 1/8-0.005], 'BorderType', 'none');
pcfilter = uipanel(psettings, 'Title', 'Color Filter', ...
        'Position', [0.01, 4/8+0.005, 0.98, 1/8-0.005], 'BorderType', 'none'); 
peditor = uipanel(psettings, 'Title', 'Graphical Editor', ...
          'Position', [0.01, 3/8+0.005, 0.98, 1/8-0.005], 'BorderType', 'none');
pskip = uipanel(psettings, 'Title', 'Skipping', ...
        'Position', [0.01, 2/8+0.005, 0.98, 1/8-0.005], 'BorderType', 'none');   
pbatch = uipanel(psettings, 'Title', 'Mode', ...
         'Position', [0.01, 1/8+0.005, 0.98, 1/8-0.01], 'BorderType', 'none'); 
papply = uipanel(psettings, ...
         'Position', [0.01, 0.01, 0.98, 1/8-0.01], 'BorderType', 'none'); 
     
% add setting buttons/fields
houtdir = uicontrol(poutdir, 'Style', 'edit', 'String', 'Output Directory', ...
          'Units', 'normalized', 'Position', [0.01, 0.01, 2/3-0.005, 0.98], ...
          'TooltipString', 'Directory where analysis results will be saved', ...
          'Callback', @outdir_Callback);
hbrowse = uicontrol(poutdir, 'Style', 'pushbutton', 'String', 'Browse', ...
          'Units', 'normalized', 'Position', [2/3+0.005, 0.01, 1/3-0.015, 0.98], ...
          'Callback', @browse_Callback);
uicontrol(ptrim, 'Style', 'text', 'String', 'Start Time (sec)', ...
          'Units', 'normalized', 'Position', [0.01, 2/3+0.005, 0.5-0.015, 1/3-0.015], ...
          'TooltipString', 'Trim this many seconds from beginning of video');
uicontrol(ptrim, 'Style', 'text', 'String', 'End Time (sec)', ...
          'Units', 'normalized', 'Position', [0.5+0.005, 2/3+0.005, 0.5-0.015, 1/3-0.015], ...
          'TooltipString', 'Trim this many seconds from end of video');
hstime = uicontrol(ptrim, 'Style', 'edit', 'String', '0', ...
          'Units', 'normalized', 'Position', [0.01, 0.01, 0.5-0.015, 2/3-0.015], ...
          'Tag', 'stime', 'Callback', @ttime_Callback);
hetime = uicontrol(ptrim, 'Style', 'edit', 'String', '0', ...
          'Units', 'normalized', 'Position', [0.5+0.005, 0.01, 0.5-0.015, 2/3-0.015], ...
          'Tag', 'etime', 'Callback', @ttime_Callback);
harc(1) = uicontrol(parc, 'Style', 'togglebutton', 'String', 'On', ...
          'Units', 'normalized', 'Position', [0.01, 0.01, 0.5-0.015,0.98], ...
          'Value', 1, 'TooltipString', 'Attempt to crop video to active region', ...
          'Tag', 'arc', 'Callback', @toggle_Callback);
harc(2) = uicontrol(parc, 'Style', 'togglebutton', 'String', 'Off', ...
          'Units', 'normalized', 'Position', [0.5+0.005, 0.01, 0.5-0.015, 0.98], ...
          'Value', 0, 'TooltipString', 'Deactivate ARC (saves disk space)', ...
          'Tag', 'arc', 'Callback', @toggle_Callback);
uicontrol(pcfilter, 'Style', 'text', 'String', 'Active', ...
          'Units', 'normalized', 'Position', [0.01, 2/3+0.005, 1/4-0.015, 1/3-0.015]);
uicontrol(pcfilter, 'Style', 'text', 'String', 'Red', ...
          'Units', 'normalized', 'Position', [1/4+0.005, 2/3+0.005, 1/4-0.01, 1/3-0.015], ...
          'TooltipString', 'Red value between 0-255');
uicontrol(pcfilter, 'Style', 'text', 'String', 'Green', ...
          'Units', 'normalized', 'Position', [2/4+0.005, 2/3+0.005, 1/4-0.01, 1/3-0.015], ...
          'TooltipString', 'Green value between 0-255');
uicontrol(pcfilter, 'Style', 'text', 'String', 'Blue', ...
          'Units', 'normalized', 'Position', [3/4+0.005, 2/3+0.005, 1/4-0.015, 1/3-0.015], ...
          'TooltipString', 'Blue value between 0-255');
hcfilton(1) = uicontrol(pcfilter, 'Style', 'togglebutton', 'String', 'On', ...
              'Units', 'normalized', 'Position', [0.01, 0.01, 1/8-0.015, 2/3-0.015], ...
              'Value', 0, 'TooltipString', 'Turn on color filtering', ...
              'Tag', 'cfilt', 'Callback', @toggle_Callback);
hcfilton(2) = uicontrol(pcfilter, 'Style', 'togglebutton', 'String', 'Off', ...
              'Units', 'normalized', 'Position', [1/8+0.005, 0.01, 1/8-0.015, 2/3-0.015], ...
              'Value', 1, 'TooltipString', 'Turn off color filtering', ...
              'Tag', 'cfilt', 'Callback', @toggle_Callback);
hrgb(1) = uicontrol(pcfilter, 'Style', 'edit', 'String', 0,...
               'Units', 'normalized', 'Position', [1/4+0.005, 0.01, 1/4-0.01, 2/3-0.015], ...
               'Tag', 'red', 'Callback', @rgb_Callback);
hrgb(2) = uicontrol(pcfilter, 'Style', 'edit', 'String', 0,...
               'Units', 'normalized', 'Position', [2/4+0.005, 0.01, 1/4-0.01, 2/3-0.015], ...
               'Tag', 'green', 'Callback', @rgb_Callback);
hrgb(3) = uicontrol(pcfilter, 'Style', 'edit', 'String', 0, ...
               'Units', 'normalized', 'Position', [3/4+0.005, 0.01, 1/4-0.015, 2/3-0.015], ...
               'Tag', 'blue', 'Callback', @rgb_Callback);
heditor(1) = uicontrol(peditor, 'Style', 'togglebutton', 'String', 'On', ...
             'Units', 'normalized', 'Position', [0.01, 0.01, 0.5-0.015,0.98], ...
             'Value', 1, 'TooltipString', 'Start editor after processing each file', ...
             'Tag', 'edit', 'Callback', @toggle_Callback);
heditor(2) = uicontrol(peditor, 'Style', 'togglebutton', 'String', 'Off', ...
             'Units', 'normalized', 'Position', [0.5+0.005, 0.01, 0.5-0.015, 0.98], ...
             'Value', 0, 'TooltipString', 'Do not open editor after processing each file', ...
             'Tag', 'edit', 'Callback', @toggle_Callback);
hskip(1) = uicontrol(pskip, 'Style', 'togglebutton', 'String', 'On', ...
           'Units', 'normalized', 'Position', [0.01, 0.01, 0.5-0.015,0.98], ...
           'Value', 0, 'TooltipString', 'Run all modules regardless of existing data', ...
           'Tag', 'skip', 'Callback', @toggle_Callback);
hskip(2) = uicontrol(pskip, 'Style', 'togglebutton', 'String', 'Off', ...
           'Units', 'normalized', 'Position', [0.5+0.005, 0.01, 0.5-0.015, 0.98], ...
           'Value', 1, 'TooltipString', 'Only run modules that have not already run (saves time)', ...
           'Tag', 'skip', 'Callback', @toggle_Callback);
hbatch(1) = uicontrol(pbatch, 'Style', 'togglebutton', 'String', 'Selection', ...
          'Units', 'normalized', 'Position', [0.01, 0.01, 0.5-0.015,0.98], ...
          'Value', 0, 'TooltipString', 'Run module/pipeline for currently selected file', ...
          'Tag', 'batch', 'Callback', @toggle_Callback);
hbatch(2) = uicontrol(pbatch, 'Style', 'togglebutton', 'String', 'Batch', ...
          'Units', 'normalized', 'Position', [0.5+0.005, 0.01, 0.5-0.015, 0.98], ...
          'Value', 1, 'TooltipString', 'Run module/pipeline for all files', ...
          'Tag', 'batch', 'Callback', @toggle_Callback);
happly = uicontrol(papply, 'Style', 'pushbutton', 'String', 'Apply Settings', ...
         'Units', 'normalized', 'Position', [0.01, 0.01, 0.98, 0.98], ...
         'TooltipString', 'Overwrite existing settings for all files', ...
         'Callback', @apply_Callback);
    
% store gui data
gdata.f = f;
gdata.hfiles = hfiles;
gdata.houtdir = houtdir;
gdata.harc = harc;
gdata.hcfilton = hcfilton;
gdata.hrgb = hrgb;
gdata.heditor = heditor;
gdata.hskip = hskip;
gdata.hbatch = hbatch;
gdata.filedata = {};
gdata.outdir = '';
gdata.stime = 0;
gdata.etime = 0;
gdata.arc = true;
gdata.cfilt = false;
gdata.rgb = uint8([0,0,0]);
gdata.edit = true;
gdata.skip = false;
gdata.batch = true;

guidata(f, gdata);

% display initial state
f.Visible = 'on';

end %main function

%% Functions\Callbacks

function adddir_Callback(hObject, eventdata)
    % get data
    gdata = guidata(hObject);
    
    % open dialog for selecting directory
    rootdir = uigetdir;
    
    % return if cancel or no files selected
    if isequal(rootdir, 0)
        return
    end  
    
    % get files
    exts = {'*.avi';'*.AVI';'*.mj2';'*.MJ2';'*.mpg';'*.MPG';'*.wmv';'*.WMV';'*.mp4';'*.MP4';'*.m4v';'*.M4V';'*.mov';'*.MOV'};
    files = {};
    for i = 1:length(exts)
        filelist = dir(fullfile(rootdir, exts{i}));
        idx = [filelist.isdir];
        filelist = {filelist(~idx).name}';


        %build full file path
        filelist = cellfun(@(x) fullfile(rootdir, x), filelist, 'UniformOutput', false);
        files = [files; filelist];
    end
    
    % return if no files found
    if isequal(files, {})
        return
    end
    
    % set output directory if not already set
    if isequal(gdata.outdir, '')
        gdata.outdir = rootdir;
        gdata.houtdir.String = rootdir;
    end
    
    % append files to filedata
    n = size(gdata.filedata, 1);
    for i = 1:length(files)
        gdata.filedata{n+i, 1} = files{i};
        gdata.filedata{n+i, 2} = gdata.stime;
        gdata.filedata{n+i, 3} = gdata.etime;
        gdata.filedata{n+i, 4} = gdata.arc;
        gdata.filedata{n+i, 5} = gdata.outdir;
    end
    
    % update file display
    gdata.hfiles.Data = gdata.filedata;
    
    % reassign guidata
    guidata(hObject, gdata);
end %adddir_Callback

function addfile_Callback(hObject, eventdata)
    % get data
    gdata = guidata(hObject);
    
    % open dialog for selecting file
    [files, filepath] = uigetfile({'*.avi;*.mj2;*.mpg;*.wmv;*.mp4;*.m4v;*.mov', ...
           'Video Files (*.avi,*.mj2,*.mpg,*.wmv,*.mp4,*.m4v,*.mov)'}, ...
           'Select Input File(s)', 'MultiSelect', 'on');
    
    % return if cancel or no files selected
    if isequal(files, 0)
        return
    end
        
    % build full file paths
    if isa(files, 'char')
        files = {fullfile(filepath, files)};
    else
        files = cellfun(@(x) fullfile(filepath, x), files, 'UniformOutput', false);
    end
    
    % set output directory if not already set
    if isequal(gdata.outdir, '')
        gdata.outdir = filepath;
        gdata.houtdir.String = filepath;
    end
    
    % append files to filedata
    n = size(gdata.filedata, 1);
    for i = 1:length(files)
        gdata.filedata{n+i, 1} = files{i};
        gdata.filedata{n+i, 2} = gdata.stime;
        gdata.filedata{n+i, 3} = gdata.etime;
        gdata.filedata{n+i, 4} = gdata.arc;
        gdata.filedata{n+i, 5} = gdata.outdir;
    end
    
    % update file display
    gdata.hfiles.Data = gdata.filedata;
       
    % reassign guidata
    guidata(hObject, gdata);
end %addfile_Callback

function remove_Callback(hObject, eventdata)
    % get data
    gdata = guidata(hObject);
  
    % delete row
    gdata.filedata(gdata.selection,:) = [];
    
    % update file display
    gdata.hfiles.Data = gdata.filedata;
       
    % reassign guidata
    guidata(hObject, gdata);
end %remove_Callback

function files_SelectionCallback(hObject, eventdata)
    % skip if no index
    if isempty(eventdata.Indices)
        return
    end
    
    % get data
    gdata = guidata(hObject);
    gdata.selection = eventdata.Indices(:,1);
    
    % reassign guidata
    guidata(hObject, gdata);
end %files_SelectionCallback

function files_EditCallback(hObject, eventdata)
    % get data
    gdata = guidata(hObject);
    idx = eventdata.Indices;
    val = eventdata.NewData;
    r = idx(1,1);
    c = idx(1,2);
    
    % check which column editted (5 - outdir; 4 - ARC; 3 - End; 2 - Start)
    switch c
        case 5
            % check format of outdir
            if ~ischar(val) || ~exist(val, 'dir')
                % reset previous value
                hObject.Data{r,c} = eventdata.PreviousData;
                return
            end
        case 4
            % check format of ARC
            if ~islogical(val)
                % reset previous value
                hObject.Data{r,c} = eventdata.PreviousData;
                return
            end
        case {3,2}
            % check format
            if ~isnumeric(val) || int64(val) ~= val || val < 0
                % reset previous value
                hObject.Data{r,c} = eventdata.PreviousData;
                return
            end
    end %switch
    
    % update proper data cell
    gdata.filedata{r,c} = val;
    
    % reassign guidata
    guidata(hObject, gdata);
end %files_EditCallback

function outdir_Callback(hObject, eventdata)
    % get data
    gdata = guidata(hObject);
    val = hObject.String;
    
    % check format of outdir
    if ~ischar(val) || ~exist(val, 'dir')
        % reset previous value
        hObject.String = gdata.outdir;
        return
    end
    
    % update outdir
    gdata.outdir = val;
       
    % reassign guidata
    guidata(hObject, gdata);
end %outdir_Callback

function browse_Callback(hObject, eventdata)
    % get data
    gdata = guidata(hObject);
    
    % open dialog for selecting directory
    rootdir = uigetdir;
    
    % return if cancel or no files selected
    if isequal(rootdir, 0)
        return
    end  
    
    % update outdir
    gdata.houtdir.String = rootdir;
    gdata.outdir = rootdir;
       
    % reassign guidata
    guidata(hObject, gdata);
end %browse_Callback

function ttime_Callback(hObject, eventdata)
    % get data
    gdata = guidata(hObject);
    sval = hObject.String;
    val = str2double(sval);
    
    % check format of outdir
    if  ~all(isstrprop(sval, 'digit'))|| int64(val) ~= val || val < 0
        % reset previous value
        if isequal(hObject.Tag, 'stime')
            hObject.String = gdata.stime;
        else
            hObject.String = gdata.etime;
        end
        return
    end
    
    % update outdir
    if isequal(hObject.Tag, 'stime')
        gdata.stime = val;
    else
        gdata.etime = val;
    end
       
    % reassign guidata
    guidata(hObject, gdata);
end %stime_Callback

function rgb_Callback(hObject, eventdata)
    % get data
    gdata = guidata(hObject);
    sval = hObject.String;
    val = str2double(sval);
    
    % check format of outdir
    if  ~all(isstrprop(sval, 'digit'))|| uint8(val) ~= val
        % reset previous value
        switch hObject.Tag
            case 'red'
                hObject.String = gdata.rgb(1);
            case 'green'
                hObject.String = gdata.rgb(2);
            case 'blue'
                hObject.String = gdata.rgb(3);
        end
        return
    end
    
    % update rgb
    switch hObject.Tag
        case 'red'
            gdata.rgb(1) = val;
        case 'green'
            gdata.rgb(2) = val;
        case 'blue'
            gdata.rgb(3) = val;
    end
       
    % reassign guidata
    guidata(hObject, gdata);
end %rgb_Callback

function toggle_Callback(hObject, eventdata)
    % get data
    gdata = guidata(hObject);
    
    % determine which toggle
    switch hObject.Tag
        case 'arc'
            toggle = gdata.harc;
        case 'cfilt'
            toggle = gdata.hcfilton;
        case 'edit'
            toggle = gdata.heditor;
        case 'skip'
            toggle = gdata.hskip;
        case 'batch'
            toggle = gdata.hbatch;
    end
    
    % get index of hot toggle
    idx = find(toggle ~= hObject);
    
    % toggle
    hObject.Value = true;
    for i = idx
        toggle(i).Value = false;
    end
    
    % update values
    switch hObject.Tag
        case 'arc'
            gdata.harc = toggle;
            gdata.arc = ~gdata.arc;
        case 'cfilt'
            gdata.hcfilton = toggle;
            gdata.cfilt = ~gdata.cfilt;
        case 'edit'
            gdata.heditor = toggle;
            gdata.edit = ~gdata.edit;
        case 'skip'
            gdata.hskip = toggle;
            gdata.skip = ~gdata.skip;
        case 'batch'
            gdata.hbatch = toggle;
            gdata.batch = ~gdata.batch;
    end
    
    % reassign guidata
    guidata(hObject, gdata);
end %toggle_Callback

function apply_Callback(hObject, eventdata)
    % get data
    gdata = guidata(hObject);
    
    % apply settings to filedata
    for i = 1:size(gdata.filedata, 1)
        gdata.filedata{i, 2} = gdata.stime;
        gdata.filedata{i, 3} = gdata.etime;
        gdata.filedata{i, 4} = gdata.arc;
        gdata.filedata{i, 5} = gdata.outdir;
    end
    
    % update file display
    gdata.hfiles.Data = gdata.filedata;

    % reassign guidata
    guidata(hObject, gdata);
end %apply_Callback

function run_Callback(hObject, eventdata)
    % get data
    gdata = guidata(hObject);
    
    % set module
    switch hObject.Tag
        case 'ppvid'
            module = 1;
        case 'detect'
            module = 2;
        case 'read'
            module = 3;
        case 'assemble'
            module = 4;
        case 'edit'
            module = 5;
        otherwise
            module = 0;
    end
    
    % get subset if mode is selection
    filedata = gdata.filedata;
    if ~gdata.batch
        filedata = filedata(gdata.selection,:);
    end
    
    % set color filtering status
    if gdata.cfilt
        rgb = gdata.rgb;
    else
        rgb = uint8([0,0,0]);
    end
    
    % set editor status
    if module == 5
        edit = true;
    else
        edit = gdata.edit;
    end
    
    % process each file
    parfor i = 1:size(filedata, 1)
        % create output directory
        [~,name,~] = fileparts(filedata{i,1});
        outdir = fullfile(filedata{i,5}, name);
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end
        
        %call main 
        disp(['PROCESSING: ' filedata{i,1} '...']);
        main(filedata{i,1}, filedata{i,2}, filedata{i,3}, 'ARC', filedata{i,4}, ...
            'Output', outdir, 'RGBFilter', rgb, 'Force', ~gdata.skip, ...
            'Editor', edit, 'Module', module);
    end

end %run_Callback