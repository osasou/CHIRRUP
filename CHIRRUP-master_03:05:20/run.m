
function [propfound, ave_err] = run(r, l, re, m, p, EbN0, K, trials)
    addpath('utils');
%master testing function, runs multiple trials, for definitions of
%parameters see the Encoder and Decoder classes

    params_in=[];
    sumpropfound=0;
    sumerr=0;

    
    for trial = 1:trials
        [propfound_trial, err_trial] = chirrup_test(r,l,re,m,p,K,EbN0,[],params_in);
        sumpropfound=sumpropfound+propfound_trial;
        sumerr=sumerr+err_trial;
    end

    propfound = sumpropfound/trials;
    ave_err = sumerr/trials;

end



function [propfound_trial, err_trial] = chirrup_test(r,l,re,m,p,K,EbN0,input_bits,params_in)
    %runs a single test
    %;‚ğ‚Â‚¯‚é‚Æˆ—‚ğ‰B‚¹‚é
    
    encoder=Encoder(r,l,re,m,p,K,EbN0,input_bits);
    [encoder, input_bits] = encoder.generate_random_bits(); %we update the value of input_bits to save confusion, despite already being encoder.input_bits
    [Y, parity] = encoder.chirrup_encode;
    decoder=Decoder(Y,r,l,parity,re,m,p,K,params_in);
    [output_bits, err_trial] = decoder.chirrup_decode();
    propfound_trial = compare_bits(input_bits,output_bits);
end
