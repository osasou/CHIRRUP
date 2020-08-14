

Decoder.m :
recov = self.chirp_rec(Yp(:,slot),ceil(self.params.sparsity_factor*self.K/2^(self.p-1)),slot);
-->
recov = self.chirp_rec(Yp(:,slot),self.K,slot); 
とした
これでもうまく復号できてるみたい
だから、self.params.sparsity_factorを消した。
あと、self.params.circuits を 3 から 1 にしていけそうだったから、for c = 1:self.params.circuitsを消した。

h_hat = h_hat(:,1,kmin); になっていて、h_hat = h_hat(:,1:kmin);に直す。
h_hat = abs(h_hat)を消しておく                          ↑ここ

Encoder.m : 
y = hx + n の hをこれまでレイリー分布に従う実数としていたが、普通に複素数にしなきゃいけなかったので直す。
h = rayleigh(1)から
h = normrnd(0,0.5)+1i*normrnd(0,0.5);にした

rev7終了段階では、一応ちゃんと復号して、Symbol Error Rate は悪くない状態。むしろ、まだ削れるところがたくさんあったっていうことに驚きがあった。

次のrev8では、通信路hをどこで推定しているのかをちゃんと確認する


