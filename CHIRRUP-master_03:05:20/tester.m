addpath("utils")
r = 0
l = 0
re = 1

EbN0=0
trials = 10
active_user_k = 3
circle_r = 1
%Encoder.m�̒��ɂ�circle_r����
dd = 1
  
prop=1  
mvalues=[6]
pvalues=[6]
%disp(mvalues)
%circle_radius(m)


%%add
patches=2^r;

%tester�ł͕ϐ� K : number of messages��1���瑝�₵�Ă���B

%%add

for a = 1:size(mvalues, 2) % a : 1 to m
    %{
    disp('a=')
    disp(a)
    %}
    m=mvalues(a);
    
    for b=1:size(pvalues,2)% b:1to5
        p=pvalues(b);
        i=1;
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
        err=[];
        prop=1;
        packet_er_rate = 1;
        
        while packet_er_rate > 0.05
            EbN0_dB=[EbN0_dB, i*dd];
            disp(i*dd)
            %{
            if i == 1
                i=i+1;
                continue;
            end
            %}
            EbN0 = 10^(0.1*i);
            %prop��ave_time�����΂ɂȂ��Ă���
            [prop, ave_err] = run(r, l, re, m, p, EbN0, active_user_k, trials);
            %{
            disp("prop")
            disp(prop)
            %}
            
            packet_er_rate = 1 - prop;
            
            disp("PER")
            disp(packet_er_rate)
            
            output = [output, packet_er_rate];
            err = [err, ave_err];
            
            %{
            disp(K)
            disp(output)
            disp(time)
            disp(prop)
            %}
            i=i+1;
            %%add
            
            if(i>20*1/dd)
                break
            end
            
            
            %add
        end
        %output=[output, 0.05];
        %K=[K, i];
        
        filename=strcat("tests/B", num2str(B),'r', num2str(r),'l', num2str(l),'r', num2str(r),'m', num2str(m),'p', num2str(p), 'trials', num2str(trials), 'circle_r', num2str(circle_r), 'K=', num2str(active_user_k))
        save(filename, "K", "output", "err");
    end
end



x=strcat("tests/B", num2str(B),'r', num2str(r),'l', num2str(l),'r', num2str(r),'m', num2str(m),'p', num2str(p), 'trials', num2str(trials))
x(1)
plot(EbN0_dB, output)
xlabel('EbN0(dB)')
ylabel('err')