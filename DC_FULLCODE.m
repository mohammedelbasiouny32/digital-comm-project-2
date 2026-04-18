% =========================================================================
% --- Digital Communication ---
% --- Project 3: Matched Filters, Correlators, ISI, and Raised Cosine ---
% =========================================================================

clc;
clear;
close all;

%% ========================================================================
% --- REQUIREMENT 1: Matched filters and correlators (Noise-Free) ---
% =========================================================================
disp('Running Requirement 1: Noise-Free Environment...');

N_req1 = 10;                     % Number of bits
samples_per_sym_req1 = 5;        % 5 samples per symbol (200 ms spacing for Ts = 1s)

% a) Generate 10 random bits and b) Convert to polar (+1, -1)
bits_req1 = randi([0 1], 1, N_req1);
symbols_req1 = 2 * bits_req1 - 1;

% c) Generate an impulse train
impulses_req1 = upsample(symbols_req1, samples_per_sym_req1);

% d) Transmitted Signal
p = [5 4 3 2 1] / sqrt(55);      % Normalized discrete pulse shape
y_req1 = conv(impulses_req1, p);
y_req1 = y_req1(1 : N_req1*samples_per_sym_req1); % Truncate tail

% e) Receiver Filters
h_mf = fliplr(p);                % Matched filter
h_rect = ones(1, samples_per_sym_req1) / sqrt(samples_per_sym_req1); % Rectangular filter

out_mf_req1 = conv(y_req1, h_mf);
out_rect_req1 = conv(y_req1, h_rect);
sampling_instants_req1 = samples_per_sym_req1 : samples_per_sym_req1 : (N_req1 * samples_per_sym_req1);

% --- Plot Requirement 1a ---
figure('Name', 'Requirement 1a: Filter Outputs', 'NumberTitle', 'off');
subplot(2, 1, 1);
plot(out_mf_req1, 'b', 'LineWidth', 1.5); hold on;
stem(sampling_instants_req1, out_mf_req1(sampling_instants_req1), 'k', 'filled', 'LineStyle', 'none');
title('Output of Matched Filter'); grid on; legend('Matched Filter Output', 'Sampling Instants');

subplot(2, 1, 2);
plot(out_rect_req1, 'r', 'LineWidth', 1.5); hold on;
stem(sampling_instants_req1, out_rect_req1(sampling_instants_req1), 'k', 'filled', 'LineStyle', 'none');
title('Output of Rectangular Filter'); grid on; legend('Rect Filter Output', 'Sampling Instants');

% --- Requirement 1b: Correlator ---
out_corr = zeros(1, length(y_req1));
for k = 1:N_req1
    idx = (k-1)*samples_per_sym_req1 + 1 : k*samples_per_sym_req1;
    out_corr(idx) = cumsum(y_req1(idx) .* p);
end

figure('Name', 'Requirement 1b: Matched Filter vs Correlator', 'NumberTitle', 'off');
plot(out_mf_req1(1:length(y_req1)), 'b', 'LineWidth', 1.5); hold on;
plot(out_corr, 'g--', 'LineWidth', 2);
stem(sampling_instants_req1, out_corr(sampling_instants_req1), 'k', 'filled', 'LineStyle', 'none');
title('Matched Filter vs. Correlator Output'); grid on;
legend('Matched Filter', 'Correlator', 'Sampling Instants', 'Location', 'Best');


%% ========================================================================
% --- REQUIREMENT 2: Noise Analysis & BER ---
% =========================================================================
disp('Running Requirement 2: Noise Analysis...');

N_req2 = 10000;                  % Generate 10000 bits
samples_per_sym_req2 = 5;        % 5 samples per symbol

% Generate bits and sequence
bits_req2 = randi([0 1], 1, N_req2);
symbols_req2 = 2 * bits_req2 - 1;
impulses_req2 = upsample(symbols_req2, samples_per_sym_req2);

y_req2 = conv(impulses_req2, p);
y_req2 = y_req2(1 : N_req2*samples_per_sym_req2); 

% Setup Noise Analysis
Eb = 1; 
EbN0_dB = -2:1:5;
BER_mf = zeros(size(EbN0_dB));
BER_rect = zeros(size(EbN0_dB));
BER_th = zeros(size(EbN0_dB));

% Monte Carlo Loop
for k = 1:length(EbN0_dB)
    EbN0_lin = 10^(EbN0_dB(k) / 10);
    N0 = Eb / EbN0_lin;
    noise_variance = N0 / 2;
    
    n_noise = sqrt(noise_variance) * randn(1, length(y_req2));
    v = y_req2 + n_noise;
    
    out_mf_req2 = conv(v, h_mf);
    out_rect_req2 = conv(v, h_rect);
    
    sampling_instants_req2 = samples_per_sym_req2 : samples_per_sym_req2 : (N_req2 * samples_per_sym_req2);
    sampled_mf = out_mf_req2(sampling_instants_req2);
    sampled_rect = out_rect_req2(sampling_instants_req2);
    
    detected_bits_mf = (sampled_mf > 0);
    detected_bits_rect = (sampled_rect > 0);
    
    BER_mf(k) = sum(detected_bits_mf ~= bits_req2) / N_req2;
    BER_rect(k) = sum(detected_bits_rect ~= bits_req2) / N_req2;
    BER_th(k) = 0.5 * erfc(sqrt(EbN0_lin));
end

% --- Plot Requirement 2 ---
figure('Name', 'Requirement 2: BER Performance', 'NumberTitle', 'off');
semilogy(EbN0_dB, BER_th, 'k-', 'LineWidth', 2); hold on;
semilogy(EbN0_dB, BER_mf, 'bo-', 'LineWidth', 1.5, 'MarkerSize', 6);
semilogy(EbN0_dB, BER_rect, 'rx-', 'LineWidth', 1.5, 'MarkerSize', 6);
title('BER vs E_b/N_0 for Binary PAM Signaling');
xlabel('E_b/N_0 (dB)'); ylabel('Bit Error Rate (BER)'); grid on;
legend('Theoretical BER', 'Matched Filter BER', 'Rectangular Filter BER', 'Location', 'SouthWest');


%% ========================================================================
% --- REQUIREMENT 3: ISI and Raised Cosine Filters ---
% =========================================================================
disp('Running Requirement 3: Eye Diagrams (This may generate several windows)...');

N_req3 = 100;                    % Number of data bits
samples_per_sym_req3 = 8;        % Oversampling factor

bits_req3 = randi([0 1], 1, N_req3);
symbols_req3 = 2 * bits_req3 - 1;
impulses_req3 = upsample(symbols_req3, samples_per_sym_req3);

cases = [0, 2; 0, 8; 1, 2; 1, 8];
titles = {'Case a: R=0, Delay=2', 'Case b: R=0, Delay=8', ...
          'Case c: R=1, Delay=2', 'Case d: R=1, Delay=8'};

for i = 1:4
    R = cases(i, 1);
    delay = cases(i, 2);
    
    % SRRC filter (using rcosdesign)
    h_srrc = rcosdesign(R, delay*2, samples_per_sym_req3, 'sqrt');
    
    % Point A: Tx Output
    sig_A = conv(impulses_req3, h_srrc);
    
    % Point B: Rx Output
    sig_B = conv(sig_A, h_srrc);
    
    % Plot Eye Diagram at Point A
    eyediagram(sig_A, 2*samples_per_sym_req3);
    set(gcf, 'Name', [titles{i} ' - Point A (Tx Output)'], 'NumberTitle', 'off');
    title([titles{i} ' - Point A (Tx Output)']);
    
    % Plot Eye Diagram at Point B
    eyediagram(sig_B, 2*samples_per_sym_req3);
    set(gcf, 'Name', [titles{i} ' - Point B (Rx Output)'], 'NumberTitle', 'off');
    title([titles{i} ' - Point B (Rx Output)']);
end

disp('Simulation Complete!');