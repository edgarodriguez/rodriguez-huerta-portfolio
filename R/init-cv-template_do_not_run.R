#!/usr/bin/env Rscript
# Generates cv_inputs.xlsx at the project root, pre-seeded with real CV data
# transcribed once from Rodriguez_Huerta_CV-quarto.pdf. Run from project root:
#   Rscript R/init-cv-template.R

suppressPackageStartupMessages(library(openxlsx))

OUT <- "cv_inputs.xlsx"

# ---- meta -------------------------------------------------------------------

meta <- data.frame(
  key = c("firstname", "lastname", "position", "address",
          "email", "orcid", "linkedin", "website", "location"),
  value = c(
    "Edgar",
    "Rodríguez-Huerta",
    "Rights Lab Senior Research Fellow in Social Sustainability and Complex Systems",
    "Data Science, Sustainability and Supply Chain Mapping | £2.1m in Co-I & PI grant funding | FWCI: 1.42",
    "edgar.rodriguezhuerta@nottingham.ac.uk",
    "0000-0002-6887-0040",
    "linkedin.com/in/edgarodriguez/",
    "",
    "Nottingham, UK"
  ),
  stringsAsFactors = FALSE
)

# ---- experience -------------------------------------------------------------

experience <- data.frame(
  title = c(
    "Rights Lab Senior Research Fellow in Social Sustainability and Complex Systems",
    "Rights Lab Research Fellow and Lead in Social-Ecological Systems Modelling",
    "Rights Lab Research Fellow in Sustainable Ecosystems and Society"
  ),
  location = c(
    "University of Nottingham, Rights Lab — Nottingham, UK",
    "University of Nottingham, Rights Lab — Nottingham, UK",
    "University of Nottingham, Rights Lab — Nottingham, UK"
  ),
  date = c("Oct 2024 – present", "Dec 2021 – Sep 2024", "Dec 2021 – Sep 2024"),
  description = c("", "", ""),
  details = c(
    "Quantitative research focused on understanding climate change and decent work interconnections.\nSupply chain mapping and analysis to generate risk assessments using Social-LCA.\nGeneration of climate change models to explore effect on labour conditions.",
    "Awarded Global Talent Visa by UK Government with British Academy endorsement",
    ""
  ),
  filter = c(TRUE, TRUE, TRUE),
  stringsAsFactors = FALSE
)

# ---- industry ---------------------------------------------------------------

industry <- data.frame(
  title    = "Senior Project Developer and Business Intelligence Specialist",
  location = "JLC Corporation — Mérida, México",
  date     = "Jan 2010 – Jan 2013",
  description = "",
  details  = "Managed Business Intelligence and Enterprise Resource Program software, including stakeholder training\nDesigned dashboards and reports for retail, financial and academic sectors.",
  filter   = TRUE,
  stringsAsFactors = FALSE
)

# ---- education --------------------------------------------------------------

education <- data.frame(
  title = c(
    "Ph.D. in Sustainability Science",
    "Master's degree in Sustainability Science and Technology",
    "Master's degree in Logistics",
    "Undergraduate degree in Industrial Engineering"
  ),
  location = c(
    "Universitat Politècnica de Catalunya, Institute for Sustainability Science — Barcelona, Spain",
    "Universitat Politècnica de Catalunya, Institute for Sustainability Science — Barcelona, Spain",
    "Universidad de Zaragoza, Zaragoza Logistics Center — Zaragoza, Spain",
    "Instituto Tecnológico de Mérida — Mérida, México"
  ),
  date = c("Sep 2015 – Mar 2020", "2013 – 2015", "2008 – 2009", "2003 – 2008"),
  description = c("", "", "", ""),
  details = c(
    "Dissertation: Water Societal Metabolism in Yucatan Peninsula, Mexico. Application of Multi-Scale Integrated Analysis of Societal and Ecosystem Metabolism (MuSIASEM)\nThree peer-reviewed publications as first author\nBuilt exploratory tool to analyse effect of climate change in water demand (R, QGIS, Tableau)",
    "120 ECTS. Grade: 8.9/10. Rank 2/12\nMSc thesis: Societal Metabolism in the Energy Sector in Catalunya, applying spatial analysis with QGIS\nCollaborated with multi-cultural and interdisciplinary team",
    "105 ECTS. Grade: 9.1/10\nMSc thesis: Methodologies for a Sustainability Balanced Scorecard in the Logistics Sector\nProfessional fellowship program in logistics. Training program in multiple companies",
    "Grade: 9.4/10"
  ),
  filter = c(TRUE, TRUE, TRUE, TRUE),
  stringsAsFactors = FALSE
)

# ---- publications -----------------------------------------------------------

publications <- data.frame(
  id = 1:17,
  type = c(
    rep("peer-reviewed", 7),
    rep("non-peer-reviewed", 2),
    rep("under-review", 5),
    rep("other-outcome", 3)
  ),
  authors = c(
    "**Rodríguez-Huerta**, E., Bell, B., Jackson, B., Blackstone, N.T., Battaglia, K., Marquez, A.S., Benoît Norris, C., Decker Sparks, J.L., Conrad, Z., Matteson, J.",
    "**Rodríguez-Huerta**, E., Leão L., Landman, T.",
    "Tigchelaar, M., Jackson, B., Selig, E., Davis, A., O'Regan, E., Trond, K., Nakayama, S., Boyd, D., Cheung, W., **Rodríguez-Huerta**, E., Williams, C., Decker Sparks, J.",
    "Boyd, D., Jackson, B., Decker Sparks, J., Giles M. F, Girindran, R., Gosiling, S., Trodd, Z. Ni Bhriain, L., **Rodríguez-Huerta**, E.",
    "Blackstone, N.T., Battaglia K., **Rodríguez-Huerta**, E., Bell, B., Decker Sparks J., Cash S., Conrad Z., Nikkhah A., Jackson B., Matteson J., Gao S., Fuller K., Zhang F.F., Webb P.",
    "Lumley-Sapanski A., **Rodríguez-Huerta**, E., Young, M., Nicholson A., Schwarz K.",
    "Blackstone, N.T., **Rodríguez-Huerta**, E., Battaglia K., Jackson B., Jackson E., Benoît Norris C., Decker Sparks, J.L.",
    # non-peer-reviewed
    "Cockayne, J., **Rodríguez-Huerta** E., Burcu, O.",
    "Boyd, D., **Rodríguez-Huerta**, E., Jackson B., Decker Sparks, J.L.",
    # under-review
    "**Rodríguez-Huerta**, E., Jackson, B., Blackstone, N.T., Decker Sparks, J.L.",
    "**Rodríguez-Huerta**, E., Trevizan. A., Landman, T., et al.",
    "**Rodríguez-Huerta**, E., Walker, R., Ní Bharain, L., Boyd, D., Jackson, B.",
    "Bell, B., Cudhea, F., Battaglia, K., Marquez, A.S., Morris, E., Nelson, J., **Rodríguez-Huerta**, E., Jackson, B., Wang, L., Conrad, Z., Decker Sparks, J.L., Luo, H., Fuller, K., Gao, S., Harney, B., Cash, S., Webb, P., Zhang, F.F., Blackstone, N.T.",
    "Jackson, B., **Rodríguez-Huerta**, E., Marshall, H., Pereira, A.C., Chandler, C., Light, M., Iqbal, S., Boyd, D., Decker Sparks, J.L.",
    # other-outcome
    "**Rodriguez Huerta**, E.",
    "Jackson, B., **Rodriguez Huerta**, E., Boyd, D., Girindran, R., Ni Bhriain, L., & Trodd, Z.",
    "**Rodriguez Huerta**, E."
  ),
  year = c(
    "anticipated 2025", "2025", "2025", "2024", "2024", "2024", "2023",
    "2022", "2021",
    "anticipated 2025", "anticipated 2026", "anticipated 2026", "anticipated 2026", "anticipated 2026",
    "2024-ongoing", "2024", "2023"
  ),
  title = c(
    "The human cost of current and recommended diets in the U.S.",
    "Climate change, decent work and workers' health in Brazil: theoretical considerations",
    "Conceptualization of Decent Work in Fishing in a Changing Climate",
    "The future of decent work: Forecasting heat stress and the intersection of sustainable development challenges in India's brick kilns",
    "Diets cannot be sustainable without ensuring the well-being of communities, workers, and animals in food value chains",
    "Criminalizing survivors of modern slavery: the United Kingdom's National Referral Mechanism as a border-making process",
    "Forced labour risk is pervasive in the US land-based food supply",
    "The Energy of Freedom? Solar Energy, Modern Slavery and the Just Transition",
    "The Social and Ecological Impacts of Supply Chains",
    "Modern slavery's carbon cost in supply chains: the case of Brazilian soy and sugarcane",
    "Exploratory Analysis of the interrelationships between occupational health and decent work",
    "Exploration of off-season labour patterns for Indian brick kiln workers",
    "Shifting to recommended diets in the US improves health outcomes, but has differing environmental, social, and economic impacts",
    "Measuring the co-occurrence of tree loss and modern slavery in Brazil between 2001-2021",
    "Multilingual website for dissemination activities and results of the project 'Climate Change, Occupational Health, and Decent Work: Worker Vulnerabilities and Responses in Brazilian Agriculture'",
    "Environmental Impacts Training Module: Assessing Risks to Workers in India (Versions: English, Hindi, Punjabi & Bengali)",
    "Interactive Visualizations to expand on results from the 'Forced labor risk is pervasive in the US land-based food supply (Blackstone et al. 2023)'"
  ),
  venue = c(
    "accepted for Nature Food",
    "Revista Brasileira de Saúde Ocupacional",
    "Marine Policy",
    "Sustainable Development",
    "Nature Food",
    "Journal of Social Policy",
    "Nature Food",
    "Research report, 70,000 words, funded by the British Academy",
    "Research report, 16,000 words, funded by the World Wide Fund for Nature",
    "Book chapter for Supply Chains and the SDGs (Elgar Companion)",
    "in preparation for World Development",
    "in preparation for International Journal of Operations & Production Management",
    "in preparation for Nature Food",
    "in preparation, TBD",
    "Digital Artefact: Website Content",
    "Digital Artefact: Website Content",
    "Digital Artefact: Website Content"
  ),
  url = c(
    "https://doi.org/10.21203/rs.3.rs-4999594/v1",
    "https://doi.org/10.1590/2317-6369/16224en2025v50eddsst12",
    "https://doi.org/10.1016/j.marpol.2025.106846",
    "https://doi.org/10.1002/sd.3272",
    "https://doi.org/10.1038/s43016-024-01048-0",
    "https://doi.org/10.1017/S0047279424000230",
    "https://doi.org/10.1038/s43016-023-00794-x",
    "https://www.thebritishacademy.ac.uk/publications/the-energy-of-freedom-solar-energy-modern-slavery-and-the-just-transition/",
    "",
    "", "", "", "", "",
    "https://www.clidewo.com",
    "https://nottingham-repository.worktribe.com/output/44691673",
    "https://sites.tufts.edu/lasting/data/"
  ),
  doi = rep("", 17),
  details = rep("", 17),
  filter = rep(TRUE, 17),
  stringsAsFactors = FALSE
)

# ---- grants -----------------------------------------------------------------

grants <- data.frame(
  title = c(
    "UK Home Office (Modern Slavery Innovation Fund)",
    "British Academy (ISPF ODA Challenge-Oriented Research Grants)",
    "UK Home Office (Modern Slavery Innovation Fund)",
    "Industry collaboration (Retail sector)",
    "UK Home Office (Modern Slavery Innovation Fund)",
    "British Academy (Just Transitions within Sectors and Industries Globally)",
    "World Wild Fund (USA)",
    "Consejo Nacional de Ciencia y Tecnólogia (CONACyT - México)",
    "Agència de Gestió d'Ajuts Universitaris i de Recerca (AGAUR)"
  ),
  location = c(
    "£322,000 (Co-I)", "£178,000 (PI)", "£149,000 (Co-I)", "£450,000 (Co-I)",
    "£799,000 (Co-I)", "£80,000 (Co-I)", "£60,000 (Co-I)",
    "£80,000 (Scholarship)", "£4,000 (Scholarship)"
  ),
  filter_money = rep(TRUE, 9),
  date = c(
    "2025 – 2026", "2024 – 2025", "2024 – 2025", "2024 – 2025", "2024 – 2025",
    "2021 – 2022", "2021 – 2022", "2014 – 2020", "2014 – 2015"
  ),
  description = c(
    "The GeoAI for Decent Work: Innovating Engagement with Government, Civil Society and Survivors",
    "Climate Change, Occupational Health, and Decent Work: Worker Vulnerabilities and Response in Brazilian Agriculture",
    "Adding value to the GeoAI Platform for Decent Work: A Survivor-Informed Socio-Ecological Assessment",
    "Salient and Evolving Human Rights Risks",
    "Using Data Science to Transform India's Brick Kilns",
    "Solar Energy, Modern Slavery, and the Just Transition",
    "The Social and Ecological Impacts of Supply Chains",
    "PhD and MSc Scholarship",
    "MSc Fellowship for Directed Academic Activities"
  ),
  details = rep("", 9),
  filter = rep(TRUE, 9),
  stringsAsFactors = FALSE
)

# ---- awards -----------------------------------------------------------------

awards <- data.frame(
  title = c(
    "Distinguished alumni of 2025 in the Industrial Engineering programme",
    "THE Awards — Finalist, Research Project of the Year in Social Sciences",
    "University of Nottingham Knowledge Exchange and Impact Awards",
    "Chamber of Commerce of Aragon, Spain — Memoria Pilot award"
  ),
  location = c(
    "Instituto Tecnólogico de Mérida",
    "Team member of Slavery from Space: Using Satellites for Human Rights and Sustainable Development",
    "Team member of Slavery from Space: Using Satellites for Human Rights and Sustainable Development",
    "Report in Logistics Excellence for large enterprises (La Bella Easo, Zaragoza)"
  ),
  date = c("2025", "2024", "2024", "2008"),
  description = c("", "", "", ""),
  details = c("", "", "", ""),
  filter = c(TRUE, TRUE, TRUE, TRUE),
  stringsAsFactors = FALSE
)

# ---- events -----------------------------------------------------------------

events <- data.frame(
  id = 1:8,
  title = c(
    "Conference: II International Congress on Ecological Humanities",
    "Workshop: Just transitions in food, farming and fisheries",
    "Workshop: Addressing Human Trafficking and Forced Labour in the Anthropocene",
    "Workshop: Visualizing Complexity Science",
    "Collaboration: Friedman School of Nutrition Science and Policy at Tufts University",
    "Workshop: Decent Fisheries Work in a Changing Climate",
    "Brown bag sessions",
    "22nd Ordinary Session of the Yucatan Peninsula Basin Council"
  ),
  location = c(
    "The Johns Hopkins University - Universitat Pompeu Fabra Public Policy Center — Barcelona, Spain",
    "Ethical Trading Initiative, IIED, BananaLink — London, UK",
    "Survivor Alliance, The Human Trafficking Legal Center, The Freedom Fund — Oxford, UK",
    "Complexity Science Hub — Vienna, Austria",
    "Leading A Sustainability Transition in Nutrition Globally (LASTING) Project — Boston, MA, USA",
    "Stanford University, the King Center and Center for Ocean Solutions — Stanford, CA, USA",
    "U.S. Department of Labor and Tufts University — Washington DC, USA",
    "Consejo de Cuenca de la Península de Yucatán & Ithaca Environmental — Mérida, México"
  ),
  date = c("Jul 2025", "Jun 2025", "Apr 2025", "Sep 2024", "2022 – 2024",
           "May 2023", "Mar 2022", "Feb 2021"),
  description = c(
    "Decent Work and Workers Health nexus in Brazilian agriculture",
    "", "", "", "", "",
    "How Social Life Cycle Assessment (S-LCA) can help address forced labour",
    "Invitation to co-design the Regional Water Program 2020-2024 of the Yucatan Peninsula"
  ),
  details = rep("", 8),
  type = c("Talk", "Workshop", "Workshop", "Workshop", "Collaboration",
           "Workshop", "Talk", "Other"),
  filter = rep(TRUE, 8),
  stringsAsFactors = FALSE
)

# ---- teaching ---------------------------------------------------------------

teaching <- data.frame(
  title = c(
    "Data management and visualization for academic research",
    "Seminar: Sustainability science to tackle forced labour: methods and measurements"
  ),
  location = c(
    "Instituto Tecnológico de Mérida — Mérida, México",
    "Universitat Politècnica de Catalunya, Institute for Sustainability Science — Barcelona, Spain"
  ),
  date = c("Nov 2021", "Jul 2025"),
  description = c("Graduate course", "Seminar"),
  details = c("Course for MSc students in Regional Development Studies", ""),
  filter = c(TRUE, TRUE),
  stringsAsFactors = FALSE
)

# ---- training ---------------------------------------------------------------

training <- data.frame(
  title = c(
    "Research Communication Programme",
    "MOOC: Partnering for change — Link research to societal challenges",
    "Stepping into Leadership 2023/24 — LMA Development Programmes",
    "MOOC: Analysing/Presenting Data/Information",
    "MOOC: Data Science — Statistics and Machine Learning Specialization",
    "MOOC: Specialization in Data Science (R Programming)",
    "MOOC: Spatial Data Science and Applications",
    "MOOC: Systems Thinking in Public Health",
    "MOOC: Ecosystem Services — A Method for Sustainable Development",
    "MOOC: Sustainability of Social-Ecological Systems — Nexus among Water, Energy, and Food"
  ),
  location = c(
    "Research Academy University of Nottingham",
    "Network for Transdisciplinary Research td-net of the Swiss Academies of Arts and Sciences",
    "Research Academy University of Nottingham",
    "Edward Tufte Course (8h)",
    "Coursera Programme (Johns Hopkins University) (133h)",
    "Coursera Programme (Johns Hopkins University) (290h)",
    "Coursera Programme (Yonsei University) (24h)",
    "Coursera Programme (Johns Hopkins University) (20h)",
    "Coursera Programme (University of Geneva) (24h)",
    "Coursera Programme (Universitat Autònoma de Barcelona) (48h)"
  ),
  date = c("Jun 2025", "Apr 2025", "Feb 2024", "Oct 2023", "Jan 2021",
           "Oct 2020", "Sep 2020", "Aug 2020", "Jul 2020", "Jul 2020"),
  description = rep("", 10),
  details = rep("", 10),
  filter = rep(TRUE, 10),
  stringsAsFactors = FALSE
)

# ---- skills -----------------------------------------------------------------

skills <- data.frame(
  category = c("Programming", "Software"),
  items = c(
    "R, SQL (intermediate), Quarto",
    "Tableau [Desktop and Prep], Rstudio, QGIS, OpenLCA, Zotero, VosViewer, Xerte (intermediate), Affinity (learning), Observable (learning)"
  ),
  filter = c(TRUE, TRUE),
  stringsAsFactors = FALSE
)

# ---- languages --------------------------------------------------------------

languages <- data.frame(
  language = c("Spanish", "English"),
  level    = c("Native",  "Fluent"),
  filter   = c(TRUE, TRUE),
  stringsAsFactors = FALSE
)

# ---- services ---------------------------------------------------------------

services <- data.frame(
  category = c("Grants and Journals Reviewed", "Student Supervision", "Societies"),
  items = c(
    "British Academy for Knowledge Frontiers: Just Transition; Journal of Cleaner Production; Energy Policy; Hydrogeology Journal; Joule; Anti-Trafficking Review; Economía Creativa.",
    "PhD Students: 3 supervised — Topics in Food Systems. MSc Students: 4 supervised — Research in data extraction, and regional development. Support for MSc students from the Technical University of Denmark (DTU) for the project \"Sociotechnical dimension of renewable energies\" (Apr 2024). BSc Students: 3 supervised — Placement students related to data science projects and just transition.",
    "Member of The British Academy Career Researcher Network since 2023."
  ),
  filter = c(TRUE, TRUE, TRUE),
  stringsAsFactors = FALSE
)

# ---- cv_negatives -----------------------------------------------------------

cv_negatives <- data.frame(
  id = 1:15,
  section = c(
    rep("Degree Programmes Not Admitted To", 3),
    rep("Funding & Fellowships Not Awarded", 4),
    rep("Papers Rejected Before Publication", 4),
    rep("Awards & Prizes Not Received", 2),
    rep("Collaborations That Did Not Work Out", 2)
  ),
  title = c(
    "MPhil Environmental Change & Management",
    "MSc Sustainability Science",
    "MSc Global Health & Development",
    "ERC Starting Grant — Sustainability Science",
    "Marie Skłodowska-Curie Individual Fellowship",
    "UKRI PhD Scholarship",
    "Chevening Scholarship",
    "Modern slavery risk in critical mineral supply chains",
    "Climate migration and forced labour nexus",
    "SoLCA framework for informal sector labour assessment",
    "Network complexity as proxy for modern slavery obscurity",
    "ISIE Young Researcher Award",
    "Sustainability Science Prize",
    "Joint supply chain audit project with major NGO",
    "International consortium on climate-labour modelling"
  ),
  location = c(
    "University of Oxford — Rejected",
    "Lund University — Waitlisted, not offered",
    "University College London — Rejected",
    "European Research Council — Not shortlisted",
    "European Commission — Rejected after review",
    "UK Research & Innovation — Waitlisted, not funded",
    "UK Foreign Office — Rejected at final stage",
    "Science — Rejected after peer review",
    "Nature Climate Change — Desk rejected",
    "Journal of Cleaner Production — Withdrawn after major revisions",
    "PNAS — Desk rejected",
    "International Society for Industrial Ecology — Shortlisted, not awarded",
    "Sustainability Science Forum — Nominated, not awarded",
    "Funding fell through after 6 months of planning",
    "Partnership dissolved due to institutional changes"
  ),
  date = c(
    "2021", "2020", "2019",
    "2024", "2023", "2022", "2021",
    "2024", "2023", "2023", "2022",
    "2023", "2022",
    "2024", "2023"
  ),
  filter = rep(TRUE, 15),
  stringsAsFactors = FALSE
)

# ---- write workbook ---------------------------------------------------------

wb <- createWorkbook()

# Reorder events columns: id first, then type before filter for readability
events <- events[, c("id", "title", "location", "date", "description", "details", "type", "filter")]

sheet_data <- list(
  meta = meta, education = education, experience = experience,
  industry = industry, grants = grants, awards = awards, events = events,
  teaching = teaching, services = services, training = training,
  publications = publications, skills = skills, languages = languages,
  cv_negatives = cv_negatives
)

header_style <- createStyle(textDecoration = "bold", fgFill = "#E5EAE6",
                            border = "bottom", borderColour = "#c8d0cc")

for (sheet in names(sheet_data)) {
  addWorksheet(wb, sheet)
  writeData(wb, sheet, sheet_data[[sheet]], headerStyle = header_style)
  setColWidths(wb, sheet, cols = seq_len(ncol(sheet_data[[sheet]])), widths = "auto")
  freezePane(wb, sheet, firstRow = TRUE)
}

saveWorkbook(wb, OUT, overwrite = TRUE)
cat(sprintf("Wrote %s with %d sheets.\n", OUT, length(sheet_data)))
