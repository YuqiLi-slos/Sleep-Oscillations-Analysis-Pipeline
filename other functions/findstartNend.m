%% find the start and end of NaN/not NaN

function [start_idx, end_idx]=findstartNend(localPFC_noSWS_NAN,st)
% example array
if st==("findnan")
    arr = isnan(localPFC_noSWS_NAN);
elseif st==("findsignal")
    arr = ~isnan(localPFC_noSWS_NAN);
end

% calculate the difference between consecutive elements
diff_arr = diff(arr);

% find the indices where the difference is equal to 1
start_idx = find(diff_arr == 1) + 1; % add 1 because of the zero padding from diff function
end_idx = find(diff_arr == -1);

% handle special cases where first or last element is 1
if arr(1) == 1
    start_idx = [1 start_idx];
end
if arr(end) == 1
    end_idx = [end_idx length(arr)];
end
end
