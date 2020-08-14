addpath("utils")
r = 0
l = 0
%re = 1
re = 0

EbN0=0
trials = 100
active_user_k = 1
circle_r = 1
%Encoder.m‚Ì’†‚É‚àcircle_r‚ ‚è
dd = 1
  
prop=1  
mvalues=[2]
pvalues=[0]
%disp(mvalues)
%circle_radius(m)


%%add
patches=2^r;

%tester‚Å‚Í•Ï” K : number of messages‚ğ1‚©‚ç‘‚â‚µ‚Ä‚¢‚éB

%%add

for a = 1:size(mvalues, 2) % a : 1 to m
    %{
    disp('a=')
    disp(a)
    %}
    m=mvalues(a);
    
    for b=1:size(pvalues,2)% b:1to5
        p=pvalues(b);
        i=0;
        i_0=i;
        haba=20;
        %{
        disp('m')
        disp(m)
        disp('p')
        disp(p)
        %}
        %%add
        if (re==0)
            B = m*(m+3)/2 + p - 1;
        else
            B = m*(m+1)/2 + p - 1;
        end
        if (r<1)
            B = patches*B;
        else
            B = patches*B - sum(l(2:end));
        end
        %%add
        output=[];
        EbN0_dB=[] ;
        h_dist=[];
        prop=1;
        packet_er_rate = 1;
        
        %while packet_er_rate > 0.00001
        while packet_er_rate < 10
            EbN0_dB=[EbN0_dB, i*dd];
            disp(i*dd)
            %{
            if i == 1
                i=i+1;
                continue;
            end
            %}
            EbN0 = 10^(0.1*i);
            %prop‚Æave_time‚ª”½‘Î‚É‚È‚Á‚Ä‚¢‚½
            [prop, h_dist_dash] = run(r, l, re, m, p, EbN0, active_user_k, trials);
            %{
            disp("prop")
            disp(prop)
            %}
            
            packet_er_rate = 1 - prop;
            
            disp("PER")
            disp(packet_er_rate)
            
            output = [output, packet_er_rate];
            h_dist = [h_dist, h_dist_dash];
            
            %{
            disp(K)
            disp(output)
            disp(time)
            disp(prop)
            %}
            i=i+1;
            %%add
            
            if(i > i_0+(haba*1/dd))
                break
            end
            
            %add
        end
        %output=[output, 0.05];
        %K=[K, i];
        
        filename=strcat("tests/B", num2str(B),'r', num2str(r),'l', num2str(l),'r', num2str(r),'m', num2str(m),'p', num2str(p), 'trials', num2str(trials), 'circle_r', num2str(circle_r), 'K=', num2str(active_user_k))
        save(filename, "i", "output");
    end
end



x=strcat("tests/B", num2str(B),'r', num2str(r),'l', num2str(l),'r', num2str(r),'m', num2str(m),'p', num2str(p), 'trials', num2str(trials))
x(1)
plot(EbN0_dB, output)
xlabel('EbN0(dB)')
ylabel('err')