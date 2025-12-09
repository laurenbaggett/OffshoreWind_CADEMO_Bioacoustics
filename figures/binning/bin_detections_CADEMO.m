% bin_detections_CADEMO

% CHNMS_NO
effort.Start = [datetime('06-Nov-2023 00:00:00') datetime('16-Mar-2024 23:00:00') datetime('14-May-2024 00:00:00')];
effort.End = [datetime('16-Mar-2024 22:28:45') datetime('13-May-2024 19:31:13') datetime('06-Nov-2024 20:57:13')];

spd = 60*60*24;

%% odonts

sp = {'PhA','PhB','LoA','Gg','DdDcTt'};

IDpath = 'M:\Odonts\detEdited_ID';
fileList = cellstr(ls(IDpath));
filePrefix = 'CHNMS';
fileMatchIdx = find(~cellfun(@isempty,regexp(fileList,filePrefix))>0);

p.gth =  .5;    % gap time in hrs between sessions
p.minBout = 0;  % minimum bout duration in seconds
p.ltsaMax = 6;  % ltsa maximum duration per session
p.binDur = 1; % 1 day bins

binEffort_minute = intervalToBinTimetable_LMB(effort.Start,effort.End,p); 
binEffort_minute.Properties.VariableNames{1} = 'bin';
binEffort_minute.Properties.VariableNames{2} = 'sec';
binEffort = retime(binEffort_minute,"daily","sum"); % retime to daily

dets = nan(height(binEffort_minute),length(sp)); % save for each day, each species

matchingFile = fileList(fileMatchIdx);

for j = 1:length(sp)

    zcClicks = [];

    for f = 1: length(matchingFile)
        fprintf('Loading file: %s\n',matchingFile{f});
        load(fullfile(IDpath,matchingFile{f}))

        if isrow(zID)
            zID = zID';
        end
        idxZc = find(strcmp(mySpID,sp{j})); % put in your desired species ID here, Zc is Ziphius cavirostris
        zcLabels = zID(:,2) == idxZc;
        zcClicks = [zcClicks;zID(zcLabels,1)];
    end

    clickTimes = datetime(zcClicks(:,1),'convertfrom','datenum'); % grab the times, convert to datetime
    [counts, edges] = histcounts(clickTimes,[binEffort_minute.tbin;(binEffort_minute.tbin(end)+minutes(1))]); % bin # of calls within each minute
    counts(counts>0) = 1; % reset to 1
    daily = timetable(binEffort_minute.tbin,counts');
    % daily = retime(daily,'daily','sum');
    dets(:,j) = daily.Var1;

end

labelstr = sp;

%% mf (orcas pinnipeds)

df = dir('M:\Odonts\MidFreq_scan\*.xlsx');

orca = [];
pp = [];
for i = 1:length(df)
    
    thisFile = readtable([df(i).folder,'\',df(i).name]);
    orca = [orca;thisFile(strcmp(thisFile.SpeciesCode,'Oo'),5:6)];
    pp = [pp;thisFile(strcmp(thisFile.SpeciesCode,'UP'),5:6)];

end

binData = zeros(size(binEffort_minute.tbin,1),1); % preallocate
numtbins = datenum(binEffort_minute.tbin);
for i = 1:size(orca,1)
    % start times
    stTime = datenum(orca.StartTime(i)); % grab this starting datetime
    [~, closeStIdx] = min(abs(numtbins-stTime)); % find the closest time bin
    if numtbins(closeStIdx) > stTime % if the time bin starts after the log start
        closeStIdx = closeStIdx - 1; % move back 1 bin
        if closeStIdx == 0
            closeStIdx = 1;
        end
    end
    % end times
    edTime = datenum(orca.EndTime(i)); % grab this ending datetime
    [~, closeEdIdx] = min(abs(numtbins-edTime)); % find the closest time bin
    if numtbins(closeEdIdx) > edTime % if the time bin starts after the log end
        closeEdIdx = closeEdIdx + 1; % move up 1 bin
    end
    % log bin durations
    if closeStIdx == closeEdIdx % if log occurs within one time bin
        logIdx = closeStIdx;
    else % if log occurs within multiple time bins
        logIdx = closeStIdx:1:closeEdIdx;
    end
    binData(logIdx) = 1; % plug these values in
end
binData = timetable(binEffort_minute.tbin,binData);
% binData = retime(binData,'daily','sum');
dets = [dets,binData.Var1];

binData = zeros(size(binEffort_minute.tbin,1),1); % preallocate
numtbins = datenum(binEffort_minute.tbin);
for i = 1:size(pp,1)
    % start times
    stTime = datenum(pp.StartTime(i)); % grab this starting datetime
    [~, closeStIdx] = min(abs(numtbins-stTime)); % find the closest time bin
    if numtbins(closeStIdx) > stTime % if the time bin starts after the log start
        closeStIdx = closeStIdx - 1; % move back 1 bin
        if closeStIdx == 0
            closeStIdx = 1;
        end
    end
    % end times
    edTime = datenum(pp.EndTime(i)); % grab this ending datetime
    [~, closeEdIdx] = min(abs(numtbins-edTime)); % find the closest time bin
    if numtbins(closeEdIdx) > edTime % if the time bin starts after the log end
        closeEdIdx = closeEdIdx + 1; % move up 1 bin
    end
    % log bin durations
    if closeStIdx == closeEdIdx % if log occurs within one time bin
        logIdx = closeStIdx;
    else % if log occurs within multiple time bins
        logIdx = closeStIdx:1:closeEdIdx;
    end
    binData(logIdx) = 1; % plug these values in
end
binData = timetable(binEffort_minute.tbin,binData);
% binData = retime(binData,'daily','sum');
dets = [dets,binData.Var1];

labelstr = [labelstr, {'Oo','Pped'}]; % save labels for knowing later

%% mysticetes

% humpbacks
humps = dir('M:\Mysticetes\Humpback_NNET\hump_nnet_no_threshold_3.92s\GPLReview_60s_fulldataset\*.mat');
allDets = [];
for i = 1:length(humps)

    load([humps(i).folder,'\',humps(i).name]);
    allDets = [allDets;[cell2mat({Times.julian_start_time})',cell2mat(Labels)]];

end
allDets = timetable(datetime(allDets(:,1),'convertfrom','datenum'),allDets(:,2));
allDets = allDets(allDets.Var1==1,:);
[counts, edges] = histcounts(allDets.Time,[binEffort_minute.tbin;(binEffort_minute.tbin(end)+minutes(1))]); % bin # of calls within each minute
% counts(counts>0) = 1;
dets = [dets,counts'];

labelstr = [labelstr, 'Mn'];

% wmd
calls = {'A','B','D'}; % the call types to plot
wmd = dir('M:\Mysticetes\WhaleMoanDetector_finalOutputs\all\*.txt');

% combine all detections
allDets = []; % preallocate
for j = 1:length(wmd)
    thisFile = readtable([wmd(j).folder,'\',wmd(j).name]); % load the file for this week
    allDets = [allDets;thisFile];
end

wmdCalls = nan(height(binEffort_minute),length(calls));
for c = 1:length(calls) % for each call type
    thisCall = allDets(strcmp(calls(c), allDets.label), :); % grab detections of this call type
    [counts, edges] = histcounts(thisCall.start_time,[binEffort_minute.tbin;(binEffort_minute.tbin(end)+minute(1))]); % bin # of calls within each minute
    wmdCalls(:,c) = counts'; % add them to the table
end

wmdCalls(wmdCalls>0) = 1;
daily = timetable(binEffort_minute.tbin,wmdCalls);
% daily = retime(daily,'daily','sum');
dets = [dets,daily.Var1];

labelstr = [labelstr, calls];

% save('M:\bin_detections_CADEMO','dets','labelstr');

%% gray

df = dir('M:\Mysticetes\Nicole_logs\CHNMS_NO_01_lowFreq_NS.xlsx');

gray = [];
for i = 1:length(df)
    
    thisFile = readtable([df(i).folder,'\',df(i).name]);
    gray = [gray;thisFile(strcmp(thisFile.SpeciesCode,'Er'),5:6)];

end

gray.StartTime = datetime(gray.StartTime,'convertfrom','excel');
gray.EndTime = datetime(gray.EndTime,'convertfrom','excel');

binData = zeros(size(binEffort_minute.tbin,1),1); % preallocate
numtbins = datenum(binEffort_minute.tbin);
for i = 1:size(gray,1)

    % start times
    stTime = datenum(gray.StartTime(i)); % grab this starting datetime
    [~, closeStIdx] = min(abs(numtbins-stTime)); % find the closest time bin
    if numtbins(closeStIdx) > stTime % if the time bin starts after the log start
        closeStIdx = closeStIdx - 1; % move back 1 bin
        if closeStIdx == 0
            closeStIdx = 1;
        end
    end
    % end times
    edTime = datenum(gray.EndTime(i)); % grab this ending datetime
    [~, closeEdIdx] = min(abs(numtbins-edTime)); % find the closest time bin
    if numtbins(closeEdIdx) > edTime % if the time bin starts after the log end
        closeEdIdx = closeEdIdx + 1; % move up 1 bin
    end
    % log bin durations
    if closeStIdx == closeEdIdx % if log occurs within one time bin
        logIdx = closeStIdx;
    else % if log occurs within multiple time bins
        logIdx = closeStIdx:1:closeEdIdx;
    end
    binData(logIdx) = 1; % plug these values in
end
binData = timetable(binEffort_minute.tbin,binData);
% binData = retime(binData,'daily','sum');
dets = [dets,binData.Var1];

labelstr = [labelstr, 'Er'];

%% fin

% % load in the data
% detections = dir('M:\Mysticetes\Fin20Hz\xml_output\allDets\*.mat');
% 
% allDets = []; % preallocate to save all explosions
% allTimes = [];
% 
% for i = 1:length(detections)
%     calls = load([detections(i).folder,'\',detections(i).name]);
%     if height(calls) > 0
%         allDets = [allDets;[calls.dayVal',calls.ScoreVal']];
%     end
% end
% 
% allDets = timetable(datetime(allDets(:,1),'convertfrom','datenum'),allDets(:,2));
% allDets = retime(allDets,'daily','sum');
% 
% dets = [dets,allDets.Var1];
% labelstr = [labelstr, 'Bp'];

%% fish

logs01 = readtable('M:/Fish/CHNMS_NO_01_fish.xlsx');
logs02 = readtable('M:/Fish/CHNMS_NO_03_fish.xlsx');
UF310 = [];
bocaccio = [];
UF440 = [];
UF310 = [UF310;logs01(strcmp(logs01.Comments,'UF310'),5:6)];
bocaccio = [bocaccio;logs02(strcmp(logs02.Comments,'bocaccio'),5:6)];
UF440 = [UF440;logs02(strcmp(logs02.Comments,'UF440'),5:6)];


binData = zeros(size(binEffort_minute.tbin,1),1); % preallocate
numtbins = datenum(binEffort_minute.tbin);
for i = 1:size(UF310,1)
    % start times
    stTime = datenum(UF310.StartTime(i)); % grab this starting datetime
    [~, closeStIdx] = min(abs(numtbins-stTime)); % find the closest time bin
    if numtbins(closeStIdx) > stTime % if the time bin starts after the log start
        closeStIdx = closeStIdx - 1; % move back 1 bin
        if closeStIdx == 0
            closeStIdx = 1;
        end
    end
    % end times
    edTime = datenum(UF310.EndTime(i)); % grab this ending datetime
    [~, closeEdIdx] = min(abs(numtbins-edTime)); % find the closest time bin
    if numtbins(closeEdIdx) > edTime % if the time bin starts after the log end
        closeEdIdx = closeEdIdx + 1; % move up 1 bin
    end
    % log bin durations
    if closeStIdx == closeEdIdx % if log occurs within one time bin
        logIdx = closeStIdx;
    else % if log occurs within multiple time bins
        logIdx = closeStIdx:1:closeEdIdx;
    end
    binData(logIdx) = 1; % plug these values in
end
binData = timetable(binEffort_minute.tbin,binData);
% binData = retime(binData,'daily','sum');
dets = [dets,binData.Var1];


binData = zeros(size(binEffort_minute.tbin,1),1); % preallocate
numtbins = datenum(binEffort_minute.tbin);
for i = 1:size(UF440,1)
    % start times
    stTime = datenum(UF440.StartTime(i)); % grab this starting datetime
    [~, closeStIdx] = min(abs(numtbins-stTime)); % find the closest time bin
    if numtbins(closeStIdx) > stTime % if the time bin starts after the log start
        closeStIdx = closeStIdx - 1; % move back 1 bin
        if closeStIdx == 0
            closeStIdx = 1;
        end
    end
    % end times
    edTime = datenum(UF440.EndTime(i)); % grab this ending datetime
    [~, closeEdIdx] = min(abs(numtbins-edTime)); % find the closest time bin
    if numtbins(closeEdIdx) > edTime % if the time bin starts after the log end
        closeEdIdx = closeEdIdx + 1; % move up 1 bin
    end
    % log bin durations
    if closeStIdx == closeEdIdx % if log occurs within one time bin
        logIdx = closeStIdx;
    else % if log occurs within multiple time bins
        logIdx = closeStIdx:1:closeEdIdx;
    end
    binData(logIdx) = 1; % plug these values in
end
binData = timetable(binEffort_minute.tbin,binData);
% binData = retime(binData,'daily','sum');
dets = [dets,binData.Var1];


binData = zeros(size(binEffort_minute.tbin,1),1); % preallocate
numtbins = datenum(binEffort_minute.tbin);
for i = 1:size(bocaccio,1)
    % start times
    stTime = datenum(bocaccio.StartTime(i)); % grab this starting datetime
    [~, closeStIdx] = min(abs(numtbins-stTime)); % find the closest time bin
    if numtbins(closeStIdx) > stTime % if the time bin starts after the log start
        closeStIdx = closeStIdx - 1; % move back 1 bin
        if closeStIdx == 0
            closeStIdx = 1;
        end
    end
    % end times
    edTime = datenum(bocaccio.EndTime(i)); % grab this ending datetime
    [~, closeEdIdx] = min(abs(numtbins-edTime)); % find the closest time bin
    if numtbins(closeEdIdx) > edTime % if the time bin starts after the log end
        closeEdIdx = closeEdIdx + 1; % move up 1 bin
    end
    % log bin durations
    if closeStIdx == closeEdIdx % if log occurs within one time bin
        logIdx = closeStIdx;
    else % if log occurs within multiple time bins
        logIdx = closeStIdx:1:closeEdIdx;
    end
    binData(logIdx) = 1; % plug these values in
end
binData = timetable(binEffort_minute.tbin,binData);
% binData = retime(binData,'daily','sum');
dets = [dets,binData.Var1];

labelstr = [labelstr, {'UF310','UF440','Bocaccio'}];

%% make into a timetable for saving

savetable = array2timetable(dets,'RowTimes',binEffort_minute.tbin);
savetable.Properties.VariableNames = labelstr;

save('M:\Report_Drafts\092025\CADEMO_minute_binned_allSpecies_allMinutes.mat','savetable');
