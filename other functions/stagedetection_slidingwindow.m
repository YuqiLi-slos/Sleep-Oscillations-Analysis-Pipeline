function [stage,window_list,mean_total,std_total]=stagedetection_slidingwindow(filtered_PFC_SWS,...
                                                       fil_localPFC_zeropadding,...
                                                       localPFC_NAN,...
                                                       coef,thre,plot_display,...
                                                       windowSize,...
                                                       localPFC_zeropadding,...
                                                       mean_total,std_total)

%default sampling frequency is 1000 Hz, window 500 is 0.5 s
win =500;

st=("findsignal");

[signalstart, signalend]=findstartNend(localPFC_NAN,st);
signal=filtered_PFC_SWS(1,:);
signal_abs = abs(signal);

%normalised_signal=zscore(signal_abs);

if (~exist('mean_total', 'var')) 
        mean_total = mean(signal_abs);
        std_total = std(signal_abs);
end



signal_abs_zeropadding=abs(fil_localPFC_zeropadding);


mean_signal = [];
std_signal = [];
mini_stage = [];

%detection threshold: 10 seconds
%windowSize = 10000;

window_list = [];

% res array -> save indices 
stage = [];


for i = 1:length(signalstart)
    start_idx = signalstart(i);
    end_idx = signalend(i);
    remainingData = end_idx - start_idx;
    
    if remainingData > windowSize
       
        nWindows = ceil((end_idx - start_idx + 1) / windowSize);
        counter = 0;
        
        if mod(remainingData,windowSize) <= (windowSize/2)
            for j = 1:nWindows-2
                counter = 0;
                window_list_start = start_idx;
                for k = 1:windowSize/win%per sec
                    tmp_mean = mean(signal_abs_zeropadding(start_idx:start_idx+win-1));
                    tmp_std = std(signal_abs_zeropadding(start_idx:start_idx+win-1));
                    mean_signal= [mean_signal tmp_mean];
                    std_signal= [std_signal tmp_std];


                    if tmp_mean > mean_total + coef*std_total
                        mini_stage = [mini_stage; start_idx start_idx+win-1];
                        counter = counter+1;
                    end

                    start_idx = start_idx+win;
                 
                end
                window_list = [window_list; window_list_start start_idx-1];
                 % check counter 
                if counter >= thre*windowSize/win
                    tmp_start = signalstart(i)+(j-1)*windowSize;
                    tmp_end = tmp_start + windowSize -1;
                    stage = [stage; tmp_start tmp_end];
                end
            end
            counter = 0;
            tmp_start = start_idx;
            tmp_end = end_idx;
            n_subwin = ceil(((end_idx-start_idx)+1)/win);
            
            window_list = [window_list; tmp_start tmp_end];

            for k = 1:n_subwin
                if k == n_subwin
                    tmp_mean = mean(signal_abs_zeropadding(tmp_start:end_idx));
                    tmp_std = std(signal_abs_zeropadding(tmp_start:end_idx));
                    mean_signal= [mean_signal tmp_mean];
                    std_signal= [std_signal tmp_std];


                    if tmp_mean > mean_total + coef*std_total
                        mini_stage = [mini_stage; tmp_start end_idx];
                        counter = counter+1;
                    end
                    
                else
                    tmp_mean = mean(signal_abs_zeropadding(tmp_start:tmp_start+win-1));
                    tmp_std = std(signal_abs_zeropadding(tmp_start:tmp_start+win-1));
                    mean_signal= [mean_signal tmp_mean];
                    std_signal= [std_signal tmp_std];


                    if tmp_mean > mean_total + coef*std_total
                        mini_stage = [mini_stage; tmp_start tmp_start+win-1];
                        counter = counter+1;
                    end
                end
                
                tmp_start = tmp_start + win;
            end
            if counter >= thre*floor((end_idx-start_idx)/win)
                    stage = [stage; start_idx end_idx];
            end          
        else
            %%% case if more than 0.5 sec left -> new window
            for j = 1:nWindows-1
                counter = 0;
                window_list_start = start_idx;
                for k = 1:windowSize/win
                    tmp_mean = mean(signal_abs_zeropadding(start_idx:start_idx+win-1));
                    tmp_std = std(signal_abs_zeropadding(start_idx:start_idx+win-1));
                    mean_signal= [mean_signal tmp_mean];
                    std_signal= [std_signal tmp_std];


                    if tmp_mean > mean_total + coef*std_total
                        mini_stage = [mini_stage; start_idx start_idx+win-1];
                        counter = counter+1;
                    end

                    start_idx = start_idx+win;
                 
                end
                window_list = [window_list; window_list_start start_idx-1];
                 % check counter 
                if counter >= thre*windowSize/win
                    tmp_start = signalstart(i)+(j-1)*windowSize;
                    tmp_end = tmp_start + windowSize -1;
                    stage = [stage; tmp_start tmp_end];
                end
            end
            counter = 0;
            tmp_start = start_idx;
            tmp_end = end_idx;
            n_subwin = ceil(((end_idx-start_idx)+1)/win);
            
            window_list = [window_list; tmp_start tmp_end];
            
            for k = 1:n_subwin
                if k == n_subwin
                    tmp_mean = mean(signal_abs_zeropadding(tmp_start:end_idx));
                    tmp_std = std(signal_abs_zeropadding(tmp_start:end_idx));
                    mean_signal= [mean_signal tmp_mean];
                    std_signal= [std_signal tmp_std];


                    if tmp_mean >mean_total + coef*std_total
                        mini_stage = [mini_stage; tmp_start end_idx];
                        counter = counter+1;
                    end
                    
                else
                    tmp_mean = mean(signal_abs_zeropadding(tmp_start:tmp_start+win-1));
                    tmp_std = std(signal_abs_zeropadding(tmp_start:tmp_start+win-1));
                    mean_signal= [mean_signal tmp_mean];
                    std_signal= [std_signal tmp_std];


                    if tmp_mean >mean_total + coef*std_total
                        mini_stage = [mini_stage; tmp_start tmp_start+win-1];
                        counter = counter+1;
                    end
                end
                
                tmp_start = tmp_start + win;
            end
            if counter >= thre*floor((end_idx-start_idx)/win)
                    stage = [stage; start_idx end_idx];
            end
        end
        
       
        
    end
end






if plot_display==("True")

            
           
            time = 1:length(signal_abs_zeropadding);            
            ax(1) = subplot(3,1,1);
            plot(time,localPFC_zeropadding)
           
            hold on;
            xline(stage(:,1), 'r')
            xline(stage(:,2), 'b--'); hold off;
            

end

disp"done"
            
end
