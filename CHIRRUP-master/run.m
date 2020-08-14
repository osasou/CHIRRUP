
function [propfound, ave_err] = run(r, l, re, m, p, EbN0, K, trials)
    addpath('utils');
%master testing function, runs multiple trials, for definitions of
%parameters see the Encoder and Decoder classes

    params_in=[];
    sumpropfound=0;
    h_dist=0;

    
    for trial = 1:trials
        [propfound_trial, h_dist] = chirrup_test(r,l,re,m,p,K,EbN0,[]);
        sumpropfound=sumpropfound+propfound_trial;
        h_dist=h_dist+h_dist;
    end

    propfound = sumpropfound/trials;
    ave_err = h_dist/trials;

end



function [propfound_trial, h_dist] = chirrup_test(r,l,re,m,p,K,EbN0,input_bits)
    %runs a single test
    %;‚ğ‚Â‚¯‚é‚Æˆ—‚ğ‰B‚¹‚é
    
    encoder=Encoder(r,l,re,m,p,K,EbN0,input_bits);
    [encoder, input_bits] = encoder.generate_random_bits(); %we update the value of input_bits to save confusion, despite already being encoder.input_bits
    [Y, parity, h_all] = encoder.chirrup_encode;
    decoder=my_Decoder(Y,r,l,parity,re,m,p,K);
    [output_bits] = decoder.my_chirrup_decode();
    propfound_trial = compare_bits(input_bits,output_bits)
%     h_dist = distance_h(h_all, h_hat);
    h_dist = 1;
end
