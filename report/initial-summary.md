# Supervisors Meeting

* Comments
	- Kelvin: Legs shift is promising, others aren't so sure. We're very happy detecting legs.
* Is Matlab clustering giving me equal-sized groups?
	- I ran 3 iterations on the normative data and found that linkage cluster (ward) gave different-sized groups:
		Normative data: Cls 46 60 92; Tru 105 65 28
		Normative data: Cls 32 78 88; Tru 101 52 45
		Normative data: Cls 63 52 83; Tru 101 61 36
		<!-- Implemented by adding the following line to the end of BatchAnalyzer:calculateBatch `disp(sprintf('%s: Cls %d %d %d; Tru %d %d %d', obj.Name, sum(idx==1), sum(idx==2), sum(idx==3), sum(thisIterLabels==1), sum(thisIterLabels==2), sum(thisIterLabels==3)));` -->
* Kelvin: Is NMI dependent on number of clusters? (Note the 2 clusters drops down). Maybe try testing within Canada. Is NMI=0.1 the same for 3 clusters vs 2 clusters? Is it meaningful to compare across cluster sizes? Find the theoretical answer.
	- Yes, according to theory, NMI can be compared with different numbers of clusters. See https://nlp.stanford.edu/IR-book/html/htmledition/evaluation-of-clustering-1.html.
	- In our data it looks like there's a slight increase in NMI as the number of clusters increases: `batbox-2019-3-19-104913.png`.
* Martha: Prepare a results+discussion of this
* Batch with the rats and with combined SCI group.
* Martha: which parts am I worried about defending? Ask for help on them.

## Results

The data comes from three electrodiagnostic nerve excitability test (NET) datasets (median nerve, i.e. arm) from Canada (n=120), Japan (n=85), and Portugal (n=42). Additionally, some trials used a Canadian common peroneal nerve (i.e. leg) dataset (n=X), a rat dataset (n=X), and a spinal cord injury (SCI) dataset (n=X). The data as analyzed here consists of 36 real-valued measures (age, temperature, and 34 excitability variables) and one categorical measure (male/female) extracted from the NET datasets.

<!-- Describe zero mean unit variance. -->

<!-- Defend use of NMI. -->

In all of the following tests, two or more datasets were combined. The normalized mutual information (NMI) was calculated based on a random sample of 80% of the combined dataset, reported as mean (standard deviation) across 30 different random samples. A different random seed was used for each of the 30 trials, but the same 30 seeds were used for each test in a given figure.

Normalized mutual information can be used to compare two clusterings (or known labels and a clustering) to measure how similar they are. A score of 0 indicates no similarity, while 1 indicates they are identical. Therefore, NMI for the combined Canadian/Japanese/Portuguese dataset should be near 0 if it is appropriate to combine them into a normative dataset, while any combination with leg, rat, or SCI data should be significantly higher. NMI is normalized to account for different numbers of clusters, so it is appropriate to compare it even when the number of groups is different.

In Figure 1, NMI for the normative dataset (i.e. combined Canadian, Japanese, and Portuguese data) is compared to two different randomly generated lists of three labels with a length of 247. (NMI for identical lists is always exactly 1, so it is not shown.) As expected, NMI for random data is near zero. The normative data is not quite zero, indicating potential (but small) batch effects.

[FIG1: normative and random]

All of the results in Figure 1 used 3 labels, but future figures will not. While NMI theory allows for comparison of NMI with different numbers of clusters, it is illustrative to present a visual comparison of diverse cluster sizes (Figure 2). In this set of tests, one or more of the datasets was randomly divided in half to increase the number of clusters. (The same split was used for all 30 iterations.) For example, Canadian data (n=120) was randomly split into Canadian data A (n=60) and B (n=60) and then combined with Japanese (n=85) and Portuguese (n=42) data to measure NMI with 4 clusters.

*But actually, with random data, it looks to me like as the number of clusters increases, the mean and standard deviation get smaller (approach zero). So with data that has no batch effects, I think increased clusters would follow the same pattern? Second, if data has 3 strongly-batched data, I would expect that splitting that into 9 clusters would decrease the NMI. Within each cluster (where there are no batch effects) we have now created 3 groups, but the cluster-internal NMI would be 0 (if we were to calculate it on just the 3 sub-groups of one cluster), so I suspect the overall NMI would be reduced as a result. I should probably test this so I can more easily explain the below figure. (On the same lines, there's a difference between splitting one label into two labels or adding an entirely new label and associated data. I'm not entirely sure which one is theoretically not going to change NMI; I assume the former.)*

[FIG2: Various splits]

To be confident in the normative data it was necessary to show a near-zero NMI, but that is not sufficient. The NMI must also change significantly when non-normative data is added. Leg data is similar to arm data, but it is different enough that it should show up as a different batch. Rat data is radically different from human, so it should be even more clearly a different batch. A spinal cord injury can cause significant changes to some excitability variables, so the SCI dataset, which contains participants with diverse impairments, should also demonstrate batch effects. Figure 3 compares NMI for datasets between these groups. It shows that non-normative data increases the NMI as expected.

[FIG3: rat, SCI, leg]

The datasets tested in Figure 3 are significantly different than median nerve (arm), so it is unsurprising that they introduced a noticeable change in the NMI. However, potential technical or ethnic differences between datasets could be more subtle. To test the impact of such smaller changes, some of the 34 excitability variables were subtly adjusted (see Figure 4). In the "RC shift" tests, the 7 variables derived from one portion of the NET (recovery cycle, RC) were transformed in one of the three datasets as if the corresponding underlying data had shifted left or right, imitating a plausible technical difference between datasets. In the "RC shrink" tests, those same 7 variables were increased or decreased by 30%. <!-- confirm --> The results show a (probably not significant?) small increase in NMI.

[FIG4: Adjust RC]

Larger changes were introduced by doubling or halving the variance in one of the three datasets, imitating a potentially plausible biological difference (though changing the variance by a factor of 2 is larger-than-plausible; 40% would be more realistic). Figure 5 shows that such changes cause barely-noticeable changes to NMI. Doubling the variance of the Canadian data even *decreased* NMI, though it is likely that's due to a random difference in clustering rather than revealing a true difference between datasets. (The variance of the Canadian data is similar to the variance of the other data, indicating an increase in variance is not warranted.)

[FIG5: Adjust variance]

Figures 1–5 show that NMI is an effective measure for detecting batch effects, so it can be used to determine if NET data from diverse sources can be appropriately combined. It is sensitive to large changes (e.g. leg, rat, or SCI data), though it may not be sensitive to smaller, biologically-plausible changes. These results suggest that there are no large batch effects between the Canadian, Japanese, and Portuguese data. If batch effects exist, they must be small. <!-- Though I suspect if the majority of the parameters changed by 50%, I wouldn't detect it, so I'm not sure this really counts as "small". -->

Since the NMI of the normative data is non-zero, it is interesting to consider if the batch effects can be attributed to any specific features. Figure 6 shows the NMI calculated with each one of the 36 features removed, ranked in order of average impact on the NMI. These differences are clearly not significant.

[FIG6: Delete each feature, ranked by impact]

Since many of the features are correlated, it is not surprising that deleting a single feature would not be impactful, so each combination of two or three features was deleted with similar results. When the features were ranked by their effect on the NMI when all possible combinations of three features were deleted, five of the features consistently resulted in a decrease to the NMI (especially when they were deleted together): SDTC, hyperpolarization I/V slope, TEd (10–20ms), TEd (90–100ms), and age. Since distribution of ages in each dataset is different, and since some of the excitability measures are correlated with age <!-- which ones? -->, it is plausible that the observed batch effects are entirely due to the age differences in the datasets. Figure 7 shows the effect of deleting three features at once. Results to the left of the Normative Data were the 10 best-performing combinations; results to the right, the worst-performing. However, since this plot only shows the 20 most extreme results out of 4495 combinations, these differences are not likely to be significant.

[FIG7: Delete triple-features]

To consider whether deleting the five identified features is meaningful, Figure 7 shows the change in NMI based on deleting all five of the features most likely to increase NMI compared to a few random selections of 5 features. <!-- I have no idea what this will show. -->

[FIG7: Delete sets of 5]
