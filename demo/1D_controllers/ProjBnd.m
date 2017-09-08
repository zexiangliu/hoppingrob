function Bnd_list = ProjBnd(R,Int_list)
    Bnd_list = cell(size(Int_list));
    for i = 1:length(Int_list)
        for j = 1:(length(Int_list{i})-1)
            int2 = Int_list{i}(j:j+1).^2;
            Bnd_list{i}{j} = sqrt(R^2 - max(int2));
        end
    end

end