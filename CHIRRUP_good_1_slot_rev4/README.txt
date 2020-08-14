
Decoderで
chirrup_decodeのcompを取り除く
charp_recのcompは何もしていない
self.params.circuitsを3から1にすることでcharp_recのエラーを回避

find_bitsの最後をいじった

グラフでは、1ユーザしかいない時に必ず復号できるけど、
多分、self.params.circuitsを1にしたせいで、charp_recでの
peeling offが行われていない様子。



