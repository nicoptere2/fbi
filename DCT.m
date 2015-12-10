function blocks = exercice7(im)
 
w = size(im,2);
h = size(im,1);
n_blocks = 0;
for i=1:2:(h-3)
     for j=1:2:(w-3)
        n_blocks = n_blocks+1;
        b = im(i:(i+3),j:(j+3));
        bdct = dct2(b);
        bdct = round(bdct/QP);
        vdct = bdct(:);
        blocks(n_blocks,1:15) = vdct(2:16);
     end
end
end
