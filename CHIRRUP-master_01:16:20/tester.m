addpath("utils")
r = 0
l = 0
re = 1

EbN0=5
trials = 5

  
prop=1  
mvalues=[10]
pvalues=[1]
%disp(mvalues)

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
        K=[] ;
        time=[];
        prop=1;

        
        while prop > 0.40
            K=[K, i];
            disp(i)
            %prop��ave_time�����΂ɂȂ��Ă���
            [prop, ave_time] = run(r, l, re, m, p, EbN0, i, trials);
            disp("prop")
            disp(prop)
            output = [output, prop];
            time = [time, ave_time];
            
            %{
            disp(K)
            disp(output)
            disp(time)
            disp(prop)
            %}
            i=i+1;
            %%add
            
            if(i>10)
                break
            end
            
            
            %add
        end
        %output=[output, 0.05];
        %K=[K, i];
        
        filename=strcat("tests/B", num2str(B),'r', num2str(r),'l', num2str(l),'r', num2str(r),'m', num2str(m),'p', num2str(p), 'trials', num2str(trials))
        save(filename, "K", "output", "time");
    end
end



x=strcat("tests/B", num2str(B),'r', num2str(r),'l', num2str(l),'r', num2str(r),'m', num2str(m),'p', num2str(p), 'trials', num2str(trials))
x(1)
plot(K, output)
xlabel('K')
ylabel('prop found')