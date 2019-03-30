function sad = SAD(block1,block2)

sad = sum(   abs( block1(:)-block2(:))   );