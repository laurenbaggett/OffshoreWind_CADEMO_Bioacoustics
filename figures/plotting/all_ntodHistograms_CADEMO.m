% all_ntodHistograms_CADEMO

load('M:\Report_Drafts\092025\CADEMO_minute_binned_allSpecies_allMinutes.mat'); % load minute bins
global CADEMO
loadParams('M:\Report_Drafts\092025\CADEMO_figures_colors.params')
speciesList = {'Ph','PhB','LoA','Gg','DdDcTt','Orca','Pinniped','Humpback','BlueAB','BlueB','BlueD','GrayM3','UF310','UF440','Bocaccio'};
savedir = 'M:\Report_Drafts\092025';


q = dbInit('Server','breach.ucsd.edu','Port',9779); % connect to Tethys
lat = 34.4486;
lon = 360-120.4716;
night = dbDiel(q, lat, lon,  savetable.Time(1), savetable.Time(end)); % get sunrise sunset data from Tethys
night = datetime(night,'convertfrom','datenum');
ntod = fn_normTimeofd_ASB(savetable.Time, night(:,2), night(:,1)); % function from Alba, calculate normalized time of day
savetable.ntod = ntod;

for sp = 1:15 % for each species

    if sp == 1

        theseCounts = savetable(:,[sp sp+1 end]);
        PhA = theseCounts(theseCounts.PhA > 0,[1 3]);
        PhB = theseCounts(theseCounts.PhB > 0,[2 3]);
        edges = [-1:0.05:1]; % define bin edges for the histogram

        N1 = histcounts(PhA.ntod, [edges, edges(end)+0.1]);
        N2 = histcounts(PhB.ntod, [edges, edges(end)+0.1]);
        centers = edges + diff([edges,edges(end)+0.1])/2;
        
        f = figure
        h1 = bar(centers,[N2;N1]','stacked','edgecolor','black','barwidth',1,'facealpha',0.8);
        y_limits = get(gca, 'yLim');
        h2 = patch([0 0 1 1],[y_limits(1) y_limits(2) y_limits(2) y_limits(1)],[0.8 0.8 0.8],'edgecolor','none');
        uistack(h1,'top')
        h1(1).FaceColor = CADEMO.colorMat(sp+1,:);
        h1(2).FaceColor = CADEMO.colorMat(sp,:);
        xlim([-1 1])
        f.Units = 'inches';
        f.Position = [1 1 4 4];

        saveas(f,[savedir,'\ntodHistogram_',speciesList{sp},'.png']);
        close all

    elseif sp >= 3 & sp <= 8 || sp == 11 || sp == 12 % LoA, Gg, DcDcTt, Oo, Pinniped, Mn, D calls or gray whales

        theseCounts = savetable(:,[sp end]);
        edges = [-1:0.05:1]; % define bin edges for the histogram
        theseCounts.Properties.VariableNames = {'sp','ntod'}; % rename for easier access
        theseCounts = theseCounts(theseCounts.sp > 0,:); % subset for only bins with clicks for this species

        f = figure
        h1 = histogram(theseCounts.ntod,edges,'EdgeColor','black','facecolor',CADEMO.colorMat(sp,:),'facealpha',0.8);
        y_limits = get(gca, 'yLim');
        h2 = patch([0 0 1 1],[y_limits(1) y_limits(2) y_limits(2) y_limits(1)],[0.8 0.8 0.8],'edgecolor','none');
        uistack(h1,'top')
        xlim([-1 1])
        f.Units = 'inches';
        f.Position = [1 1 4 4];

        saveas(f,[savedir,'\ntodHistogram_',speciesList{sp},'.png']);
        close all


    elseif sp == 9 % A and B calls together

        theseCounts = savetable(:,[sp sp+1 end]);
        A = theseCounts(theseCounts.A > 0,[1 3]);
        B = theseCounts(theseCounts.B > 0,[2 3]);
        edges = [-1:0.05:1]; % define bin edges for the histogram

        N1 = histcounts(A.ntod, [edges, edges(end)+0.1]);
        N2 = histcounts(B.ntod, [edges, edges(end)+0.1]);
        centers = edges + diff([edges,edges(end)+0.1])/2;
        
        f = figure
        h1 = bar(centers,[N2;N1]','stacked','edgecolor','black','barwidth',1,'facealpha',0.8);
        y_limits = get(gca, 'yLim');
        h2 = patch([0 0 1 1],[y_limits(1) y_limits(2) y_limits(2) y_limits(1)],[0.8 0.8 0.8],'edgecolor','none');
        uistack(h1,'top')
        h1(1).FaceColor = CADEMO.colorMat(sp+1,:);
        h1(2).FaceColor = CADEMO.colorMat(sp,:);
        xlim([-1 1])
        f.Units = 'inches';
        f.Position = [1 1 4 4];

        saveas(f,[savedir,'\ntodHistogram_',speciesList{sp},'.png']);
        close all

    elseif sp >= 13 && sp <= 15 % fish

        theseCounts = savetable(:,[sp end]);
        edges = [-1:0.05:1]; % define bin edges for the histogram
        theseCounts.Properties.VariableNames = {'sp','ntod'}; % rename for easier access
        theseCounts = theseCounts(theseCounts.sp > 0,:); % subset for only bins with clicks for this species

        f = figure
        h1 = histogram(theseCounts.ntod,edges,'EdgeColor','black','facecolor',CADEMO.colorMat(sp+1,:),'facealpha',0.8);
        y_limits = get(gca, 'yLim');
        h2 = patch([0 0 1 1],[y_limits(1) y_limits(2) y_limits(2) y_limits(1)],[0.8 0.8 0.8],'edgecolor','none');
        uistack(h1,'top')
        xlim([-1 1])
        f.Units = 'inches';
        f.Position = [1 1 4 4];

        saveas(f,[savedir,'\ntodHistogram_',speciesList{sp},'.png']);
        close all

    end
        
end

%% anthropogenic sounds

ships = load('M:\Report_Drafts\092025\ships_binned_minute.mat'); % load minute bins
explosions = load('M:\Report_Drafts\092025\explosions_binned_minute.mat');
savedir = 'M:\Report_Drafts\092025';


q = dbInit('Server','breach.ucsd.edu','Port',9779); % connect to Tethys
lat = 34.4486;
lon = 360-120.4716;
night = dbDiel(q, lat, lon,  ships.binEffort.tbin(1), ships.binEffort.tbin(end)); % get sunrise sunset data from Tethys
night = datetime(night,'convertfrom','datenum');
ntod = fn_normTimeofd_ASB(ships.binEffort.tbin, night(:,2), night(:,1)); % function from Alba, calculate normalized time of day
ships.binEffort.ntod = ntod;
explosions.binEffort.ntod = ntod;

% explosions
theseCounts = explosions.binEffort(:,[3 4]);
edges = [-1:0.05:1]; % define bin edges for the histogram
theseCounts.Properties.VariableNames = {'sp','ntod'}; % rename for easier access
theseCounts = theseCounts(theseCounts.sp > 0,:); % subset for only bins with clicks for this species

f = figure
h1 = histogram(theseCounts.ntod,edges,'EdgeColor','black','facecolor',[0.6 0.6 0.6],'facealpha',0.8);
y_limits = get(gca, 'yLim');
h2 = patch([0 0 1 1],[y_limits(1) y_limits(2) y_limits(2) y_limits(1)],[0.8 0.8 0.8],'edgecolor','none');
uistack(h1,'top')
xlim([-1 1])
f.Units = 'inches';
f.Position = [1 1 4 4];

saveas(f,[savedir,'\ntodHistogram_explosions.png']);
close all

% ships
theseCounts = ships.binEffort(:,[3 4]);
edges = [-1:0.05:1]; % define bin edges for the histogram
theseCounts.Properties.VariableNames = {'sp','ntod'}; % rename for easier access
theseCounts = theseCounts(theseCounts.sp > 0,:); % subset for only bins with clicks for this species

f = figure
h1 = histogram(theseCounts.ntod,edges,'EdgeColor','black','facecolor',[0.3 0.3 0.3],'facealpha',0.8);
y_limits = get(gca, 'yLim');
h2 = patch([0 0 1 1],[y_limits(1) y_limits(2) y_limits(2) y_limits(1)],[0.8 0.8 0.8],'edgecolor','none');
uistack(h1,'top')
xlim([-1 1])
f.Units = 'inches';
f.Position = [1 1 4 4];

saveas(f,[savedir,'\ntodHistogram_ships.png']);
close all
