library(ggplot2)
library(tidyr)

df = read.csv(file.choose())
# setwd('D:/3학년_1학기/ESC/Final Project_BCG')
# df = read.csv("ml_case_training_data.csv") # 

View(df)

summary(df)
str(df)

# 1. id : contact id -----------------------------------------------
length(unique(df$id)) # 고유한 id

# 2. activity_new : category of the company's activity -------------
table(df$activity_new) # 업종

# 3. channel_sales : code of the sales channel ---------------------
table(df$channel_sales) # corporate, SME, and residential customer
df$channel_sales[df$channel_sales == ""] <-  NA # 빈 문자열을 결측값으로 변환
df$channel_sales <- factor(df$channel_sales, labels = LETTERS[1:7]) # 범주형 변수화
# 암호화 되어있어 의미를 알 수 없음. 범주만 구분하면 되기 때문에 ABC...로 변환
str(df$channel_sales) 

# 4. origin_up : code of the electricity campaign the customer first subscribed to 
table(df$origin_up) 
df$origin_up <- NULL

# 5. consumption variables : electricty / gas consumption ---------- 
summary(df$cons_12m) # 지난 12개월 electricity 사용량
summary(df$cons_last_month) # 지난달 electricity 사용량
summary(df$cons_gas_12m) # 지난 12개월 gas consumption
summary(df$pow_max)

unique(df$no_consumption) # 사용량 있는지 없는지
binary <- ifelse(df$cons_last_month == 0, 1, 0)
all(binary == df$no_consumption)
df$no_consumption <- NULL # no_consumption 변수의 정보가 모두 cons_last_month에 담겨있으므로 drop

binary2 <- ifelse(df$cons_gas_12m == 0, 0, 1)
cor(df$has_gas, binary2) # [gas를 구독하고 있는지]와 [gas 사용량] 
# 완전히 일치하지는 않지만, 상관성 매우 높음. 다중공선성 문제 방지를 위해 has gas도 삭제하자. 
df$has_gas <- NULL

ggplot(data = df, mapping = aes(x = cons_12m, y = cons_last_month))+
  geom_point() 
# 비정상적으로 큰 값은 삭제하도록 하자. 
ind = order(df$cons_12m, decreasing = TRUE)[1] # 가장 큰 cons_12m 관측값의 인덱스
df = df[-ind, ]

ggplot(data = df) +
  geom_point(mapping = aes(x = cons_12m, y = cons_last_month, color = channel_sales)) 

ggplot(data = df, aes(x = channel_sales, y = cons_12m)) + geom_boxplot()
ggplot(data = df, aes(x = channel_sales, y = cons_gas_12m)) + geom_boxplot()
ggplot(data = df, aes(x = channel_sales, y = cons_last_month)) + geom_boxplot()

ggplot(data = df, aes(x = pow_max, y = cons_12m)) +
  geom_point() + geom_hline(yintercept=6400000, color = 'red')
ggplot(data = df, aes(x = pow_max, y = cons_last_month))+
  geom_point() + geom_hline(yintercept=800000, color = 'red')
ggplot(data = df, aes(x = pow_max, y = cons_gas_12m, color = channel_sales)) +
  geom_point() + geom_hline(yintercept=2000000, color = 'red')

# 6. days_active and num_years_antig ---------------------------------------------
# day / year from activation of the contract may be highly correlated
ggplot(data = df, mapping = aes(x = days_active, y = num_years_antig)) + 
  geom_point()
df[c("days_active", "num_years_antig")][(df$days_active < 0), ]
df <- df[(df$days_active > 0), ]
# days_active의 두 음수값은 명백한 오류로 보이고 수가 많지 않기 때문에 행을 삭제한다. 

ggplot(data = df, mapping = aes(x = days_active, y = num_years_antig)) + 
  geom_point() 
# 선형관계 매우 강하다는 것을 확인할 수 있음. 
df$num_years_antig <- NULL

# + days_since_last_modification 
df$days_since_last_modification <- abs(df$days_since_last_modification)
boxplot(df$days_since_last_modification) # 음수일 수 없는 변수이므로 절대값을 씌워서 boxplot을 그려본다.

# 4만 넘는 값들(194개) 어떻게 해야할까요...?

# 7. margins ----------------------------------------------------------------
summary(df$net_margin) # total net margin
summary(df$margin_gross_pow_ele) # gross margin on power subscription
summary(df$margin_net_pow_ele) # net margin on power subscription

plot(x = df$margin_gross_pow_ele, y = df$margin_net_pow_ele)
mod <- lm(margin_net_pow_ele~margin_gross_pow_ele, data = df); mod 
# 두 변수 간의 상관계수가 매우 높으므로 다중공선성 문제 발생을 방지하기 위해 두 변수 중 하나만 선택한다. 
# plot을 살펴보면 gross에 표기 오류로 보이는 부분이 있으므로 
df$margin_gross_pow_ele <- NULL

df$net_margin <- abs(df$net_margin)
df$margin_net_pow_ele <- abs(df$margin_net_pow_ele)
boxplot(df$net_margin)
boxplot(df$margin_net_pow_ele)

df[is.na(df$net_margin), c("margin_net_pow_ele", "net_margin")]
# 행을 삭제할까요 평균으로 대체할까요...?

# 8. forecast ----------------------------------------------------------------
summary(df$forecast_base_bill_ele) # forecasted electricity bill baseline for next month
summary(df$forecast_base_bill_year) # forecasted electricity bill baseline for calendar year
summary(df$forecast_bill_12m) # forecasted electricity bill baseline for 12 months
summary(df$forecast_cons_12m) # forecasted electricity consumption for next 12 months
summary(df$forecast_cons_year) # forecasted electricity consumption for next calendar year
summary(df$forecast_discount_energy) # forecasted value of current discount 
summary(df$forecast_meter_rent_12m) # forecasted bill of meter rental for the next 12 months
summary(df$forecast_price_energy_p1) # forecasted energy price for 1st period
summary(df$forecast_price_energy_p2) # forecasted energy price for 2nd period
summary(df$forecast_price_pow_p1) # forecasted power price for 1st period


# 9. nb_prod_act ------------------------------------------------------------
summary(df$nb_prod_act) # number of products that are active
boxplot(df$nb_prod_act)

# 10. imp_cons --------------------------------------------------------------
summary(df$imp_cons) # current paid consumption
boxplot(df$imp_cons)

df$imp_cons <- abs(df$imp_cons)
boxplot(df$imp_cons)

# 11. churn -----------------------------------------------------------------
df$chrun  

