
distance_h.m を完成させたい
そのために、h を返り値として返すようにEncoderとDecoderの設定をする

Encoder.m : 
  [Y, h_all] = chirrup_encode(self)
  [Y, h_all] = sim_from_bits(self,sigma,bits)
  として、hに関しての返り値を設定

run.m : 
  ave_err -> ave_dist
  function [propfound_trial, h_dist_trial] = chirrup_test(re,m,p,K,EbN0,input_bits)
  とした
  h_all_in = [];
  h_all_out = [];
  を追加
  [Y, h_all_in] = encoder.chirrup_encode;
  [output_bits, h_all_out] = decoder.chirrup_decode();
  とした
  h_dist_trial = distance_h(h_all_in, h_all_out);
  を追加

tester.m :
  err -> dist
  ave_err -> ave_dist
  
Decoder.m :
  tic tokを消す
  timing -> h_all
  chirrup_decode(self)関数内の
  processed_bits{patch} = bit_matrix';とかを消した
  output_bitsは複数出てきて、kmin = min(self.K,size(output_bits,2));で人数分を取っている。
  h_hatをouter_recov().cとしていて、output_bitsと同様に複数出てくる。output_bitsと同様にkmin分だけを取ってくるような処理 h_hat = h_hat(:,1,kmin)を加えた。

x = distance_h(in, out) : 
  x = in - out;とした

この段階で、EncoderのhとDecoderのh_hatは全然揃ってないのでそこを直していく。
多分33行目のh_hat = h_hat(:,1,kmin)がダメなのかな？
