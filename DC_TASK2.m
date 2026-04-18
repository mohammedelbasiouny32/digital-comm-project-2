% --- Introduction to Communications: Project 3 ---
% --- Requirement 2: Noise Analysis & BER ---

%% 1. Initialization and Signal Generation
N = 10000;                  % a- Generate 10000 bits
samples_per_sym = 5;        % 5 samples per symbol

% Generate bits and map to polar signaling (+1, -1)
bits = randi([0 1], 1, N);
symbols = 2 * bits - 1;

% Upsample and convolve with the normalized pulse shape
impulses = upsample(symbols, samples_per_sym);
p = [5 4 3 2 1] / sqrt(55);
y = conv(impulses, p);
y = y(1 : N*samples_per_sym); % Truncate convolution tail

%% 2. Define Receiver Filters
% Matched Filter
h_mf = fliplr(p);
% Rectangular Filter (sampled and energy-normalized)
h_rect = ones(1, samples_per_sym) / sqrt(samples_per_sym);

%% 3. Noise Analysis Setup
% Since the pulse p[n] is energy-normalized to 1, and symbols are +/- 1, 
% the Energy per bit (Eb) is exactly 1.
Eb = 1; 

% Define the sweep range for Eb/N0 in dB
EbN0_dB = -2:1:5;

% Pre-allocate arrays for Bit Error Rates
BER_mf = zeros(size(EbN0_dB));
BER_rect = zeros(size(EbN0_dB));
BER_th = zeros(size(EbN0_dB));

%% 4. Monte Carlo Simulation Loop
for k = 1:length(EbN0_dB)
    
    % Convert Eb/N0 from dB to linear scale
    EbN0_lin = 10^(EbN0_dB(k) / 10);
    
    % Calculate N0 based on the linear Eb/N0 ratio
    N0 = Eb / EbN0_lin;
    
    % c- Scale the noise sequence to have variance = N0/2
    noise_variance = N0 / 2;
    
    % b- Generate zero-mean AWGN and scale it
    n_noise = sqrt(noise_variance) * randn(1, length(y));
    
    % d- Add noise to transmitted sequence
    v = y + n_noise;
    
    % Pass the noisy signal through both filters
    out_mf = conv(v, h_mf);
    out_rect = conv(v, h_rect);
    
    % Sample the output at the optimum instants
    sampling_instants = samples_per_sym : samples_per_sym : (N * samples_per_sym);
    sampled_mf = out_mf(sampling_instants);
    sampled_rect = out_rect(sampling_instants);
    
    % Decision Device: > 0 means bit 1, <= 0 means bit 0
    detected_bits_mf = (sampled_mf > 0);
    detected_bits_rect = (sampled_rect > 0);
    
    % Calculate the probability of error (BER) for this Eb/N0 step
    BER_mf(k) = sum(detected_bits_mf ~= bits) / N;
    BER_rect(k) = sum(detected_bits_rect ~= bits) / N;
    
    % Calculate Theoretical BER
    BER_th(k) = 0.5 * erfc(sqrt(EbN0_lin));
end

%% 5. Plotting Requirement 2
figure('Name', 'Requirement 2: BER Performance', 'NumberTitle', 'off');

% Using semilogy because BER plots span multiple orders of magnitude
semilogy(EbN0_dB, BER_th, 'k-', 'LineWidth', 2);
hold on;
semilogy(EbN0_dB, BER_mf, 'bo-', 'LineWidth', 1.5, 'MarkerSize', 6);
semilogy(EbN0_dB, BER_rect, 'rx-', 'LineWidth', 1.5, 'MarkerSize', 6);

title('BER vs E_b/N_0 for Binary PAM Signaling');
xlabel('E_b/N_0 (dB)');
ylabel('Bit Error Rate (BER)');
grid on;
legend('Theoretical BER', 'Matched Filter BER', 'Rectangular Filter BER', 'Location', 'SouthWest');