function dec = az2dec(az,n)
% convert decimal to base-n (ig. binary) encoding.
if(n>62)
    error('n cannot be greater than 62!');
elseif(n==0)
    dec = str2num(az);
    return;
elseif(n == 1)
    error('n cannot be 1!');
end

len = length(az);
dec = 0;

for i = 1:len
   dec = dec + alpha_map(az(len-i+1))*n^(i-1);
end
end

function digit = alpha_map(letter)
    if(letter-'0' <= 9 && letter-'0'>=0)
        digit = letter - '0';
    elseif(letter-'A' <= 25 && letter-'A'>=0)
        digit = letter - 'A' + 10;
    elseif(letter-'a' <= 25 && letter-'a'>=0)
        digit = letter - 'a' + 36;
    else
        error('digit is out of bound!');
    end
end
