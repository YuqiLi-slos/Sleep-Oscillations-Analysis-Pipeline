%% Sharp wave ripple detection

%REMOVE DC CURRENT - not necessary for CA1 though because it's based on
%frequency and power entirely
clear DCremoved_CA1
DCremoved_CA1(1,:)=localCA1(1,:)-mean(localCA1(1,:));

%80-250 HZ FILTER - ripple band frequency
clear filtered_CA1
filtered_CA1(1,:)=bandpass(DCremoved_CA1(1,:),[80 250],1000,'ImpulseResponse','fir');

% CALL MYFINDRIPPLE

signal=filtered_CA1;

% Detection Scripts taken from (Jarzebowski et al., 2021)
% https://github.com/przemyslawj/ach-effect-on-hpc/tree/master/src/detection
fs=1000;
time = (1:size(filtered_CA1,2)) / fs;
clear ripples
[ripples, sd, normalizedSquaredSignal] = MyFindRipples(time', signal', ...
                     'frequency', fs, ...
                     'thresholds', [3 5 0.01],...
                     'durations', [10 15 300],...
                     'std', 0);
TIME=size(LFPchan_nomov{1},2)/1000/60

% The timestamps generated was based on the signals with movement blocks
% removed, here I add the movement blocks back to get the original
% timestamps
corrected_ripple=insert_mov(ripples,movement);

 %% optional - plot the detection of ripples

figure 

plot (DCremoved_CA1)
hold on

y=ones(size(ripples(:,2)));
scatter(ripples(:,1)*1000,y,'filled','r')
scatter(ripples(:,3)*1000,y,'filled','b')

%CA1 ripple band signal
plot(filtered_CA1); 


