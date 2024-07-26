%% Import OpenEphys binary files into numerical arrays

clc;close all; clear all;
[binName,path] = uigetfile('*.*', 'Select Binary File');

% Function load_open_ephys_binary() created by openEPHYS
% Download from https://github.com/open-ephys/analysis-tools/blob/master/load_open_ephys_binary.m
D=load_open_ephys_binary([path,'structure.oebin'],'continuous',1,'mmap');

% OPTIONAL - Import binary data in different batches

batchnumber=1 
% length of recording to read in this batch
minute_to_read=600; 
% acquisition frequency
samplingfrequency=2000 

length_to_read=samplingfrequency*60*minute_to_read; 

initial_position=(batchnumber-1)*length_to_read+1
end_position=initial_position+length_to_read-1

% special case where the final batch is less than the length to read
if end_position>size(D.Data.Data.mapped,2)
    end_position=size(D.Data.Data.mapped,2)
end

%check which channels for this animal, 1:32 refers to the channels being
%read
data_batch{1}=double(D.Data.Data.mapped(1:32 ,initial_position:end_position)); 
total_recording_length=size(D.Data.Data.mapped,2)/2000/60


%% Assign channels and downsampling 

% extract PFC, S1, CA1, and EMG channels
% LFPchan includes 6 channels, with PFC signals in the first two channels
% S1 signals in 3 and 4
% CA1 signals in 5 and 6
clear EMGchan
clear dataArray
clear LFPchan
clear fEMGchan

% Y1 is the animal name, check which are the corresponding channels for each recording site
% from sugery, and assign them in order.


Y1=[7,31,32,21,22,13,14];
% confirm which mouse to analyse
animalname=Y1;

for a=1:size(data_batch,2) 
    
    dataArray{a}=data_batch{a}(animalname,:); 
    
    % number of channels
    nChan=size(dataArray{a},1); 
    
    ii=0;
    iii=0;
    
    % downsampling of EMG
    for i=1:nChan
        % make sure EMG should always be in the first channel 
        if i==1 
            
            iii=iii+1;
            % downsample to 1000Hz from 2000Hz
            EMGchan{a}(iii,:)=resample(dataArray{a}(i,:),1,2); 
            
            
   % downsampling of LFP signals         
        else
            % remaining channels are LFP signals
            ii=ii+1; 
            % downsample to 1000Hz from 2000Hz
            LFPchan{a}(ii,:)=resample(dataArray{a}(i,:),1,2); 
            
        end
    end
end


%% movement detection - automatic

% adjust coef by eye inspection in the generated plot
coef=0.1
mean_total+coef*std_total
proxy={};
proxy{1}=LFPchan{1}(3,:);
EMGchan;
% SAMPLING FREQUENCY AFTER DOWNSAMPLING
SF=1000;
[movement, mean_total, std_total] = EMGmovementdetection(EMGchan,coef,SF);


PFC_example = LFPchan{1}(1,:);

%sup_CA1 = LFPchan{1}(6,:);
EMG=EMGchan{1}(1,:);
time = 1:length(EMG);

fig = figure;
sgtitle('Click on movement start and end coordinates')
ax(1) = subplot(2,1,1);
plot(time,PFC_example)
title('PFC_example (single channel)')


ax(4) = subplot(2,1,2);
plot(time,EMG)

title('EMG')
linkaxes(ax,'x')
plot(time,EMG)
hold on;

xline(movement(:,1), 'r')
xline(movement(:,2), 'b--'); hold off;

%% Remove movement /zeropadding/NAN for further analysis
LFPchan_nomov=[];
LFPchan_nomov=fragment_delete(LFPchan, movement);


LFPchan_zeropadding=[];
LFPchan_zeropadding= zeropadding(LFPchan,movement);
zeropad_timelength=size(LFPchan_zeropadding{1},2)/1000/60;

LFPchan_NAN= NotAValue(LFPchan,movement);


%% Sort the channels and make suitable substraction - step4

% make subtraction to get local signal so that DOWN state points upward and SWR points downward

clear localPFC

localPFC=LFPchan_nomov{1}(1,:)-LFPchan_nomov{1}(2,:);

localPFC_zeropadding=LFPchan_zeropadding{1}(1,:)-LFPchan_zeropadding{1}(2,:);

plot(localPFC_zeropadding)

localPFC_NAN=LFPchan_NAN{1}(1,:)-LFPchan_NAN{1}(2,:);


clear localS1

localS1=LFPchan_nomov{1}(3,:)-LFPchan_nomov{1}(4,:); 

localS1_zeropadding=LFPchan_zeropadding{1}(3,:)-LFPchan_zeropadding{1}(4,:);

plot(localS1_zeropadding)

localS1_NAN=LFPchan_NAN{1}(3,:)-LFPchan_NAN{1}(4,:);


clear localCA1

localCA1=LFPchan_nomov{1}(6,:)-LFPchan_nomov{1}(5,:);

localCA1_zeropadding=LFPchan_zeropadding{1}(6,:)-LFPchan_zeropadding{1}(5,:);

plot(localCA1_zeropadding)

localCA1_NAN=LFPchan_NAN{1}(6,:)-LFPchan_NAN{1}(5,:);
