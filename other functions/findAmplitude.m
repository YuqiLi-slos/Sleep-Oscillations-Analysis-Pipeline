function mean_power=findAmplitude(filtered_data, timestamps)

average_power=[];

start_idx=timestamps(:,1);
end_idx=timestamps(:,2);
mean_power=[];
for i = 1:size(start_idx,1)
signal=filtered_data(1,start_idx(i):end_idx(i));
abs_signal=abs(signal);
mean_power=[mean_power; mean(abs_signal)];

end
end

