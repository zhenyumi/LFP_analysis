 function [peak,onset]=find_negativepeak(temp,t_old,TT)
temp_o=temp;
onset=0;
T=round(TT/(t_old(2)-t_old(1)));

while onset==0 
    [index,~]=find(temp==-1,1,'first');
    if (index+T)<length(temp)
        if temp(index:index+T)==-1
            %temp(1:index)=0;
            temp(1:index+T)=0; %
            [indexy,~]=find(temp==1,1,'first');
            onset=index-1;
             peak=indexy-1; %
             if isempty(peak)
                 %temp(1:index)=0;
                 temp(1:index+T)=0; %
                 onset=0;
             end
        else 
            %temp(1:index)=0;
            temp(1:index+T)=0; %
            onset=0;
        end 
    else
        TTT=TT/2;
        try
        [peak,onset]=find_negativepeak(temp_o,t_old,round(TTT));
        catch err
            peak=1; onset=1;
        end
        
    end
end