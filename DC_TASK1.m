
%% Initialization 
N = 10;                     
samples_per_sym = 5;        

bits = randi([0 1], 1, N);
symbols = 2 * bits - 1;

impulses = upsample(symbols, samples_per_sym);

%% Step (d): Transmitted Signal

p = [5 4 3 2 1] / sqrt(55);

y = conv(impulses, p);

y = y(1 : N*samples_per_sym); 

%% Step (e): Receiver Filters

h_mf = fliplr(p);

h_rect = ones(1, samples_per_sym) / sqrt(samples_per_sym);

out_mf = conv(y, h_mf);
out_rect = conv(y, h_rect);

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
% Implement the Correlator 
out_corr = zeros(1, length(y));

for k = 1:N
    
    idx = (k-1)*samples_per_sym + 1 : k*samples_per_sym;

    out_corr(idx) = cumsum(y(idx) .* p);
end

figure('Name', 'Requirement 1b: Matched Filter vs Correlator', 'NumberTitle', 'off');

plot(out_mf(1:length(y)), 'b', 'LineWidth', 1.5);
hold on;
plot(out_corr, 'g--', 'LineWidth', 2);
stem(sampling_instants, out_corr(sampling_instants), 'k', 'filled', 'LineStyle', 'none');

title('Matched Filter vs. Correlator Output');
xlabel('Sample Index (n)');
ylabel('Amplitude');
grid on;
legend('Matched Filter Output', 'Correlator Output', 'Sampling / Dump Instants', 'Location', 'Best');