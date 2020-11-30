# Load libraries ----------------------------------------------------------
library(here)
library(dplyr)
library(surveytoolbox)
library(infer)
library(ggplot2)
library(broom)


# Load data ---------------------------------------------------------------
dsuq <- read.csv(paste0(here(),"/datasets/DSUQ.csv"))
bfi <- read.csv(paste0(here(),"/datasets/BFI.csv"))


# Calculate participants' extraversion scores on the BFI --------------------
bfi <- bfi %>%
  mutate(Extraversion1 = X2..Is.talkative,
         Extraversion2 = 6 - X7..Is.reserved,
         Extraversion3 = X12..Is.full.of.energy,
         Extraversion4 = X17..Generates.a.lot.of.enthusiasm,
         Extraversion5 = 6 - X22..Tends.to.be.quiet,
         Extraversion7 = X27..Has.an.assertive.personality,
         Extraversion8 = 6 - X32..Is.sometimes.shy..inhibited,
         Extraversion9 = X37..Is.outgoing..sociable) %>%
  mutate(Extraversion = apply_row(., select_helpers = contains("Extraversion"), sum, na.rm = TRUE))


# Join participants' smartphone use characteristics with their extraversion scores --------
dsuq <- dsuq %>%
  inner_join(bfi, by = "X1..Subject.ID") %>%
  select(X18..I.usually.use.my.smartphone.with, Extraversion) %>%
  mutate(X18_2groups = case_when(
    X18..I.usually.use.my.smartphone.with == "my left hand" ~ "one hand",
    X18..I.usually.use.my.smartphone.with == "my right hand" ~ "one hand",
    TRUE ~ "two hands"
  ))


# Independent-samples t-test ----------------------------------------------
# Hypotheses
## H0: Individuals' extroversion is independent on the hand they use their smartphones with
## H1: Individuals' extroversion is dependent on the hand they use their smartphones with

# Hypothesis testing
## Method 1 - Computational approach
### Calculate observed t-statistic
obs_t <- dsuq %>%
  specify(Extraversion ~ X18_2groups) %>%
  calculate(stat = "t", order = c("one hand", "two hands")) %>%
  pull()
  
### Generate null t-distribution for when H0 is true
null_distribution_t <- dsuq %>%
  specify(Extraversion ~ X18_2groups) %>%
  hypothesise(null = "independence") %>%
  generate(reps = 5000, type = "permute") %>%
  calculate(stat = "t", order = c("one hand", "two hands"))

### Calculate p-value
null_distribution_t %>%
  get_p_value(obs_stat = obs_t, direction = "both") # p-value is 0.712

### Visualise p-value in the null t-distribution
null_distribution_t %>%
  visualise() +
  shade_p_value(obs_stat = obs_t, direction = "both") +
  labs(x = "t-statistics")

### Calculate confidence interval
obs_diff <- dsuq %>%
  specify(Extraversion ~ X18_2groups) %>%
  calculate(stat = "diff in means", order = c("one hand", "two hands")) %>%
  pull() # observed difference in means is -0.51

dsuq %>%
  specify(Extraversion ~ X18_2groups) %>%
  generate(reps = 5000, type = "bootstrap") %>%
  calculate(stat = "diff in means", order = c("one hand", "two hands")) %>%
  get_ci(point_estimate = obs_diff, type = "se") # 95% C.I. for difference in means is -3.10 to 2.08

## Method 2 - Approximation approach
t.test(Extraversion ~ X18_2groups,
       data = dsuq,
       null = 0,
       alternative = "two.sided") # p-value is -.699; 95% C.I. for difference in means is -3.14 to 2.12

# Conclusion
## The independent t-test suggests that there is no significant difference between the levels of extraversion
## between individuals who use their smartphones with one hand and those who use it with two hands (p > 0.05).

## The observed difference in means is -0.51, with a 95% confidence interval spanning from -3.10 to 2.08


# One-way ANOVA -------------------------------------------------------------------
# Hypothesis testing
# Hypotheses
## H0: Individuals' extroversion is independent on the hand they use their smartphones with
## H1: Individuals' extroversion is dependent on the hand they use their smartphones with

# Hypothesis testing
## Calculate mean extraversion score for each group
dsuq %>%
  group_by(X18..I.usually.use.my.smartphone.with) %>%
  summarise(mean(Extraversion)) # Left hand: 25.1; right hand: 26.1; two hands: 26.4

## Run ANOVA
tidy(aov(Extraversion ~ X18..I.usually.use.my.smartphone.with, data = dsuq)) # p = 0.857

## Run post-hoc test (note: This was run despite an insignificant p-value found in the ANOVA. This was just a practice for myself.)
K <- length(unique(dsuq$X18..I.usually.use.my.smartphone.with)) *
  (length(unique(dsuq$X18..I.usually.use.my.smartphone.with)) - 1) /
  2

bonferroni_corrected_sig_lv <- 0.05 / K # Modified significance level for the post-hoc tests is 0.017

pairwise.t.test(dsuq$Extraversion, dsuq$X18..I.usually.use.my.smartphone.with, p.adjust.method = "none") # None of the p-values are smaller than 0.017

# Conclusion
## The one-way ANOVA suggests that there is no significant difference between the levels of extraversion
## between individuals who use their smartphones with left hand, right hand and two hands (p > 0.017).