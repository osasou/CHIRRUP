function propfound = compare_bits(input,output)

k1 = size(input,2);
k2 = size(output,2);

found = zeros(k1,1);
%{
disp("k1")
disp(k1)

disp("k2")
disp(k2)
%}
for i = 1:k1
    %{
    disp("input")
    disp(i)
    disp(input(:,i))
    %}
    for j = 1:k2
        %{
        disp("output")
        disp(j)
        disp(output(:,j))
        %}
        if any(output(:,j)~=input(:,i)) % ~= means != in C lang
            continue
        end
        found(i,1) = j;
        break
    end
end

propfound = sum(found>0)/k1; 