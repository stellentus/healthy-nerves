# Exploratory Factor Analysis of Electrodiagnostic Nerve Test Results

We were working toward EFA where the extraction of the components (or factors) was done using Principal Components Analysis (PCA). This is the short range goal as PCA may not be the best solution for our data. One alternative is Independent Components Analysis (or ICA).

## Export Data from MEF Files to Matlab <!-- DONE -->

Instructions:
1. Export MEF to Excel.
2. Import Excel to Matlab.
3. Label the columns as a structure array.
4. Save it as a data file.

## Missing Data <!-- DONE (deleting missing rows) -->

Possible Approaches:

1. Delete missing rows. But this drops outliers (e.g. needed 100mA but only had 50mA).
2. Assume missing at random (MAR). But that's not true (as noted in point 1 above).
3. A technique that doesn't assume MAR.
4. Alternating Least Squares method with PCA.

Option 1 is easy, but option 3 is best. Perhaps I can start with a script that does option 1, and replace that code if I come up with a better option.

## Factor Analysis

Possible Approaches:

1. PCA. It's common but not true factor analysis.
2. Maximum likelihood.
3. Principal Axis Factors.
4. ICA? Is it a superset of ML and PAF, or different?
5. Something else?

Options 2 and 3 were in [EFABestPractices]. Again, I'll start with 1 but eventually move to something else.

## Retain Essential Factors

1. Retain eigenvalues greater than 1.0. This is common but not ideal. 
2. Scree Test (often available in software)
3. Velicer’s MAP Criteria (Velicer & Jackson, 1990). Accurate and easy to use, but often not in software.
4. Parallel Analysis (Velicer & Jackson, 1990). Accurate and easy to use, but often not in software.

Start with 1, but then look at the others. I think the scree test involves looking for a break in the data. The PCA curve was smooth, but perhaps the scree test will work better with a different method of factor analysis.

"After rotation (see below for rotation criteria) compare the item loading tables; the one with the 'cleanest' factor structure – item loadings above .30, no or few item crossloadings, no factors with fewer than three items – has the best fit to the data. If all loading tables look messy or uninterpretable then there is a problem with the data that cannot be resolved by manipulating the number of factors retained." [EFABestPractices]

## Rotate the Data

1. Varimax rotation. This is orthogonal, which is often a poor choice.
2. "There is no widely preferred method of oblique rotation; all tend to produce similar results (Fabrigar et al., 1999), and it is fine to use the default delta (0) or kappa (4) values in the software packages." [EFABestPractices]

## Create a Composite Nerve Health Measure

We need a simple measure of the health of a nerve.

## Compare the Data to Another Group

Compare the nerve health measure to data from a clinically relevant population, e.g. the SCI group
