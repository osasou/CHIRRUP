function K = makeDGC(re,m)
% m行m列の行列で全て0ではない対象行列となる行列を返す。
% re = 0 の場合は対角の値も考える。
% re = 1 の場合は対角の値は全て0。
% e.g. makeDGC(1,3)は3つできる。makeDGC(0,3)は6つできる。


[i j] = upper_indices(re,m);
%disp([i,j])
%makeDGC(1,3)の場合、
%i=[1 1 2]
%j=[2 3 3]と入る

for p = 1:length(i)
    
    K(:,:,p) = zeros(m,m);
    % i行j列とj行i列に1を代入する
    % K_1(p = 1)には、1行2列と2行1列に1を
    % K_2(p = 2)には、1行3列と3行1列に1を
    % K_3(p = 3)には、2行3列と3行2列に1を代入
    K(i(p),j(p),p) = 1;
    K(j(p),i(p),p) = 1;
    
end

%disp(K)