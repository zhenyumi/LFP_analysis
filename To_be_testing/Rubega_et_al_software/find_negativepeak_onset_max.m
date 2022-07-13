function [peak,peak_value,onset,onset_value,max,max_value]=find_negativepeak_onset_max(temp,t_old,TT,rat,perc)
% Thanks to this function, it's possible to compute the features of interest (maximum, onset, negative peak)

temp_o=temp;
max_v=0;
T=round(TT/(t_old(2)-t_old(1)));

while max_v==0  
    [index,~]=find(temp==-1,1,'first');
    if (index+T)<length(temp)
        if temp(index:index+T)==-1
            temp(1:index)=0; 
            [indexy,~]=find(temp==1,1,'first');
            max_v=index-1;
             peak=indexy-1; 
             if isempty(peak)
                 temp(1:index)=0; 
                 max_v=0;
             end
        else 
            temp(1:index)=0;
            max_v=0;
        end 
    else
        [peak,max_v]=find_negativepeak(temp_o,t_old,round(TT/2));
    end
end

peak_value=rat(peak);

k=1;
control=2;

if abs(rat(peak))<abs(rat(peak-k)) && abs(rat(peak))>abs(rat(peak+k))
    control=1;
elseif abs(rat(peak))<abs(rat(peak+k)) && abs(rat(peak))>abs(rat(peak-k)) 
    control=0;
end
   

if control==0

    while abs(rat(peak))<abs(rat(peak-k)) && abs(rat(peak))>abs(rat(peak+k))
        peak=peak-k;
    end


elseif control==1
    
    while abs(rat(peak))<abs(rat(peak+k)) && abs(rat(peak))>abs(rat(peak-k)) 
        peak=peak+k;
    end

         
end

peak_value=rat(peak);
    
onset_value=rat(max_v)-perc*abs(peak_value-rat(max_v));

onset=find(rat(1:peak)>=onset_value,1,'last');

max=max_v;
max_value=rat(max_v);

    

