# load required libraries
library(dplyr)
library(readr)

# load file with region of interest (ROI) definitions 
rois <- read_csv("../rois.csv")

# load ERP mean amplitude data
n100 <- read_table("data/N1Onset95-155.txt") %>% rename ("n100" = "value")
p200 <- read_table("data/P2Onset210-270.txt") %>% rename ("p200" = "value")
lpp_ons <- read_table("data/LPP_Onset_600-1000.txt") %>%  rename("lpp" = "value")

# integrate the dfferent tables into one single dataframe and tidy it
onset_mean_amp <- n100 %>% 
  inner_join(p200) %>%
  inner_join(lpp_ons) %>% 
  separate(ERPset, c("subject", NA)) %>% 
  mutate(
    chlabel = factor(chlabel),
    binlabel = factor(binlabel),
    subject = factor(subject),
    ROI = factor(case_when(
      chlabel %in% left_anterior ~ "left_anterior",
      chlabel %in% left_central ~ "left_central",
      chlabel %in% left_posterior ~ "left_posterior",
      chlabel %in% medial_anterior ~ "medial_anterior",
      chlabel %in% medial_central ~ "medial_central",
      chlabel %in% medial_posterior ~ "medial_posterior",
      chlabel %in% right_anterior ~ "right_anterior", 
      chlabel %in% right_central ~ "right_central",
      chlabel %in% right_posterior ~ "right_posterior",
      TRUE ~ "none")),
    ROI = relevel(ROI, ref = "medial_central")) %>% 
  filter(ROI != "none") %>% 
  dplyr::select(subject, chlabel, bini, binlabel, n100, p200, lpp, ROI)

# separate bins into independent variables
onset_meanAmp_all <- onset_mean_amp %>% 
  separate(binlabel, into = c(NA, NA, "accent", "type", "sp_sex"), remove = F) %>% 
  filter(accent %in% c("foreign", "native"),
         type %in% c("critiques", "praises"),
         is.na(sp_sex)) %>% 
  mutate(accent = factor(accent),
         type = factor(type),
         sp_sex = factor("omni")) %>% 
  mutate(accent = relevel(accent, ref = "native"),
         type = relevel(type, ref = "praises"))

# Statistical modeling
mod <- lmer(n100 ~ accent * type * ROI + (1 | subject), data = onset_meanAmp_all, REML = FALSE)
anova(mod)

# Estimated marginal means for pairwise comparison
emm <- emmeans(mod, pairwise ~ accent*type | ROI, adjust = "Tukey")
summary(emm)

