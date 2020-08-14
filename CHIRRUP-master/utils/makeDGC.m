function K = makeDGC(re,m)
% m�sm��̍s��őS��0�ł͂Ȃ��Ώۍs��ƂȂ�s���Ԃ��B
% re = 0 �̏ꍇ�͑Ίp�̒l���l����B
% re = 1 �̏ꍇ�͑Ίp�̒l�͑S��0�B
% e.g. makeDGC(1,3)��3�ł���BmakeDGC(0,3)��6�ł���B


[i j] = upper_indices(re,m);
%disp([i,j])
%makeDGC(1,3)�̏ꍇ�A
%i=[1 1 2]
%j=[2 3 3]�Ɠ���

for p = 1:length(i)
    
    K(:,:,p) = zeros(m,m);
    % i�sj���j�si���1��������
    % K_1(p = 1)�ɂ́A1�s2���2�s1���1��
    % K_2(p = 2)�ɂ́A1�s3���3�s1���1��
    % K_3(p = 3)�ɂ́A2�s3���3�s2���1����
    K(i(p),j(p),p) = 1;
    K(j(p),i(p),p) = 1;
    
end

%disp(K)