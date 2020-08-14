
Encoder.mとtester.mのB = m*(m+3)/2 - 1 の - 1をとった
input_bitsとoutput_bitsをm=10のとき、65bitにした

Encoderのsim_from_bitsにおいて、先頭に0,1をつけるのをやめて、
スロットを一つにした
comp()関数を丸ごと取り去った。

いまだに、alpha, d, h は1で雑音はsigma = 0;


Decoderでは、復号する時に、先頭の1ビットを取り除かないようにした
それだけです。




