
%% 1. Initialization
N = 100;                   
samples_per_sym = 8;        

bits = randi([0 1], 1, N);
symbols = 2 * bits - 1;

impulses = upsample(symbols, samples_per_sym);

%% 2. Define the 4 Test Cases [Roll-off (R), Delay]

cases = [0, 2; 0, 8; 1, 2; 1, 8];
titles = {'Case a: R=0, Delay=2', 'Case b: R=0, Delay=8', ...
          'Case c: R=1, Delay=2', 'Case d: R=1, Delay=8'};

%% 3. Simulation and Eye Diagram Generation
for i = 1:4
    R = cases(i, 1);
    delay = cases(i, 2);
    

    h_srrc = rcosdesign(R, delay*2, samples_per_sym, 'sqrt');
    
    % --- Point A: Transmitter Output ---

    sig_A = conv(impulses, h_srrc);
    
    % --- Point B: Receiver Output ---

    sig_B = conv(sig_A, h_srrc);
    
    % --- Plotting Eye Diagrams ---
    
    % Eye Diagram at Point A (Tx Output)
    eyediagram(sig_A, 2*samples_per_sym);
    set(gcf, 'Name', [titles{i} ' - Point A (Tx Output)'], 'NumberTitle', 'off');
    title([titles{i} ' - Point A (Tx Output)']);
    
    % Eye Diagram at Point B (Rx Output)
    eyediagram(sig_B, 2*samples_per_sym);
    set(gcf, 'Name', [titles{i} ' - Point B (Rx Output)'], 'NumberTitle', 'off');
    title([titles{i} ' - Point B (Rx Output)']);
end