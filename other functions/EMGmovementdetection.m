function [movement, mean_total, std_total] = EMGmovementdetection(EMGchan,coef,SF)

% use high frequency component >300 Hz to detect muscle movment
filtered_EMG(1,:) = highpass((EMGchan{1}(1,:)),300,1000);
win = SF/10;
idx = win;

% square signal to remove directionality, use mean + std threshold method
signal=filtered_EMG(1,:);
signal_sqr = signal.^2;
start_idx = 1;
mean_total = mean(signal_sqr);
std_total = std(signal_sqr);



mean_signal = [];
std_signal = [];
movement_magnitude = [];

for i = 1:floor((length(signal_sqr)/win))
    
    tmp_mean = mean(signal_sqr(start_idx:start_idx+win-1));
    tmp_std = std(signal_sqr(start_idx:start_idx+win-1));
    mean_signal= [mean_signal tmp_mean];
    std_signal= [std_signal tmp_std];
    
    
    if tmp_mean > mean_total + coef*std_total
        movement_magnitude = [movement_magnitude; start_idx start_idx+win-1];
    end
    
    start_idx = start_idx+win;
    
end



% combine movement blocks if they are close together - concartenate movement that are super close and basically one event block
minInterSamples = SF*2; %2s
secondPass = [];
movement = movement_magnitude(1,:);
for i = 2:size(movement_magnitude,1)
    if movement_magnitude(i,1) - movement(2) < minInterSamples
        % Merge
        movement = [movement(1) movement_magnitude(i,2)];
    else
        secondPass = [secondPass ; movement];
        movement = movement_magnitude(i,:);
    end
end
secondPass = [secondPass ; movement];
if isempty(secondPass)
    disp('Mov merge failed');
    movement = [];
    return
else
    %disp(['After ripple merge: ' num2str(length(secondPass)) ' events.']);
end

movement = secondPass;

% concartenate movement that are relatively close - unlikely there are any sleep in between

minInterSamples = SF*10; %10s
ThirdPass = [];
movement_tmp = movement(1,:);
for i = 2:size(movement,1)
    if movement(i,1) - movement_tmp(2) < minInterSamples
        % Merge
        movement_tmp = [movement_tmp(1) movement(i,2)];
    else
        ThirdPass = [ThirdPass ; movement_tmp];
        movement_tmp = movement(i,:);
    end
end
ThirdPass = [ThirdPass ; movement_tmp];
if isempty(ThirdPass)
    disp('Mov merge failed');
    movement_tmp = [];
    return
else
    %disp(['After ripple merge: ' num2str(length(secondPass)) ' events.']);
end

movement = ThirdPass;

% concartenate movement that are close on macroscale - remove short period
% of sleep between two waking period - probably quite wakefulness


 waketime=movement(:,2)-movement(:,1);
 consec_wake=[];
 mov=movement;
 


 % look for consecutive wake periods (>15s movement)
    for i=2:length(waketime)-1
     
        if waketime(i)>SF*15 && waketime(i+1)>SF*15
            consec_wake=[consec_wake; movement(i,:)];
           
        else if waketime(i)>SF*15 && waketime (i-1)>SF*15
                consec_wake=[consec_wake; movement(i,:)];
                
     
            end
        end
     
    end
% remove these consecutive wake period for now
     mov=movement;
    for i=1:size(consec_wake,1)
        idx=mov(:,1)==consec_wake(i,1);
        mov(idx,:)=[];
    end
    
    
    % if there are no more than 30s sleep like activity between two
    % consecutive wakefulness, probably it's not actual sleep but waking in
    % quiteness
    minInterSamples = SF*30;
    FourthPass = [];
    movement_tmp = movement(1,:);
    
    if  ~isempty(consec_wake)
    consecwake_tmp = consec_wake(1,:);
 
    
    for i = 2:size(consec_wake,1)
    
 	if consec_wake(i,1) - consecwake_tmp(2) < minInterSamples
 		% Merge
 		consecwake_tmp = [consecwake_tmp(1) consec_wake(i,2)];
 	else
 		FourthPass = [FourthPass ; consecwake_tmp];
 		consecwake_tmp = consec_wake(i,:);
 	end
 end
 FourthPass = [FourthPass ; consecwake_tmp];
 
 if isempty(FourthPass)
 	disp('Mov merge failed');
     consecwake_tmp = [];
 	return
 else
 	
 end

 mov=[mov ; FourthPass];
 movement=sortrows(mov,2);
 
    end
%movement = FourthPass;
% discard movement that are too short (<200ms) so unlikely to be a real movement
minDuration=SF/5;
time=(1:length((EMGchan{1}(1,:))))';
movement = [time(movement(:,1)) time(movement(:,2))];
duration = movement(:,2)-movement(:,1);
movement(duration < minDuration,:) = [];
duration = movement(:,2)-movement(:,1);







end