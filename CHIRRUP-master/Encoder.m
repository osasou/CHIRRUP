classdef Encoder
%Class responsible for encoding chirps - contains all functons pertaining to encoding
    properties
        r               % 0, 1 or 2; 2^r patches
        l               % length-2^r vector of parity check digits, recommend: r=0: l=0, r=1: l=[0 15], r=2: l = [0 10 10 15]
        re              % logical: false(0)=complex chirps, true(1)=real chirps
        m               % size of chirp code (2^m is length of codewords in each slot), recommend m = 6, 7 or 8
        p               % 2^p slots require p<=(m-r)(m-r+3)/2-1 for complex
                        % p<=(m-r)(m-r+1)/2-1 for real
        K               % number of messages
        EbN0            % energy-per-bit (Eb/N0)
        input_bits      % raw input bitstring
        B               % number of bits being encoded
        patches         % number of patches
        B_patch         % number of bits per patch
    end

    methods
        function self = Encoder(r,l,re,m,p,K,EbN0,input_bits)
            addpath('utils');
            self.r = r;
            self.l = l;
            self.re = re;
            self.m = m;
            self.p = p;
            self.K = K;
            self.EbN0 = EbN0;
            self.input_bits = input_bits;
            self.patches=2^r;
            
            self.B_patch = m*(m+3)/2 + p;
            
            self.B = self.patches*self.B_patch;
            %end means the value of 'r'
        end

        function [self,bits] = generate_random_bits(self)
        % generates some random bits to pass into encoder
        % row 行 : B(number of bits being encoded)
        % column 列 : K(number of messages)
            bits = rand(self.B,self.K) > 0.5;
            %disp("bits")
            %disp(bits)
            % 0 ~ 15のbits
%              A = [0:15]
%              b = de2bi(A);
%              bits = flip(b);
%              bits = flip(b, 2);
%              bits = bits.';
%{
            encoder = Encoder(0,0,0,2,2,16,200,NaN)
            [encoder, input_bits] = encoder.generate_random_bits()
            [Y, parity] = encoder.chirrup_encode()
            decoder = Decoder(Y,0,0,[],0,2,2,16)
            [output_bits timing_trial] = decoder.chirrup_decode()
            で確かめることができる
            %}
            self.input_bits=bits;
        end


        function [Y ,parity, h_all_real] = chirrup_encode(self)

        %chirrup_encode  Generates K random messages and performs CHIRRUP encoding
        %
        % Y            Y{p} is a 2^m x 2^p matrix of measurements for patch p
        % input_bits   B x K matrix of the K B-bit messages
        % parity       parity check codes generated in the tree encoding
        %
        % No. of messages is B = 2^r*[(m-r-p)(m-r-p+3)/2+p-1]-sum(l)  for complex
        %                          B = 2^r*[(m-r-p)(m-r-p+1)/2+p-1)-sum(l) for real

            global h_all_real
            parity = [];
            patch_bits = self.input_bits.';
            flag = false;
            %generate measurements for each patch
            for patch = 1:self.patches
                sigma = sqrt(self.patches*2^self.m/(self.B*self.EbN0));
                [Y{patch}, h_all_real] = self.sim_from_bits(sigma,patch_bits(:,:,patch));
            end
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function [Y, h_all_real] = sim_from_bits(self,sigma,bits)

        % sim_from_bits  Generates binary chirp measurements（大きさ） from bits
        % sigma      SD of noise: sigma = sqrt(patches*2^m/(B*EbN0))
        % bits       k x 2^m matrix of bits to encode
        %
        % Y          length-2^m vector of measurements
        %

        alpha = 1;
        circle_r = 1;
        active_user_num = self.K;
        [x,y] = random_circle(circle_r, active_user_num);
        d_dash = abs(x).^2 + abs(y).^2;
        d = sqrt(d_dash);
            Y = zeros(2^self.m,2^self.p);
            h_all_real=[];
            h_all_img=[];
            for slot_num = 1:2^self.p
                for k = 1:self.K %the number of active user で回す
                    rng('shuffle')

                    %make (P,b) for each slot
                    bits1 = [bits(k,:)]
                    [P1,b1] = self.makePb(bits1)
                    rm1 = self.gen_chirp(P1,b1)

%                     h_real=rayleigh_rand(1);
%                     h_img=rayleigh_rand(1);
%                     h=0.1;
                    h_real = 1;
                    h_all_real=[h_all_real,h_real];

%                     h_real*rm_real + h_img*rm_img
%                     h*(rm)
%                     Y(:,slot_num) = Y(:,slot_num)+(h_real+1i*h_img)*1/(d(k)^alpha)*rm1;
                    Y(:, slot_num) = rm1;
                end
                if (self.re==0)
                    %add noise (Gaussian for real, Complex Gaussian for complex)
                    %B = repmat(A,n) は、行と列の次元に A のコピーを n 個含む配列を返します。
                    sigma = 0.0;
                    Y(:,slot_num) = Y(:,slot_num) + repmat(sigma*(randn(2^self.m,1)+1i*randn(2^self.m,1)), 1)
                else
                    Y(:,slot_num) = Y(:,slot_num) + repmat(sigma*randn(2^self.m,1), [1 2^self.p]);
                end
            end
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function [P,b] = makePb(self,bits)

        % generates a P and b from a bit string

            if (self.re==0)
                nMuse = self.m*(self.m+1)/2;
            else
                nMuse = self.m*(self.m-1)/2;
            end
            basis = makeDGC(self.re,self.m);
            Pbits = bits(1:nMuse); %bits[1:3]の前半分
           
            P = mod( sum(basis(:,:,find(Pbits)),3), 2);
            b = bits(nMuse+1:nMuse+self.m);
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end

    methods(Static)
            function rm = gen_chirp(P,b)
            % generates a read-muller code from an input P and b
                M = length(b);
                rm = zeros(2^M,1);
                a = zeros(M,1);
                for q = 1:2^M
                    sum1 = a'*P*a;
                    sum2 = b*a;
                    rm(q) = i^sum1 * (-1)^sum2;
                    % next a
                    for ix = M:-1:1
                        if a(ix)==1
                            a(ix)=0;
                        else
                            a(ix)=1;
                            break;
                        end
                    end
                end
            end
    end
end