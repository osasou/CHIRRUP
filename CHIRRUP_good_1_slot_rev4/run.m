
function [propfound, ave_err] = run(re, m, p, EbN0, K, trials)
    addpath('utils');
%master testing function, runs multiple trials, for definitions of
%parameters see the Encoder and Decoder classes

    sumpropfound=0;
    sumerr=0;

    for trial = 1:trials
        [propfound_trial, err_trial] = chirrup_test(re,m,p,K,EbN0,[]);
        sumpropfound=sumpropfound+propfound_trial;
        sumerr=sumerr+err_trial;
    end

    propfound = sumpropfound/trials;
    ave_err = sumerr/trials;

end



function [propfound_trial, err_trial] = chirrup_test(re,m,p,K,EbN0,input_bits)
    %runs a single test
    %;‚ğ‚Â‚¯‚é‚Æˆ—‚ğ‰B‚¹‚é
    
    encoder=Encoder(re,m,p,K,EbN0,input_bits);
    [encoder, input_bits] = encoder.generate_random_bits(); %we update the value of input_bits to save confusion, despite already being encoder.input_bits
    [Y] = encoder.chirrup_encode;
    decoder=Decoder(Y,re,m,p,K);
    [output_bits, err_trial] = decoder.chirrup_decode();
    propfound_trial = compare_bits(input_bits,output_bits);
end
