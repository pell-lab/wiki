# load required libraries
library(dplyr)
library(readr)
library(tidyr)
library(lme4)
library(lmerTest)
library(emmeans)

# load file with region of interest (ROI) definitions 
rois <- read_csv("../rois.csv") %>% mutate(ROI = factor(ROI))

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
      chlabel %in% rois[rois$ROI == "LeftAnterior",]$chlabel ~ "left_anterior",
      chlabel %in% rois[rois$ROI == "LeftCentral",]$chlabel ~ "left_central",
      chlabel %in% rois[rois$ROI == "LeftPosterior",]$chlabel ~ "left_posterior",
      chlabel %in% rois[rois$ROI == "MedialAnterior",]$chlabel ~ "medial_anterior",
      chlabel %in% rois[rois$ROI == "MedialCentral",]$chlabel ~ "medial_central",
      chlabel %in% rois[rois$ROI == "MedialPosterior",]$chlabel ~ "medial_posterior",
      chlabel %in% rois[rois$ROI == "RightAnterior",]$chlabel ~ "right_anterior", 
      chlabel %in% rois[rois$ROI == "RightCentral",]$chlabel ~ "right_central",
      chlabel %in% rois[rois$ROI == "RightPosterior",]$chlabel ~ "right_posterior",
      TRUE ~ "none")),
    ROI = relevel(ROI, ref = "medial_central")) %>% 
  filter(ROI != "none") %>% 
  dplyr::select(subject, chlabel, bini, binlabel, n100, p200, lpp, ROI)

# separate bins into independent variables
onset_mean_amp_tidy <- onset_mean_amp %>% 
  separate(binlabel, into = c(NA, NA, "accent", "type", "sp_sex"), remove = F) %>% 
  filter(accent %in% c("foreign", "native"),
         type %in% c("critiques", "praises"),
         is.na(sp_sex)) %>% 
  mutate(accent = factor(accent), # turn into factors
         type = factor(type),
         sp_sex = factor("omni")) %>% 
  mutate(accent = relevel(accent, ref = "native"), # set reference for contrasts
         type = relevel(type, ref = "praises"))

# Linear mixed effects modeling
mod <- lmer(n100 ~ accent * type * ROI + (1 | subject), data = onset_mean_amp_tidy, REML = FALSE)
anova(mod)

# Estimated marginal means for pairwise comparison
emm <- emmeans(mod, pairwise ~ accent*type | ROI, adjust = "Tukey")
summary(emm)
