%% seasonal_circles_CADEMO

%% from everything bins

load('M:\Report_Drafts\092025\CADEMO_daily_summedMinutes_binned_allSpecies_allMinutes.mat');

season = nan(height(savetable),1);
mnth = month(savetable.Time);
wi = find(mnth==1 | mnth==2 | mnth==3);
season(wi) = 1; % assign winter to 1
spr = find(mnth==4 | mnth==5 | mnth==6);
season(spr) = 2; % spring is 2
smm = find(mnth==7 | mnth==8 | mnth==9);
season(smm) = 3; % winter is 3
fall = find(mnth==10 | mnth==11 | mnth==12);
season(fall) = 4; % fall is 4

savetable.season = season;
global CADEMO
loadParams('M:\Report_Drafts\092025\CADEMO_figures_colors.params')
ypos = [1 1.5 2.5 3.5 4.5 5.5 7 8.5 9.5 10 11 12 13 14.5 15.5 16.5];

allsp = nan(4,16);

figure
hold on
for s = 1:16 % for each species

    varName = savetable.Properties.VariableNames{s};
    thisCall = savetable(savetable.(varName)>0,:);

    wi = sum(thisCall.(varName)(thisCall.season==1));
    spr = sum(thisCall.(varName)(thisCall.season==2));
    smm = sum(thisCall.(varName)(thisCall.season==3));
    fall = sum(thisCall.(varName)(thisCall.season==4));

    allsp(1,s) = wi;
    allsp(2,s) = spr;
    allsp(3,s) = smm;
    allsp(4,s) = fall;

    win = wi/(wi+spr+smm+fall);
    sprn = spr/(wi+spr+smm+fall);
    smmn = smm/(wi+spr+smm+fall);
    falln = fall/(wi+spr+smm+fall);

    if win == 0
        win = nan;
    end
    if sprn == 0
        sprn = nan;
    end
    if smmn == 0
        smmn = nan;
    end
    if falln == 0
        falln = nan;
    end

    scatter([1 2 3 4],repmat(ypos(s),4,1),[win sprn smmn falln]*350,CADEMO.colorMat(s,:),'filled','MarkerEdgeColor','black')
 
end

set(gca, 'YDir','reverse')
yline(6.25,'LineStyle','--')
yline(7.75,'LineStyle','--')
yline(13.75,'LineStyle','--')
ylim([0.5 17])
xlim([0 5])

% --- your scatter plotting loop stays the same ---

set(gca, 'YDir','reverse')
yline(6.25,'LineStyle','--')
yline(7.75,'LineStyle','--')
yline(13.75,'LineStyle','--')
ylim([0.5 17])

hold on

% reference proportions for legend
legVals  = [0.25 0.5 1.0];
legSizes = legVals * 350;  % same as scatter SizeData

% choose x-position for legend (data units)
xLegend = 5;

% choose y-positions for legend circles
yLegendStart = 16;   % top y in data units
dy = 1.5;            % spacing between circles

for i = 1:numel(legVals)
    scatter(xLegend, yLegendStart - (i-1)*dy, legSizes(i), ...
        'w','filled','MarkerEdgeColor','k');
    text(xLegend + 0.5, yLegendStart - (i-1)*dy, ...
        sprintf('%d%%', round(legVals(i)*100)), ...
        'VerticalAlignment','middle');
end

%% now make some pie charts
allsp = allsp';
varNames = savetable.Properties.VariableNames;

for p = 1:4
    thisSeason = allsp(:,p);
    thisSeason = thisSeason./sum(thisSeason); % normalize to get percentages
    thisSeason = thisSeason*100;

    figure
    pc = piechart(thisSeason, varNames(1:end-1));
    pc.ColorOrder = CADEMO.colorMat;
    pc.FaceAlpha = 1;   
end

% make these per species type
odonts = 1:1:6;
pinnipeds = 7;
mysts = 8:1:13;
fish = 14:1:16;

for p = 1:4
    thisSeason = allsp(:,p);
    figure
    
    for g = 1:4 % for each group of species
        if g == 1 % odonts
            thisSpecies = thisSeason(odonts);
            thisSpecies = thisSpecies./sum(thisSpecies);
            thisSpecies = thisSpecies*100;

            subplot(4,1,1)
            pc = piechart(thisSpecies, varNames(odonts));
            pc.ColorOrder = CADEMO.colorMat(odonts,:);
            pc.FaceAlpha = 1;   
            
        elseif g == 2 % pinnipeds

            thisSpecies = thisSeason(pinnipeds);
            thisSpecies = thisSpecies./sum(thisSpecies);
            thisSpecies = thisSpecies*100;

            subplot(4,1,2)
            pc = piechart(thisSpecies, varNames(pinnipeds));
            pc.ColorOrder = CADEMO.colorMat(pinnipeds,:);
            pc.FaceAlpha = 1;   

        elseif g == 3 % mysticetes

            thisSpecies = thisSeason(mysts);
            thisSpecies = thisSpecies./sum(thisSpecies);
            thisSpecies = thisSpecies*100;

            subplot(4,1,3)
            pc = piechart(thisSpecies, varNames(mysts));
            pc.ColorOrder = CADEMO.colorMat(mysts,:);
            pc.FaceAlpha = 1; 

        elseif g == 4 % fish

            thisSpecies = thisSeason(fish);
            thisSpecies = thisSpecies./sum(thisSpecies);
            thisSpecies = thisSpecies*100;

            subplot(4,1,4)
            pc = piechart(thisSpecies, varNames(fish));
            pc.ColorOrder = CADEMO.colorMat(fish,:);
            pc.FaceAlpha = 1; 

        end
  
    end

end

%% try stacked rectangles instead

allsp = allsp';
varNames = savetable.Properties.VariableNames;

figure
for p = 1:4
    thisSeason = allsp(:,p);
    thisSeason = thisSeason./sum(thisSeason); % normalize to get percentages
    thisSeason = thisSeason*100;

    subplot(1,4,p)
    hold on
    x0 = 0; y0 = 0; w = 1; h = 1; % rectangle base

    ypos = y0;
    for i = 1:length(thisSeason)
        h_i = thisSeason(i) * h;
        rectangle('Position',[x0, ypos, w, h_i], ...
                  'FaceColor', CADEMO.colorMat(i,:), ...
                  'EdgeColor','black');
        ypos = ypos + h_i;
    end
    % axis equal tight
    ylim([0 100])
    set(gca, 'YDir','reverse')

end

% make these per species type
odonts = 1:1:6;
pinnipeds = 7;
mysts = 8:1:13;
fish = 14:1:16;

for p = 1:4
    thisSeason = allsp(:,p);
    figure
    
    for g = 1:4 % for each group of species
        if g == 1 % odonts
            thisSpecies = thisSeason(odonts);
            thisSpecies = thisSpecies./sum(thisSpecies);
            thisSpecies = thisSpecies*100;
            theseColors = CADEMO.colorMat(odonts,:);

            subplot(4,1,g)
            hold on
            x0 = 0; y0 = 0; w = 1; h = 1; % rectangle base

            ypos = y0;
            for i = 1:length(thisSpecies)
                h_i = thisSpecies(i) * h;
                rectangle('Position',[x0, ypos, w, h_i], ...
                    'FaceColor', theseColors(i,:), ...
                    'EdgeColor','black');
                ypos = ypos + h_i;
            end
            % axis equal tight
            ylim([0 100])
            set(gca, 'YDir','reverse')
            
        elseif g == 2 % pinnipeds

            thisSpecies = thisSeason(pinnipeds);
            thisSpecies = thisSpecies./sum(thisSpecies);
            thisSpecies = thisSpecies*100;
            theseColors = CADEMO.colorMat(pinnipeds,:);

            subplot(4,1,g)
            hold on
            x0 = 0; y0 = 0; w = 1; h = 1; % rectangle base

            ypos = y0;
            for i = 1:length(thisSpecies)
                h_i = thisSpecies(i) * h;
                rectangle('Position',[x0, ypos, w, h_i], ...
                    'FaceColor', theseColors(i,:), ...
                    'EdgeColor','black');
                ypos = ypos + h_i;
            end
            % axis equal tight
            ylim([0 100])
            set(gca, 'YDir','reverse')  

        elseif g == 3 % mysticetes

            thisSpecies = thisSeason(mysts);
            thisSpecies = thisSpecies./sum(thisSpecies);
            thisSpecies = thisSpecies*100;
            theseColors = CADEMO.colorMat(mysts,:);

            subplot(4,1,g)
            hold on
            x0 = 0; y0 = 0; w = 1; h = 1; % rectangle base

            ypos = y0;
            for i = 1:length(thisSpecies)
                h_i = thisSpecies(i) * h;
                rectangle('Position',[x0, ypos, w, h_i], ...
                    'FaceColor', theseColors(i,:), ...
                    'EdgeColor','black');
                ypos = ypos + h_i;
            end
            % axis equal tight
            ylim([0 100])
            set(gca, 'YDir','reverse')

        elseif g == 4 % fish

            thisSpecies = thisSeason(fish);
            thisSpecies = thisSpecies./sum(thisSpecies);
            thisSpecies = thisSpecies*100;
            theseColors = CADEMO.colorMat(fish,:);

            subplot(4,1,g)
            hold on
            x0 = 0; y0 = 0; w = 1; h = 1; % rectangle base

            ypos = y0;
            for i = 1:length(thisSpecies)
                h_i = thisSpecies(i) * h;
                rectangle('Position',[x0, ypos, w, h_i], ...
                    'FaceColor', theseColors(i,:), ...
                    'EdgeColor','black');
                ypos = ypos + h_i;
            end
            % axis equal tight
            ylim([0 100])
            set(gca, 'YDir','reverse') 

        end
  
    end

end

