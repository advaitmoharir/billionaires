# India's Billionaire Boom

This repository contains the data and code for the article "India's Billionaire Boom", written by Arjun Jayadev and Advait Moharir

## Repo Structure

The repository consists of the following files:

1. `01_datas`: This consists of the data required to generate figures
2. `02_code`: This has code to generate figures
3. `03_exhibits`: This consists of all the figures in the article

## Replication

To replicate, the software Stata is needed with packages `wbopendata`, `here`, `schemepack`, `isocodes` installed via `ssc`.

1. Download the repository and open the stata project `billionaires.stpr`.
2. In the project, open the do file `plots.do`
3. Run the file - all the figures will be generated and stored in `03_exhibits`



