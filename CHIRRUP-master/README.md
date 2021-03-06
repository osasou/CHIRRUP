# CHIRRUP
CHIRRUP algorithm for unsourced multiple access

This toolbox performs encoding and decoding using CHIRRUP for unsourced 
multiple access, as described in the paper 'CHIRRUP: a practical algorithm 
for unsourced multiple access' (Calderbank/Thompson 2018). There is also 
code for performing repeated tests to obtain average success proportions 
and timings.

## Code
There are 3 main files:  

Encoder.m, contains the Encoder class, responsible for encoding chirps  
Decoder.m, contains the Decoder class, responsible for decoding chrips  
run.m, contains the functions run and chirrup_test, of which the latter runs a single test, and the former runs multiple

Additionally, there is a tester.m script file, in which parameters may be modifed to automatically run tests, saving results and producing a plot

## Usage

e.g.1

rは0で
##Encoder(r,l,re,m,p,K,EbN0,input_bits)
encoder = Encoder(0,0,1,8,7,200,200,NaN)  
[encoder, input_bits] = encoder.generate_random_bits()  
[Y, parity] = encoder.chirrup_encode()

self = Decoder(Y,r,l,parity,re,m,p,K,params_in)
decoder = Decoder(Y,0,0,[],1,8,7,200)  
[output_bits timing_trial] = decoder.chirrup_decode()
propfound = compare_bits(input_bits,output_bits)

etc.................

>> encoder = Encoder(0,0,1,8,0,9,5,NaN)
[encoder, input_bits] = encoder.generate_random_bits()
[Y, parity] = encoder.chirrup_encode()
decoder = Decoder(Y,0,0,[],1,8,0,9)
[output_bits timing_trial] = decoder.chirrup_decode()
propfound = compare_bits(input_bits,output_bits)

input
   0   0   0   1
   1   1   1   0
   1   1   1   0
   1   0   0   1
   0   0   1   1
   0   1   1   0
   1   1   1   0
   0   0   1   1
   1   0   1   1
   0   0   1   0
   0   0   1   1
   1   0   0   0
   0   1   1   0
   1   0   0   0
   0   1   1   1
   0   0   0   1
   1   0   1   0
   0   0   1   0
   0   1   1   1
   0   1   1   1
   0   0   1   0
   0   0   0   1
   1   1   0   0
   0   1   0   1
   1   0   1   1
   1   0   0   1
   0   1   1   1
   1   0   1   1
   0   0   1   0
   1   1   1   1
   0   1   0   1
   1   1   0   1
   1   0   0   1
   1   1   1   1
   0   1   1   0
ならうまくいっているかと、、、

>> 
encoder = Encoder(0,0,1,8,10,512,5,NaN)
[encoder, input_bits] = encoder.generate_random_bits()
[Y, parity] = encoder.chirrup_encode()
decoder = Decoder(Y,0,0,[],1,8,10,512)
[output_bits timing_trial] = decoder.chirrup_decode()
propfound = compare_bits(input_bits,output_bits)

encoder = Encoder(0,0,1,3,4,3,5,NaN)
[encoder, input_bits] = encoder.generate_random_bits()
[Y, parity] = encoder.chirrup_encode()



etc..

##Encoder(r,l,re,m,p,K,EbN0,input_bits)

r=0:→1patch
l=0:←r=0よりrecommended
reはどっちでもいいかな。。1の方が実数範囲
m:→2^mでYの行数 length of codeword  in this case m=3
p=0:→1slot
K:number of message
EbN0:200は大きいらしい

input_bits:B*K行列
B=1*{m*(m+3)/2 + 0 - 1} - 0 =   m*(m+3)/2 - 1    : ← 2^r*{m*(m+3)/2 + p - 1} - sum(l(2:end))において、r=0,p=0,end=r=0よりsum()=0


encoder = Encoder(0,0,1,3,1,4,5,NaN)  
[encoder, input_bits] = encoder.generate_random_bits()  
[Y, parity] = encoder.chirrup_encode()


##Decoder(Y,r,l,parity,re,m,p,K,params_in)

decoder = Decoder(Y,0,0,[],1,3,1,4)  
[output_bits timing_trial] = decoder.chirrup_decode()
propfound = compare_bits(input_bits,output_bits)

etc.
encoder = Encoder(0,0,1,3,3,4,5,NaN)
[encoder, input_bits] = encoder.generate_random_bits()
[Y, parity] = encoder.chirrup_encode()
decoder = Decoder(Y,0,0,[],1,3,3,4)
[output_bits timing_trial] = decoder.chirrup_decode()
propfound = compare_bits(input_bits,output_bits)

e.g.2

encoder = Encoder(1,[0 15],0,7,7,100,20,NaN)  
[encoder, input_bits] = encoder.generate_random_bits()  
[Y, parity] = encoder.chirrup_encode() 
decoder = Decoder(Y,1,[0 15],parity,0,7,7,100)
[output_bits timing_trial] = decoder.chirrup_decode()
propfound = compare_bits(input_bits,output_bits)

### Encoding
To perform CHIRRUP encoding:  
```
encoder = Encoder(r,l,re,m,p,K,EbN0,input_bits);  
[Y, parity] = encoder.chirrup_encode()
```

input_bits may be entered manually, else a random selection may be generated by running `[encoder, input_bits] = encoder.generate_random_bits()` after initialising an encoder object 

For example: 
```
encoder = Encoder(0,0,1,8,7,200,200,NaN)  
[encoder, input_bits] = encoder.generate_random_bits()  
[Y, parity] = encoder.chirrup_encode()
``` 
performs CHIRRUP encoding of 200 messages as 1=2^0 patches (with no parity
bits trivially), using real binary chirps of size 2^8 in 2^7 slots, with
energy-per-bit in Eb/N0=200.
```
encoder = Encoder(1,[0 15],0,7,7,100,20,NaN)  
[encoder, input_bits] = encoder.generate_random_bits()  
[Y, parity] = encoder.chirrup_encode()  
```
performs CHIRRUP encoding of 100 messages as 2=2^1 patches (with 15 parity
bits), using complex binary chirps of size 2^7 in 2^7 slots, with
energy-per-bit Eb/N0=20.


### Decoding

To perform CHIRRUP decoding,
```
decoder = Decoder(Y,r,l,parity,re,m,p,K,params_in)
[output_bits timing_trial] = decoder.chirrup_decode()
```

For example,
```
decoder = Decoder(Y,0,0,[],1,8,7,200)  
[output_bits timing_trial] = decoder.chirrup_decode()
```
performs CHIRRUP decoding of 200 messages as 1=2^0 patches (with no parity
bits trivially), using real binary chirps of size 2^8 in 2^7 slots.

```
decoder = Decoder(Y,1,[0 15],parity,0,7,7,100)
[output_bits timing_trial] = decoder.chirrup_decode()
```
performs CHIRRUP decoding of 100 messages as 2=2^1 patches (with 15 parity
bits), using complex binary chirps of size 2^7 in 2^7 slots.

The proportion of correctly identified messages can be found using

```
propfound = compare_bits(input_bits,output_bits)
```

A repeated test over a number of trials can be run using
`[propfound ave_time] = run(r, l, re, m, p, EbN0, K, trials)`

## Authors
The code is largely authored by Andrew Thompson (National Physical 
Laboratory, UK), but some of the original chirp reconstruction code is also 
written by Sina Jafarpour (Facebook, USA), based on the work in the paper
'A fast reconstruction algorithm for deterministic compressive sensing using 
second order reed-muller codes' (Howard/Calderbank/Searle, Conference on 
Information Science and Systems, Princeton, NJ, 2008). The fast Hadamard 
transform routine is by Gylson Thomas (Jyothi Engineering College, India). 
Some refactoring of the code has been undertaken by Bilal Chughtai (University of Cambridge, UK)

Please refer to the code for more detailed explanation of input and output 
parameters for each program.

Contact details for author: [andrewjthompson42@gmail.com](andrewjthompson42@gmail.com)
