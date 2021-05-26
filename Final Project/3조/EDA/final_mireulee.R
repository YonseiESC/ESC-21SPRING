library(ggplot2)
library(tidyr)
setwd('D:/3학년_1학기/ESC/Final Project_BCG')
df = read.csv("ml_case_training_data.csv") 

str(df)
summary(df)

#---------------------------------------------------------------------------
# 1. churn
df$churn # 결측값 없음. 0 또는 1

#---------------------------------------------------------------------------
# 2. origin_up
df$origin_up <- factor(df$origin_up)
summary(df$origin_up)

#---------------------------------------------------------------------------
# 3. pow_max
summary(df$pow_max)
ggplot(data = df) +
  geom_density(aes(x = pow_max))

# is there relationship between subscribed power and consumption?
ggplot(data = df) + 
  geom_point(mapping = aes(x = pow_max, y = cons_12m)) + 
  geom_hline(yintercept=6400000, color = 'red')
  
ggplot(data = df) +
  geom_point(mapping = aes(x = pow_max, y = cons_gas_12m)) + 
  geom_hline(yintercept=2000000, color = 'red')

ggplot(data = df) +
  geom_point(mapping = aes(x = pow_max, y = cons_last_month)) +
  geom_hline(yintercept=800000, color = 'red')
# subscribed power(pow_max)가 아무리 커도 consumption에는 한계가 있다. 

#---------------------------------------------------------------------------
# 4. net_margin
summary(df$net_margin)
sum(is.na(df$net_margin)) / length(df$net_margin) # 결측값 비율

ggplot(data = df) +
  geom_boxplot(aes(x = net_margin))

df$net_margin[is.na(df$net_margin)] = median(df$net_margin, na.rm = TRUE) # outlier가 너무 많아 평균 대신 median으로 대체

#---------------------------------------------------------------------------
# 5. num_years_antig
summary(df$num_years_antig)
ggplot(data = df) +
  geom_histogram(mapping = aes(x = num_years_antig), binwidth = 1)

# days_active와의 관계
df2 = df[df$days_active > 0, ]# date of activation으부터 몇일 되었는지가 음수일 수 없으므로 제거
ggplot(data = df2, aes(x = days_active, y = num_years_antig)) +
  geom_point() +
  geom_smooth(method = lm)
cor(df2$days_active, df2$num_years_antig)
# 상관관계가 매우 높아 다중공선성 문제가 발생할 수 있으므로 days_active와 num_years_antig 중 하나만 사용하는 것이 좋을 것 같다. 



