
%% Golay encode (using codeword table)
% input: message: binary(logical) 12x1 vector
% output: codeword: binary(logical) 24x1 vector

function codeword = golay_encode(message)
    persistent golay_table
    if isempty(golay_table)
        load("golay_table.mat", "golay_table");
    end

    message = int8(message.');
    seq = bin2dec(char(message+48));
    codeword = golay_table(:,seq+1);
end