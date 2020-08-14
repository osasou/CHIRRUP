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
            if (re==0)
                 self.B_patch = m*(m+3)/2 + p - 1;
            else
                %{
                if(p==0)
                    self.B_patch = m*(m+1)/2;
                else
                    self.B_patch = m*(m+1)/2 + p - 1;
                end
                %}
                 self.B_patch = m*(m+1)/2 + p - 1;
            end
            
            if (r<1)
                self.B = self.patches*self.B_patch;
            else
                self.B = self.patches*self.B_patch - sum(l(2:end));
            end
            
            %end means the value of 'r'
            % thesis 'chirrup''s equation p,9
            %2^r*{m*(m+3)/2 + p - 1} - sum(l(2:end))
        end

        function [self,bits] = generate_random_bits(self)
        % generates some random bits to pass into encoder
        % row �s : B(number of bits being encoded)
        % column �� : K(number of messages)
            bits = rand(self.B,self.K) > 0.5;
            %disp("bits")
            %disp(bits)
            % 0 ~ 31��bits
            A = [0:15]
            b = de2bi(A);
            bits = flip(b);
            bits = flip(b, 2);
            bits = bits.';
            %
            %{
            encoder = Encoder(0,0,0,2,0,16,200,NaN)
            [encoder, input_bits] = encoder.generate_random_bits()
            [Y, parity] = encoder.chirrup_encode()
            �Ŋm���߂邱�Ƃ��ł���
            
            encoder = Encoder(0,0,0,2,6,16,200,NaN)
            [encoder, input_bits] = encoder.generate_random_bits()
            [Y, parity] = encoder.chirrup_encode()
            decoder = Decoder(Y,0,0,[],0,2,6,16)
            [output_bits timing_trial] = decoder.chirrup_decode()
            
            encoder = Encoder(0,0,0,2,2,16,200,NaN)
            [encoder, input_bits] = encoder.generate_random_bits()
            [Y, parity] = encoder.chirrup_encode()
            decoder = Decoder(Y,0,0,[],0,2,2,16)
            [output_bits timing_trial] = decoder.chirrup_decode()
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
        %
        % AJT (12/9/18)

            global h_all_real
            parity = [];
            %generate random messages
            % input_bits = rand(B,K)>0.5;
            %tree encoding
            if (self.patches>1) %patch��1�ł�邩��g��Ȃ�
                [patch_bits, parity] = self.tree_encoder();
                patch_bits = permute(patch_bits,[2 1 3]);
                %permute(A,[]):�s��A��[]�̏��Ԃŕ��ёւ���B��̏ꍇ�Apatch_bits(N x K x
                %n)��(K x N x n)�ɕύX�B���]�u����.
            else
                patch_bits = self.input_bits.';
                %disp(self.input_bits)
                %disp(patch_bits)
                % .' : �]�u����.
            end
            flag = false;
            %generate measurements for each patch
            for patch = 1:self.patches
                sigma = sqrt(self.patches*2^self.m/(self.B*self.EbN0));
                [Y{patch}, h_all_real] = self.sim_from_bits(sigma,patch_bits(:,:,patch));
            end
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function [patch_bits, parity] = tree_encoder(self)
        % tree_encoder  Encodes a message into patches using parity check digits
        %
        % input_bits      B x K matrix of the K B-bit messages
        % N               number of bits per patch
        %
        %
        % patch_bits       N x K x n tensor of the K N-bit messages in each patch
        %
        % Regardless of input, zero parity check digits are used for the first
        % patch, and a number of parity check digits is used for the last patch to
        % agree with the total number of bits B. Ensure that B + sum(l) = N x n.
        
        %
        % Code is based on 'A Coupled Compressive Sensing Scheme for Unsourced
        % Multiple Access' by Amalladinne et al. 2018 (arXiv 1806.00138)
            %N=16;
            self.l(1) = 0;
            %l(n) = N*n - size(input_bits,1) - sum(l) + l(n);
            %�������ꂽ
           
            patch_bits(:,:,1) = self.input_bits(1:self.B_patch,:);
            count = self.B_patch;
            for i = 2:self.patches
                patch_bits(1:self.B_patch-self.l(i),:,i) = self.input_bits(count+1:count+self.B_patch-self.l(i),:);
                count = count + N - self.l(i);
                parity{i} = double(rand(self.l(i),count)>0.5);
                patch_bits(self.B_patch-self.l(i)+1:self.B_patch,:,i) = mod(parity{i}*self.input_bits(1:count,:),2);
            end
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function [Y, h_all_real] = sim_from_bits(self,sigma,bits)

        % sim_from_bits  Generates binary chirp measurements�i�傫���j from bits
        % sigma      SD of noise: sigma = sqrt(patches*2^m/(B*EbN0))
        % bits       k x 2^m matrix of bits to encode
        %
        % Y          length-2^m vector of measurements
        %
        % AJT (12/9/18)

        alpha = 1;
        circle_r = 1;
        active_user_num = self.K;
        [x,y] = random_circle(circle_r, active_user_num);
        d_dash = abs(x).^2 + abs(y).^2;
        d = sqrt(d_dash);
            Y = zeros(2^self.m,2^self.p);
            h_all_real=[];
            h_all_img=[];
            %Y��2^p����slots�̊e��M��������Ă���
            
            %p=0�Ȃ̂ŁAzeros(2^m,1)�ƂȂ�
            for k = 1:self.K %the number of active user �ŉ�
                rng('shuffle')
                %{
                disp("bits = input_bits^t")
                disp(bits)
                %}
                %compute slots
                comps = self.compute_slots(bits(k,:));
                %{
                disp("comps")
                disp(comps)
                %}

                %make (P,b) for each slot
                
                
                %�������S���킩��Ȃ����܂�����
                
                bits1 = [0 bits(k,:)]
                [sample_P1,sample_b1] = self.makePb(bits1)
                sample_rm1 = self.gen_chirp(sample_P1,sample_b1)
                
                bits2 = [1 bits(k,:)];
                [sample_P2,sample_b2] = self.makePb(bits2)
                sample_rm2 = self.gen_chirp(sample_P2,sample_b2)
                
                
                %{
                disp("bits1")
                disp(bits1)
                disp("bits2")
                disp(bits2)
                %}
                

%                 [] = self.makePb(bits2)
        
                
                [Pee1,bee1] = self.makePb(bits1);
                %{
                disp("P1:")
                disp(Pee1)
                disp("b1:")
                disp(bee1)
                %}
                
                [Pee2,bee2] = self.makePb(bits2);

                %{
                disp("P2:")
                disp(Pee2)
                disp("b2:")
                disp(bee2)
                %}

                %generate binary chirp vector for each slot
                rm1 = self.gen_chirp(Pee1,bee1);
                rm2 = self.gen_chirp(Pee2,bee2);
                
                %{
                disp("reed-muller1")
                disp(rm1)

                disp("reed-muller2")
                disp(rm2)
                %}
                
                %{
                rm = rm1 + rm2
                
                disp("rm")
                disp(rm)
                %}
                
                %add onto measurement
                %setofcoefs=[1,1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,2];
                %pos = randi(length(setofcoefs));
%                 h_real=rayleigh_rand(1)+1;
%                 h_img=rayleigh_rand(1)+1;
                h_real=rayleigh_rand(1);
                h_img=rayleigh_rand(1);
                
                %h=0.1;
                h_all_real=[h_all_real,h_real];
                h_all_img=[h_all_img,h_img];
                %disp("d")
                %disp(d)
                
                %������comp(1)=comp(2)=1���ƈӖ��Ȃ�
                %Y(:,comps(1)) = Y(:,comps(1))+h*1/(d(k)^alpha)*rm1;                
                Y(:,comps(1)) = Y(:,comps(1))+(h_real+1i*h_img)*1/(d(k)^alpha)*rm1;
                %{
                disp("Y(:,comps(1))")
                disp(Y(:,comps(1)))
                %}
%                 h_real=rayleigh_rand(1)+1;
%                 h_img=rayleigh_rand(1)+1;
                h_real=rayleigh_rand(1);
                h_img=rayleigh_rand(1);
                %h = 0.1;
                h_all_real=[h_all_real,h_real];
                h_all_img=[h_all_img,h_img];
                Y(:,comps(2)) = Y(:,comps(2))+(h_real+1i*h_img)*1/(d(k)^alpha)*rm2;
                %{
                disp("Y(:,comps(2))")
                disp(Y(:,comps(2)))
                %}
         
            end
            %disp("before")
            %disp(Y)

            %add noise (Gaussian for real, Complex Gaussian for complex)
            if (self.re==0)
                %B = repmat(A,n) �́A�s�Ɨ�̎����� A �̃R�s�[�� n �܂ޔz���Ԃ��܂��B
                Y = Y + repmat(sigma*(randn(2^self.m,1)+1i*randn(2^self.m,1)),[1 2^self.p]);
            else
                Y = Y + repmat(sigma*randn(2^self.m,1),[1 2^self.p]);

            end
            %disp("after")
            %disp(Y)
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function comps = compute_slots(self, bits)
            if (self.re==0) %���f��������
                nMuse = self.m*(self.m+1)/2;
            else
                nMuse = self.m*(self.m-1)/2;
            end
            %outofbinary([0 1 1]) �� ans = 3
            %disp("end")
            %disp(bits(end-self.p+1:end)) bits[]�̍Ōォ��|-p+1|�Ԗڂ���Ō�܂ł̔z��
            %(end-self.p+1:end)��
            comps(1) = outofbinary(bits(end-self.p+1:end))+1;
            
            %trans���ĉ��H�H�H�H
            
            trans = bits(nMuse+self.m -1 : -1: nMuse+self.m -self.p ); %nMuse+m-1����nMuse+m-p�܂ŋt(-1)�����Ɏ��o��
            
            if outofbinary(trans)==0
                trans(1) = 1;
            end
            comps(2) = outofbinary(mod(bits(end-self.p+1:end)+trans,2))+1;
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function [P,b] = makePb(self,bits)

        % generates a P and b from a bit string
        %
        % bits      vector of bits
        %
        % P     symettric real matrix
        % b     real vector

            if (self.re==0)
                nMuse = self.m*(self.m+1)/2;
            else
                nMuse = self.m*(self.m-1)/2;
            end
            basis = makeDGC(self.re,self.m);
            Pbits = bits(1:nMuse); %bits[1:3]�̑O����
            %{
            disp("basis")
            disp(basis)
            disp("Pbits")
            disp(Pbits)
            %}
            
            %find(X):�z�� X ���ɂ���X�̔�[���v�f�̐��`�C���f�b�N�X���܂ރx�N�g����Ԃ��܂�
            %k = find(001
            %         100
            %         101)�̏ꍇ�A
            %k = 4*1
            %   2
            %   3
            %   7
            %   9   ���Ԃ�
            %�s��͗�Ō��Ă���
            P = mod( sum(basis(:,:,find(Pbits)),3), 2);
            %sum(A,3):�s��A�̂R�Ԗڂ̎����ɉ����Ęa���v�Z����B�܂�A�s��̑����Z�Ȃ���
            b = bits(nMuse+1:nMuse+self.m);
            % bits[4:6]�̌�딼��
            
            %{
            disp("P")
            disp(P)
            disp("b")
            disp(b)
            %}
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