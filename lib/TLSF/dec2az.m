function az = dec2az(dec,n)
% convert decimal to base-n (ig. binary) encoding.
if(n>62)
    error('n cannot be greater than 62!');
elseif(n==0)
    az = num2str(dec);
    return;
elseif(n == 1)
    error('n cannot be 1!');
end

if(dec==0)
    az = '0';
    return;
end

len = floor(log(dec)/log(n))+1;
az = '';

for i = 1:len
   digit = floor(dec/n^(len-i));
   az = [az,alpha_map(digit)];
   dec = dec - digit*n^(len-i);
end
end

function letter = alpha_map(digit)
    if(digit>=0 && digit <=9)
        letter = num2str(digit);
    elseif(digit <= 35)
        letter = char('A'+digit-10);
    elseif(digit <= 61)
        letter = char('a'+digit-36);
    else
        error('digit is out of bound!');
    end
end
