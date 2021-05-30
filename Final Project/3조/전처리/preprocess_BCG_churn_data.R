# import library
library("tidyverse")
library("corrplot")
library(psych)
# load dataset
setwd("C:/Users/82108/Desktop/final_project")
data = read.csv("ml_case_training_data.csv")

####################################################################
# 전처리 전 데이터 확인
####################################################################
# of rows: 16092, # of columns: 30
dim(data)
summary(data)
colnames(data)

# 전처리할 변수 이름 리스트 생성
drop_col_names = list()
abs_col_names = list()
missing_values_col_names = list()

####################################################################
## id 및 범주형 변수 전처리
####################################################################
# 1. id : contact id -----------------------------------------------
length(unique(data$id)) # 고유한 id, 분석에서 제외
drop_col_names <- append('id', drop_col_names)


# 2. activity_new $ channel_sales $ origin_up
# 2-1. 결측값 처리 - activity_new channel_sales: 9542, channel_sales: 4216, origin_up: 87
colSums(is.na(data %>% select(activity_new, channel_sales, origin_up)))
as.data.frame(table(data$activity_new)) # 업종
as.data.frame(table(data$channel_sales)) # corporate, SME, and residential customer / 빈 문자열 4216개
as.data.frame(table(data$origin_up))
data$activity_new[data$activity_new == ""] <-  NA # 빈 문자열을 결측값으로 변환
data$channel_sales[data$channel_sales == ""] <-  NA
data$origin_up[data$origin_up == ""] <-  NA


# 2-2. 범주형 변수화
data$channel_sales <- factor(data$channel_sales, labels = LETTERS[1:7])
str(data$channel_sales) 


####################################################################
## 수치형 변수 전처리
####################################################################
numerical_var = data %>% select(-c(id,activity_new,origin_up,channel_sales))

# 0. 상관관계 확인- 결측치 제거하지 않은 경우 & 결측치 제거한 경우
numerical_var_cor <- cor(numerical_var)
round(numerical_var_cor, 2) 
corrplot(numerical_var_cor, method='shade', shade.col=NA, tl.col='black')

numerical_var_cor_without_na <- cor(na.omit(numerical_var))
round(numerical_var_cor_without_na, 2) 
corrplot(numerical_var_cor_without_na, method='shade', shade.col=NA, tl.col='black')



# 1. consumption variables -----------------------------------------
# cons_12m, cons_gas_12m, cons_last_month, no_consumption, has_gas, pow_max
summary(data$cons_12m) # 지난 12개월 electricity 사용량
summary(data$cons_last_month) # 지난달 electricity 사용량
summary(data$cons_gas_12m) # 지난 12개월 gas consumption
summary(data$pow_max)


## 1-1. 상관관계 높은 변수 제거 - cons_12m과 cons_last_moth, cons_gas12m과 has_gas의 상관관계 높음
con_var <- numerical_var %>% select(c(cons_12m, cons_gas_12m, cons_last_month, no_consumption, pow_max, has_gas))
corrplot(round(cor(con_var), 2), method='shade', shade.col=NA, tl.col='black')

if_cons_last_month <- ifelse(data$cons_last_month == 0, 1, 0)
all(if_cons_last_month == data$no_consumption) # no_consumption 변수의 정보가 모두 cons_last_month에 담겨있으므로 drop

if_cons_gas_12m <- ifelse(data$cons_gas_12m == 0, 0, 1)
cor(data$has_gas, if_cons_gas_12m) # 완전히 일치하지는 않지만, 상관성 매우 높음. 다중공선성 문제 방지를 위해 has gas도 삭제하자.

drop_col_names <- append('no_consumption', drop_col_names) 
drop_col_names <- append('cons_12m', drop_col_names)
drop_col_names <- append('has_gas', drop_col_names) 


## 1-2. 변수 변환
psych::describe(data$cons_gas_12m)
hist(data$cons_gas_12m, freq=TRUE)
hist(data$cons_last_month, freq=TRUE)
hist(data$pow_max, freq=TRUE)


## 1-3. 결측값 처리 - 결측값 없음 
colSums(is.na(data %>% select(cons_last_month, cons_gas_12m, pow_max)))


## 1-4. 아웃라이어 처리
boxplot(data$cons_last_month)
boxplot(data$cons_gas_12m)
boxplot(data$pow_max)


# 2. day variables ---------------------------------------------------------
# days_active, num_years_antig, days_since_last_modification

## 2-1. 상관관계 높은 변수 제거 - days_active와 num_years_antig의 상관관계 높음
days_var <- numerical_var %>% select(c(days_active, num_years_antig, days_since_last_modification))
corrplot(round(cor(days_var), 2), method='shade', shade.col=NA, tl.col='black')
ggplot(data = days_var, mapping = aes(x = days_active, y = num_years_antig)) + 
  geom_point() 

drop_col_names <- append('num_years_antig', drop_col_names) 


## 2-2. 변수 변환 및 음수값 처리 - days_since_last_modification에 음수값 존재
hist(data$days_active, freq=TRUE)
hist(data$days_since_last_modification, freq=TRUE)
abs_col_names <- append('days_since_last_modification', abs_col_names)


## 2-3. 결측값 처리 - 결측값 없음 
colSums(is.na(data %>% select(days_active, days_since_last_modification)))


## 2-4. 아웃라이어 처리
boxplot(data$days_active)
boxplot(data$days_since_last_modification)


# 3. margins ----------------------------------------------------------------
# net_margin, margin_gross_pow_ele, margin_net_pow_ele
summary(data$net_margin) # total net margin
summary(data$margin_gross_pow_ele) # gross margin on power subscription
summary(data$margin_net_pow_ele) # net margin on power subscription

## 3-1. 상관관계 높은 변수 제거 - margin_gross_pow_ele와 margin_net_pow_ele 간 상관계수 높음
plot(x = data$margin_gross_pow_ele, y = data$margin_net_pow_ele)
mod <- lm(margin_net_pow_ele~margin_gross_pow_ele, data = data); mod # plot을 살펴보면 gross에 표기 오류로 보이는 부분이 있으므로 margin_gross_pow_el을 삭제

drop_col_names <- append('margin_gross_pow_ele', drop_col_names)


## 3-2. 변수 변환 및 음수값 처리 - net_margin, margin_net_pow_ele에 음수값 존재
hist(data$net_margin, freq=TRUE)
hist(data$margin_net_pow_ele, freq=TRUE)
abs_col_names <- append('net_margin', abs_col_names)
abs_col_names <- append('margin_net_pow_ele', abs_col_names)


## 3-3. 결측값 처리 - 결측값 존재 net_margin: 11개, margin_net_pow_ele: 9개 
data[is.na(data$net_margin), c("margin_net_pow_ele", "net_margin")]
colSums(is.na(data %>% select(net_margin, margin_net_pow_ele)))
missing_values_col_names <- append(c('net_margin', 'margin_net_pow_ele'),missing_values_col_names)

                                   
## 3-4. 아웃라이어 처리
boxplot(data$net_margin)
boxplot(data$margin_net_pow_ele)



# 4. forecast & cons----------------------------------------------------------------
summary(data$forecast_base_bill_ele) # forecasted electricity bill baseline for next month
summary(data$forecast_base_bill_year) # forecasted electricity bill baseline for calendar year
summary(data$forecast_bill_12m) # forecasted electricity bill baseline for 12 months
summary(data$forecast_cons_12m) # forecasted electricity consumption for next 12 months
summary(data$forecast_cons_year) # forecasted electricity consumption for next calendar year
summary(data$forecast_discount_energy) # forecasted value of current discount 
summary(data$forecast_meter_rent_12m) # forecasted bill of meter rental for the next 12 months
summary(data$forecast_price_energy_p1) # forecasted energy price for 1st period
summary(data$forecast_price_energy_p2) # forecasted energy price for 2nd period
summary(data$forecast_price_pow_p1) # forecasted power price for 1st period
summary(data$imp_cons)

## 4-1. 상관관계 높은 변수 제거 - forecast_cons_year와 price 관련 변수들만 남김
forecast_var <- numerical_var %>% select(c(forecast_base_bill_ele, forecast_base_bill_year,
                                       forecast_bill_12m, forecast_cons,forecast_cons_12m,
                                       forecast_cons_year,forecast_discount_energy,
                                       forecast_meter_rent_12m,forecast_price_energy_p1,
                                       forecast_price_energy_p2, forecast_price_pow_p1,
                                       imp_cons))
corrplot(round(cor(na.omit(forecast_var)), 2), method='shade', shade.col=NA, tl.col='black')
colSums(is.na(forecast_var)) #결측치가 많고 상관계수 높은 변수 제거
drop_col_names <- append(c('forecast_base_bill_ele', 'forecast_base_bill_year', 
                         'forecast_bill_12m','forecast_cons',
                         'forecast_cons_12m','imp_cons'),
                         drop_col_names) 

## 4-2. 변수 변환 및 음수값 처리 - forecast_cons_year, forecast_meter_rent_12m, forecast_price_pow_p1에 음수값 존재
hist(data$forecast_cons_year, freq=TRUE)
hist(data$forecast_discount_energy, freq=TRUE)
hist(data$forecast_meter_rent_12m, freq=TRUE)
hist(data$forecast_price_energy_p1, freq=TRUE)
hist(data$forecast_price_energy_p2, freq=TRUE)
hist(data$forecast_price_pow_p1, freq=TRUE)

abs_col_names <- append('forecast_cons_year', abs_col_names)
abs_col_names <- append('forecast_meter_rent_12m', abs_col_names)
abs_col_names <- append('forecast_price_pow_p1', abs_col_names)


## 4-3. 결측값 처리 - 결측값 존재 forecast_price_energy_p1, forecast_price_energy_p2, forecast_price_pow_p1 각각 125개
forecast_var_dropped <- data %>% select(forecast_cons_year, forecast_discount_energy,
                                        forecast_meter_rent_12m, forecast_price_energy_p1,
                                        forecast_price_energy_p2,forecast_price_pow_p1 )
colSums(is.na(data %>% select(forecast_cons_year, forecast_discount_energy,
                              forecast_meter_rent_12m, forecast_price_energy_p1,
                              forecast_price_energy_p2,forecast_price_pow_p1 )))
missing_values_col_names <- append(c('forecast_price_energy_p1', 'forecast_price_energy_p2', 'forecast_price_pow_p1'),missing_values_col_names)

                                   
## 4-4. 아웃라이어 처리
boxplot(data$forecast_cons_year)
boxplot(data$forecast_discount_energy)
boxplot(data$forecast_meter_rent_12m)
boxplot(data$forecast_price_energy_p1)
boxplot(data$forecast_price_energy_p2)
boxplot(data$forecast_price_pow_p1)


# 9. nb_prod_act ------------------------------------------------------------
summary(data$nb_prod_act) # number of products that are active
boxplot(data$nb_prod_act)


#############################################################################
## 전처리 통합
#############################################################################
# drop columns
selected_variables <- data %>% select(-unlist(drop_col_names))

# negative values to positive
abs_col_names = unlist(abs_col_names)
selected_variables[ , abs_col_names]  <- lapply(selected_variables[ ,abs_col_names] , abs)


# handle missing values
missing_values_col_names


# drop outliers
length(which(data$cons_last_month < summary(data$cons_last_month)[2]-1.5*IQR(data$cons_last_month) |(data$cons_last_month > summary(data$cons_last_month)[5] + 1.5*IQR(data$cons_last_month))))
# data$cons_last_month <- ifelse(data$cons_last_month < summary(data$cons_last_month)[2]-1.5*IQR(data$cons_last_month) |data$cons_last_month > summary(data$cons_last_month)[5] + 1.5*IQR(data$cons_last_month), NA, data$cons_last_month)

