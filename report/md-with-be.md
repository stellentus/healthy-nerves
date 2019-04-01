# Is it worth filling missing data when testing for batch effects.

Filling with zeros causes a massive increase. But leaving the NaN is even larger (results not shown, but near 0.5 for normative data). CCA is about the same as IterRegr, but numRat drops to 2, so none of those comparisons are meaningful. (They drop by a lot.) This reminds me I should check which rat values are missing.
RMStuf is the results after removing Age, Refractoriness at 2 and 2.5, and RRP. This causes almost no change in the scores (and it's *certainly* not significant). That's important because those 4 variables are often missing in the rat data, but it looks like either those 4 variables are not used or the code to fill missing values is doing a good job. (Out of 49 rats, the rates of missingness are RRP 29, Age 37, Ref@2 18, Ref@2.5 16). See the commit with hash 34f05584d4322f7dc71656f6f2a2082bebafffd0.

I wondered if the batch effects decreased based on sample size because I incorrectly thought I was running CCA when I ran Zero, so I thought the lower number of samples showed higher batch effects and I wondered if it was just due to sample size. I coded batchesDiminishing.m (commit:25834c5de8d6c5a1006a9ec9b6dbfe62f6dd444b) before realizing that the issue was with my code. The images (batch-norm-sample-size.png) show that there isn't a sample size effect above around 200 samples or so.

Zero: Normative Data vs Random Data

Name               ,  Zero  ,  std  ,  Iter  ,  std  ,  CCA   ,  std  , RMStuf ,  std  
------------------ , ------ , ----- , ------ , ----- , ------ , ----- , ------ , ----- 
Normative Data     ,  0.208 , 0.078 ,  0.132 , 0.037 ,  0.127 , 0.034 ,  0.136 , 0.037 
Shuffled Normative ,  0.182 , 0.088 ,  0.094 , 0.027 ,  0.091 , 0.031 ,  0.107 , 0.038 
Random Labels      ,  0.066 , 0.013 ,  0.066 , 0.013 ,  0.064 , 0.016 ,  0.066 , 0.013 


Zero: Impact of Splitting Within-Group Data

Name                ,  Zero  ,  std  ,  Iter  ,  std  ,  CCA   ,  std  , RMStuf ,  std  
------------------- , ------ , ----- , ------ , ----- , ------ , ----- , ------ , ----- 
Random (Can-sized)  ,  0.022 , 0.012 ,  0.022 , 0.012 ,  0.026 , 0.015 ,  0.022 , 0.012 
Three-split Can     ,  0.075 , 0.049 ,  0.080 , 0.047 ,  0.070 , 0.053 ,  0.068 , 0.036 
Random (Jap-sized)  ,  0.040 , 0.027 ,  0.040 , 0.027 ,  0.049 , 0.023 ,  0.040 , 0.027 
Three-split Jap     ,  0.172 , 0.077 ,  0.125 , 0.049 ,  0.116 , 0.061 ,  0.127 , 0.055 
Random (Por-sized)  ,  0.088 , 0.052 ,  0.088 , 0.052 ,  0.115 , 0.062 ,  0.088 , 0.052 
Three-split Por     ,  0.225 , 0.093 ,  0.202 , 0.092 ,  0.200 , 0.067 ,  0.207 , 0.073 
Random (Norm-sized) ,  0.066 , 0.013 ,  0.066 , 0.013 ,  0.064 , 0.016 ,  0.066 , 0.013 
Shuffled Normative  ,  0.182 , 0.088 ,  0.094 , 0.027 ,  0.091 , 0.031 ,  0.107 , 0.038 
Normative Data      ,  0.208 , 0.078 ,  0.132 , 0.037 ,  0.127 , 0.034 ,  0.136 , 0.037 


Zero: One Country vs Two

Name                   ,  Zero  ,  std  ,  Iter  ,  std  ,  CCA   ,  std  , RMStuf ,  std  
---------------------- , ------ , ----- , ------ , ----- , ------ , ----- , ------ , ----- 
Normative vs Canada    ,  0.141 , 0.162 ,  0.068 , 0.033 ,  0.058 , 0.050 ,  0.072 , 0.047 
Random (N vs Canada)   ,  0.009 , 0.008 ,  0.009 , 0.008 ,  0.009 , 0.008 ,  0.009 , 0.008 
Normative vs Japan     ,  0.204 , 0.202 ,  0.092 , 0.036 ,  0.079 , 0.024 ,  0.098 , 0.041 
Random (N vs Japan)    ,  0.061 , 0.018 ,  0.061 , 0.018 ,  0.064 , 0.018 ,  0.061 , 0.018 
Normative vs Portugal  ,  0.375 , 0.202 ,  0.240 , 0.038 ,  0.228 , 0.044 ,  0.248 , 0.034 
Random (N vs Portugal) ,  0.200 , 0.023 ,  0.200 , 0.023 ,  0.197 , 0.030 ,  0.200 , 0.023 


Zero: Comparisons with Leg Data

Name              ,  Zero  ,  std  ,  Iter  ,  std  ,  CCA   ,  std  , RMStuf ,  std  
----------------- , ------ , ----- , ------ , ----- , ------ , ----- , ------ , ----- 
Random Labels     ,  0.066 , 0.013 ,  0.066 , 0.013 ,  0.064 , 0.016 ,  0.066 , 0.013 
Normative Data    ,  0.208 , 0.078 ,  0.132 , 0.037 ,  0.127 , 0.034 ,  0.136 , 0.037 
Can Arms->Legs    ,  0.411 , 0.087 ,  0.327 , 0.054 ,  0.308 , 0.086 ,  0.364 , 0.066 
Add Legs          ,  0.302 , 0.069 ,  0.278 , 0.058 ,  0.242 , 0.054 ,  0.289 , 0.054 
Normative vs Legs ,  0.337 , 0.116 ,  0.289 , 0.076 ,  0.262 , 0.083 ,  0.305 , 0.104 


Zero: Comparisons with Rat Data

Name           ,  Zero  ,  std  ,  Iter  ,  std  ,  CCA   ,  std  , RMStuf ,  std  
-------------- , ------ , ----- , ------ , ----- , ------ , ----- , ------ , ----- 
Random Labels  ,  0.066 , 0.013 ,  0.066 , 0.013 ,  0.064 , 0.016 ,  0.066 , 0.013 
Normative Data ,  0.208 , 0.078 ,  0.132 , 0.037 ,  0.127 , 0.034 ,  0.136 , 0.037 
Can->Rat       ,  0.684 , 0.079 ,  0.649 , 0.090 ,  0.401 , 0.091 ,  0.633 , 0.067 
Jap->Rat       ,  0.693 , 0.087 ,  0.650 , 0.080 ,  0.399 , 0.082 ,  0.639 , 0.066 
Add Rats       ,  0.497 , 0.077 ,  0.447 , 0.049 ,  0.271 , 0.064 ,  0.436 , 0.038 
Human vs Rats  ,  0.972 , 0.026 ,  0.993 , 0.014 ,  0.510 , 0.096 ,  0.987 , 0.021 


Zero: Adjusting Recovery Cycle (RC)

Name            ,  Zero  ,  std  ,  Iter  ,  std  ,  CCA   ,  std  
--------------- , ------ , ----- , ------ , ----- , ------ , ----- 
Random Labels   ,  0.066 , 0.013 ,  0.066 , 0.013 ,  0.064 , 0.016 
Normative Data  ,  0.208 , 0.078 ,  0.132 , 0.037 ,  0.127 , 0.034 
Can shift right ,  0.218 , 0.065 ,  0.150 , 0.037 ,  0.140 , 0.045 
Jap shift right ,  0.199 , 0.081 ,  0.145 , 0.049 ,  0.130 , 0.042 
Por shift right ,  0.215 , 0.071 ,  0.164 , 0.047 ,  0.156 , 0.062 
Can shift left  ,  0.217 , 0.077 ,  0.153 , 0.047 ,  0.142 , 0.050 
Jap shift left  ,  0.210 , 0.076 ,  0.153 , 0.040 ,  0.142 , 0.044 
Por shift left  ,  0.211 , 0.076 ,  0.139 , 0.034 ,  0.137 , 0.046 
Can shrink      ,  0.353 , 0.114 ,  0.276 , 0.088 ,  0.267 , 0.074 
Jap shrink      ,  0.293 , 0.069 ,  0.261 , 0.081 ,  0.236 , 0.088 
Por shrink      ,  0.267 , 0.074 ,  0.198 , 0.046 ,  0.178 , 0.049 

