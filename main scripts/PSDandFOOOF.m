%% PSD and parametrising PSD component

% remove REM SLEEP and non-sleep movement blocks
movNrem=sort([movement;CA1_REM],1);
filtered_PFC_tmp=fragment_delete(localPFC_zeropadding, movNrem);
filtered_PFC_psd(1,:) = bandpass(filtered_PFC_tmp(1,:),[0.1 300],1000);


% PSD calculation using pwelch
[PFC_psd, PFC_freqs] = pwelch(filtered_PFC_psd, 2000,1000, [0.5:0.5:20], 1000)

% plot PSD
figure
plot(PFC_freqs,10*log10(PFC_psd));

% Transpose, to make inputs row vectors
PFC_freqs = PFC_freqs';
PFC_psd = PFC_psd';

% FOOOF functions developed by (Donoghue et al., 2020)
% downloaded from https://github.com/fooof-tools/fooof

% Use default setting
% settings = struct();  

% Or use knee when aperiodic component change drastically
settings.aperiodic_mode='knee'; 
% settings.peak_width_limits=[1,12.0]

f_range = [0.5,20];

% Run FOOOF, also returning the model
fooof_results_PFC = fooof(PFC_freqs, PFC_psd, f_range, settings, true);

% Plot the resulting model
fooof_plot(fooof_results_PFC)


