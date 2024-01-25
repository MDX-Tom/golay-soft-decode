
clear

%% Simulation of Eb/N0(or SNR) vs BER/FER for (24,12) Golay code

k = 12;
rate = 1/2;
n = 24;

eb_n0_dB = 6;
eb_n0 = 10.^(eb_n0_dB/10);
es_n0_dB = eb_n0_dB + 10*log10(rate);
es_n0 = 10.^(es_n0_dB/10);
awgn_sigma = sqrt(1./(2*es_n0)); % bpsk
ber_bpsk_theo = erfc(sqrt(es_n0))./2;
ber_bpsk_uncoded = erfc(sqrt(eb_n0))./2;

frame_counts = 2e7; 
print_frame_interval = frame_counts / 10;

total_info_bits = k * frame_counts;
total_codeword_bits = n * frame_counts;

load("golay_table.mat", "golay_table");
golay_table_bpsk = 2*golay_table - 1; % The codeword table with BPSK modulation

dec2message = zeros(k, 2^k);
for a = 1 : 2^k
    dec2message(:, a) =  double(dec2bin(a-1, k)-48);
end

ber = zeros(length(awgn_sigma), 1);
ber_bpsk = zeros(length(awgn_sigma), 1);
fer = zeros(length(awgn_sigma), 1);

for i_sigma = 1 : length(awgn_sigma)

    sigma = awgn_sigma(i_sigma);
    bit_error_count = 0;
    frame_error_count = 0;

    parfor i_frame = 1 : frame_counts

        dec2message_copy = dec2message;
        golay_table_bpsk_copy = golay_table_bpsk;

        if mod(i_frame, print_frame_interval) == 0
            fprintf("\ti_sigma = %d\tProgress = %d%%\n", i_sigma, i_frame/frame_counts*100);
        end
        
        %% Generate random infobits
        info_bits = randi([0 1], k, 1);
        
        %% Encode
        codeword = golay_encode(info_bits);
        
        %% BPSK modulation
        volt = double(2*codeword - 1);
        
        %% Send through a noisy AWGN channel
        noise = normrnd(0, sigma, size(volt));
        volt = volt + noise;

        %% MAP soft-decision decoding (minimum Euclidean Distance)

        diff = volt - golay_table_bpsk_copy;
        dist = vecnorm(diff); % Euclidean Distance
        [min_dist, min_dist_index] = min(dist);

        % Calculate bit errors
        bit_error_count_this_frame = nnz(dec2message_copy(:, min_dist_index)-info_bits);
        bit_error_count = bit_error_count + bit_error_count_this_frame;
        if bit_error_count_this_frame > 0
            frame_error_count = frame_error_count + 1;
        end

    end % i_frame

    % Calculate BER/FER
    fer(i_sigma) = frame_error_count / frame_counts;
    ber(i_sigma) = bit_error_count / total_info_bits;

end % i_sigma


%% Plot
figure
legend_strs = [];
semilogy(eb_n0_dB, fer, '-*', eb_n0_dB, ber, '-*', eb_n0_dB, ber_bpsk_uncoded, '-*', LineWidth=1.5)
hold on
grid on
legend(["FER", "BER", "BER - BPSK"]);
xlabel("Eb/N0 (dB)")
ylabel("Pe")
title("(24,12) Golay code with MAP soft-decision decoding")
