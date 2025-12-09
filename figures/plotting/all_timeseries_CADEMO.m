%% all_timeseries_CADEMO

% plot timeseries using species colors, for each call
load('M:\Report_Drafts\092025\CADEMO_daily_summedMinutes_binned_allSpecies.mat');

% load colors
global CADEMO
loadParams('M:\Report_Drafts\092025\CADEMO_figures_colors.params')
speciesList = {'Ph','PhB','LoA','Gg','DdDcTt','Orca','Pinniped','Humpback','BlueAB','BlueB','BlueD','GrayM3','Fin20Hz','UF310','UF440','Bocaccio'};
savedir = 'M:\Report_Drafts\092025';

% calculate effort
effort.Start = [datetime('06-Nov-2023 00:00:00') datetime('16-Mar-2024 23:00:00') datetime('14-May-2024 00:00:00')];
effort.End = [datetime('16-Mar-2024 22:28:45') datetime('13-May-2024 19:31:13') datetime('06-Nov-2024 20:57:13')];
p.binDur = 1; % 1 minute
spd = 60*60*24;

% convert intervals in bins
binEffort = intervalToBinTimetable_LMB(effort.Start,effort.End,p); 
binEffort.Properties.VariableNames{1} = 'bin';
binEffort.Properties.VariableNames{2} = 'sec';
binEffort = retime(binEffort,'daily','sum');
savetable.effort = binEffort.sec;

savetable = retime(savetable,'weekly','sum'); % make weekly
savetable.effort = (savetable.effort./(spd*7))*100;

for sp = 1:16 % for each species

    if sp == 1 % plot PhA and PhB together

        f = figure
        colororder({mat2str(CADEMO.colorMat(sp+1,:)),'k'})
        yyaxis left
        bh = bar(savetable.Time,savetable{:,sp:sp+1}./60,'stacked','barwidth',1,'edgecolor','black');
        set(bh,'FaceColor','Flat')
        bh(1).CData = CADEMO.colorMat(sp,:);
        bh(2).CData = CADEMO.colorMat(sp+1,:);
        % ylim([0 100])
        hold on
        yyaxis right
        scatter(savetable.Time(savetable.effort<100),savetable.effort(savetable.effort<100),10,'o','filled')
        ylim([0 100])
        legend(bh,{'PhA','PhB'})
        xlim([savetable.Time(1)-days(7) savetable.Time(end)+days(7)])
        f.Units = 'inches';
        f.Position = [1 1 10 2];

        saveas(f,[savedir,'\timeseries_',speciesList{sp},'.png']);
        close all
    
    elseif sp == 3 || sp==4 || sp==5 || sp==6 || sp==7 || sp == 12 || sp == 14 || sp == 15 || sp == 16 % LoA, Gg, DdDcTt, Orca, Pinniped, Gray M3, all fish
        
        f = figure
        colororder({mat2str(CADEMO.colorMat(sp,:)),'k'})
        yyaxis left
        bar(savetable.Time,savetable{:,sp}./60,'edgecolor','black','barwidth',1)
        hold on
        yyaxis right
        scatter(savetable.Time(savetable.effort<100),savetable.effort(savetable.effort<100),10,'o','filled')
        ylim([0 100])
        xlim([savetable.Time(1)-days(7) savetable.Time(end)+days(7)])
        f.Units = 'inches';
        f.Position = [1 1 10 2];

        saveas(f,[savedir,'\timeseries_',speciesList{sp},'.png']);
        close all

    elseif sp == 8 % humpbacks

        load('M:\Mysticetes\Humpback_NNET\humpback_error_weekly.mat')

        f = figure
        colororder({mat2str(CADEMO.colorMat(sp,:)),'k'})
        yyaxis left
        bar(savetable.Time,savetable{:,sp}./60,'edgecolor','black','barwidth',1)
        hold on
        errorbar(weekEffort.Time-days(1),savetable{:,sp}/60, weekEffort.lowerCI/60,weekEffort.upperCI/60,'linestyle','none','color','black')
        yyaxis right
        scatter(savetable.Time(savetable.effort<100),savetable.effort(savetable.effort<100),10,'o','filled')
        ylim([0 100])
        xlim([savetable.Time(1)-days(7) savetable.Time(end)+days(7)])
        f.Units = 'inches';
        f.Position = [1 1 10 2];

        saveas(f,[savedir,'\timeseries_',speciesList{sp},'.png']);
        close all

    elseif sp == 9 % A and B calls

        load('M:\Mysticetes\WhaleMoanDetector_finalOutputs\WMD_CI.mat')

        f = figure
        colororder({mat2str(CADEMO.colorMat(sp,:)),'k'})
        yyaxis left
        bh = bar(savetable.Time,savetable{:,sp:sp+1}./60,'stacked','barwidth',1,'edgecolor','black');
        set(bh,'FaceColor','Flat')
        bh(1).CData = CADEMO.colorMat(sp,:);
        bh(2).CData = CADEMO.colorMat(sp+1,:);        
        hold on
        errorbar(savetable.Time,savetable{:,sp}/60, lowerCI(:,1),upperCI(:,1),'linestyle','none','color','black')
        errorbar(savetable.Time,savetable{:,sp}/60+savetable{:,sp+1}/60, lowerCI(:,2),upperCI(:,2),'linestyle','none','color','black')
        ylim([0 175])
        yyaxis right
        scatter(savetable.Time(savetable.effort<100),savetable.effort(savetable.effort<100),10,'o','filled')
        ylim([0 100])
        xlim([savetable.Time(1)-days(7) savetable.Time(end)+days(7)])
        f.Units = 'inches';
        f.Position = [1 1 10 2];

        saveas(f,[savedir,'\timeseries_',speciesList{sp},'.png']);
        close all

    elseif sp == 11 % D calls

        load('M:\Mysticetes\WhaleMoanDetector_finalOutputs\WMD_CI.mat')

        f = figure
        colororder({mat2str(CADEMO.colorMat(sp,:)),'k'})
        yyaxis left
        bar(savetable.Time,savetable{:,sp}./60,'edgecolor','black','barwidth',1)
        hold on
        errorbar(savetable.Time,savetable{:,sp}./60, lowerCI(:,3),upperCI(:,3),'linestyle','none','color','black')
        ylim([0 250])
        yyaxis right
        scatter(savetable.Time(savetable.effort<100),savetable.effort(savetable.effort<100),10,'o','filled')
        ylim([0 100])
        xlim([savetable.Time(1)-days(7) savetable.Time(end)+days(7)])
        f.Units = 'inches';
        f.Position = [1 1 10 2];

        saveas(f,[savedir,'\timeseries_',speciesList{sp},'.png']);
        close all

    elseif sp == 13 % fin whale index

        f = figure
        colororder({mat2str(CADEMO.colorMat(sp,:)),'k'})
        hold on
        yyaxis left
        scatter(savetable.Time,savetable{:,sp},'filled')
        line(savetable.Time,savetable{:,sp})
        yyaxis right
        scatter(savetable.Time(savetable.effort<100),savetable.effort(savetable.effort<100),10,'o','filled')
        ylim([0 100])
        xlim([savetable.Time(1)-days(7) savetable.Time(end)+days(7)])
        f.Units = 'inches';
        f.Position = [1 1 10 2];

        saveas(f,[savedir,'\timeseries_',speciesList{sp},'.png']);
        close all
    end 

end


%% anthropogenic signals

effort.Start = [datetime('06-Nov-2023 00:00:00') datetime('16-Mar-2024 23:00:00') datetime('14-May-2024 00:00:00')];
effort.End = [datetime('16-Mar-2024 22:28:45') datetime('13-May-2024 19:31:13') datetime('06-Nov-2024 20:57:13')];
p.binDur = 1; % 1 minute
spd = 60*60*24;

% load in the data
detections = dir('M:\Anth\CHNMS_explosions\*.mat');
savedir = 'M:\Report_Drafts\092025';

allExplosions = []; % preallocate to save all explosions

for i = 1:length(detections)

    % load in the time and vote data
    load([detections(i).folder,'\',detections(i).name],'bt')

    % if there are detections in this file
    if size(bt,1)>0

        % grab the detections that were ruled as positive
        posDet = bt(bt(:,3)==1,:);

        % if there are positive detections in the file, save for future
        % calculations
        if size(posDet,1)~=0
            allExplosions = [allExplosions; posDet];
        end

    end
end

% convert intervals in bins 
binEffort = intervalToBinTimetable_LMB(effort.Start,effort.End,p);

% put detections into the table
expTimes = datetime(allExplosions(:,4),'convertfrom','datenum');
expTimes = dateshift(expTimes,'start','minute');

presBins = zeros(height(binEffort),1);

for i = 1:length(expTimes)   
    presBins(find(binEffort.tbin==expTimes(i))) = presBins(find(binEffort.tbin==expTimes(i)))+1;
end
binEffort.Presence = presBins;
save("M:\Report_Drafts\092025\explosions_binned_minute.mat","binEffort");
binEffort_weekly = retime(binEffort,'weekly','sum');

% make a figure
f = figure
colororder({'[0.6 0.6 0.6]','k'})
hold on
yyaxis left
bar(binEffort_weekly.tbin,binEffort_weekly.Presence,'barwidth',1)
yyaxis right
scatter(binEffort_weekly.tbin(binEffort_weekly.effortSec<(60*60*24*7)),(binEffort_weekly.effortSec(binEffort_weekly.effortSec<(60*60*24*7))/(60*60*24*7))*100,'o','filled')
ylim([0 100])
box on
f.Units = 'inches';
f.Position = [1 1 10 2];
saveas(f,[savedir,'\timeseries_explosions.png']);
close all


% now for ships
% load in the data
detections = dir('M:\Anth\CHNMS_ships\*.mat');

allShips = []; % preallocate to save all ship detections

for i = 1:length(detections)

    % load in the time and vote data
    load([detections(i).folder,'\',detections(i).name],'shipLabels','shipTimes')

    % find indices of actual ships
    shipInd = find(strcmp(shipLabels,'ship'));

    if size(shipInd,1)>0 % if there are ships
        % grab and save to large array
        allShips = [allShips; shipTimes(shipInd,:)];
    end

end

% convert intervals in bins 
binEffort = intervalToBinTimetable_LMB(effort.Start,effort.End,p);
binEffort_weekly = retime(binEffort,'weekly','sum');

% put detections into the table
expTimes = datetime(allShips(:,1),'convertfrom','datenum');
expTimes(:,2) = datetime(allShips(:,2),'convertfrom','datenum');
expTimes = dateshift(expTimes,'start','minute');

allMinutes = [];
for k = 1:length(expTimes)
    thisRange = expTimes(k,1):minutes(1):expTimes(k,2);
    allMinutes = [allMinutes thisRange];
end

[counts, edges, bin] = histcounts(allMinutes,[binEffort.tbin; binEffort.tbin(end)+minutes(1)]); % bin # of calls within each minute
binEffort.ships = counts';
save("M:\Report_Drafts\092025\ships_binned_minute.mat","binEffort");

[counts, edges, bin] = histcounts(allMinutes,[binEffort_weekly.tbin; binEffort_weekly.tbin(end)+days(7)]); % bin # of calls within each minute
binEffort_weekly.ships = counts';

f = figure
colororder({'[0.3 0.3 0.3]','k'})
hold on
yyaxis left
bar(binEffort_weekly.tbin,binEffort_weekly.ships,'barwidth',1)
yyaxis right
scatter(binEffort_weekly.tbin(binEffort_weekly.effortSec<(60*60*24*7)),(binEffort_weekly.effortSec(binEffort_weekly.effortSec<(60*60*24*7))/(60*60*24*7))*100,'o','filled')
box on
f.Units = 'inches';
f.Position = [1 1 10 2];
saveas(f,[savedir,'\timeseries_ships.png']);