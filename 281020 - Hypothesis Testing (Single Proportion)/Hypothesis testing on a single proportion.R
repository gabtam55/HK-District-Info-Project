# Load packages -----------------------------------------------------------
library(tidyverse)
library(infer)
library(hkdatasets)


# Load data ---------------------------------------------------------------
hkdc <- hkdatasets::hkdc %>%
  filter(District_EN == "Eastern",
         Gender_EN != "NA")

# Hypothetical scenario ----------------------------------------------------------------
# We only have access to the gender of district councilors (DC) in the Eastern district in Hong Kong.
# There 18 districts in Hong Kong in total.


# Hypotheses --------------------------------------------------------------
# H0: DC in Hong Kong are 50% male and 50% female.
# H1: There are more male DCs in Hong Kong.


# Calculate proportion of DCs who are male -----------------------------
p_hat <- hkdc %>%
  summarise(prop_male = mean(Gender_EN == "Male")) %>%
  pull()


# Computational approach --------------------------------------------------
# Generate null distribution
null <- hkdc %>%
  specify(response = Gender_EN,
          success = "Male") %>%
  hypothesise(null = "point", p = 0.5) %>%
  generate(rep = 500, type = "simulate") %>%
  calculate(stat = "prop")

# Compute p-value
null %>%
  summarise(one_tailed_pval = mean(stat >= p_hat)) %>%
  pull(one_tailed_pval) # The p-value is 0.01

# Visualise the null distribution and the p-value
ggplot(null, aes(x = stat)) +
  geom_density() +
  geom_vline(xintercept = p_hat, color = "red") # Most simulated statistics are smaller than p_hat

# Construct a confidence interval
SE <- hkdc %>%
  specify(response = Gender_EN,
          success = "Male") %>%
  generate(rep = 500, type = "bootstrap") %>%
  calculate(stat = "prop") %>%
  summarise(se = sd(stat)) %>%
  pull()

c(p_hat - 2 * SE, p_hat + 2 * SE) # The confidence interval for p_hat is 0.55 to 0.86


# Conclusion --------------------------------------------------------------
# The p-value is smaller than 0.05 and therefore we reject the null hypothesis.
# We are in favour of the alternative hypothesis that there are more male DCs in Hong Kong.
# We are 95% confident that the true population parameter is between 0.55 and 0.86.