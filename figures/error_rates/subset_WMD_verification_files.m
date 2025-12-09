%% subset_WMD_verification_files

effort = readtable('M:\Mysticetes\WhaleMoanDetector_finalOutputs\random_encounters_to_verify.csv');
verify = dir('M:\Mysticetes\WhaleMoanDetector_finalOutputs\verified_detections_LMB\*.txt');
allDets = [];

for i = 1:length(verify)-1 % for each verified file
    
    % grab the week number
    wk = extractAfter(verify(i).name,'week');
    wk = extractBefore(wk,'.txt');
    wk = str2num(wk);

    thisEffort = effort(wk,:); % grab the effort for this week
    thisVerify = readtable([verify(i).folder,'\',verify(i).name]); % load the file for this week

    onEffortDets = thisVerify(find(thisVerify.start_time>thisEffort.Var1 & thisVerify.end_time<thisEffort.Var2),:); % find detections within the on-effort period
    
    % if size(unique(onEffortDets.pr),1)==1 % if no labels within this time period have been changed, might indicate a problem
    %     if unique(onEffortDets.pr)==1
    %         keyboard
    %     end
    % end

    % writetable(onEffortDets,[verify(i).folder,'\',verify(i).name,'_subsetted.csv']); % save the subsetted version

    allDets = [allDets;onEffortDets]; % save all labels for precision-recall curve

end

%% precision-recall curves

% make precision-revall curve per call type
% bin the labels and plot curves with score in color

% edges = [0.2:0.1:0.8]; % define edges of bins
calls = {'A','B','D','40Hz'}; % list of call types to loop through

for c = 1:length(calls) % for each call type

    thisCall = allDets(strcmp(calls(c),allDets.label),:); % grab detections of this call type
    thisCall = sortrows(thisCall,-5); % sort in descending order by score
    thisCall = thisCall(thisCall.score<0.8 | isnan(thisCall.score),:);

    fn = cumsum(thisCall.pr == 3); % false negatives, true labeled false
    tp = cumsum(thisCall.pr == 1); % true positives, true labeled true
    fp = cumsum(thisCall.pr == 2); % false positives, false labeled true
    precision = tp./(tp+fp);
    recall = tp./(tp+fn);

    figure
    scatter(recall,precision,20,thisCall.score,'filled')
    xlabel('Recall');
    ylabel('Precision');
    title(['Precision-Recall Curve ',calls{c},' calls']);
    grid on;
    h = colorbar;
    xlim([0 1]);
    ylim([0 1]);
    ylabel(h, 'score');
    h.Ticks = [0.2:0.2:0.8];
    caxis([0.19 0.81])

end

% save('M:\Mysticetes\WhaleMoanDetector_finalOutputs\WMD_standard_error_singleValue.mat','N_upper','N_lower');


%% binned scores
% calls = {'A','B','D','40Hz'}; % list of call types to loop through
calls = {'40Hz'};
scoreBins = 0.2:0.1:1;          % Define score thresholds

for c = 1:length(calls) % for each call type

    thisCall = allDets(strcmp(calls(c), allDets.label), :); % grab detections of this call type
    thisCall = sortrows(thisCall,-5); % sort in descending order by score

    precision = nan(size(scoreBins));
    recall = nan(size(scoreBins));

    for b = 1:length(scoreBins)
        thresh = scoreBins(b);
        selected = thisCall(thisCall.score >= thresh, :);  % Keep high-confidence detections

        % True Positives, False Positives, False Negatives
        tp = sum(selected.pr == 1);
        fp = sum(selected.pr == 2);
        fn = sum(thisCall.pr==3) + sum(thisCall.pr==1) - tp;
        % fn = sum(thisCall.pr == 1) - tp;  % Missed true positives

        precision(b) = tp / (tp + fp);
        recall(b) = tp / (tp + fn);
    end

    % Plot
    figure
    scatter(recall, precision, 80, scoreBins, 'filled');
    hold on
    plot(recall,precision,'--k','linewidth',1.2)
    xlabel('Recall');
    ylabel('Precision');
    title(['Precision-Recall Curve (binned) - ', calls{c}, ' calls']);
    xlim([0 1]);
    ylim([0 1]);
    grid on;
    colormap('parula');
    h = colorbar;
    ylabel(h, 'Score threshold');
    h.Ticks = scoreBins(2:end-1); % Avoid clutter
    caxis([min(scoreBins)-0.1 max(scoreBins)+0.1])

end

%% plot distribution of scores for each type

calls = {'A','B','D','40Hz'}; % list of call types to loop through
rgb = get(groot,"FactoryAxesColorOrder");
rgb = rgb([1,2,4:end],:);
breaks = [0.2:0.1:1];

for c = 1:length(calls)

    thisCall = allDets(strcmp(calls(c), allDets.label), :); % grab detections of this call type

    figure
    histogram(thisCall.score,breaks,'facecolor',rgb(c,:),'facealpha',0.5)
    hold on
    histogram(thisCall.score(thisCall.pr==2),breaks,'facecolor',rgb(c,:),'facealpha',1)
    title(['Distribution of scores - ', calls{c}, ' calls']);
    legend({'All dets','False dets'})
    ylabel('Counts')
    xlabel('Scores')

end

%% calculate precision/recall for each week and call type for error

effort = readtable('M:\Mysticetes\WhaleMoanDetector_finalOutputs\random_encounters_to_verify.csv');
verify = dir('M:\Mysticetes\WhaleMoanDetector_finalOutputs\verified_detections_LMB\*.txt');
calls = {'A','B','D','40Hz'}; % list of call types to loop through
precision = nan(length(verify)-1,4);
error = nan(length(verify)-1,4);
TP = nan(length(verify)-1,4); FP = nan(length(verify)-1,4); FN = nan(length(verify)-1,4); pred = nan(length(verify)-1,4);

precCI = nan(length(verify)-1,length(calls));
recallCI = nan(length(verify)-1,length(calls));

for i = 1:length(verify)-1 % for each verified file
    
    % grab the week number
    wk = extractAfter(verify(i).name,'week');
    wk = extractBefore(wk,'.txt');
    wk = str2num(wk);

    thisEffort = effort(wk,:); % grab the effort for this week
    thisVerify = readtable([verify(i).folder,'\',verify(i).name]); % load the file for this week

    onEffortDets = thisVerify(find(thisVerify.start_time>thisEffort.Var1 & thisVerify.end_time<thisEffort.Var2),:); % find detections within the on-effort period
    
    % calculate FP/FN rates per call type
    for c = 1:length(calls)

        thisCall = onEffortDets(strcmp(calls(c), onEffortDets.label), :); % grab detections of this call type
        tp = sum(thisCall.pr == 1);
        fp = sum(thisCall.pr == 2);
        fn = sum(thisCall.pr==3); 
        precision(i,c) = tp / (tp + fp);
        recall(i,c) = tp / (tp + fn);
        if (tp+fp) > 0
            precCI(wk,c) = binofit(tp,tp+fp,0.05); % 95\% confidence interval
        elseif (tp+fn) > 0
            recallCI(wk,c) = binofit(tp,tp+fn,0.05); % 95\% confidence interval
        end

    end

end

save('M:\Mysticetes\WhaleMoanDetector_finalOutputs\WMD_CI.mat','precision','recall','precCI','recallCI');

%%

effort = readtable('M:\Mysticetes\WhaleMoanDetector_finalOutputs\random_encounters_to_verify.csv');
verify = dir('M:\Mysticetes\WhaleMoanDetector_finalOutputs\verified_detections_LMB\*.txt');
calls = {'A','B','D','40Hz'}; % list of call types to loop through

predicted = nan(length(verify)-1, length(calls)); % predicted calls per week per call type
lowerCI = nan(length(verify)-1, length(calls));    % lower CI on actual calls
upperCI = nan(length(verify)-1, length(calls));    % upper CI on actual calls

for i = 1:length(verify)-1 % for each verified file
    
    % grab the week number
    wk = extractAfter(verify(i).name,'week');
    wk = extractBefore(wk,'.txt');
    wk = str2num(wk);

    thisEffort = effort(wk,:); % grab the effort for this week
    thisVerify = readtable([verify(i).folder,'\',verify(i).name]); % load the file for this week

    onEffortDets = thisVerify(find(thisVerify.start_time>thisEffort.Var1 & thisVerify.end_time<thisEffort.Var2),:); % find detections within the on-effort period

    % calculate FP/FN rates per call type
    for c = 1:length(calls)

        % Number of model predictions of this call type
        thisCall = onEffortDets(strcmp(calls(c), onEffortDets.label), :); % grab detections of this call type
        predicted(i,c) = sum(thisCall.pr==1) + sum(thisCall.pr==2);
        
        fp = sum(thisCall.pr==2);
        fpr = fp/(height(thisCall));
        lowerCI(i,c) = fpr*predicted(i,c);

        fn = sum(thisCall.pr==3);
        fnr = fn/height(thisCall);
        upperCI(i,c) = fnr*predicted(i,c);

    end

end

save('M:\Mysticetes\WhaleMoanDetector_finalOutputs\WMD_CI.mat','lowerCI','upperCI');

%% calculate standard error per week based on verified labels

effort = readtable('M:\Mysticetes\WhaleMoanDetector_finalOutputs\random_encounters_to_verify.csv');
verify = dir('M:\Mysticetes\WhaleMoanDetector_finalOutputs\verified_detections_LMB\*.txt');
calls = {'A','B','D','40Hz'}; % list of call types to loop through

for i = 1:length(verify)-1 % for each verified file
    
    % grab the week number
    wk = extractAfter(verify(i).name,'week');
    wk = extractBefore(wk,'.txt');
    wk = str2num(wk);

    thisEffort = effort(wk,:); % grab the effort for this week
    thisVerify = readtable([verify(i).folder,'\',verify(i).name]); % load the file for this week

    onEffortDets = thisVerify(find(thisVerify.start_time>thisEffort.Var1 & thisVerify.end_time<thisEffort.Var2),:); % find detections within the on-effort period
    
    % calculate FP/FN rates per call type
    for c = 1:length(calls)

        thisCall = onEffortDets(strcmp(calls(c), onEffortDets.label), :); % grab detections of this call type
        tp = sum(thisCall.pr == 1);
        fp = sum(thisCall.pr == 2);
        fn = sum(thisCall.pr==3); % + sum(thisCall.pr==1) - tp;
        precision(i,c) = tp / (tp + fp);
        recall(i,c) = tp / (tp + fn);
        TP(i,c) = tp; FP(i,c) = fp; FN(i,c) = fn;

    end

end
