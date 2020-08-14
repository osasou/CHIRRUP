addpath("utils")
r = 0
l = 0
re = 0

EbN0=5
trials = 20

  
prop=1  
mvalues=[1]
pvalues=[1]
%disp(mvalues)

%%add
patches=2^r;

%tester‚Å‚Í•Ï” K : number of messages‚ğ1‚©‚ç‘‚â‚µ‚Ä‚¢‚éB

%%add

for a = 1:size(mvalues, 2) % a : 1 to m
    m=mvalues(a);
    
    for b=1:size(pvalues,2)% b:1to5
        p=pvalues(b);
        i=1;

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
        err=[];
        prop=1;

        
        while prop > -1.0
            K=[K, i];
            disp(i)
            %prop‚Æave_time‚ª”½‘Î‚É‚È‚Á‚Ä‚¢‚½
            [prop, ave_err] = run(r, l, re, m, p, EbN0, i, trials);
            disp("prop")
            disp(prop)
            output = [output, prop];
            err = [err, ave_err];
            
            i=i+1;
            
            if(i>10)
                break
            end
            
            
            %add
        end
        %output=[output, 0.05];
        %K=[K, i];
        
        filename=strcat("tests/B", num2str(B),'r', num2str(r),'l', num2str(l),'r', num2str(r),'m', num2str(m),'p', num2str(p), 'trials', num2str(trials))
        save(filename, "K", "output", "err");
    end
end



x=strcat("tests/B", num2str(B),'r', num2str(r),'l', num2str(l),'r', num2str(r),'m', num2str(m),'p', num2str(p), 'trials', num2str(trials))
x(1)
plot(K, output)
xlabel('K')
ylabel('output')