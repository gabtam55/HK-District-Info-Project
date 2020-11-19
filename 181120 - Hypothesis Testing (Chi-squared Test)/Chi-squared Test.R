# Load packages -----------------------------------------------------------
library(tidyverse)
library(infer)


# Load data ---------------------------------------------------------------
gss <- gss

gss_class <- gss %>%
  filter(year >= 2000) %>%
  select(partyid, class) %>%
  filter(partyid %in% c("rep", "dem")) %>%
  filter(class %in% c("lower class", "working class", "middle class", "upper class")) %>%
  droplevels()


# Explore data ----------------------------------------------------------
# Contingency table
table(gss_class)

# Bar chart
ggplot(gss_class, aes(x = partyid, fill = class)) +
  geom_bar(position = "fill") +
  labs(x = "", y = "")


# Hypotheses--------------------------------------------------------------
# Null hypothesis: The socioeconomic class of US residents is independent of their political party affiliations.
# Alternative hypothesis: The socioeconomic class of US residents is dependent on their political party affiliations.


# Chi-squared test (computational approach) -------------------------------
# Calculate observed chi-square
chi_obs_stat <- gss_class %>%
  chisq_stat(class ~ partyid)

# Generate null distribution
null <- gss_class %>%
  specify(class ~ partyid) %>%
  hypothesize(null = "independence") %>%
  generate(rep = 500, type = "permute") %>%
  calculate(stat = "Chisq")

# Visualise p-value
ggplot(null, aes(x = stat)) +
  geom_density() +
  geom_vline(xintercept = chi_obs_stat, colour = "red") +
  geom_label(x = 10.6, y = 0.15, label = "p = 0.016", size = 5) +
  labs(x = "Chi-squared distance")

# Calculate p-value
null %>%
  summarise(p_val = mean(stat > chi_obs_stat)) # p = 0.016


# Conclusion --------------------------------------------------------------
# The p-value is smaller than 0.05 and therefore we reject the null hypothesis.
# We are in favor of the alternative hypothesis that socioeconomic class of US residents is dependent on their political party affiliations.