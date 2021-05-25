### BCG_EDA4

Powerco - Powerco는 뉴질랜드에서 두 번째로 큰 가스 및 최대 전기 유통 업체입니다. 네트워크를 통해 전기와 천연 가스를 모두 분배하는 두 회사 중 하나입니다.(other - Vector Limited)

Goal - 고객 이탈 예측 / 모델을 근거로 상업적 행동 제안 - (가장 설명력 있는 변수? / subscribed power&consumption 간의 상관관계? / channel sales와 고객이탈의 관계?)

#### Forecast_discount_energy - forecasted value of current discount 

- 0~50 / 0 값이 많음(96.4%)
- NA 없음
- not much correlation-Pearson's r

![1](/Users/kwanseok/ESC-21SPRING/파이널과제/img/1.png)

<img src="/Users/kwanseok/ESC-21SPRING/파이널과제/img/1-1.png" alt="1-1" style="zoom: 50%;" />

<img src="/Users/kwanseok/ESC-21SPRING/파이널과제/img/1-3.png" alt="1-3" style="zoom: 67%;" />



#### forecast_meter_rent_12m - forecasted bill of meter rental for the next 12 months

- 0 값 5%, NA 없음 / 값이 고르게 분포

- Outlier : 음수값도 존재 (-242.96, -114.91, -13.6, -0.5) 4개인데 이해되진 않음. 아마 0으로 넣어주고 분석해야 할 것 같음 / 매우 큰 값들 존재 - 2411, 1052, 894, 884, 725, 662, 641(5개), 599(8개), 585, 562  등

  -> 앞에 5개 값 정도 제거해 주면 괜찮을 것 같다. 2411일 때는 churn이 1이긴 함.

<img src="/Users/kwanseok/ESC-21SPRING/파이널과제/img/1-4.png" alt="1-4" style="zoom:50%;" />

- correlation w/ forecast_price_energy_p1(-), p2(+), pow_max(+)

![2](/Users/kwanseok/ESC-21SPRING/파이널과제/img/2.png)

![2-1](/Users/kwanseok/ESC-21SPRING/파이널과제/img/2-1.png)

<img src="/Users/kwanseok/ESC-21SPRING/파이널과제/img/2-2.png" alt="2-2" style="zoom: 67%;" /> 뒤에 큰 값들 자르고 보면 왼쪽과 같은 histogram 얻음.

#### forecast_price_energy_p1 - forecasted energy price for 1st period

- 125개의 NA 값(0.8%) 밑에 p2, forecast_price_pow_p1과 같은 행의 것들(확인함)

- correlation w/ forecast_meter_rent_12m(-)

- Outlier: 0근처와 0.25 근방에 보이긴 함.

  <img src="/Users/kwanseok/ESC-21SPRING/파이널과제/img/2-5.png" alt="2-5" style="zoom:33%;" /> 

  정규분포 가정일 때 z-score 3이상인 곳을 robust하게 보면, 그런 값들이 없음. 걍 다 써도 괜찮을 것 같음.

<img src="/Users/kwanseok/ESC-21SPRING/파이널과제/img/2-4.png" alt="2-4" style="zoom:50%;" />

![3](/Users/kwanseok/ESC-21SPRING/파이널과제/img/3.png)

![3-1](/Users/kwanseok/ESC-21SPRING/파이널과제/img/3-1.png)

<img src="/Users/kwanseok/ESC-21SPRING/파이널과제/img/3-2.png" alt="3-2" style="zoom:50%;" />



forecast_price_energy_p2 - forecasted energy price for 2nd period

- 125개의 NA 값(0.8%)

- 0 값 약 45% 나머지는 0.07~0.11 정도에 많이 분포

- Outlier: boxplot 상으로 whisker 밖의 점들이 없으므로 그냥 써도 괜찮을 것 같음.

  <img src="/Users/kwanseok/ESC-21SPRING/파이널과제/img/3-3.png" alt="3-3" style="zoom:50%;" />

![4](/Users/kwanseok/ESC-21SPRING/파이널과제/img/4.png)

![4-1](/Users/kwanseok/ESC-21SPRING/파이널과제/img/4-1.png)

<img src="/Users/kwanseok/ESC-21SPRING/파이널과제/img/4-2.png" alt="4-2" style="zoom:50%;" />

forecast_price_pow_p1 - forecasted power price for 1st period

- 125개의 NA 값(0.8%)

- 0 - 100개 / 44.31137796- 44.5%, 40.606701 - 32.1%로 두 개 값에 많은 값 분포 / 음수 값 하나 있는데 제거해야 함.

- Outlier: 0근처와 60 근처에 보임, 하지만 60 근처(4% 이상)에 꽤 많은 값이 있으므로 그냥 사용.

  0은 100개 있고 그 다음 중간에 아무 값도 없다가 32부터 등장하는 것을 보면 outlier에 해당.

  -> 분석 시에 많은 영향을 미친다면 제거하는 방향도 고려! (churn 값이 1인 경우는 없기도 함)

<img src="/Users/kwanseok/ESC-21SPRING/파이널과제/img/5-3.png" alt="5-3" style="zoom:50%;" />

![5](/Users/kwanseok/ESC-21SPRING/파이널과제/img/5.png)

![5-1](/Users/kwanseok/ESC-21SPRING/파이널과제/img/5-1.png)

<img src="/Users/kwanseok/ESC-21SPRING/파이널과제/img/5-2.png" alt="5-2" style="zoom:50%;" />

#### Correlation 있다고 한 것들 Interactions

P1 and 12m

<img src="/Users/kwanseok/ESC-21SPRING/파이널과제/img/6.png" alt="6" style="zoom:67%;" />



P2 and 12m

<img src="/Users/kwanseok/ESC-21SPRING/파이널과제/img/6-1.png" alt="6-1" style="zoom:50%;" />

12m and pow_max

<img src="/Users/kwanseok/ESC-21SPRING/파이널과제/img/6-3.png" alt="6-3" style="zoom:50%;" />

#### NA imputation

Missing value에는 3가지 종류 - 여기서는 Missing at Random인 것 같음

Missing인 것이 그렇게 많지 않으므로 빼고 해도 괜찮을 것 같음 (0.8%)

전체적으로 보면 다음과 같음.. - 가운데 forecast 부분 / activity_new / channel_sales 순으로 많은 듯

NA 너무 많은 열은 imputation하거나 그 열 전체를 버리는 등의 방법이 있을 수 있겠음

imputation의 경우는 중간에 배운 mice 방법 활용할 수도? (Bayes session 중에)

![7](/Users/kwanseok/ESC-21SPRING/파이널과제/img/7.png)



