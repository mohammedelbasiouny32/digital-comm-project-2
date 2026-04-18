% --- Introduction to Communications: Project 3 ---
% --- Requirement 1: Noise-Free Environment ---

%% Initialization & Step (a) to (c)
N = 10;                     % Number of bits
samples_per_sym = 5;        % 5 samples per symbol (200 ms spacing for Ts = 1s)

% a) Generate 10 random bits and b) Convert to polar (+1, -1)
bits = randi([0 1], 1, N);
symbols = 2 * bits - 1;

% c) Generate an impulse train (upsample inserts n-1 zeros between elements)
impulses = upsample(symbols, samples_per_sym);

%% Step (d): Transmitted Signal
% Define the normalized discrete pulse shape p[n]
p = [5 4 3 2 1] / sqrt(55);

% Convolve impulse train with pulse shape to get transmitted signal y[n]
y = conv(impulses, p);
% Truncate y[n] to N*samples_per_sym to remove the zero-tail from convolution
y = y(1 : N*samples_per_sym); 

%% Step (e): Receiver Filters
% i. Matched filter to p[n] (time-reversed)
h_mf = fliplr(p);

% ii. Rectangular filter (sampled and energy-normalized)
% The continuous pulse is 1 for duration Ts. Sampled 5 times, it's an array of ones.
h_rect = ones(1, samples_per_sym) / sqrt(samples_per_sym);

% Pass the signal y[n] through both filters
out_mf = conv(y, h_mf);
out_rect = conv(y, h_rect);

% Define sampling instants. Because the filters are causal and length 5, 
% the convolution peak for each symbol occurs at the end of its 5-sample window.
sampling_instants = samples_per_sym : samples_per_sym : (N * samples_per_sym);


%% --- Requirement 1a: Plot Outputs of Both Filters ---
figure('Name', 'Requirement 1a: Filter Outputs', 'NumberTitle', 'off');

% Subplot 1: Matched Filter
subplot(2, 1, 1);
plot(out_mf, 'b', 'LineWidth', 1.5);
hold on;
stem(sampling_instants, out_mf(sampling_instants), 'k', 'filled', 'LineStyle', 'none');
title('Output of Matched Filter (h(t) = p(Ts - t))');
xlabel('Sample Index (n)');
ylabel('Amplitude');
grid on;
legend('Matched Filter Output', 'Sampling Instants');

% Subplot 2: Rectangular Filter
subplot(2, 1, 2);
plot(out_rect, 'r', 'LineWidth', 1.5);
hold on;
stem(sampling_instants, out_rect(sampling_instants), 'k', 'filled', 'LineStyle', 'none');
title('Output of Rectangular Filter');
xlabel('Sample Index (n)');
ylabel('Amplitude');
grid on;
legend('Rect Filter Output', 'Sampling Instants');


%% --- Requirement 1b: Matched Filter vs Correlator ---
% Implement the Correlator (Integrate and Dump)
out_corr = zeros(1, length(y));

for k = 1:N
    % Define the discrete time window for the current symbol
    idx = (k-1)*samples_per_sym + 1 : k*samples_per_sym;
    
    % Multiply received signal window by the local pulse p[n] and integrate (cumsum)
    out_corr(idx) = cumsum(y(idx) .* p);
end

figure('Name', 'Requirement 1b: Matched Filter vs Correlator', 'NumberTitle', 'off');

% Note: We plot only the first N*samples_per_sym of the matched filter output 
% to align perfectly with the correlator's running time index.
plot(out_mf(1:length(y)), 'b', 'LineWidth', 1.5);
hold on;
plot(out_corr, 'g--', 'LineWidth', 2);
stem(sampling_instants, out_corr(sampling_instants), 'k', 'filled', 'LineStyle', 'none');

title('Matched Filter vs. Correlator Output');
xlabel('Sample Index (n)');
ylabel('Amplitude');
grid on;
legend('Matched Filter Output', 'Correlator Output', 'Sampling / Dump Instants', 'Location', 'Best');