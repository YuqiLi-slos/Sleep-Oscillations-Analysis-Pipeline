%% simple staging and SWA/sigma activity extraction

% this script is to classify each sleep epoch (window) into NREM and REM 


clear filtered_PFC_SWS
filtered_PFC_SWS(1,:) = bandpass(localPFC(1,:),[0.5 4],1000); 

% find the window_list (10 second per window/sleep epoch)
plot_display=("notTrue");

%doesn't matter the coef and thre here, it's to generate window list only
coef=0.1; 
thre=0.2;
windowSize=10000;

[~,window_list,~,~]=stagedetection_slidingwindow(filtered_PFC_SWS,...
                                                       fil_localPFC_SWS_zeropadding,...
                                                       localPFC_NAN,...
                                                       coef,thre,plot_display,...
                                                       windowSize,...
                                                       localPFC_zeropadding);




% define each window/sleep epoch is REM sleep or NREM sleep based on
% delta:theta ratio
clear fil_CA1_zeropadding
fil_CA1_zeropadding(1,:)=bandpass(localCA1_zeropadding(1,:),[1 4],1000);               
clear fil_CA1_theta_zeropadding
fil_CA1_theta_zeropadding(1,:)=bandpass(localCA1_zeropadding(1,:),[5 11],1000);               


start_idx=window_list(:,1);
end_idx=window_list(:,2);

mean_power=[];

for i = 1:size(start_idx,1)
signal=fil_CA1_zeropadding(1,start_idx(i):end_idx(i));
abs_signal=abs(signal);
mean_power(i,1)=mean(abs_signal);


signal=fil_CA1_theta_zeropadding(1,start_idx(i):end_idx(i));
abs_signal=abs(signal);
mean_power(i,2)=mean(abs_signal);

end

% x axis is delta, y axis is theta
scatter(mean_power(:,1),mean_power(:,2),[],'filled','MarkerFaceColor','b')
ylabel('theta amplitude (µV)')
xlabel('delta amplitude (µV)')
ratio=mean_power(:,2)./mean_power(:,1);

%% check if ratio is reasonble using k means
k=2;
idx = kmeans(ratio,k);


group_1 = ratio(idx==1);
group_2 = ratio(idx==2);

max_g1 = max(group_1);
max_g2 = max(group_2);

% figure to visualise seggregation between two groups
% scatter(group_1, ones(1,length(group_1)));hold on;
% scatter(group_2, ones(1,length(group_2)));
% 
% xlabel('theta : delta ratio')

idx=ratio<=min(max_g1,max_g2);


% scatter(mean_power(idx,1),mean_power(idx,2),[],'filled','MarkerFaceColor','b')
CA1_NREM= window_list(idx,:);

% hold on

idx=ratio>min(max_g1,max_g2);
% scatter(mean_power(idx,1),mean_power(idx,2),[],'filled','MarkerFaceColor','r')
CA1_REM=setdiff(window_list,CA1_NREM,'rows');




