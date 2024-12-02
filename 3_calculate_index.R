
bipa2024_metrics <- calculate_metrics(
  metrics_base,
  countries = dqc_bipa2024$countries,
  theme_dq = dqc_bipa2024$dq_data_themes
)

bipa2024_indicators <- calculate_tier(bipa2024_metrics, "indicator")

bipa2024_themes <- calculate_tier(bipa2024_indicators, "theme")

bipa2024_domains <- calculate_tier(bipa2024_themes, "domain")

bipa2024_index <- calculate_tier(bipa2024_domains, "index")
