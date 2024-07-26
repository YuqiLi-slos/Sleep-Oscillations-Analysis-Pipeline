%% NAN of selected fragments
function LFPchan_zeropadding= NotAValue(LFPchan,movement)

LFPchan_zeropadding=LFPchan;

if iscell(LFPchan)
    
    for i=  1:size(movement,1)
        
        j=movement(i,1);
        k=movement(i,2);
        

  
        LFPchan_zeropadding{1}(:,(j:k))=NaN(length(k-j));
        
    end

else 
     for i=  1:size(movement,1)
        
        j=movement(i,1);
        k=movement(i,2);
        

  
        LFPchan_zeropadding(:,(j:k))=NaN(length(k-j));
     end
end


end

