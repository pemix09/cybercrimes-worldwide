library(dplyr)
data <- read.csv(
  "modified_data.csv",
  fill = TRUE
)

attack_destinations_count_per_country <- data %>%
  group_by(Destination.Country) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  filter(Destination.Country != "") %>%
  rename(Country = Destination.Country, Destination_count = count)

attack_sources_count_per_country <- data %>%
  group_by(Source.Country) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  filter(Source.Country != "") %>%
  rename(Country = Source.Country, Source_count = count)

attacks_per_country <- full_join(attack_destinations_count_per_country, attack_sources_count_per_country, by = "Country")

anomaly_scores_average_per_country <- data %>%
  group_by(Source.Country) %>%
  filter(Anomaly.Scores != "") %>%
  summarise(average = mean(Anomaly.Scores)) %>%
  rename(Average_score = average, Country = Source.Country)

average_payload_lengths_per_country <- data %>%
  group_by(Source.Country) %>%
  filter(Packet.Length != "") %>%
  summarise(average = mean(Packet.Length)) %>%
  rename(Payload_length = average, Country = Source.Country)
