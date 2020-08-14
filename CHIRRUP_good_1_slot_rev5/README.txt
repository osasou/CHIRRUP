
変更点はDecoderのみだと思う

chirrup_decoder
 recov = self.chirp_recをして、
 outer_recov = recov;するだけっていう
 単純なことでした

chirp_rec
 while文だけそのまま残してあげるっていう
 単純なことでした


distance_h.mを追加
中身は何も変えていない

グラフについて...
rev5_....fig：雑音sigma = 0, h = 1, alpha = 1, d = 1とした時の結果
rayleigh_....fig；雑音sigma = 0, h = rayleigh_rand(), alpha = 1, d = 1
EbnoXX_....fig；XXdBでの雑音sigmaは計算で出している。つまり、雑音ありの通信路
 同じ  _rayleigh....fig：さらにh = rayleigh_rand()になっている
 同じ  _  同じ   _alphaX_circle_rY：さらにalpha = X, circle_r = Y での結果

Rev5では基本的に alpha と circle_r をいじっていない。いじったのは h と ebno sigma くらい
一つだけ alpha=0.6 circle_r=4 でやったファイルがある

