% plot_WMD_outputs

calls = {'A','B','D','40Hz'}; % the call types to plot
spd = 60*60*24; % seconds per day for datetime conversion

effort.Start = [datetime('06-Nov-2023 00:00:00') datetime('16-Mar-2024 23:00:00') datetime('14-May-2024 00:00:00')];
effort.End = [datetime('16-Mar-2024 22:28:45') datetime('13-May-2024 19:31:13') datetime('06-Nov-2024 20:57:13')];

wmd = dir('M:\Mysticetes\WhaleMoanDetector_finalOutputs\all\*.txt');

p.binDur = 1; % 1 minute

%% group effort in bins

effort.diffSec = seconds(effort.End-effort.Start) ;
effort.bins = effort.diffSec/(60*p.binDur);
effort.roundbin = round(effort.diffSec/(60*p.binDur));

% convert intervals in bins 
binEffort = intervalToBinTimetable_LMB(effort.Start,effort.End,p); 
binEffort.Properties.VariableNames{1} = 'bin';
binEffort.Properties.VariableNames{2} = 'sec';

%% group detections in bins

% combine all detections
allDets = []; % preallocate
for j = 1:length(wmd)
    thisFile = readtable([wmd(j).folder,'\',wmd(j).name]); % load the file for this week
    allDets = [allDets;thisFile];
end

for c = 1:length(calls) % for each call type

    thisCall = allDets(strcmp(calls(c), allDets.label), :); % grab detections of this call type
    [counts, edges] = histcounts(thisCall.start_time,[binEffort.tbin;(binEffort.tbin(end)+minute(1))]); % bin # of calls within each minute
    binEffort{:,end+1} = counts'; % add them to the table

end

binEffort.Properties.VariableNames = [{'Effort_Bin','Effort_s'},calls]; % give the table meaningful names

% match them back to original week delinations that I verified
depStart = datetime('06-Nov-2023 00:00:00'); % start of effort
depEnd = datetime('06-Nov-2024 20:57:13'); % end effort
weekStartTimes = depStart:calweeks(1):(depEnd - calweeks(1)); % start times of all weeks in recording period
binEffort.idx = discretize(binEffort.tbin,[weekStartTimes,weekStartTimes(end)+calweeks(1),weekStartTimes(end)+calweeks(2)]); % match the minutes to the correct week
binEffort = timetable2table(binEffort); binEffort.tbin = []; % get rid of the time so can summarize
weekEffort = groupsummary(binEffort,'idx','sum'); % retime the table
tbin = [weekStartTimes,weekStartTimes(end)+calweeks(1)]; % give it the new dates
weekEffort = table2timetable(weekEffort,'RowTimes',tbin); % make into a timetable

writetimetable(weekEffort,'M:\Mysticetes\WhaleMoanDetector_finalOutputs\binned_baleen_detections.csv');


%% make figures

rgb = get(groot,"FactoryAxesColorOrder"); % grab colors
rgb = rgb([1,2,4:end],:); % remove yellow, hard to see
load('M:\Mysticetes\WhaleMoanDetector_finalOutputs\WMD_CI.mat')
% upperCI(53,:) = [nan nan nan nan];
% lowerCI(53,:) = [nan nan nan nan];

figure

for c = 1:length(calls) % for each call type
    
    subplot(4,1,c)
    colororder({num2str(rgb(c,:)),'k'})
    yyaxis left
    bar(weekEffort.Time,(weekEffort{:,c+4})/60,'stacked','barwidth',1,'edgecolor','none','FaceAlpha',0.5)
    hold on
    errorbar(weekEffort.Time,(weekEffort{:,c+4})/60, lowerCI(:,c),upperCI(:,c),'color',rgb(c,:),'linestyle','none')
    ylim([0 max((weekEffort{:,c+4})/60)+20])
    % ylabel('Cumulative # Calls/Week')
    yyaxis right
    scatter(weekEffort.Time(weekEffort.sum_Effort_Bin>0&weekEffort.sum_Effort_Bin<10080),(weekEffort.sum_Effort_Bin(weekEffort.sum_Effort_Bin>0&weekEffort.sum_Effort_Bin<10080)/10080)*100,10,'k','filled')
    ylim([0 100])
    % ylabel("% of Effort/Week")

    if c < length(calls)
        set(gca, 'XTickLabel', []);
    end

end