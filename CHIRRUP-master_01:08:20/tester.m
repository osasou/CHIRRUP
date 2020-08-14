addpath("utils")
r = 0
l = 0
%re = 1
re = 1

EbN0=20
trials = 10

  
prop=1  
mvalues=[6]
pvalues=[5]

%%add
patches=2^r;

%tester�ł͕ϐ� K : number of messages��1���瑝�₵�Ă���B

%%add

for a = 1:size(mvalues, 2) % a:1to6
    disp('a=')
    disp(a)
    m=mvalues(a);
    
    for b=1:size(pvalues,2)% b:1to5
        p=pvalues(b);
        i=1;
        disp('m')
        disp(m)
        disp('p')
        disp(p)
        %%add
        if (re==0)
            B = m*(m+3)/2 + p - 1;
        else
            B = m*(m+1)/2 + p - 1;
        end
        B = patches*B - sum(l(2:end));
        %%add
        output=[];
        K=[] ;
        time=[];
        prop=1;

        
        while prop < 10.0
            K=[K, i];
            disp(i)
            %[ave_time, prop] = run(r, l, re, m, p, EbN0, i, trials);
            [prop, ave_time] = run(r, l, re, m, p, EbN0, i, trials);
            output = [output, prop];
            time = [time, ave_time];
            
            disp(K)
            disp(output)
            disp(time)
            disp(prop)
            i=i+1;
            %%add
            if(i>15)
                break
            end
            %add
        end
        
        filename=strcat("tests/B", num2str(B),'r', num2str(r),'l', num2str(l),'r', num2str(r),'m', num2str(m),'p', num2str(p), 'trials', num2str(trials))
        save(filename, "K", "output", "time");
    end
end



x=strcat("tests/B", num2str(B),'r', num2str(r),'l', num2str(l),'r', num2str(r),'m', num2str(m),'p', num2str(p), 'trials', num2str(trials))
x(1)
plot(K, output)
xlabel('K')
ylabel('prop found')