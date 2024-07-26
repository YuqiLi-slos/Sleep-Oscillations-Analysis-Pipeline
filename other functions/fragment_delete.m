function LFPchan_nomov=fragment_delete(LFPchan, movement)

LFPchan_nomov=LFPchan;
% remove the movement fragments in all channels

if iscell(LFPchan)
    for i=  size(movement,1):-1:1

        j=movement(i,1);
        k=movement(i,2);

        LFPchan_nomov{1}(:,(j:k))=[];

    end

else

    for i=  size(movement,1):-1:1

        j=movement(i,1);
        k=movement(i,2);

        LFPchan_nomov(:,(j:k))=[];

    end
end
end





